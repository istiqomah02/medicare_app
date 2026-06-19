import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/obat_model.dart';
import '../widgets/common_widgets.dart';

class JadwalScreen extends StatefulWidget {
  const JadwalScreen({super.key});

  @override
  State<JadwalScreen> createState() => _JadwalScreenState();
}

class _JadwalScreenState extends State<JadwalScreen> {
  int _selectedDay = 31;

  final List<Map<String, dynamic>> _days = [
    {'n': 25, 'label': 'Sen'},
    {'n': 26, 'label': 'Sel'},
    {'n': 27, 'label': 'Rab'},
    {'n': 28, 'label': 'Kam'},
    {'n': 29, 'label': 'Jum'},
    {'n': 30, 'label': 'Sab'},
    {'n': 31, 'label': 'Min'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildCalendarStrip(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  ..._buildObatSections(),
                  const SectionLabel(text: 'KELUARGA'),
                  KeluargaCard(anggota: anggotaAdek),
                  const SectionLabel(text: 'OBAT AKTIF'),
                  _buildObatAktifCard(),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Jadwal',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                      color: AppColors.slate800, letterSpacing: -0.4)),
              SizedBox(height: 2),
              Text('Minggu, 31 Mei 2026',
                  style: TextStyle(fontSize: 12, color: AppColors.slate400)),
            ],
          ),
          Row(
            children: [
              _navBtn(Icons.chevron_left),
              const SizedBox(width: 6),
              _navBtn(Icons.chevron_right),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navBtn(IconData icon) {
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(
        color: AppColors.slate50,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.slate100, width: 0.5),
      ),
      child: Icon(icon, size: 18, color: AppColors.slate900),
    );
  }

  Widget _buildCalendarStrip() {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
        child: Row(
          children: _days.map((d) {
            final int day = d['n'] as int;
            final bool active = day == _selectedDay;
            return GestureDetector(
              onTap: () => setState(() => _selectedDay = day),
              child: Container(
                width: 44,
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(vertical: 7),
                decoration: BoxDecoration(
                  color: active ? AppColors.slate800 : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text('${d['n']}',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700,
                            color: active ? Colors.white : AppColors.slate800)),
                    const SizedBox(height: 2),
                    Text(d['label'] as String,
                        style: TextStyle(
                            fontSize: 10,
                            color: active ? AppColors.slate400 : AppColors.slate400)),
                    const SizedBox(height: 3),
                    if (!active)
                      Container(
                        width: 5, height: 5,
                        decoration: BoxDecoration(
                          color: day % 3 == 0 ? AppColors.amber400 : AppColors.green400,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  List<Widget> _buildObatSections() {
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

  Widget _buildObatAktifCard() {
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
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(o.nama,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                              color: AppColors.slate800)),
                      Text('Stok: ${o.stokTablet} Tablet',
                          style: const TextStyle(fontSize: 11, color: AppColors.slate400)),
                    ]),
                    Text('${o.stokHariLagi} hari lagi',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: labelColor)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 7,
                    backgroundColor: AppColors.slate100,
                    valueColor: AlwaysStoppedAnimation<Color>(barColor),
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
