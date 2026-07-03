import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/obat_model.dart';
import 'tambah_obat_screen.dart';

class DetailAnggotaScreen extends StatelessWidget {
  final AnggotaKeluarga anggota;
  const DetailAnggotaScreen({super.key, required this.anggota});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: SafeArea(
        child: ValueListenableBuilder<List<Obat>>(
          valueListenable: obatNotifier,
          builder: (context, semuaObat, _) {
            final obatAnggota =
                semuaObat.where((o) => o.anggotaId == anggota.id).toList();
            final total = obatAnggota.length;
            final sudah = obatAnggota
                .where((o) => o.status == MedStatus.sudah)
                .length;
            final belum = total - sudah;
            final persentase = total > 0 ? ((sudah / total) * 100).round() : 0;

            return Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildProfilRingkas(persentase),
                      const SizedBox(height: 16),
                      _buildStatCard(total, sudah, belum, persentase),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Daftar Obat',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.slate800)),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    TambahObatScreen(anggotaAwal: anggota),
                              ),
                            ),
                            child: Row(
                              children: const [
                                Icon(Icons.add_circle_outline,
                                    size: 18, color: AppColors.purple600),
                                SizedBox(width: 4),
                                Text('Tambah Obat',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.purple600)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (obatAnggota.isEmpty)
                        _buildEmptyObat(context)
                      else
                        ...obatAnggota.map((o) => _obatCard(o)),
                    ],
                  ),
                ),
              ],
            );
          },
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

  Widget _buildProfilRingkas(int persentase) {
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
                Text('Kepatuhan minum obat: $persentase%',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.slate400)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(int total, int sudah, int belum, int persentase) {
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
                  value: '$total',
                  color: AppColors.slate600,
                  icon: Icons.medication_outlined,
                ),
              ),
              Container(width: 0.5, height: 44, color: AppColors.slate100),
              Expanded(
                child: _statItem(
                  label: 'Sudah Diminum',
                  value: '$sudah',
                  color: AppColors.green400,
                  icon: Icons.check_circle_outline,
                ),
              ),
              Container(width: 0.5, height: 44, color: AppColors.slate100),
              Expanded(
                child: _statItem(
                  label: 'Belum Diminum',
                  value: '$belum',
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
              value: total > 0 ? sudah / total : 0,
              minHeight: 10,
              backgroundColor: AppColors.slate100,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.green400),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text('$persentase% kepatuhan hari ini',
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

  Widget _buildEmptyObat(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      alignment: Alignment.center,
      child: Column(
        children: [
          const Icon(Icons.medication_outlined,
              size: 40, color: AppColors.slate300),
          const SizedBox(height: 10),
          Text('Belum ada obat untuk ${anggota.nama}',
              style: const TextStyle(
                  fontSize: 13, color: AppColors.slate400)),
        ],
      ),
    );
  }

  Widget _obatCard(Obat o) {
    Color statusColor;
    String statusText;
    switch (o.status) {
      case MedStatus.sudah:
        statusColor = AppColors.green400;
        statusText = 'Sudah';
        break;
      case MedStatus.terlewat:
        statusColor = AppColors.red400;
        statusText = 'Terlewat';
        break;
      case MedStatus.belum:
        statusColor = AppColors.amber400;
        statusText = 'Belum';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.slate100, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(o.nama,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.slate800)),
                const SizedBox(height: 2),
                Text('${o.dosis} • ${o.waktu}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.slate400)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(statusText,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor)),
          ),
        ],
      ),
    );
  }
}