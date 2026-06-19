import 'package:flutter/material.dart';
import '../app_theme.dart';

class TambahObatScreen extends StatefulWidget {
  const TambahObatScreen({super.key});

  @override
  State<TambahObatScreen> createState() => _TambahObatScreenState();
}

class _TambahObatScreenState extends State<TambahObatScreen> {
  final _namaCtrl = TextEditingController();
  final _dosisCtrl = TextEditingController();
  final _stokCtrl = TextEditingController();
  String _instruksi = 'Setelah makan';
  final Set<String> _waktuSelected = {'Pagi 08.00'};
  final Set<String> _hariSelected = {'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'};
  bool _notifMinum = true;
  bool _notifStok = true;

  final List<String> _waktuOptions = ['Pagi 08.00', 'Siang 13.00', 'Sore 17.00', 'Malam 20.00'];
  final List<String> _hariOptions = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  final List<String> _instruksiOptions = ['Setelah makan', 'Sebelum makan', 'Saat makan', 'Bebas'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.slate800),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Tambah Obat'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: AppColors.slate100),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          _buildInfoCard(),
          const _SectionLabel(text: 'WAKTU MINUM'),
          _buildWaktuCard(),
          const _SectionLabel(text: 'NOTIFIKASI'),
          _buildNotifCard(),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.slate900,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Simpan Obat',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
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
          _buildField('Nama obat', _namaCtrl, hint: 'cth. Amoxicillin Trihydrate'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildField('Dosis', _dosisCtrl, hint: 'cth. 1 tablet')),
              const SizedBox(width: 10),
              Expanded(child: _buildField('Stok', _stokCtrl, hint: '30', keyboardType: TextInputType.number)),
            ],
          ),
          const SizedBox(height: 12),
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
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.slate900)),
        const SizedBox(height: 5),
        TextField(
          controller: ctrl,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, color: AppColors.slate800),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.slate400),
            filled: true,
            fillColor: AppColors.slate50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.slate100, width: 0.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.slate100, width: 0.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.slate400, width: 1),
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
        const Text('Instruksi minum',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.slate900)),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: _instruksi,
          onChanged: (v) => setState(() => _instruksi = v!),
          items: _instruksiOptions
              .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14))))
              .toList(),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.slate50,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.slate100, width: 0.5)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.slate100, width: 0.5)),
          ),
        ),
      ],
    );
  }

  Widget _buildWaktuCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.slate100, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Pilih waktu',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.slate900)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6, runSpacing: 6,
            children: _waktuOptions.map((w) {
              final sel = _waktuSelected.contains(w);
              return GestureDetector(
                onTap: () => setState(() => sel ? _waktuSelected.remove(w) : _waktuSelected.add(w)),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.slate900 : AppColors.slate50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: sel ? AppColors.slate900 : AppColors.slate100, width: 0.5),
                  ),
                  child: Text(w,
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : AppColors.slate900)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          const Text('Hari pengulangan',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.slate900)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _hariOptions.map((h) {
              final sel = _hariSelected.contains(h);
              return GestureDetector(
                onTap: () => setState(() => sel ? _hariSelected.remove(h) : _hariSelected.add(h)),
                child: Container(
                  width: 36, height: 32,
                  decoration: BoxDecoration(
                    color: sel ? AppColors.slate800 : AppColors.slate50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: sel ? AppColors.slate800 : AppColors.slate100, width: 0.5),
                  ),
                  child: Center(
                    child: Text(h,
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600,
                            color: sel ? Colors.white : AppColors.slate900)),
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.slate100, width: 0.5),
      ),
      child: Column(
        children: [
          _buildNotifRow(
            icon: Icons.notifications_outlined,
            iconBg: AppColors.green50,
            iconColor: AppColors.green600,
            title: 'Pengingat minum',
            subtitle: '15 menit sebelum jadwal',
            value: _notifMinum,
            onChanged: (v) => setState(() => _notifMinum = v),
          ),
          Divider(height: 0.5, color: AppColors.slate50),
          _buildNotifRow(
            icon: Icons.warning_amber_outlined,
            iconBg: AppColors.amber50,
            iconColor: AppColors.amber600,
            title: 'Peringatan stok',
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.slate800)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.slate400)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: AppColors.slate900,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: AppColors.slate100,
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Text(text,
          style: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700,
              color: AppColors.slate400, letterSpacing: 0.8)),
    );
  }
}
