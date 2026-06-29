import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/user_model.dart';
import 'login_screen.dart';

/// Layar untuk berpindah ke akun lain yang sudah tersimpan, atau
/// menambahkan akun baru. Dibuka dari kartu profil di PengaturanScreen.
class TambahAkunScreen extends StatelessWidget {
  const TambahAkunScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  const _SectionLabel(text: 'AKUN TERSIMPAN'),
                  _buildDaftarAkun(context),
                  const SizedBox(height: 20),
                  _buildTambahBaru(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(4, 6, 20, 14),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 20, color: AppColors.slate800),
          ),
          const SizedBox(width: 4),
          const Text('Pilih Akun',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate800,
                  letterSpacing: -0.4)),
        ],
      ),
    );
  }

  /// Reaktif terhadap currentUserNotifier, supaya tanda "akun aktif"
  /// langsung berubah begitu user menekan akun lain.
  Widget _buildDaftarAkun(BuildContext context) {
    return ValueListenableBuilder<UserAccount?>(
      valueListenable: currentUserNotifier,
      builder: (context, akunAktif, _) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.slate100, width: 0.5),
          ),
          child: Column(
            children: daftarAkun.asMap().entries.map((entry) {
              final i = entry.key;
              final akun = entry.value;
              final isLast = i == daftarAkun.length - 1;
              final aktif = akunAktif != null &&
                  akunAktif.email.toLowerCase() == akun.email.toLowerCase();

              return Column(
                children: [
                  InkWell(
                    onTap: aktif
                        ? null
                        : () {
                            simpanAkunLogin(akun.email);
                            Navigator.pop(context);
                          },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.slate800,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(akun.inisial,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(akun.nama,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.slate800)),
                                const SizedBox(height: 2),
                                Text(akun.email,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.slate400)),
                              ],
                            ),
                          ),
                          if (aktif)
                            const Icon(Icons.check_circle_rounded,
                                color: AppColors.slate800, size: 20)
                          else
                            const Icon(Icons.chevron_right,
                                color: AppColors.slate400),
                        ],
                      ),
                    ),
                  ),
                  if (!isLast)
                    const Divider(
                        height: 0.5,
                        indent: 16,
                        endIndent: 16,
                        color: AppColors.slate100),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildTambahBaru(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.slate100, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.slate100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add_rounded,
                  color: AppColors.slate800, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Tambah Akun Baru',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate800)),
            ),
            const Icon(Icons.chevron_right, color: AppColors.slate400),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.slate400,
              letterSpacing: 0.8)),
    );
  }
}
