import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../app_theme.dart';
import '../models/obat_model.dart';

class TambahObatScreen extends StatefulWidget {
  // Kalau dibuka dari DetailAnggotaScreen, isi ini biar langsung ke-set target-nya
  final AnggotaKeluarga? anggotaAwal;

  const TambahObatScreen({super.key, this.anggotaAwal});

  @override
  State<TambahObatScreen> createState() => _TambahObatScreenState();
}

class _TambahObatScreenState extends State<TambahObatScreen> {
  final _namaCtrl = TextEditingController();
  final _dosisCtrl = TextEditingController();
  final _stokCtrl = TextEditingController();
  String _instruksi = 'Setelah makan';
  final Set<String> _waktuSelected = {'Pagi 08.00'};
  final Set<String> _hariSelected = {
    'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'
  };
  bool _notifMinum = true;
  bool _notifStok = true;
  bool _isLoading = false;

  // null = Diri Sendiri
  String? _anggotaIdTerpilih;

  final List<String> _waktuOptions = [
    'Pagi 08.00', 'Siang 13.00', 'Sore 17.00', 'Malam 20.00'
  ];
  final List<String> _hariOptions = [
    'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'
  ];
  final List<String> _instruksiOptions = [
    'Setelah makan', 'Sebelum makan', 'Saat makan', 'Bebas'
  ];

