import 'package:flutter/material.dart';

class UserAccount {
  final String nama;
  final String email;
  final String inisial;

  const UserAccount({
    required this.nama,
    required this.email,
    required this.inisial,
  });
}

// Data akun yang tersimpan
final List<UserAccount> daftarAkun = [
  const UserAccount(
    nama: 'Ahmad Fauzi',
    email: 'ahmad@medicare.id',
    inisial: 'AF',
  ),
  const UserAccount(
    nama: 'Siti Rahma',
    email: 'siti@medicare.id',
    inisial: 'SR',
  ),
];

// Akun yang sedang login
UserAccount? akunTerakhirLogin;

// ValueNotifier untuk reaktivitas
final ValueNotifier<UserAccount?> currentUserNotifier = ValueNotifier(null);

/// Membuat inisial otomatis dari nama, contoh: "Arum Puspita" -> "AP"
String _buatInisial(String nama) {
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

/// Login dengan email. Jika email sudah ada di daftarAkun, akan login
/// menggunakan data yang sudah ada (nama diabaikan).
/// Jika email belum ada, akan membuat akun baru otomatis menggunakan
/// [nama] yang diberikan (atau email sebagai fallback jika nama kosong).
void simpanAkunLogin(String email, {String nama = ''}) {
  final emailBersih = email.trim();
  final existingIndex = daftarAkun.indexWhere(
    (a) => a.email.toLowerCase() == emailBersih.toLowerCase(),
  );

  UserAccount akun;
  if (existingIndex != -1) {
    // Akun sudah ada -> pakai data yang tersimpan
    akun = daftarAkun[existingIndex];
  } else {
    // Akun belum ada -> buat akun baru otomatis
    final namaFinal =
        nama.trim().isNotEmpty ? nama.trim() : emailBersih.split('@').first;
    akun = UserAccount(
      nama: namaFinal,
      email: emailBersih,
      inisial: _buatInisial(namaFinal),
    );
    daftarAkun.add(akun);
  }

  akunTerakhirLogin = akun;
  currentUserNotifier.value = akun;
}
