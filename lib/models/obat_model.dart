import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

enum MedStatus { sudah, belum, terlewat }

/// Jenis notifikasi/log — dipakai untuk membedakan ikon & warna di layar Notifikasi
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
  }) : waktuTambah = waktuTambah ?? DateTime.now();

  Obat copyWith({
    String? id,
    String? nama,
    String? dosis,
    String? waktu,
    String? instruksi,
    MedStatus? status,
    int? stokTablet,
    int? stokHariLagi,
    Set<String>? hari,
    bool? notifMinum,
    bool? notifStok,
    DateTime? waktuTambah,
  }) {
    return Obat(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      dosis: dosis ?? this.dosis,
      waktu: waktu ?? this.waktu,
      instruksi: instruksi ?? this.instruksi,
      status: status ?? this.status,
      stokTablet: stokTablet ?? this.stokTablet,
      stokHariLagi: stokHariLagi ?? this.stokHariLagi,
      hari: hari ?? this.hari,
      notifMinum: notifMinum ?? this.notifMinum,
      notifStok: notifStok ?? this.notifStok,
      waktuTambah: waktuTambah ?? this.waktuTambah,
    );
  }
}

class AnggotaKeluarga {
  final String nama;
  final String inisial;
  final int totalObat;
  final int sudahDiminum;

  const AnggotaKeluarga({
    required this.nama,
    required this.inisial,
    required this.totalObat,
    required this.sudahDiminum,
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
    required this.id,
    required this.namaObat,
    required this.status,
    this.jenis = JenisLog.ditambahkan,
    required this.waktuLog,
    DateTime? waktu,
  }) : waktu = waktu ?? DateTime.now();
}

// === Data Store ===
List<Obat> daftarObat = [];
List<LogAktivitas> logAktivitas = [];

// Sample data
final AnggotaKeluarga anggotaAdek = const AnggotaKeluarga(
  nama: 'Adek',
  inisial: 'A',
  totalObat: 4,
  sudahDiminum: 2,
);

// === Reactive Notifiers ===
final ValueNotifier<List<Obat>> obatNotifier = ValueNotifier([]);
final ValueNotifier<List<LogAktivitas>> logNotifier = ValueNotifier([]);

// === Functions ===

void tambahObat(Obat obat) {
  daftarObat.add(obat);
  obatNotifier.value = List.from(daftarObat);

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
}

void updateStatusObat(String id, MedStatus status) {
  final index = daftarObat.indexWhere((o) => o.id == id);
  if (index != -1) {
    final obatLama = daftarObat[index];
    daftarObat[index] = obatLama.copyWith(status: status);
    obatNotifier.value = List.from(daftarObat);

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

void hapusObat(String id) {
  final index = daftarObat.indexWhere((o) => o.id == id);
  if (index != -1) {
    final obat = daftarObat[index];
    daftarObat.removeAt(index);
    obatNotifier.value = List.from(daftarObat);

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
  }
}

/// Catat notifikasi pengingat "waktunya minum obat" — dipanggil manual sekarang,
/// nanti akan otomatis terpicu lewat push notification terjadwal.
void catatPengingatMinum(Obat obat) {
  final log = LogAktivitas(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    namaObat: obat.nama,
    status: MedStatus.belum,
    jenis: JenisLog.pengingat,
    waktuLog: 'Waktunya minum • ${obat.waktu}',
    waktu: DateTime.now(),
  );
  logAktivitas.insert(0, log);
  logNotifier.value = List.from(logAktivitas);
}

/// Catat notifikasi "obat terlewat" — obat yang jadwalnya sudah lewat tapi belum diminum
void catatObatTerlewat(Obat obat) {
  final log = LogAktivitas(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    namaObat: obat.nama,
    status: MedStatus.terlewat,
    jenis: JenisLog.terlewat,
    waktuLog: 'Terlewat • jadwal ${obat.waktu}',
    waktu: DateTime.now(),
  );
  logAktivitas.insert(0, log);
  logNotifier.value = List.from(logAktivitas);
}

/// Catat notifikasi "stok menipis" — dipanggil saat stokHariLagi obat sudah rendah
void catatStokMenipis(Obat obat) {
  final log = LogAktivitas(
    id: DateTime.now().millisecondsSinceEpoch.toString(),
    namaObat: obat.nama,
    status: MedStatus.belum,
    jenis: JenisLog.stokMenipis,
    waktuLog: 'Stok tinggal ${obat.stokHariLagi} hari lagi',
    waktu: DateTime.now(),
  );
  logAktivitas.insert(0, log);
  logNotifier.value = List.from(logAktivitas);
}

/// Cek semua obat, catat notifikasi stok menipis untuk yang stoknya <= 3 hari lagi.
/// Bisa dipanggil sekali saat app dibuka (mis. dari main.dart / beranda_screen).
void cekStokMenipisSemuaObat() {
  for (final obat in daftarObat) {
    if (obat.notifStok && obat.stokHariLagi <= 3) {
      catatStokMenipis(obat);
    }
  }
}

/// Hapus satu entri notifikasi/log berdasarkan id
void hapusLogAktivitas(String id) {
  logAktivitas.removeWhere((l) => l.id == id);
  logNotifier.value = List.from(logAktivitas);
}

/// Hapus semua riwayat notifikasi/log sekaligus
void hapusSemuaLog() {
  logAktivitas.clear();
  logNotifier.value = List.from(logAktivitas);
}

Map<String, dynamic> getStatistikKepatuhan() {
  final total = daftarObat.length;
  final sudah = daftarObat.where((o) => o.status == MedStatus.sudah).length;
  final terlewat =
      daftarObat.where((o) => o.status == MedStatus.terlewat).length;
  final persentase = total > 0 ? (sudah / total * 100).round() : 0;

  return {
    'total': total,
    'sudah': sudah,
    'terlewat': terlewat,
    'persentase': persentase,
  };
}

String _formatWaktu(DateTime waktu) {
  return '${waktu.hour.toString().padLeft(2, '0')}:${waktu.minute.toString().padLeft(2, '0')}';
}

String _formatTanggalWaktu(DateTime waktu) {
  final bulan = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des'
  ];
  return '${waktu.day} ${bulan[waktu.month - 1]} ${waktu.year} ${_formatWaktu(waktu)}';
}

void initDummyData() {
  if (daftarObat.isEmpty) {
    final obat1 = Obat(
      id: '1',
      nama: 'Amoxicillin Trihydrate',
      dosis: '1 tablet',
      waktu: 'Pagi 08.00',
      instruksi: 'Setelah makan',
      status: MedStatus.sudah,
      stokTablet: 10,
      stokHariLagi: 24,
    );
    tambahObat(obat1);

    final obat2 = Obat(
      id: '2',
      nama: 'Ketoconazole',
      dosis: '1 tablet',
      waktu: 'Siang 13.00',
      instruksi: 'Setelah makan',
      status: MedStatus.belum,
      stokTablet: 12,
      stokHariLagi: 3,
    );
    tambahObat(obat2);

    final obat3 = Obat(
      id: '3',
      nama: 'Cetirizine',
      dosis: '1 tablet',
      waktu: 'Malam 20.00',
      instruksi: 'Setelah makan',
      status: MedStatus.sudah,
      stokTablet: 8,
      stokHariLagi: 3,
    );
    tambahObat(obat3);

    // Contoh notifikasi variatif supaya layar Notifikasi terlihat realistis
    catatPengingatMinum(obat2);
    catatObatTerlewat(obat2);
    cekStokMenipisSemuaObat();
  }
}

// ─────────────────────────────────────────────
// Fitur Anggota Keluarga (lokal, tersimpan di SharedPreferences)
// ─────────────────────────────────────────────

List<AnggotaKeluarga> daftarAnggotaKeluarga = [anggotaAdek];

final ValueNotifier<List<AnggotaKeluarga>> anggotaKeluargaNotifier =
    ValueNotifier<List<AnggotaKeluarga>>([anggotaAdek]);

const String _kAnggotaKeluargaKey = 'daftar_anggota_keluarga';

/// Buat inisial otomatis dari nama, contoh: "Budi Santoso" -> "BS"
String buatInisialAnggota(String nama) {
  final parts =
      nama.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    return parts.first
        .substring(0, parts.first.length >= 2 ? 2 : 1)
        .toUpperCase();
  }
  return (parts.first[0] + parts.last[0]).toUpperCase();
}

