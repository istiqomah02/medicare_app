import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../services/notification_service.dart';
import 'user_model.dart';

enum MedStatus { sudah, belum, terlewat }
enum JenisLog { ditambahkan, pengingat, terlewat, stokMenipis, dihapus }

class Obat {
  final String id;
  final String nama;
  final String dosis;
  final String waktu;
  final String instruksi;
  final MedStatus status;
  final int stokTablet;
  final int stokHariLagi;
  final Set<String> hari;
  final bool notifMinum;
  final bool notifStok;
  final DateTime waktuTambah;
  final String? anggotaId;
  final DateTime tanggalMulai; // mulai berlaku dari tanggal ini (jam dibuang)

  Obat({
    required this.id,
    required this.nama,
    required this.dosis,
    required this.waktu,
    required this.instruksi,
    required this.status,
    required this.stokTablet,
    required this.stokHariLagi,
    this.hari = const {'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'},
    this.notifMinum = true,
    this.notifStok = true,
    DateTime? waktuTambah,
    this.anggotaId,
    DateTime? tanggalMulai,
  })  : waktuTambah = waktuTambah ?? DateTime.now(),
        tanggalMulai = tanggalMulai == null
            ? DateTime(DateTime.now().year, DateTime.now().month,
                DateTime.now().day)
            : DateTime(tanggalMulai.year, tanggalMulai.month, tanggalMulai.day);

  /// Tanggal proyeksi stok bakal habis (tanggalMulai + stokHariLagi hari)
  DateTime get tanggalHabis => tanggalMulai.add(Duration(days: stokHariLagi));

  Obat copyWith({
    String? id, String? nama, String? dosis, String? waktu,
    String? instruksi, MedStatus? status, int? stokTablet,
    int? stokHariLagi, Set<String>? hari, bool? notifMinum,
    bool? notifStok, DateTime? waktuTambah, String? anggotaId,
    DateTime? tanggalMulai,
  }) {
    return Obat(
      id: id ?? this.id, nama: nama ?? this.nama, dosis: dosis ?? this.dosis,
      waktu: waktu ?? this.waktu, instruksi: instruksi ?? this.instruksi,
      status: status ?? this.status, stokTablet: stokTablet ?? this.stokTablet,
      stokHariLagi: stokHariLagi ?? this.stokHariLagi,
      hari: hari ?? this.hari, notifMinum: notifMinum ?? this.notifMinum,
      notifStok: notifStok ?? this.notifStok,
      waktuTambah: waktuTambah ?? this.waktuTambah,
      anggotaId: anggotaId ?? this.anggotaId,
      tanggalMulai: tanggalMulai ?? this.tanggalMulai,
    );
  }
}

class AnggotaKeluarga {
  final String id;
  final String nama;
  final String inisial;
  final String hubungan; // cth: Anak, Ayah, Ibu, dll
  final String? akunTerkaitEmail;
  int totalObat;
  int sudahDiminum;

  AnggotaKeluarga({
    required this.id,
    required this.nama,
    required this.inisial,
    this.hubungan = 'Anggota Keluarga',
    this.akunTerkaitEmail,
    this.totalObat = 0,
    this.sudahDiminum = 0,
  });

  int get belum => totalObat - sudahDiminum;
  int get persentase =>
      totalObat > 0 ? ((sudahDiminum / totalObat) * 100).round() : 0;
}

class LogAktivitas {
  final String id;
  final String namaObat;
  final MedStatus status;
  final JenisLog jenis;
  final String waktuLog;
  final DateTime waktu;

  LogAktivitas({
    required this.id, required this.namaObat, required this.status,
    this.jenis = JenisLog.ditambahkan, required this.waktuLog, DateTime? waktu,
  }) : waktu = waktu ?? DateTime.now();
}

// === Data Store ===
List<Obat> daftarObat = [];
List<LogAktivitas> logAktivitas = [];

// === Reactive Notifiers ===
final ValueNotifier<List<Obat>> obatNotifier = ValueNotifier([]);
final ValueNotifier<List<LogAktivitas>> logNotifier = ValueNotifier([]);

