import 'dart:typed_data';
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

  // TAMBAHAN: sync daftarAkunNotifier & reset foto profil saat ganti akun
  daftarAkunNotifier.value = List.from(daftarAkun);
  fotoProfilNotifier.value = null;
}

// ─────────────────────────────────────────────
// TAMBAHAN — tidak mengubah kode di atas sama sekali
// ─────────────────────────────────────────────

/// Notifier daftar akun tersimpan — dipakai oleh KelolaAkunScreen.
final ValueNotifier<List<UserAccount>> daftarAkunNotifier =
    ValueNotifier<List<UserAccount>>(List.from(daftarAkun));

/// Notifier path foto profil akun yang sedang aktif.
/// Dipakai di Android/iOS/Desktop (path file asli).
final ValueNotifier<String?> fotoProfilNotifier = ValueNotifier<String?>(null);

/// Notifier bytes foto profil — dipakai khusus di Web, karena dart:io File
/// tidak bisa dipakai di web. Diisi bersamaan dengan fotoProfilNotifier
/// setiap kali user pilih foto baru.
final ValueNotifier<Uint8List?> fotoProfilBytesNotifier =
    ValueNotifier<Uint8List?>(null);

/// Penyimpanan password terpisah (key: email lowercase → password).
/// Karena UserAccount tidak punya field password, kita simpan di Map ini.
final Map<String, String> _passwordMap = {
  'cahyaniarum@gmail.com': '123456',
  'budipurnomo16@gmail.com': '123456',
};

/// Ambil password akun berdasarkan email.
String getPassword(String email) =>
    _passwordMap[email.toLowerCase()] ?? '';

/// Dipanggil dari UbahKataSandiScreen.
void ubahPassword(String email, String passwordBaru) {
  _passwordMap[email.toLowerCase()] = passwordBaru;
}

/// Dipanggil dari EditProfilScreen untuk mengupdate nama & inisial akun aktif.
void ubahNamaProfil(String namaBaru) {
  final akun = currentUserNotifier.value;
  if (akun == null) return;

  final int idx = daftarAkun.indexWhere(
      (a) => a.email.toLowerCase() == akun.email.toLowerCase());

  if (idx != -1) {
    final String inisial = namaBaru.trim().split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2)
        .join()
        .toUpperCase();

    daftarAkun[idx] = UserAccount(
      nama:        namaBaru.trim(),
      email:       daftarAkun[idx].email,
      inisial:     inisial,
      role:        daftarAkun[idx].role,
      isLastLogin: daftarAkun[idx].isLastLogin,
    );

    daftarAkunNotifier.value  = List.from(daftarAkun);
    currentUserNotifier.value = daftarAkun[idx];
  }
}

/// Dipanggil dari TambahAkunScreen (popup tambah akun).
/// Hanya menambahkan akun baru ke [daftarAkun] -- TIDAK menjadikannya
/// akun aktif. User harus tap akunnya secara manual nanti untuk login.
/// Mengembalikan true kalau berhasil ditambah, false kalau email sudah ada.
bool tambahAkunTanpaLogin(String email, String password) {
  final String emailRapi = email.trim();
  if (emailRapi.isEmpty) return false;

  final bool sudahAda = daftarAkun.any(
      (a) => a.email.toLowerCase() == emailRapi.toLowerCase());
  if (sudahAda) return false;

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
    isLastLogin: false,
  ));

  _passwordMap[emailRapi.toLowerCase()] = password;

  daftarAkunNotifier.value = List.from(daftarAkun);
  return true;
}


void hapusAkun(String email) {
  daftarAkun.removeWhere(
      (a) => a.email.toLowerCase() == email.toLowerCase());
  _passwordMap.remove(email.toLowerCase());
  daftarAkunNotifier.value = List.from(daftarAkun);
}

// ─────────────────────────────────────────────
// LUPA KATA SANDI (simulasi OTP)
// ─────────────────────────────────────────────

/// Kode OTP yang sedang aktif (simulasi — tidak benar-benar dikirim email).
String? _otpAktif;
String? _emailOtpAktif;

/// Cek apakah email terdaftar di daftarAkun.
bool emailTerdaftar(String email) {
  return daftarAkun.any(
      (a) => a.email.toLowerCase() == email.trim().toLowerCase());
}

/// Generate kode OTP 6 digit acak untuk email tertentu.
/// Mengembalikan kode tersebut (dipakai untuk ditampilkan di UI sebagai simulasi).
String generateOtp(String email) {
  final rnd = DateTime.now().millisecondsSinceEpoch % 900000 + 100000;
  _otpAktif = rnd.toString();
  _emailOtpAktif = email.trim().toLowerCase();
  return _otpAktif!;
}

/// Verifikasi kode OTP yang dimasukkan user.
bool verifikasiOtp(String email, String kode) {
  if (_otpAktif == null || _emailOtpAktif == null) return false;
  return _emailOtpAktif == email.trim().toLowerCase() && _otpAktif == kode.trim();
}

/// Reset password lewat alur lupa kata sandi (tanpa perlu password lama).
void resetPasswordViaOtp(String email, String passwordBaru) {
  _passwordMap[email.trim().toLowerCase()] = passwordBaru;
  _otpAktif = null;
  _emailOtpAktif = null;
}