enum MedStatus { sudah, belum, terlewat }

class Obat {
  final String nama;
  final String dosis;
  final String waktu;
  final String instruksi;
  final MedStatus status;
  final int stokTablet;
  final int stokHariLagi;

  const Obat({
    required this.nama,
    required this.dosis,
    required this.waktu,
    required this.instruksi,
    required this.status,
    required this.stokTablet,
    required this.stokHariLagi,
  });
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
  final String namaObat;
  final MedStatus status;
  final String waktuLog;

  const LogAktivitas({
    required this.namaObat,
    required this.status,
    required this.waktuLog,
  });
}

// === Sample Data ===
final List<Obat> daftarObat = [
  const Obat(
    nama: 'Amoxicillin Trihydrate',
    dosis: '1 tablet',
    waktu: 'Pagi - 08.00',
    instruksi: 'Setelah makan',
    status: MedStatus.sudah,
    stokTablet: 10,
    stokHariLagi: 24,
  ),
  const Obat(
    nama: 'Ketoconazole',
    dosis: '1 tablet',
    waktu: 'Siang - 13.00',
    instruksi: 'Setelah makan',
    status: MedStatus.belum,
    stokTablet: 12,
    stokHariLagi: 3,
  ),
  const Obat(
    nama: 'Cetirizine',
    dosis: '1 tablet',
    waktu: 'Malam - 20.00',
    instruksi: 'Sebelum tidur',
    status: MedStatus.sudah,
    stokTablet: 8,
    stokHariLagi: 3,
  ),
];

final AnggotaKeluarga anggotaAdek = const AnggotaKeluarga(
  nama: 'Adek',
  inisial: 'A',
  totalObat: 4,
  sudahDiminum: 2,
);

final List<LogAktivitas> logAktivitas = [
  const LogAktivitas(namaObat: 'Amoxicillin Trihydrate 500 mg', status: MedStatus.sudah, waktuLog: 'Hari ini · 08.03'),
  const LogAktivitas(namaObat: 'Ketoconazole 200 mg', status: MedStatus.belum, waktuLog: 'Kemarin · 13.00'),
  const LogAktivitas(namaObat: 'Loratadine 10 mg', status: MedStatus.sudah, waktuLog: 'Kemarin · 20.15'),
  const LogAktivitas(namaObat: 'Cetirizene 10 mg', status: MedStatus.sudah, waktuLog: '30 Mei · 08.01'),
  const LogAktivitas(namaObat: 'Vitamin Asam Askorbat 50 mg', status: MedStatus.belum, waktuLog: '30 Mei · 13.00'),
];