String? get currentUserEmail => currentUserNotifier.value?.email;

// === Functions ===

Future<void> tambahObat(Obat obat) async {
  daftarObat.add(obat);
  obatNotifier.value = List.from(daftarObat);
  hitungStatistikSemuaAnggota();

  final log = LogAktivitas(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    namaObat: obat.nama,
    status: obat.status,
    jenis: JenisLog.ditambahkan,
    waktuLog: 'Ditambahkan ${_formatTanggalWaktu(obat.waktuTambah)}',
    waktu: obat.waktuTambah,
  );
  logAktivitas.insert(0, log);
  logNotifier.value = List.from(logAktivitas);

  // Jadwalkan notifikasi pengingat minum obat kalau diaktifkan
  if (obat.notifMinum) {
    try {
      await NotificationService.jadwalkanNotifObat(
        obatId: obat.id,
        namaObat: obat.nama,
        dosis: obat.dosis,
        jamMenit: obat.waktu,
        hariAktif: obat.hari,
      );
    } catch (e) {
      print('DEBUG ERROR jadwalkanNotif: $e');
    }
  }

  try {
    final email = currentUserEmail;
    if (email != null) {
      await simpanObatKDB(obat, email);
    } else {
      print('DEBUG: email null, obat tidak disimpan ke DB');
    }
  } catch (e) {
    print('DEBUG ERROR simpanObat: $e');
  }
}

Future<void> muatObatDariDB(String email) async {
  try {
    final obatDariDB = await fetchObatByUser(email);
    daftarObat = obatDariDB;
    obatNotifier.value = List.from(daftarObat);
    hitungStatistikSemuaAnggota();

    // Re-jadwalkan notif untuk semua obat aktif yang dimuat dari DB
    // (notif terjadwal hilang kalau app di-uninstall/reinstall atau device reboot)
    for (final obat in daftarObat) {
      if (obat.notifMinum && obat.status != MedStatus.sudah) {
        try {
          await NotificationService.jadwalkanNotifObat(
            obatId: obat.id,
            namaObat: obat.nama,
            dosis: obat.dosis,
            jamMenit: obat.waktu,
            hariAktif: obat.hari,
          );
        } catch (e) {
          print('DEBUG ERROR re-jadwalkan notif ${obat.nama}: $e');
        }
      }
    }

    print('DEBUG: ${obatDariDB.length} obat dimuat dari Supabase');
  } catch (e) {
    print('DEBUG ERROR muatObat: $e');
  }
}

void updateStatusObat(String id, MedStatus status) {
  final index = daftarObat.indexWhere((o) => o.id == id);
  if (index != -1) {
    final obatLama = daftarObat[index];
    daftarObat[index] = obatLama.copyWith(status: status);
    obatNotifier.value = List.from(daftarObat);
    hitungStatistikSemuaAnggota();

    String statusText;
    JenisLog jenis;
    switch (status) {
      case MedStatus.sudah:
        statusText = 'Diminum';
        jenis = JenisLog.pengingat;
        break;
      case MedStatus.belum:
        statusText = 'Belum diminum';
        jenis = JenisLog.pengingat;
        break;
      case MedStatus.terlewat:
        statusText = 'Terlewat';
        jenis = JenisLog.terlewat;
        break;
    }

    final log = LogAktivitas(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      namaObat: obatLama.nama,
      status: status,
      jenis: jenis,
      waktuLog: '$statusText ${_formatWaktu(DateTime.now())}',
      waktu: DateTime.now(),
    );
    logAktivitas.insert(0, log);
    logNotifier.value = List.from(logAktivitas);
  }
}

