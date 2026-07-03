import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
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
  final String? anggotaId; // null = obat milik pemilik akun sendiri

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
  }) : waktuTambah = waktuTambah ?? DateTime.now();

  Obat copyWith({
    String? id, String? nama, String? dosis, String? waktu,
    String? instruksi, MedStatus? status, int? stokTablet,
    int? stokHariLagi, Set<String>? hari, bool? notifMinum,
    bool? notifStok, DateTime? waktuTambah, String? anggotaId,
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
    );
  }
}

class AnggotaKeluarga {
  final String id; // uuid dari Supabase
  final String nama;
  final String inisial;
  final String? akunTerkaitEmail; // null kalau anggota tanpa akun sendiri
  int totalObat;
  int sudahDiminum;

  AnggotaKeluarga({
    required this.id,
    required this.nama,
    required this.inisial,
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

// Ambil email user yang sedang aktif
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

  // Simpan ke Supabase
  try {
    final email = currentUserEmail;
    if (email != null) {
      await simpanObatKDB(obat, email);
      print('DEBUG: obat berhasil disimpan ke Supabase untuk $email');
    } else {
      print('DEBUG: email user aktif null, obat tidak disimpan ke DB');
    }
  } catch (e) {
    print('DEBUG ERROR simpanObat: $e');
  }
}

Future<void> muatObatDariDB(String email) async {
  try {
    final obatDariDB = await fetchObatByUser(email);
    if (obatDariDB.isNotEmpty) {
      daftarObat = obatDariDB;
      obatNotifier.value = List.from(daftarObat);
      hitungStatistikSemuaAnggota();
      print('DEBUG: ${obatDariDB.length} obat dimuat dari Supabase');
    }
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
    if (obat.notifStok && obat.stokHariLagi <= 3) catatStokMenipis(obat);
  }
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

void initDummyData() {
  if (daftarObat.isEmpty) {
    final obat1 = Obat(id: '1', nama: 'Amoxicillin Trihydrate', dosis: '1 tablet',
        waktu: 'Pagi 08.00', instruksi: 'Setelah makan', status: MedStatus.sudah,
        stokTablet: 10, stokHariLagi: 24);
    final obat2 = Obat(id: '2', nama: 'Ketoconazole', dosis: '1 tablet',
        waktu: 'Siang 13.00', instruksi: 'Setelah makan', status: MedStatus.belum,
        stokTablet: 12, stokHariLagi: 3);
    final obat3 = Obat(id: '3', nama: 'Cetirizine', dosis: '1 tablet',
        waktu: 'Malam 20.00', instruksi: 'Setelah makan', status: MedStatus.sudah,
        stokTablet: 8, stokHariLagi: 3);

    daftarObat.addAll([obat1, obat2, obat3]);
    obatNotifier.value = List.from(daftarObat);
    catatPengingatMinum(obat2);
    catatObatTerlewat(obat2);
    cekStokMenipisSemuaObat();
  }
}

// ─────────────────────────────────────────────
// Fitur Anggota Keluarga (Supabase)
// ─────────────────────────────────────────────

List<AnggotaKeluarga> daftarAnggotaKeluarga = [];
final ValueNotifier<List<AnggotaKeluarga>> anggotaKeluargaNotifier =
    ValueNotifier<List<AnggotaKeluarga>>([]);

String buatInisialAnggota(String nama) {
  final parts = nama.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
  return (parts.first[0] + parts.last[0]).toUpperCase();
}

/// Tambah anggota keluarga baru. [akunTerkaitEmail] diisi kalau anggota ini
/// mau di-link ke akun user lain yang sudah terdaftar.
Future<void> tambahAnggotaKeluarga(String nama, {String? akunTerkaitEmail}) async {
  final namaRapi = nama.trim();
  if (namaRapi.isEmpty) return;

  final email = currentUserEmail;
  if (email == null) return;

  try {
    final anggotaBaru = await simpanAnggotaKeluargaKeDB(
      userEmail: email,
      nama: namaRapi,
      inisial: buatInisialAnggota(namaRapi),
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

/// Panggil ini di splash/setelah login (gantikan muatAnggotaKeluarga lama)
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

/// Hitung ulang totalObat & sudahDiminum tiap anggota dari data obat lokal.
/// Dipanggil otomatis tiap kali daftarObat berubah (tambah/hapus/update status/muat).
void hitungStatistikSemuaAnggota() {
  for (final anggota in daftarAnggotaKeluarga) {
    final obatAnggota = daftarObat.where((o) => o.anggotaId == anggota.id);
    anggota.totalObat = obatAnggota.length;
    anggota.sudahDiminum =
        obatAnggota.where((o) => o.status == MedStatus.sudah).length;
  }
  anggotaKeluargaNotifier.value = List.from(daftarAnggotaKeluarga);
}