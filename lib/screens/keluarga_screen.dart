import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/obat_model.dart';
import '../widgets/common_widgets.dart';
import 'detail_anggota_screen.dart';

class KeluargaScreen extends StatelessWidget {
  const KeluargaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ValueListenableBuilder<List<AnggotaKeluarga>>(
                valueListenable: anggotaKeluargaNotifier,
                builder: (context, daftarAnggota, _) {
                  return daftarAnggota.isEmpty
                      ? _buildEmptyState(context)
                      : ListView(
                          padding: const EdgeInsets.only(top: 8, bottom: 24),
                          children: [
                            const Padding(
                              padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                              child: Text(
                                'Ketuk anggota untuk melihat status minum obatnya, geser ke kiri untuk hapus',
                                style: TextStyle(
                                    fontSize: 12, color: AppColors.slate400),
                              ),
                            ),
                            ...daftarAnggota.map((a) => Dismissible(
                                  key: ValueKey('anggota_${a.nama}'),
                                  direction: DismissDirection.endToStart,
                                  confirmDismiss: (_) =>
                                      _konfirmasiHapus(context, a.nama),
                                  onDismissed: (_) {
                                    hapusAnggotaKeluarga(a.nama);
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('${a.nama} dihapus dari keluarga'),
                                        backgroundColor: AppColors.slate800,
                                        behavior: SnackBarBehavior.floating,
                                        margin: const EdgeInsets.all(16),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                    );
                                  },
                                  background: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 4),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20),
                                    alignment: Alignment.centerRight,
                                    decoration: BoxDecoration(
                                      color: AppColors.red400,
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.delete_outline,
                                        color: Colors.white),
                                  ),
                                  child: KeluargaCard(
                                    anggota: a,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              DetailAnggotaScreen(anggota: a),
                                        ),
                                      );
                                    },
                                  ),
                                )),
                            const SizedBox(height: 8),
                            _buildTambahAnggota(context),
                          ],
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _konfirmasiHapus(BuildContext context, String nama) async {
    final hasil = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Hapus Anggota Keluarga',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate800)),
          content: Text('Yakin ingin menghapus $nama dari daftar keluarga?',
              style: const TextStyle(fontSize: 13, color: AppColors.slate600)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal',
                  style: TextStyle(color: AppColors.slate400)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red400,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
    return hasil ?? false;
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(8, 10, 20, 14),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new,
                size: 18, color: AppColors.slate800),
          ),
          const Text('Keluarga',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate800,
                  letterSpacing: -0.4)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.people_outline,
              size: 48, color: AppColors.slate300),
          const SizedBox(height: 12),
          const Text('Belum ada anggota keluarga',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate600)),
          const SizedBox(height: 4),
          const Text(
              'Tambahkan anggota keluarga untuk memantau\nkepatuhan minum obat bersama',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.slate400)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _showTambahAnggotaDialog(context),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.purple50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.purple200, width: 0.5),
              ),
              child: const Text('+ Tambah Anggota',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.purple600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTambahAnggota(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () => _showTambahAnggotaDialog(context),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.purple50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.purple200, width: 0.5),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_add_alt_1,
                  size: 16, color: AppColors.purple600),
              SizedBox(width: 6),
              Text('Tambah Anggota Keluarga',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.purple600)),
            ],
          ),
        ),
      ),
    );
  }

  void _showTambahAnggotaDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Tambah Anggota Keluarga',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate800)),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Nama anggota, misal: Adek',
              hintStyle: const TextStyle(color: AppColors.slate400),
              filled: true,
              fillColor: AppColors.slate50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal',
                  style: TextStyle(color: AppColors.slate400)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple600,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                final nama = controller.text.trim();
                if (nama.isEmpty) return;

                await tambahAnggotaKeluarga(nama);

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$nama berhasil ditambahkan'),
                      backgroundColor: AppColors.slate800,
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                }
              },
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
  }
}