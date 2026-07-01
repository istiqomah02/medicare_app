import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/obat_model.dart';

class RiwayatScreen extends StatelessWidget {
  // Callback opsional untuk pindah tab ke Beranda.
  // Diisi oleh MainNavigation karena RiwayatScreen adalah salah satu tab,
  // bukan halaman yang di-push, sehingga Navigator.pop tidak berlaku di sini.
  final VoidCallback? onKembali;

  const RiwayatScreen({super.key, this.onKembali});

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
              child: ValueListenableBuilder<List<Obat>>(
                valueListenable: obatNotifier,
                builder: (context, daftarObat, _) {
                  return ValueListenableBuilder<List<LogAktivitas>>(
                    valueListenable: logNotifier,
                    builder: (context, logs, _) {
                      return ListView(
                        padding: const EdgeInsets.only(bottom: 24),
                        children: [
                          const SizedBox(height: 12),
                          _buildStatGrid(daftarObat),
                          _buildSectionLabel('KEBUTUHAN PER OBAT'),
                          _buildKebutuhanCard(daftarObat),
                          _buildSectionLabel('LOG AKTIFITAS'),
                          if (logs.isEmpty)
                            _buildEmptyLog()
                          else
                            _buildLogCard(logs),
                        ],
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

  Widget _buildEmptyLog() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.slate100, width: 0.5),
      ),
      child: Column(
        children: [
          Icon(Icons.history, size: 40, color: AppColors.slate300),
          const SizedBox(height: 8),
          const Text('Belum ada aktivitas',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slate500)),
          const SizedBox(height: 4),
          const Text('Mulai minum obat untuk mencatat aktivitas',
              style: TextStyle(fontSize: 12, color: AppColors.slate400)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(8, 10, 20, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              if (onKembali != null) {
                onKembali!();
              } else {
                Navigator.maybePop(context);
              }
            },
            icon: const Icon(Icons.arrow_back_ios_new,
                size: 18, color: AppColors.slate800),
          ),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Riwayat',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.slate800,
                      letterSpacing: -0.4)),
              SizedBox(height: 2),
              Text('7 Hari terakhir',
                  style: TextStyle(fontSize: 12, color: AppColors.slate400)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatGrid(List<Obat> daftarObat) {
    final total = daftarObat.length;
    final sudah = daftarObat.where((o) => o.status == MedStatus.sudah).length;
    final terlewat = daftarObat.where((o) => o.status == MedStatus.terlewat).length;
    final kepatuhan = total > 0 ? (sudah / total * 100).round() : 0;
    
    final stats = [
      {
        'label': 'Kepatuhan minggu ini',
        'value': '$kepatuhan%',
        'color': AppColors.green400
      },
      {
        'label': 'Total dosis diminum',
        'value': '$sudah',
        'color': AppColors.slate800
      },
      {
        'label': 'Dosis terlewat',
        'value': '$terlewat',
        'color': AppColors.red400,
      },
      {
        'label': 'Hari berturut-turut',
        'value': '7',
        'color': AppColors.slate800
      },
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.slate100.withOpacity(0.2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(s['value'] as String,
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: s['color'] as Color)),
                const SizedBox(height: 4),
                Text(s['label'] as String,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.slate600)),
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
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.slate400,
              letterSpacing: 0.8)),
    );
  }

  Widget _buildKebutuhanCard(List<Obat> daftarObat) {
    if (daftarObat.isEmpty) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.slate100, width: 0.5),
        ),
        child: const Center(
          child: Text('Belum ada obat yang terdaftar',
              style: TextStyle(color: AppColors.slate400)),
        ),
      );
    }

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
          final Color barColor =
              o.stokHariLagi <= 7 ? AppColors.amber400 : AppColors.green400;
          final Color labelColor =
              o.stokHariLagi <= 7 ? AppColors.amber400 : AppColors.green400;
          final double pct = (o.stokHariLagi / 30).clamp(0.0, 1.0);
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(o.nama,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.slate800)),
                    Text('${o.stokHariLagi} hari lagi',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: labelColor)),
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
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 8,
                          height: 8,
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

  Widget _buildLogCard(List<LogAktivitas> logs) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.slate100, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.slate100.withOpacity(0.2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: logs.asMap().entries.map((entry) {
          final log = entry.value;
          final isLast = entry.key == logs.length - 1;
          final Color dotColor = log.status == MedStatus.sudah
              ? AppColors.green400
              : log.status == MedStatus.terlewat
                  ? AppColors.red400
                  : AppColors.amber400;
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    const SizedBox(height: 4),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                          color: dotColor, shape: BoxShape.circle),
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
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.slate800)),
                        const SizedBox(height: 2),
                        Text(log.waktuLog,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.slate400)),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: dotColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    log.status == MedStatus.sudah ? 'DIMINUM' :
                    log.status == MedStatus.terlewat ? 'TERLEWAT' : 'BELUM',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: dotColor,
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