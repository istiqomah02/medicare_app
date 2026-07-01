import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/obat_model.dart';

class NotifikasiScreen extends StatelessWidget {
  const NotifikasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ValueListenableBuilder<List<LogAktivitas>>(
                valueListenable: logNotifier,
                builder: (context, daftarLog, _) {
                  if (daftarLog.isEmpty) {
                    return _buildEmptyState();
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: daftarLog.length,
                    itemBuilder: (context, index) {
                      final log = daftarLog[index];
                      return Dismissible(
                        key: ValueKey('log_${log.id}'),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) {
                          hapusLogAktivitas(log.id);
                        },
                        background: Container(
                          margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          alignment: Alignment.centerRight,
                          decoration: BoxDecoration(
                            color: AppColors.red400,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.delete_outline,
                              color: Colors.white),
                        ),
                        child: _NotifLogTile(log: log),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(8, 10, 12, 14),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new,
                size: 18, color: AppColors.slate800),
          ),
          const Expanded(
            child: Text('Notifikasi',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate800,
                    letterSpacing: -0.4)),
          ),
          ValueListenableBuilder<List<LogAktivitas>>(
            valueListenable: logNotifier,
            builder: (context, daftarLog, _) {
              if (daftarLog.isEmpty) return const SizedBox.shrink();
              return _buildHapusSemuaButton(context);
            },
          ),
        ],
      ),
    );
  }

  // Tombol "Hapus Semua" dengan tampilan button (background + border),
  // bukan cuma teks polos.
  Widget _buildHapusSemuaButton(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _konfirmasiHapusSemua(context),
      style: TextButton.styleFrom(
        backgroundColor: AppColors.red400.withOpacity(0.08),
        foregroundColor: AppColors.red400,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: AppColors.red400.withOpacity(0.25)),
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: const Icon(Icons.delete_sweep_outlined, size: 16),
      label: const Text('Hapus Semua',
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.red400)),
    );
  }

  void _konfirmasiHapusSemua(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Hapus Semua Notifikasi',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate800)),
          content: const Text(
              'Semua riwayat notifikasi akan dihapus dan tidak bisa dikembalikan. Lanjutkan?',
              style: TextStyle(fontSize: 13, color: AppColors.slate600)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
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
              onPressed: () {
                hapusSemuaLog();
                Navigator.pop(dialogContext);
              },
              child: const Text('Hapus Semua'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.notifications_off_outlined,
              size: 48, color: AppColors.slate300),
          const SizedBox(height: 12),
          const Text('Belum ada notifikasi',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate600)),
          const SizedBox(height: 4),
          const Text('Riwayat pengingat obat akan muncul di sini',
              style: TextStyle(fontSize: 13, color: AppColors.slate400)),
        ],
      ),
    );
  }
}

class _NotifLogTile extends StatelessWidget {
  final LogAktivitas log;
  const _NotifLogTile({required this.log});

  @override
  Widget build(BuildContext context) {
    // Notifikasi tipe "ditambahkan" ditampilkan polos:
    // tanpa warna dan tanpa ikon/gambar sama sekali.
    final bool isPolos = log.jenis == JenisLog.ditambahkan;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slate100, width: 0.5),
      ),
      child: Row(
        children: [
          if (!isPolos) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getColor(log.jenis).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_getIcon(log.jenis),
                  color: _getColor(log.jenis), size: 20),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log.namaObat,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate800)),
                const SizedBox(height: 2),
                Text(log.waktuLog,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.slate400)),
              ],
            ),
          ),
          if (!isPolos)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _getColor(log.jenis).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(_getLabel(log.jenis),
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: _getColor(log.jenis))),
            )
          else
            Text(_getLabel(log.jenis),
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate400)),
        ],
      ),
    );
  }

  String _getLabel(JenisLog jenis) {
    switch (jenis) {
      case JenisLog.ditambahkan:
        return 'DITAMBAHKAN';
      case JenisLog.pengingat:
        return 'PENGINGAT';
      case JenisLog.terlewat:
        return 'TERLEWAT';
      case JenisLog.stokMenipis:
        return 'STOK MENIPIS';
      case JenisLog.dihapus:
        return 'DIHAPUS';
    }
  }

  Color _getColor(JenisLog jenis) {
    switch (jenis) {
      case JenisLog.ditambahkan:
        return AppColors.slate400;
      case JenisLog.pengingat:
        return AppColors.purple600;
      case JenisLog.terlewat:
        return AppColors.red400;
      case JenisLog.stokMenipis:
        return AppColors.amber400;
      case JenisLog.dihapus:
        return AppColors.slate400;
    }
  }

  IconData _getIcon(JenisLog jenis) {
    switch (jenis) {
      case JenisLog.ditambahkan:
        return Icons.add_circle_outline;
      case JenisLog.pengingat:
        return Icons.alarm;
      case JenisLog.terlewat:
        return Icons.error;
      case JenisLog.stokMenipis:
        return Icons.inventory_2_outlined;
      case JenisLog.dihapus:
        return Icons.delete_outline;
    }
  }
}
