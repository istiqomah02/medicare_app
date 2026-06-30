import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/user_model.dart';
import 'login_screen.dart';

class LupaSandiPasswordBaruScreen extends StatefulWidget {
  final String email;
  const LupaSandiPasswordBaruScreen({super.key, required this.email});

  @override
  State<LupaSandiPasswordBaruScreen> createState() =>
      _LupaSandiPasswordBaruScreenState();
}

class _LupaSandiPasswordBaruScreenState
    extends State<LupaSandiPasswordBaruScreen> {
  final _baruCon   = TextEditingController();
  final _konfirCon = TextEditingController();

  bool _showBaru   = false;
  bool _showKonfir = false;

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  void _simpan() {
    final baru   = _baruCon.text.trim();
    final konfir = _konfirCon.text.trim();

    if (baru.isEmpty || konfir.isEmpty) {
      _snack('Semua kolom harus diisi');
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

    resetPasswordViaOtp(widget.email, baru);

    // Kembali sampai ke halaman Login, supaya user login ulang dengan password baru
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kata sandi berhasil direset, silakan login kembali')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Buat Kata Sandi Baru',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.slate800)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 8),
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
                child: const Text('Simpan Kata Sandi Baru',
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