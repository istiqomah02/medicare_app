import 'package:flutter/foundation.dart';

class UserAccount {
  final String nama;
  final String email;
  final String inisial;
  final String role; // 'utama' atau 'keluarga'
  final bool isLastLogin;

  const UserAccount({
    required this.nama,
    required this.email,
    required this.inisial,
    required this.role,
    this.isLastLogin = false,
  });

  UserAccount copyWith({bool? isLastLogin}) {
    return UserAccount(
      nama: nama,
      email: email,
      inisial: inisial,
      role: role,
      isLastLogin: isLastLogin ?? this.isLastLogin,
    );
  }
}

final List<UserAccount> daftarAkun = [
  const UserAccount(
    nama: 'Arum Nur Cahyani',
    email: 'cahyaniarum@Gmail.com',
    inisial: 'AR',
    role: 'utama',
    isLastLogin: true,
  ),
  const UserAccount(
    nama: 'Budi Purnomo',
    email: 'budipurnomo16@gmail.com',
    inisial: 'BP',
    role: 'Keluarga',
    isLastLogin: false,
  ),
];

/// Akun yang ditandai sebagai terakhir dipakai login (kalau ada).
/// Dipakai di layar login untuk menampilkan kartu
/// "atau masuk dengan akun yang tersimpan".
UserAccount? get akunTerakhirLogin {
  for (final akun in daftarAkun) {
    if (akun.isLastLogin) return akun;
  }
  return null;
}

/// Notifier akun yang sedang aktif/login saat ini.
///
/// Widget yang perlu menampilkan data akun (mis. PengaturanScreen)
/// cukup "mendengarkan" notifier ini lewat `ValueListenableBuilder`,
/// jadi otomatis ikut berubah setiap kali [simpanAkunLogin] dipanggil
/// -- tidak perlu passing data manual lewat constructor/route.
final ValueNotifier<UserAccount?> currentUserNotifier =
    ValueNotifier<UserAccount?>(akunTerakhirLogin);

/// Dipanggil setiap kali user berhasil "masuk" lewat form email & sandi.
/// - Kalau email sudah ada di [daftarAkun], akun itu yang ditandai
///   sebagai terakhir login (akun lain ditandai bukan terakhir login).
/// - Kalau belum ada, otomatis dibuatkan [UserAccount] baru dari email
///   tersebut lalu langsung ditandai sebagai terakhir login.
void simpanAkunLogin(String email) {
  final String emailRapi = email.trim();
  if (emailRapi.isEmpty) return;

  final int idx = daftarAkun
      .indexWhere((akun) => akun.email.toLowerCase() == emailRapi.toLowerCase());

  for (int i = 0; i < daftarAkun.length; i++) {
    daftarAkun[i] = daftarAkun[i].copyWith(isLastLogin: i == idx);
  }

  if (idx == -1) {
    final String local = emailRapi.split('@').first;
    final String nama = local.isEmpty
        ? emailRapi
        : local[0].toUpperCase() + local.substring(1);
    final String inisial = local.isEmpty
        ? '?'
        : (local.length >= 2
            ? local.substring(0, 2).toUpperCase()
            : local.substring(0, 1).toUpperCase());

    daftarAkun.add(UserAccount(
      nama: nama,
      email: emailRapi,
      inisial: inisial,
      role: 'utama',
      isLastLogin: true,
    ));
  }

  // Beri tahu semua widget yang mendengarkan (mis. PengaturanScreen)
  // bahwa akun yang aktif sekarang sudah berubah.
  currentUserNotifier.value = akunTerakhirLogin;
}