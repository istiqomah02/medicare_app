import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/user_model.dart';
import '../main.dart';

class PilihAkunScreen extends StatefulWidget {
  const PilihAkunScreen({super.key});

  @override
  State<PilihAkunScreen> createState() => _PilihAkunScreenState();
}

class _PilihAkunScreenState extends State<PilihAkunScreen> {
  int _selectedIndex = 0;

  static const List<Color> _avatarColors = [
    AppColors.slate800,
    Color(0xFFD4B96A),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD1D5DB),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back button
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('Kembali',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600,
                          color: AppColors.slate800)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('Pilih Akun',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700,
                      color: AppColors.slate800)),
            ),
            const SizedBox(height: 4),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text('Masuk sebagai siapa hari ini?',
                  style: TextStyle(fontSize: 13, color: AppColors.slate600)),
            ),
            const SizedBox(height: 16),
            // Daftar akun
            ...daftarAkun.asMap().entries.map((entry) {
              final int i = entry.key;
              final UserAccount akun = entry.value;
              final bool selected = i == _selectedIndex;
              return GestureDetector(
                onTap: () => setState(() => _selectedIndex = i),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.purple50 : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected ? AppColors.purple200 : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: _avatarColors[i % _avatarColors.length],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(akun.inisial,
                              style: const TextStyle(color: Colors.white,
                                  fontSize: 15, fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(akun.nama,
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w700,
                                    color: selected ? AppColors.purple900 : AppColors.slate800)),
                            const SizedBox(height: 2),
                            Text(akun.email,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: selected ? AppColors.purple600 : AppColors.slate400)),
                            const SizedBox(height: 2),
                            Text(
                              akun.isLastLogin ? 'Terakhir Masuk' : akun.role,
                              style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w600,
                                color: selected ? AppColors.purple400 : AppColors.slate400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 10),
            // Tambah akun lain
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.slate800, width: 1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('+ Tambah Akun Lain',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                        color: AppColors.slate800)),
              ),
            ),
            const SizedBox(height: 8),
            // Masuk
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const MainNavigation()),
                  (route) => false,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.slate800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Masuk Dengan Akun Ini',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