Future<void> hapusObat(String id) async {
  final index = daftarObat.indexWhere((o) => o.id == id);
  if (index != -1) {
    final obat = daftarObat[index];
    daftarObat.removeAt(index);
    obatNotifier.value = List.from(daftarObat);
    hitungStatistikSemuaAnggota();

    // Batalkan notifikasi terjadwal untuk obat ini
    try {
      await NotificationService.batalkanNotifObat(obat.id, obat.hari);
    } catch (e) {
      print('DEBUG ERROR batalkanNotif: $e');
    }

    final log = LogAktivitas(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      namaObat: obat.nama,
      status: MedStatus.belum,
      jenis: JenisLog.dihapus,
      waktuLog: 'Dihapus ${_formatWaktu(DateTime.now())}',
      waktu: DateTime.now(),
    );
    logAktivitas.insert(0, log);
    logNotifier.value = List.from(logAktivitas);

    try {
      await hapusObatDariDB(id);
    } catch (e) {
      print('DEBUG ERROR hapusObat: $e');
    }
  }
}

void catatPengingatMinum(Obat obat) {
  logAktivitas.insert(0, LogAktivitas(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    namaObat: obat.nama, status: MedStatus.belum,
    jenis: JenisLog.pengingat,
    waktuLog: 'Waktunya minum • ${obat.waktu}',
    waktu: DateTime.now(),
  ));
  logNotifier.value = List.from(logAktivitas);
}

void catatObatTerlewat(Obat obat) {
  logAktivitas.insert(0, LogAktivitas(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    namaObat: obat.nama, status: MedStatus.terlewat,
    jenis: JenisLog.terlewat,
    waktuLog: 'Terlewat • jadwal ${obat.waktu}',
    waktu: DateTime.now(),
  ));
  logNotifier.value = List.from(logAktivitas);
}

void catatStokMenipis(Obat obat) {
  logAktivitas.insert(0, LogAktivitas(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    namaObat: obat.nama, status: MedStatus.belum,
    jenis: JenisLog.stokMenipis,
    waktuLog: 'Stok tinggal ${obat.stokHariLagi} hari lagi',
    waktu: DateTime.now(),
  ));
  logNotifier.value = List.from(logAktivitas);
}

void cekStokMenipisSemuaObat() {
  for (final obat in daftarObat) {
    if (obat.notifStok && obat.stokHariLagi <= 3) {
      catatStokMenipis(obat);
    }
  }
}

/// Cek obat yang jadwalnya sudah lewat lebih dari 1 jam tapi belum ditandai
/// diminum, lalu otomatis ubah statusnya jadi 'terlewat'.
/// Panggil fungsi ini setiap kali halaman utama/beranda dibuka.
void cekObatTerlewatOtomatis() {
  final now = DateTime.now();
  final hariIni = _hariSingkatDariWeekday(now.weekday);

  for (final obat in daftarObat) {
    if (obat.status == MedStatus.belum && obat.hari.contains(hariIni)) {
      final jamParts = obat.waktu.contains(':')
          ? obat.waktu.split(':')
          : obat.waktu.split('.');
      if (jamParts.length != 2) continue;

      final jam = int.tryParse(jamParts[0]);
      final menit = int.tryParse(jamParts[1]);
      if (jam == null || menit == null) continue;

      final jadwalHariIni =
          DateTime(now.year, now.month, now.day, jam, menit);

      if (now.isAfter(jadwalHariIni.add(const Duration(hours: 1)))) {
        updateStatusObat(obat.id, MedStatus.terlewat);
      }
    }
  }
}

String _hariSingkatDariWeekday(int weekday) {
  const hariList = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  return hariList[weekday - 1];
}

void hapusLogAktivitas(String id) {
  logAktivitas.removeWhere((l) => l.id == id);
  logNotifier.value = List.from(logAktivitas);
}

void hapusSemuaLog() {
  logAktivitas.clear();
  logNotifier.value = List.from(logAktivitas);
}

Map<String, dynamic> getStatistikKepatuhan() {
  final total = daftarObat.length;
  final sudah = daftarObat.where((o) => o.status == MedStatus.sudah).length;
  final terlewat = daftarObat.where((o) => o.status == MedStatus.terlewat).length;
  final persentase = total > 0 ? (sudah / total * 100).round() : 0;
  return {'total': total, 'sudah': sudah, 'terlewat': terlewat, 'persentase': persentase};
}

String _formatWaktu(DateTime waktu) =>
    '${waktu.hour.toString().padLeft(2, '0')}:${waktu.minute.toString().padLeft(2, '0')}';

