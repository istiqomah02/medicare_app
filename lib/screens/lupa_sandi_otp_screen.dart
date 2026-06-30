import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/user_model.dart';
import 'lupa_sandi_password_baru_screen.dart';

class LupaSandiOtpScreen extends StatefulWidget {
  final String email;
  final String kodeSimulasi; // ditampilkan sebagai simulasi "kode terkirim"

  const LupaSandiOtpScreen({
    super.key,
    required this.email,
    required this.kodeSimulasi,
  });

  @override
  State<LupaSandiOtpScreen> createState() => _LupaSandiOtpScreenState();
}

class _LupaSandiOtpScreenState extends State<LupaSandiOtpScreen> {
  final _otpCon = TextEditingController();
  bool _loading = false;

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _verifikasi() async {
    final kode = _otpCon.text.trim();
    if (kode.isEmpty) {
      _snack('Kode verifikasi tidak boleh kosong');
      return;
    }

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => _loading = false);

    if (!verifikasiOtp(widget.email, kode)) {
      if (!mounted) return;
      _snack('Kode verifikasi salah');
      return;
    }

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LupaSandiPasswordBaruScreen(email: widget.email),
      ),
    );
  }

  void _kirimUlang() {
    final kodeBaru = generateOtp(widget.email);
    _snack('Kode baru: $kodeBaru (simulasi)');
    setState(() {}); // refresh tampilan kode simulasi
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
        title: const Text('Verifikasi Kode',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.slate800)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: AppColors.slate800,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.lock_clock_rounded, color: Colors.white, size: 30),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Kode verifikasi telah dikirim ke\n${widget.email}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.slate400, height: 1.4),
            ),

            // ── Banner simulasi: tampilkan kode langsung (karena belum ada email service asli) ──
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF6DD),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE8D48A), width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF8A6D1F)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Mode simulasi — kode kamu: ${widget.kodeSimulasi}',
                      style: const TextStyle(
                        fontSize: 12.5, color: Color(0xFF8A6D1F), fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.slate100, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('KODE VERIFIKASI',
                      style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700,
                        color: AppColors.slate400, letterSpacing: 0.6)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _otpCon,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700,
                      color: AppColors.slate800, letterSpacing: 4),
                    decoration: const InputDecoration(
                      counterText: '',
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      hintText: '------',
                      hintStyle: TextStyle(color: AppColors.slate400, letterSpacing: 4),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),
            Center(
              child: TextButton(
                onPressed: _kirimUlang,
                child: const Text('Kirim Ulang Kode',
                    style: TextStyle(
                      color: AppColors.slate800, fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ),

            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _verifikasi,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.slate800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _loading
                    ? const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2, color: Colors.white),
                      )
                    : const Text('Verifikasi',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}