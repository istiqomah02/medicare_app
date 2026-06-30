import 'package:flutter/material.dart';

enum MedStatus { sudah, belum, terlewat }

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
}

class LogAktivitas {
  final String id;
  final String namaObat;
  final MedStatus status;
  final String waktuLog;
  final DateTime waktu;

  LogAktivitas({
    required this.id,
    required this.namaObat,
    required this.status,
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
    status: MedStatus.belum,
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
    switch (status) {
      case MedStatus.sudah:
        statusText = 'Diminum';
        break;
      case MedStatus.belum:
        statusText = 'Belum diminum';
        break;
      case MedStatus.terlewat:
        statusText = 'Terlewat';
        break;
    }

    final log = LogAktivitas(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      namaObat: obatLama.nama,
      status: status,
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
      waktuLog: 'Dihapus ${_formatWaktu(DateTime.now())}',
      waktu: DateTime.now(),
    );
    logAktivitas.insert(0, log);
    logNotifier.value = List.from(logAktivitas);
  }
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
  }
}
