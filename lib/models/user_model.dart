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
