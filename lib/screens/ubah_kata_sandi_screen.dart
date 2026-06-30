import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/user_model.dart';
import 'lupa_sandi_email_screen.dart';

class UbahKataSandiScreen extends StatefulWidget {
  const UbahKataSandiScreen({super.key});

  @override
  State<UbahKataSandiScreen> createState() => _UbahKataSandiScreenState();
}

class _UbahKataSandiScreenState extends State<UbahKataSandiScreen> {
  final _lamaCon   = TextEditingController();
  final _baruCon   = TextEditingController();
  final _konfirCon = TextEditingController();

  bool _showLama   = false;
  bool _showBaru   = false;
  bool _showKonfir = false;

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  void _simpan() {
    final lama   = _lamaCon.text.trim();
    final baru   = _baruCon.text.trim();
    final konfir = _konfirCon.text.trim();

    if (lama.isEmpty || baru.isEmpty || konfir.isEmpty) {
      _snack('Semua kolom harus diisi');
      return;
    }

    final akun = currentUserNotifier.value;
    if (akun == null) {
      _snack('Tidak ada akun yang sedang login');
      return;
    }

    if (lama != getPassword(akun.email)) {
      _snack('Kata sandi lama tidak sesuai');
      return;
    }
    if (baru.length < 6) {
      _snack('Kata sandi baru minimal 6 karakter');
      return;
    }
    if (baru != konfir) {
      _snack('Konfirmasi kata sandi tidak cocok');
      return;
    }

    ubahPassword(akun.email, baru);

    Navigator.pop(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Kata sandi berhasil diubah')));
  }

  void _lupaKataSandi() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LupaSandiEmailScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.slate800, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Ubah Kata Sandi',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.slate800)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 8),

            // ── Kartu 1: Kata Sandi Lama ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.slate100, width: 0.5),
              ),
              child: Column(
                children: [
                  _buildField(
                    label: 'Kata Sandi Lama',
                    controller: _lamaCon,
                    show: _showLama,
                    onToggle: () => setState(() => _showLama = !_showLama),
                    showDivider: false,
                  ),
                ],
              ),
            ),

            // ── Link "Lupa kata sandi?" di antara 2 kartu ──
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _lupaKataSandi,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Lupa kata sandi?',
                    style: TextStyle(
                      color: AppColors.slate800,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                    )),
              ),
            ),

            const SizedBox(height: 4),

            // ── Kartu 2: Kata Sandi Baru + Konfirmasi ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.slate100, width: 0.5),
              ),
              child: Column(
                children: [
                  _buildField(
                    label: 'Kata Sandi Baru',
                    controller: _baruCon,
                    show: _showBaru,
                    onToggle: () => setState(() => _showBaru = !_showBaru),
                    showDivider: true,
                  ),
                  _buildField(
                    label: 'Konfirmasi Kata Sandi Baru',
                    controller: _konfirCon,
                    show: _showKonfir,
                    onToggle: () => setState(() => _showKonfir = !_showKonfir),
                    showDivider: false,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _simpan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.slate800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Simpan',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required bool show,
    required VoidCallback onToggle,
    required bool showDivider,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 14),
          child: Text(label,
              style: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700,
                color: AppColors.slate400, letterSpacing: 0.6)),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                obscureText: !show,
                style: const TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.slate800),
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                  border: InputBorder.none,
                  hintText: '••••••••',
                  hintStyle: TextStyle(color: AppColors.slate400),
                ),
              ),
            ),
            GestureDetector(
              onTap: onToggle,
              child: Icon(
                show ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: AppColors.slate400, size: 18),
            ),
          ],
        ),
        if (showDivider) const Divider(height: 1, color: AppColors.slate100)
        else const SizedBox(height: 14),
      ],
    );
  }
}