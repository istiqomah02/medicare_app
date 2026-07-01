import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/obat_model.dart';

class DetailAnggotaScreen extends StatelessWidget {
  final AnggotaKeluarga anggota;
  const DetailAnggotaScreen({super.key, required this.anggota});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildProfilRingkas(),
                  const SizedBox(height: 16),
                  _buildStatCard(),
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
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(8, 10, 20, 14),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new,
                size: 18, color: AppColors.slate800),
          ),
          Text('Status ${anggota.nama}',
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate800,
                  letterSpacing: -0.4)),
        ],
      ),
    );
  }

  Widget _buildProfilRingkas() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate100, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.purple100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(anggota.inisial,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.purple600)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(anggota.nama,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate800)),
                const SizedBox(height: 4),
                Text('Kepatuhan minum obat: ${anggota.persentase}%',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.slate400)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate100, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _statItem(
                  label: 'Total Obat',
                  value: '${anggota.totalObat}',
                  color: AppColors.slate600,
                  icon: Icons.medication_outlined,
                ),
              ),
              Container(width: 0.5, height: 44, color: AppColors.slate100),
              Expanded(
                child: _statItem(
                  label: 'Sudah Diminum',
                  value: '${anggota.sudahDiminum}',
                  color: AppColors.green400,
                  icon: Icons.check_circle_outline,
                ),
              ),
              Container(width: 0.5, height: 44, color: AppColors.slate100),
              Expanded(
                child: _statItem(
                  label: 'Belum Diminum',
                  value: '${anggota.belum}',
                  color: AppColors.amber400,
                  icon: Icons.pending_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: anggota.totalObat > 0
                  ? anggota.sudahDiminum / anggota.totalObat
                  : 0,
              minHeight: 10,
              backgroundColor: AppColors.slate100,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.green400),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text('${anggota.persentase}% kepatuhan hari ini',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate600)),
          ),
        ],
      ),
    );
  }

  Widget _statItem({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 6),
        Text(value,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 2),
        Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: AppColors.slate400)),
      ],
    );
  }
}