import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/obat_model.dart';
import '../widgets/common_widgets.dart';
import 'tambah_obat_screen.dart';
import 'riwayat_screen.dart';
import 'notifikasi_screen.dart';
import 'keluarga_screen.dart';
import 'detail_anggota_screen.dart';

class BerandaScreen extends StatelessWidget {
  const BerandaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ValueListenableBuilder<List<Obat>>(
                valueListenable: obatNotifier,
                builder: (context, daftarObat, _) {
                  debugPrint('Beranda rebuild: ${daftarObat.length} obat');
                  final sudah = daftarObat
                      .where((o) => o.status == MedStatus.sudah)
                      .length;
                  return ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      ProgressCard(done: sudah, total: daftarObat.length),
                      if (daftarObat.isEmpty) _buildEmptyState(context),
                      ..._buildObatSections(daftarObat),
                      _buildKeluargaSection(context),
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

  Widget _buildKeluargaSection(BuildContext context) {
    return ValueListenableBuilder<List<AnggotaKeluarga>>(
      valueListenable: anggotaKeluargaNotifier,
      builder: (context, daftarAnggota, _) {
        if (daftarAnggota.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel(text: 'KELUARGA'),
            ...daftarAnggota.map((a) => KeluargaCard(
                  anggota: a,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailAnggotaScreen(anggota: a),
                      ),
                    );
                  },
                )),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate100, width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.slate50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.medication_outlined,
                size: 32, color: AppColors.slate300),
          ),
          const SizedBox(height: 14),
          const Text(
            'Belum ada obat',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.slate600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tambahkan obat pertama Anda\nuntuk mulai memantau jadwal minum',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.slate400,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TambahObatScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.slate800, AppColors.slate900],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Colors.white, size: 14),
                  SizedBox(width: 6),
                  Text('Tambah Obat',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('MediCare',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.slate800,
                          letterSpacing: -0.4)),
                  SizedBox(height: 2),
                  Text('Minggu, 31 Mei 2026',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.slate400)),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NotifikasiScreen()),
                ),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.slate50,
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: AppColors.slate100, width: 0.5),
                  ),
                  child: const Icon(Icons.notifications_outlined,
                      size: 20, color: AppColors.slate900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final navigator = Navigator.of(context);
                    final scaffoldMessenger =
                        ScaffoldMessenger.of(context);
                    final result = await navigator.push(
                      MaterialPageRoute(
                          builder: (_) => const TambahObatScreen()),
                    );
                    if (!context.mounted) return;
                    if (result == true) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content:
                              const Text('Obat berhasil ditambahkan!'),
                          backgroundColor: AppColors.green400,
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.slate800, AppColors.slate900],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 14),
                        SizedBox(width: 4),
                        Text('Tambah Obat',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const RiwayatScreen()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.slate100, width: 0.5),
                    ),
                    child: const Center(
                      child: Text('Lihat Riwayat',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.slate600)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const KeluargaScreen()),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: AppColors.purple50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.purple200, width: 0.5),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.people_outline,
                          size: 14, color: AppColors.purple600),
                      SizedBox(width: 4),
                      Text('Keluarga',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.purple600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ValueListenableBuilder<List<Obat>>(
            valueListenable: obatNotifier,
            builder: (context, daftarObat, _) {
              final stats = getStatistikKepatuhan();
              return Row(
                children: [
                  _buildQuickStat(
                      'Total', '${stats['total']}', AppColors.slate600),
                  const SizedBox(width: 16),
                  _buildQuickStat(
                      'Diminum', '${stats['sudah']}', AppColors.green400),
                  const SizedBox(width: 16),
                  _buildQuickStat('Kepatuhan',
                      '${stats['persentase']}%', AppColors.purple400),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text('$label: ',
            style: const TextStyle(
                fontSize: 11, color: AppColors.slate400)),
        Text(value,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color)),
      ],
    );
  }

  List<Widget> _buildObatSections(List<Obat> daftarObat) {
    final Map<String, List<Obat>> grouped = {};
    for (final o in daftarObat) {
      grouped.putIfAbsent(o.waktu, () => []).add(o);
    }
    final List<Widget> widgets = [];
    grouped.forEach((waktu, list) {
      widgets.add(SectionLabel(text: waktu.toUpperCase()));
      for (final o in list) {
        widgets.add(_buildObatCardBisaDigeser(o));
      }
    });
    return widgets;
  }

  Widget _buildObatCardBisaDigeser(Obat o) {
    return Builder(
      builder: (context) => Dismissible(
        key: ValueKey('obat_${o.id}'),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) => _konfirmasiHapusObat(context, o.nama),
        onDismissed: (_) {
          hapusObat(o.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${o.nama} berhasil dihapus'),
              backgroundColor: AppColors.red400,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        background: Container(
          margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: Alignment.centerRight,
          decoration: BoxDecoration(
            color: AppColors.red400,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.delete_outline, color: Colors.white),
        ),
        child: ObatCard(obat: o),
      ),
    );
  }

  Future<bool> _konfirmasiHapusObat(
      BuildContext context, String nama) async {
    final hasil = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: const Text('Hapus Obat?',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.slate800)),
          content: Text('Obat "$nama" akan dihapus permanen.',
              style: const TextStyle(
                  fontSize: 13, color: AppColors.slate400)),
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
                    borderRadius: BorderRadius.circular(10)),
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
}