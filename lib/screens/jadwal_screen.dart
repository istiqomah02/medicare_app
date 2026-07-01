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
  // Tanggal yang sedang dipilih user
  DateTime _selectedDate = DateTime(2026, 5, 31);

  // Senin dari minggu yang sedang ditampilkan di strip (mode ringkas)
  DateTime _weekAnchor = _mondayOf(DateTime(2026, 5, 31));

  // Status: kalender penuh sedang terbuka atau tidak (default tertutup -> mode ringkas)
  bool _isCalendarExpanded = false;

  // Bulan yang sedang ditampilkan saat kalender penuh terbuka
  DateTime _focusedMonth = DateTime(2026, 5, 1);

  // Bulan acuan untuk PageController (index tengah = bulan ini)
  final DateTime _baseMonth = DateTime(2026, 5, 1);
  static const int _pageMid =
      1000; // beri ruang ratusan bulan ke depan & belakang

  // Controller hanya dibuat saat kalender penuh dibuka, supaya hemat resource
  PageController? _monthPageController;

  static const List<String> _bulanLabel = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static const List<String> _hariLabel = [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];

  static const List<String> _hariPanjang = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  @override
  void dispose() {
    _monthPageController?.dispose();
    super.dispose();
  }

  static DateTime _mondayOf(DateTime d) {
    final DateTime onlyDate = DateTime(d.year, d.month, d.day);
    return onlyDate.subtract(Duration(days: onlyDate.weekday - 1));
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  int _pageForMonth(DateTime month) {
    return _pageMid +
        (month.year - _baseMonth.year) * 12 +
        (month.month - _baseMonth.month);
  }

  DateTime _monthForPage(int index) {
    return DateTime(_baseMonth.year, _baseMonth.month + (index - _pageMid), 1);
  }

  // Indikator berdasarkan data obat asli:
  // - Lihat obat apa saja yang dijadwalkan pada hari tersebut (field `hari` di Obat).
  // - Jika tidak ada obat yang dijadwalkan di hari itu -> tidak ada titik (null).
  // - Jika ada obat dengan stok menipis (stokHariLagi <= 7) -> kuning (perlu perhatian).
  // - Jika semua obat di hari itu stoknya masih aman -> hijau (aman).
  Color? _dotColorFor(DateTime date) {
    final String namaHari = _hariLabel[date.weekday - 1];
    final List<Obat> obatHariIni =
        daftarObat.where((o) => o.hari.contains(namaHari)).toList();

    if (obatHariIni.isEmpty) return null;

    final bool adaStokMenipis =
        obatHariIni.any((o) => o.stokHariLagi <= 7);
    return adaStokMenipis ? AppColors.amber400 : AppColors.green400;
  }

  String _formatSelectedDate() {
    final String namaHari = _hariPanjang[_selectedDate.weekday - 1];
    final String namaBulan = _bulanLabel[_selectedDate.month - 1];
    return '$namaHari, ${_selectedDate.day} $namaBulan ${_selectedDate.year}';
  }

  void _toggleCalendarExpanded() {
    setState(() {
      if (_isCalendarExpanded) {
        _isCalendarExpanded = false;
        _monthPageController?.dispose();
        _monthPageController = null;
      } else {
        _isCalendarExpanded = true;
        _focusedMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
        _monthPageController =
            PageController(initialPage: _pageForMonth(_focusedMonth));
      }
    });
  }

  void _selectDateAndCollapse(DateTime date) {
    setState(() {
      _selectedDate = date;
      _weekAnchor = _mondayOf(date);
      _isCalendarExpanded = false;
      _monthPageController?.dispose();
      _monthPageController = null;
    });
  }

  void _goToPreviousPeriod() {
    if (_isCalendarExpanded) {
      _monthPageController?.previousPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      setState(() {
        _selectedDate = _selectedDate.subtract(const Duration(days: 7));
        _weekAnchor = _mondayOf(_selectedDate);
      });
    }
  }

  void _goToNextPeriod() {
    if (_isCalendarExpanded) {
      _monthPageController?.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      setState(() {
        _selectedDate = _selectedDate.add(const Duration(days: 7));
        _weekAnchor = _mondayOf(_selectedDate);
      });
    }
  }

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
            children: [
              const Text('Jadwal',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.slate800,
                      letterSpacing: -0.4)),
              const SizedBox(height: 2),
              // Tap di sini untuk buka/tutup kalender bulan penuh
              GestureDetector(
                onTap: _toggleCalendarExpanded,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_formatSelectedDate(),
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.slate400)),
                    const SizedBox(width: 4),
                    Icon(
                      _isCalendarExpanded
                          ? Icons.expand_less
                          : Icons.expand_more,
                      size: 16,
                      color: AppColors.slate400,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              _navBtn(Icons.chevron_left, _goToPreviousPeriod),
              const SizedBox(width: 6),
              _navBtn(Icons.chevron_right, _goToNextPeriod),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.slate50,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.slate100, width: 0.5),
        ),
        child: Icon(icon, size: 18, color: AppColors.slate900),
      ),
    );
  }

  // ===================== KALENDER =====================
  // Default: strip 7 hari (ringkas, persis tampilan semula).
  // Saat baris tanggal di header ditekan -> buka kalender bulan penuh (bisa digeser antar bulan).

  Widget _buildCalendarStrip() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Column(
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _isCalendarExpanded
                ? _buildExpandedCalendar()
                : _buildWeekStrip(),
          ),
          const SizedBox(height: 10),
          _buildLegenda(),
        ],
      ),
    );
  }

  // Legenda arti warna titik di kalender, supaya pengguna tidak menebak-nebak.
  Widget _buildLegenda() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendaItem(AppColors.green400, 'Stok aman'),
        const SizedBox(width: 16),
        _legendaItem(AppColors.amber400, 'Stok menipis'),
      ],
    );
  }

  Widget _legendaItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.slate400),
        ),
      ],
    );
  }

  Widget _buildWeekStrip() {
    final List<DateTime> week =
        List.generate(7, (i) => _weekAnchor.add(Duration(days: i)));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(7, (i) {
          final DateTime date = week[i];
          final bool active = _isSameDate(date, _selectedDate);
          final Color? dotColor = _dotColorFor(date);

          return GestureDetector(
            onTap: () => setState(() => _selectedDate = date),
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
                  Text('${date.day}',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: active ? Colors.white : AppColors.slate800)),
                  const SizedBox(height: 2),
                  Text(_hariLabel[i],
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.slate400)),
                  const SizedBox(height: 3),
                  if (!active && dotColor != null)
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    )
                  else
                    const SizedBox(height: 5),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildExpandedCalendar() {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Column(
        children: [
          Center(
            child: Text(
              '${_bulanLabel[_focusedMonth.month - 1]} ${_focusedMonth.year}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.slate800,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: _hariLabel
                .map((h) => Expanded(
                      child: Center(
                        child: Text(
                          h,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.slate400,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 260,
            child: PageView.builder(
              controller: _monthPageController,
              onPageChanged: (index) {
                setState(() => _focusedMonth = _monthForPage(index));
              },
              itemBuilder: (context, index) {
                final month = _monthForPage(index);
                return _buildMonthGrid(month);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthGrid(DateTime month) {
    final int daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final int leadingBlanks = DateTime(month.year, month.month, 1).weekday - 1;

    final List<Widget> cells = [];
    for (int i = 0; i < 42; i++) {
      final int dayNum = i - leadingBlanks + 1;

      if (dayNum < 1 || dayNum > daysInMonth) {
        cells.add(const Expanded(child: SizedBox.shrink()));
        continue;
      }

      final DateTime date = DateTime(month.year, month.month, dayNum);
      final bool active = _isSameDate(date, _selectedDate);
      final Color? dotColor = _dotColorFor(date);

      cells.add(
        Expanded(
          child: GestureDetector(
            onTap: () => _selectDateAndCollapse(date),
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: active ? AppColors.slate800 : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$dayNum',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: active ? Colors.white : AppColors.slate800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  if (!active && dotColor != null)
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    )
                  else
                    const SizedBox(height: 5),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final List<Widget> rows = [];
    for (int r = 0; r < 6; r++) {
      rows.add(
        Expanded(
          child: Row(children: cells.sublist(r * 7, r * 7 + 7)),
        ),
      );
    }

    return Column(children: rows);
  }

  // ===================== BAGIAN LAIN (TIDAK DIUBAH) =====================

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
          final Color barColor =
              o.stokHariLagi <= 7 ? AppColors.amber400 : AppColors.green400;
          final Color labelColor =
              o.stokHariLagi <= 7 ? AppColors.amber400 : AppColors.green400;
          final double pct = (o.stokHariLagi / 30).clamp(0.0, 1.0);
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(o.nama,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.slate800)),
                          Text('Stok: ${o.stokTablet} Tablet',
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.slate400)),
                        ]),
                    Text('${o.stokHariLagi} hari lagi',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: labelColor)),
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