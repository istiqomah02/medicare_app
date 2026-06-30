import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/obat_model.dart';
import '../widgets/common_widgets.dart';
import 'tambah_obat_screen.dart';
import 'riwayat_screen.dart';

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
                  // Debug: print jumlah obat
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
                      SectionLabel(text: 'KELUARGA'),
                      KeluargaCard(anggota: anggotaAdek),
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

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate100, width: 0.5),
      ),
      child: Column(
        children: [
          const Icon(Icons.medication_outlined,
              size: 48, color: AppColors.slate300),
          const SizedBox(height: 12),
          const Text('Belum ada obat',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate600)),
          const SizedBox(height: 4),
          const Text('Mulai tambahkan obat Anda sekarang',
              style: TextStyle(fontSize: 13, color: AppColors.slate400)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TambahObatScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.slate800,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tambah Obat'),
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
                      style:
                          TextStyle(fontSize: 12, color: AppColors.slate400)),
                ],
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.slate50,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.slate100, width: 0.5),
                ),
                child: const Icon(Icons.notifications_outlined,
                    size: 20, color: AppColors.slate900),
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
                    final scaffoldMessenger = ScaffoldMessenger.of(context);
                    final result = await navigator.push(
                      MaterialPageRoute(
                          builder: (_) => const TambahObatScreen()),
                    );
                    if (!context.mounted) return;
                    if (result == true) {
                      scaffoldMessenger.showSnackBar(
                        SnackBar(
                          content: const Text('Obat berhasil ditambahkan!'),
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RiwayatScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.slate100, width: 0.5),
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
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: AppColors.purple50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.purple200, width: 0.5),
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
                  _buildQuickStat('Kepatuhan', '${stats['persentase']}%',
                      AppColors.purple400),
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
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 11, color: AppColors.slate400),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
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
        widgets.add(ObatCard(obat: o));
      }
    });
    return widgets;
  }
}
