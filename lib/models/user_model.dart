import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../services/supabase_service.dart';

class UserAccount {
  final String nama;
  final String email;
  final String inisial;
  final String role;
  final bool isLastLogin;

  const UserAccount({
    required this.nama,
    required this.email,
    required this.inisial,
    this.role = 'utama',
    this.isLastLogin = false,
  });
}

// Data akun lokal (cache sementara di memori)
final List<UserAccount> daftarAkun = [];

// Akun yang sedang login
UserAccount? akunTerakhirLogin;

// ValueNotifier untuk reaktivitas
final ValueNotifier<UserAccount?> currentUserNotifier = ValueNotifier(null);
final ValueNotifier<List<UserAccount>> daftarAkunNotifier =
    ValueNotifier<List<UserAccount>>([]);
final ValueNotifier<String?> fotoProfilNotifier = ValueNotifier<String?>(null);
final ValueNotifier<Uint8List?> fotoProfilBytesNotifier =
    ValueNotifier<Uint8List?>(null);

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

// Password cache lokal (tetap dipakai sebagai fallback)
final Map<String, String> _passwordMap = {};

/// Load semua user dari Supabase ke cache lokal saat app start
Future<void> muatSemuaAkunDariDB() async {
  try {
    final users = await fetchSemuaUser();
    daftarAkun.clear();
    daftarAkun.addAll(users);
    daftarAkunNotifier.value = List.from(daftarAkun);
  } catch (e) {
    // fallback: biarkan daftarAkun kosong, user bisa login manual
  }
}

/// Login — cek ke Supabase, kalau belum ada buat akun baru
Future<void> simpanAkunLogin(String email, {String nama = ''}) async {
  final emailRapi = email.trim();

  // Cek dulu di cache lokal
  int idx = daftarAkun.indexWhere(
    (a) => a.email.toLowerCase() == emailRapi.toLowerCase(),
  );

  if (idx != -1) {
    akunTerakhirLogin = daftarAkun[idx];
  } else {
    // Cek di Supabase
    UserAccount? akunDB = await fetchUserByEmail(emailRapi);

    if (akunDB != null) {
      daftarAkun.add(akunDB);
      akunTerakhirLogin = akunDB;
    } else {
      // Buat akun baru
      final String local = emailRapi.split('@').first;
      final String namaFinal = nama.trim().isNotEmpty ? nama.trim() : local;
      final akunBaru = UserAccount(
        nama: namaFinal,
        email: emailRapi,
        inisial: _buatInisial(namaFinal),
        role: 'utama',
        isLastLogin: true,
      );
      daftarAkun.add(akunBaru);
      akunTerakhirLogin = akunBaru;

      // Simpan ke Supabase
      final password = _passwordMap[emailRapi.toLowerCase()] ?? '';
      await simpanUserKeDB(akunBaru, password);
    }
  }

  currentUserNotifier.value = akunTerakhirLogin;
  daftarAkunNotifier.value = List.from(daftarAkun);
  fotoProfilNotifier.value = null;
}

String getPassword(String email) => _passwordMap[email.toLowerCase()] ?? '';

Future<void> ubahPassword(String email, String passwordBaru) async {
  _passwordMap[email.toLowerCase()] = passwordBaru;
  await updatePasswordDiDB(email, passwordBaru);
}

Future<void> ubahNamaProfil(String namaBaru) async {
  final akun = currentUserNotifier.value;
  if (akun == null) return;

  final int idx = daftarAkun
      .indexWhere((a) => a.email.toLowerCase() == akun.email.toLowerCase());

  if (idx != -1) {
    final String inisial = namaBaru
        .trim()
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    daftarAkun[idx] = UserAccount(
      nama: namaBaru.trim(),
      email: daftarAkun[idx].email,
      inisial: inisial,
      role: daftarAkun[idx].role,
      isLastLogin: daftarAkun[idx].isLastLogin,
    );

    daftarAkunNotifier.value = List.from(daftarAkun);
    currentUserNotifier.value = daftarAkun[idx];

    // Update ke Supabase
    await updateNamaUserDiDB(akun.email, namaBaru);
  }
}

Future<bool> tambahAkunTanpaLogin(String email, String password) async {
  final String emailRapi = email.trim();
  if (emailRapi.isEmpty) return false;

  final bool sudahAda =
      daftarAkun.any((a) => a.email.toLowerCase() == emailRapi.toLowerCase());
  if (sudahAda) return false;

  final String local = emailRapi.split('@').first;
  final String nama =
      local.isEmpty ? emailRapi : local[0].toUpperCase() + local.substring(1);
  final String inisial = local.isEmpty
      ? '?'
      : (local.length >= 2
          ? local.substring(0, 2).toUpperCase()
          : local.substring(0, 1).toUpperCase());

  final akunBaru = UserAccount(
    nama: nama,
    email: emailRapi,
    inisial: inisial,
    role: 'utama',
    isLastLogin: false,
  );

  daftarAkun.add(akunBaru);
  _passwordMap[emailRapi.toLowerCase()] = password;
  daftarAkunNotifier.value = List.from(daftarAkun);

  // Simpan ke Supabase
  await simpanUserKeDB(akunBaru, password);

  return true;
}

Future<void> hapusAkun(String email) async {
  daftarAkun.removeWhere((a) => a.email.toLowerCase() == email.toLowerCase());
  _passwordMap.remove(email.toLowerCase());
  daftarAkunNotifier.value = List.from(daftarAkun);

  // Hapus dari Supabase
  await hapusUserDariDB(email);
}

// ─────────────────────────────────────────────
// LUPA KATA SANDI (simulasi OTP)
// ─────────────────────────────────────────────

String? _otpAktif;
String? _emailOtpAktif;

bool emailTerdaftar(String email) {
  return daftarAkun
      .any((a) => a.email.toLowerCase() == email.trim().toLowerCase());
}

String generateOtp(String email) {
  final rnd = DateTime.now().millisecondsSinceEpoch % 900000 + 100000;
  _otpAktif = rnd.toString();
  _emailOtpAktif = email.trim().toLowerCase();
  return _otpAktif!;
}

bool verifikasiOtp(String email, String kode) {
  if (_otpAktif == null || _emailOtpAktif == null) return false;
  return _emailOtpAktif == email.trim().toLowerCase() &&
      _otpAktif == kode.trim();
}

Future<void> resetPasswordViaOtp(String email, String passwordBaru) async {
  _passwordMap[email.trim().toLowerCase()] = passwordBaru;
  await updatePasswordDiDB(email, passwordBaru);
  _otpAktif = null;
  _emailOtpAktif = null;
}