  @override
  void initState() {
    super.initState();
    _anggotaIdTerpilih = widget.anggotaAwal?.id;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.slate800, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Tambah Obat Baru',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.slate800)),
        centerTitle: false,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              const _SectionLabel(text: 'UNTUK SIAPA'),
              _buildAnggotaSelector(),
              _buildInfoCard(),
              const _SectionLabel(text: 'WAKTU MINUM'),
              _buildWaktuCard(),
              const _SectionLabel(text: 'NOTIFIKASI'),
              _buildNotifCard(),
            ],
          ),
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: _buildSimpanButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildAnggotaSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.slate100.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ValueListenableBuilder<List<AnggotaKeluarga>>(
        valueListenable: anggotaKeluargaNotifier,
        builder: (context, daftarAnggota, _) {
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _chipAnggota(id: null, label: 'Diri Sendiri'),
              ...daftarAnggota.map(
                  (a) => _chipAnggota(id: a.id, label: a.nama)),
            ],
          );
        },
      ),
    );
  }

  Widget _chipAnggota({required String? id, required String label}) {
    final sel = _anggotaIdTerpilih == id;
    return GestureDetector(
      onTap: () => setState(() => _anggotaIdTerpilih = id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: sel ? AppColors.purple600 : AppColors.slate50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: sel ? AppColors.purple600 : AppColors.slate200,
              width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (sel)
              const Icon(Icons.check_circle, color: Colors.white, size: 14),
            if (sel) const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: sel ? Colors.white : AppColors.slate800)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.slate100.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Informasi Obat',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate800)),
          const SizedBox(height: 16),
          _buildField('Nama Obat', _namaCtrl,
              hint: 'cth. Amoxicillin Trihydrate'),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                  child: _buildField('Dosis', _dosisCtrl,
                      hint: 'cth. 1 tablet')),
              const SizedBox(width: 12),
              Expanded(
                  child: _buildField('Stok', _stokCtrl,
                      hint: '30',
                      keyboardType: TextInputType.number)),
            ],
          ),
          const SizedBox(height: 14),
          _buildDropdown(),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl,
      {String? hint, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.slate600)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, color: AppColors.slate800),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.slate400),
            filled: true,
            fillColor: AppColors.slate50,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppColors.slate400, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Instruksi Minum',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.slate600)),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.slate50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: _instruksi,
            onChanged: (v) => setState(() => _instruksi = v!),
            items: _instruksiOptions
                .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e,
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.slate800))))
                .toList(),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWaktuCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.slate100.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pilih Waktu',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate800)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _waktuOptions.map((w) {
              final sel = _waktuSelected.contains(w);
              return GestureDetector(
                onTap: () => setState(() =>
                    sel ? _waktuSelected.remove(w) : _waktuSelected.add(w)),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.slate900 : AppColors.slate50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: sel
                            ? AppColors.slate900
                            : AppColors.slate200,
                        width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (sel)
                        const Icon(Icons.check_circle,
                            color: Colors.white, size: 14),
                      if (sel) const SizedBox(width: 4),
                      Text(w,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: sel
                                  ? Colors.white
                                  : AppColors.slate800)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text('Hari Pengulangan',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate800)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _hariOptions.map((h) {
              final sel = _hariSelected.contains(h);
              return GestureDetector(
                onTap: () => setState(() =>
                    sel ? _hariSelected.remove(h) : _hariSelected.add(h)),
                child: Container(
                  width: 38,
                  height: 34,
                  decoration: BoxDecoration(
                    color: sel ? AppColors.slate800 : AppColors.slate50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: sel
                            ? AppColors.slate800
                            : AppColors.slate200,
                        width: 1),
                  ),
                  child: Center(
                    child: Text(h,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: sel
                                ? Colors.white
                                : AppColors.slate800)),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotifCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.slate100.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildNotifRow(
            icon: Icons.notifications_active,
            iconBg: AppColors.green50,
            iconColor: AppColors.green600,
            title: 'Pengingat Minum',
            subtitle: '15 menit sebelum jadwal',
            value: _notifMinum,
            onChanged: (v) => setState(() => _notifMinum = v),
          ),
          Container(height: 0.5, color: AppColors.slate100),
          _buildNotifRow(
            icon: Icons.warning_amber,
            iconBg: AppColors.amber50,
            iconColor: AppColors.amber600,
            title: 'Peringatan Stok',
            subtitle: 'Saat stok < 7 hari',
            value: _notifStok,
            onChanged: (v) => setState(() => _notifStok = v),
          ),
        ],
      ),
    );
  }

  Widget _buildNotifRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.slate800)),
                Text(subtitle,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.slate400)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.slate900,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: AppColors.slate200,
          ),
        ],
      ),
    );
  }

  Widget _buildSimpanButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _simpanObat,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.slate900,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          elevation: 0,
          minimumSize: const Size(double.infinity, 0),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, size: 20),
                  SizedBox(width: 8),
                  Text('Simpan Obat',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700)),
                ],
              ),
      ),
    );
  }

  Future<void> _simpanObat() async {
    if (_namaCtrl.text.isEmpty) {
      _showSnackbar('Mohon isi nama obat', isError: true);
      return;
    }
    if (_dosisCtrl.text.isEmpty) {
      _showSnackbar('Mohon isi dosis', isError: true);
      return;
    }
    if (_stokCtrl.text.isEmpty) {
      _showSnackbar('Mohon isi stok', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    final obat = Obat(
      id: const Uuid().v4(),
      nama: _namaCtrl.text.trim(),
      dosis: _dosisCtrl.text.trim(),
      waktu: _waktuSelected.first,
      instruksi: _instruksi,
      status: MedStatus.belum,
      stokTablet: int.tryParse(_stokCtrl.text) ?? 0,
      stokHariLagi: int.tryParse(_stokCtrl.text) ?? 0,
      hari: Set.from(_hariSelected),
      notifMinum: _notifMinum,
      notifStok: _notifStok,
      anggotaId: _anggotaIdTerpilih,
    );

    await tambahObat(obat);

    if (!mounted) return;
    setState(() => _isLoading = false);
    _showSnackbar('Berhasil menambahkan ${obat.nama}', isSuccess: true);
    Navigator.pop(context, true);
  }

  void _showSnackbar(String message,
      {bool isError = false, bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? AppColors.red400
            : isSuccess
                ? AppColors.green400
                : AppColors.slate800,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _dosisCtrl.dispose();
    _stokCtrl.dispose();
    super.dispose();
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(text,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.slate400,
              letterSpacing: 0.8)),
    );
  }
}