/// Tambah anggota keluarga baru, langsung update UI & simpan ke SharedPreferences
Future<void> tambahAnggotaKeluarga(String nama) async {
  final namaRapi = nama.trim();
  if (namaRapi.isEmpty) return;

  final anggotaBaru = AnggotaKeluarga(
    nama: namaRapi,
    inisial: buatInisialAnggota(namaRapi),
    totalObat: 0,
    sudahDiminum: 0,
  );

  daftarAnggotaKeluarga.add(anggotaBaru);
  anggotaKeluargaNotifier.value = List.from(daftarAnggotaKeluarga);

  await _simpanAnggotaKeluarga();
}

/// Hapus anggota keluarga (opsional, dipakai kalau nanti mau fitur hapus)
Future<void> hapusAnggotaKeluarga(String nama) async {
  daftarAnggotaKeluarga.removeWhere((a) => a.nama == nama);
  anggotaKeluargaNotifier.value = List.from(daftarAnggotaKeluarga);
  await _simpanAnggotaKeluarga();
}

Future<void> _simpanAnggotaKeluarga() async {
  final prefs = await SharedPreferences.getInstance();
  final list = daftarAnggotaKeluarga
      .map((a) => {
            'nama': a.nama,
            'inisial': a.inisial,
            'totalObat': a.totalObat,
            'sudahDiminum': a.sudahDiminum,
          })
      .toList();
  await prefs.setString(_kAnggotaKeluargaKey, jsonEncode(list));
}

/// Panggil ini sekali di awal (misal di main.dart) untuk memuat data
/// anggota keluarga yang tersimpan sebelumnya.
Future<void> muatAnggotaKeluarga() async {
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString(_kAnggotaKeluargaKey);
  if (raw == null) return;

  try {
    final List<dynamic> list = jsonDecode(raw);
    daftarAnggotaKeluarga = list
        .map((m) => AnggotaKeluarga(
              nama: m['nama'] as String,
              inisial: m['inisial'] as String,
              totalObat: m['totalObat'] as int,
              sudahDiminum: m['sudahDiminum'] as int,
            ))
        .toList();
    if (daftarAnggotaKeluarga.isEmpty) {
      daftarAnggotaKeluarga = [anggotaAdek];
    }
    anggotaKeluargaNotifier.value = List.from(daftarAnggotaKeluarga);
  } catch (_) {
    daftarAnggotaKeluarga = [anggotaAdek];
    anggotaKeluargaNotifier.value = List.from(daftarAnggotaKeluarga);
  }
}