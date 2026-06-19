import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/obat_model.dart';

class RiwayatScreen extends StatelessWidget {
  const RiwayatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  const SizedBox(height: 12),
                  _buildStatGrid(),
                  _buildSectionLabel('KEBUTUHAN PER OBAT'),
                  _buildKebutuhanCard(),
                  _buildSectionLabel('LOG AKTIFITAS'),
                  _buildLogCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Riwayat',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                  color: AppColors.slate800, letterSpacing: -0.4)),
          SizedBox(height: 2),
          Text('7 Hari terakhir',
              style: TextStyle(fontSize: 12, color: AppColors.slate400)),
        ],
      ),
    );
  }

  Widget _buildStatGrid() {
    final stats = [
      {'label': 'Kepatuhan minggu ini', 'value': '80 %', 'color': AppColors.green400},
      {'label': 'Total dosis diminum', 'value': '20', 'color': AppColors.slate800},
      {'label': 'Dosis terlewat', 'value': '3', 'color': AppColors.amber400},
      {'label': 'Hari berturut-turut', 'value': '7', 'color': AppColors.slate800},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.6,
        children: stats.map((s) {
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.slate100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(s['value'] as String,
                    style: TextStyle(
                        fontSize: 26, fontWeight: FontWeight.w700,
                        color: s['color'] as Color)),
                const SizedBox(height: 4),
                Text(s['label'] as String,
                    style: const TextStyle(fontSize: 11, color: AppColors.slate600)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Text(text,
          style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700,
              color: AppColors.slate400, letterSpacing: 0.8)),
    );
  }

  Widget _buildKebutuhanCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.slate100, width: 0.5),
      ),
      child: Column(
        children: daftarObat.map((o) {
          final Color barColor = o.stokHariLagi <= 7 ? AppColors.amber400 : AppColors.green400;
          final Color labelColor = o.stokHariLagi <= 7 ? AppColors.amber400 : AppColors.green400;
          final double pct = (o.stokHariLagi / 30).clamp(0.0, 1.0);
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(o.nama,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                            color: AppColors.slate800)),
                    Text('${o.stokHariLagi} hari lagi',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: labelColor)),
                  ],
                ),
                const SizedBox(height: 6),
                Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.slate100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: pct,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: barColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    if (o.stokHariLagi <= 7)
                      Positioned(
                        right: 0, top: 0, bottom: 0,
                        child: Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.red400,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLogCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.slate100, width: 0.5),
      ),
      child: Column(
        children: logAktivitas.asMap().entries.map((entry) {
          final log = entry.value;
          final isLast = entry.key == logAktivitas.length - 1;
          final Color dotColor = log.status == MedStatus.sudah
              ? AppColors.green400
              : AppColors.amber400;
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 4),
                    Container(
                      width: 12, height: 12,
                      decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: AppColors.slate100,
                          margin: const EdgeInsets.symmetric(vertical: 3),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(log.namaObat,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                                color: AppColors.slate800)),
                        const SizedBox(height: 2),
                        Text(log.waktuLog,
                            style: const TextStyle(fontSize: 11, color: AppColors.slate400)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
