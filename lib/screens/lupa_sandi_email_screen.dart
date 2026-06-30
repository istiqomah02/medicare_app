import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/user_model.dart';
import 'lupa_sandi_otp_screen.dart';

class LupaSandiEmailScreen extends StatefulWidget {
  const LupaSandiEmailScreen({super.key});

  @override
  State<LupaSandiEmailScreen> createState() => _LupaSandiEmailScreenState();
}

class _LupaSandiEmailScreenState extends State<LupaSandiEmailScreen> {
  final _emailCon = TextEditingController();
  bool _loading = false;

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> _kirimKode() async {
    final email = _emailCon.text.trim();
    if (email.isEmpty) {
      _snack('Email tidak boleh kosong');
      return;
    }
    if (!email.contains('@')) {
      _snack('Format email tidak valid');
      return;
    }
    if (!emailTerdaftar(email)) {
      _snack('Email tidak terdaftar');
      return;
    }

    setState(() => _loading = true);
    // simulasi delay seolah sedang mengirim email
    await Future.delayed(const Duration(milliseconds: 700));

    final kode = generateOtp(email);
    setState(() => _loading = false);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LupaSandiOtpScreen(email: email, kodeSimulasi: kode),
      ),
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
        title: const Text('Lupa Kata Sandi',
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
                child: const Icon(Icons.mail_outline_rounded, color: Colors.white, size: 30),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Masukkan email akun Anda untuk menerima kode verifikasi',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.slate400, height: 1.4),
            ),
            const SizedBox(height: 28),
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
                  const Text('EMAIL',
                      style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700,
                        color: AppColors.slate400, letterSpacing: 0.6)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailCon,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.slate800),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      hintText: 'nama@email.com',
                      hintStyle: TextStyle(color: AppColors.slate400),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _kirimKode,
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
                    : const Text('Kirim Kode',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}