String _formatTanggalWaktu(DateTime waktu) {
  final bulan = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
  return '${waktu.day} ${bulan[waktu.month - 1]} ${waktu.year} ${_formatWaktu(waktu)}';
}

// Dummy data dinonaktifkan — semua data diambil dari Supabase
void initDummyData() {}

// ─────────────────────────────────────────────
// Fitur Anggota Keluarga (Supabase)
// ─────────────────────────────────────────────

List<AnggotaKeluarga> daftarAnggotaKeluarga = [];
final ValueNotifier<List<AnggotaKeluarga>> anggotaKeluargaNotifier =
    ValueNotifier<List<AnggotaKeluarga>>([]);

AnggotaKeluarga get anggotaAdek => daftarAnggotaKeluarga.isNotEmpty
    ? daftarAnggotaKeluarga.first
    : AnggotaKeluarga(id: '-', nama: 'Keluarga', inisial: 'K');

String buatInisialAnggota(String nama) {
  final parts = nama.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
  return (parts.first[0] + parts.last[0]).toUpperCase();
}

Future<void> tambahAnggotaKeluarga(
  String nama, {
  String hubungan = 'Anggota Keluarga',
  String? akunTerkaitEmail,
}) async {
  final namaRapi = nama.trim();
  if (namaRapi.isEmpty) return;

  final email = currentUserEmail;
  if (email == null) return;

  try {
    final anggotaBaru = await simpanAnggotaKeluargaKeDB(
      userEmail: email,
      nama: namaRapi,
      inisial: buatInisialAnggota(namaRapi),
      hubungan: hubungan,
      akunTerkaitEmail: akunTerkaitEmail,
    );
    if (anggotaBaru != null) {
      daftarAnggotaKeluarga.add(anggotaBaru);
      anggotaKeluargaNotifier.value = List.from(daftarAnggotaKeluarga);
    }
  } catch (e) {
    print('DEBUG ERROR tambahAnggotaKeluarga: $e');
  }
}

Future<void> hapusAnggotaKeluarga(String id) async {
  daftarAnggotaKeluarga.removeWhere((a) => a.id == id);
  anggotaKeluargaNotifier.value = List.from(daftarAnggotaKeluarga);
  try {
    await hapusAnggotaKeluargaDariDB(id);
  } catch (e) {
    print('DEBUG ERROR hapusAnggotaKeluarga: $e');
  }
}

Future<void> muatAnggotaKeluargaDariDB() async {
  final email = currentUserEmail;
  if (email == null) return;
  try {
    final list = await fetchAnggotaKeluargaByUser(email);
    daftarAnggotaKeluarga = list;
    anggotaKeluargaNotifier.value = List.from(daftarAnggotaKeluarga);
    hitungStatistikSemuaAnggota();
  } catch (e) {
    print('DEBUG ERROR muatAnggotaKeluargaDariDB: $e');
  }
}

Future<void> muatAnggotaKeluarga() async {
  await muatAnggotaKeluargaDariDB();
}

void hitungStatistikSemuaAnggota() {
  for (final anggota in daftarAnggotaKeluarga) {
    final obatAnggota = daftarObat.where((o) => o.anggotaId == anggota.id);
    anggota.totalObat = obatAnggota.length;
    anggota.sudahDiminum =
        obatAnggota.where((o) => o.status == MedStatus.sudah).length;
  }
  anggotaKeluargaNotifier.value = List.from(daftarAnggotaKeluarga);
}

/// Panggil ini setiap kali user PINDAH/GANTI akun (dari TambahAkunScreen atau
/// KelolaAkunScreen), supaya obat & anggota keluarga di layar sesuai akun yang
/// baru aktif — bukan nyisa dari akun sebelumnya.
Future<void> muatDataUntukAkunAktif() async {
  final email = currentUserEmail;
  if (email == null) {
    daftarObat = [];
    obatNotifier.value = [];
    daftarAnggotaKeluarga = [];
    anggotaKeluargaNotifier.value = [];
    return;
  }
  await muatObatDariDB(email);
  await muatAnggotaKeluargaDariDB();
}