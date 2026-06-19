import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/obat_model.dart';

// ── Status Badge ──────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final MedStatus status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;
    switch (status) {
      case MedStatus.sudah:
        bg = AppColors.green50; fg = AppColors.green600; label = 'Sudah';
      case MedStatus.belum:
        bg = AppColors.amber50; fg = AppColors.amber600; label = 'Belum';
      case MedStatus.terlewat:
        bg = AppColors.red50; fg = AppColors.red700; label = 'Terlewat';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}

// ── Med Icon ──────────────────────────────────────────────────
class MedIconBox extends StatelessWidget {
  final MedStatus status;
  const MedIconBox({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final Color bg = status == MedStatus.sudah ? AppColors.green50 : AppColors.amber50;
    final Color ic = status == MedStatus.sudah ? AppColors.green600 : AppColors.amber600;
    return Container(
      width: 42, height: 42,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Icon(Icons.medication_outlined, color: ic, size: 22),
    );
  }
}

// ── Obat Card ─────────────────────────────────────────────────
class ObatCard extends StatelessWidget {
  final Obat obat;
  const ObatCard({super.key, required this.obat});

  @override
  Widget build(BuildContext context) {
    final bool isOverdue = obat.status == MedStatus.belum;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: isOverdue
            ? const BorderRadius.only(topRight: Radius.circular(14), bottomRight: Radius.circular(14))
            : BorderRadius.circular(14),
        border: Border(
          left: isOverdue
              ? const BorderSide(color: AppColors.amber400, width: 3)
              : BorderSide.none,
          top: BorderSide(color: isOverdue ? AppColors.amber50 : AppColors.slate100, width: 0.5),
          right: BorderSide(color: isOverdue ? AppColors.amber50 : AppColors.slate100, width: 0.5),
          bottom: BorderSide(color: isOverdue ? AppColors.amber50 : AppColors.slate100, width: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            MedIconBox(status: obat.status),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(obat.nama,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.slate800)),
                  const SizedBox(height: 2),
                  Text('${obat.dosis} · ${obat.instruksi}',
                      style: const TextStyle(fontSize: 12, color: AppColors.slate400)),
                ],
              ),
            ),
            StatusBadge(status: obat.status),
          ],
        ),
      ),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Text(text,
          style: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700,
            color: AppColors.slate400, letterSpacing: 0.8,
          )),
    );
  }
}

// ── Keluarga Card ─────────────────────────────────────────────
class KeluargaCard extends StatelessWidget {
  final AnggotaKeluarga anggota;
  const KeluargaCard({super.key, required this.anggota});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.purple50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.purple200, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: AppColors.purple400, borderRadius: BorderRadius.circular(12)),
            child: Center(
              child: Text(anggota.inisial,
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(anggota.nama,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.purple900)),
                const SizedBox(height: 2),
                Text('${anggota.totalObat} obat hari ini',
                    style: const TextStyle(fontSize: 12, color: AppColors.purple600)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${anggota.sudahDiminum}/${anggota.totalObat} diminum',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.purple600)),
              Text('${anggota.belum} belum',
                  style: const TextStyle(fontSize: 11, color: AppColors.purple400)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Progress Bar Card ─────────────────────────────────────────
class ProgressCard extends StatelessWidget {
  final int done;
  final int total;
  const ProgressCard({super.key, required this.done, required this.total});

  @override
  Widget build(BuildContext context) {
    final double pct = total > 0 ? done / total : 0;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.slate100, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Progress hari ini',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.slate800)),
              Text('$done / $total',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.slate900)),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 7,
              backgroundColor: AppColors.slate100,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.slate900),
            ),
          ),
          const SizedBox(height: 6),
          Text('${total - done} obat lagi yang perlu diminum',
              style: const TextStyle(fontSize: 11, color: AppColors.slate400)),
        ],
      ),
    );
  }
}
