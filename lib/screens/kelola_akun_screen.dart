import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/user_model.dart';
import 'tambah_akun_screen.dart';

class KelolaAkunScreen extends StatelessWidget {
  const KelolaAkunScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.slate800, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Kelola Akun',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.slate800)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TambahAkunScreen()),
            ),
            child: const Text('Tambah',
                style: TextStyle(
                  color: AppColors.slate800, fontWeight: FontWeight.w600, fontSize: 14)),
          ),
        ],
      ),
      body: SafeArea(
        child: ValueListenableBuilder<List<UserAccount>>(
          valueListenable: daftarAkunNotifier,
          builder: (context, daftar, _) {
            if (daftar.isEmpty) {
              return const Center(
                child: Text('Belum ada akun tersimpan',
                    style: TextStyle(color: AppColors.slate400, fontSize: 14)),
              );
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 4, bottom: 8),
                  child: Text('AKUN TERSIMPAN',
                      style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700,
                        color: AppColors.slate400, letterSpacing: 0.8)),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.slate100, width: 0.5),
                  ),
                  child: Column(
                    children: daftar.asMap().entries.map((entry) {
                      final i      = entry.key;
                      final akun   = entry.value;
                      final isLast = i == daftar.length - 1;
                      final isActive = currentUserNotifier.value?.email == akun.email;
                      return Column(
                        children: [
                          ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            leading: Container(
                              width: 42, height: 42,
                              decoration: BoxDecoration(
                                color: isActive ? AppColors.slate800 : AppColors.slate100,
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: Center(
                                child: Text(akun.inisial,
                                    style: TextStyle(
                                      color: isActive ? Colors.white : AppColors.slate400,
                                      fontSize: 14, fontWeight: FontWeight.w700)),
                              ),
                            ),
                            title: Text(akun.nama,
                                style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600,
                                  color: AppColors.slate800)),
                            subtitle: Text(akun.email,
                                style: const TextStyle(fontSize: 12, color: AppColors.slate400)),
                            trailing: isActive
                                ? Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.slate800,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text('Aktif',
                                        style: TextStyle(
                                          color: Colors.white, fontSize: 11,
                                          fontWeight: FontWeight.w600)),
                                  )
                                : IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded,
                                        color: AppColors.red400, size: 20),
                                    onPressed: () => _hapusAkun(context, akun),
                                  ),
                            onTap: isActive
                                ? null
                                : () {
                                    currentUserNotifier.value = akun;
                                    Navigator.pop(context);
                                  },
                          ),
                          if (!isLast)
                            const Divider(
                                height: 0.5, indent: 16, endIndent: 16,
                                color: AppColors.slate100),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _hapusAkun(BuildContext context, UserAccount akun) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Akun',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        content: Text('Hapus akun "${akun.nama}" dari daftar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: AppColors.slate400)),
          ),
          TextButton(
            onPressed: () {
              final list = List<UserAccount>.from(daftarAkunNotifier.value);
              list.removeWhere((a) => a.email == akun.email);
              daftarAkunNotifier.value = list;
              Navigator.pop(context);
            },
            child: const Text('Hapus',
                style: TextStyle(color: AppColors.red400, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}