import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/user_model.dart';
import '../services/supabase_service.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _showPass = false;
  bool _isLoading = false;
  String? _errorText;

  Future<void> _masuk() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      setState(() => _errorText = 'Email dan kata sandi harus diisi');
      return;
    }
    if (!email.contains('@')) {
      setState(() => _errorText = 'Format email tidak valid');
      return;
    }
    if (pass.length < 6) {
      setState(() => _errorText = 'Kata sandi minimal 6 karakter');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final akunDb = await fetchUserByEmail(email);

      if (akunDb != null) {
        // Email sudah terdaftar -> password WAJIB cocok
        final passwordTersimpan = await getPasswordDariDB(email);
        if (passwordTersimpan != pass) {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
            _errorText = 'Email atau kata sandi salah';
          });
          return;
        }
        await simpanAkunLogin(email);
      } else {
        // Email belum ada -> daftar akun baru dengan password ini
        final berhasil = await tambahAkunTanpaLogin(email, pass);
        if (!berhasil) {
          if (!mounted) return;
          setState(() {
            _isLoading = false;
            _errorText = 'Gagal membuat akun, coba lagi';
          });
          return;
        }
        await simpanAkunLogin(email);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorText = 'Terjadi kesalahan, coba lagi';
      });
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const MainNavigation()));
  }

  void _masukDenganAkun(UserAccount akun) {
    simpanAkunLogin(akun.email, nama: akun.nama);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (_) => const MainNavigation()));
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD1D5DB),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            // Logo
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.slate800,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 10),
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Medi',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.slate800),
                      ),
                      TextSpan(
                        text: 'Care',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.purple400),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text('Pengingat Obat & Keluarga',
                style: TextStyle(fontSize: 13, color: AppColors.slate600)),
            const SizedBox(height: 24),
            // Card login
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Daftar Akun',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.slate800)),
                          const SizedBox(height: 4),
                          const Text('Gunakan email & kata sandi',
                              style: TextStyle(
                                  fontSize: 13, color: AppColors.slate400)),
                          const SizedBox(height: 20),
                          const Text('EMAIL',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.slate600,
                                  letterSpacing: 0.5)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: 'contoh@gmail.com',
                              hintStyle: const TextStyle(
                                  color: AppColors.slate400, fontSize: 14),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: AppColors.slate100),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: AppColors.slate100),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: AppColors.slate800),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text('KATA SANDI',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.slate600,
                                  letterSpacing: 0.5)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _passCtrl,
                            obscureText: !_showPass,
                            decoration: InputDecoration(
                              hintText: 'Masukan sandi (minimal 6 karakter)',
                              hintStyle: const TextStyle(
                                  color: AppColors.slate400, fontSize: 14),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _showPass
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: AppColors.slate400,
                                  size: 20,
                                ),
                                onPressed: () =>
                                    setState(() => _showPass = !_showPass),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: AppColors.slate100),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: AppColors.slate100),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide:
                                    const BorderSide(color: AppColors.slate800),
                              ),
                            ),
                          ),
                          if (_errorText != null) ...[
                            const SizedBox(height: 8),
                            Text(_errorText!,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.red400,
                                    fontWeight: FontWeight.w600)),
                          ],
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _masuk,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.slate800,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Text('MASUK',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (akunTerakhirLogin != null) ...[
                      const SizedBox(height: 16),
                      const Text('atau masuk dengan akun yang tersimpan',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.slate600)),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () => _masukDenganAkun(akunTerakhirLogin!),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppColors.slate800,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    akunTerakhirLogin!.inisial,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(akunTerakhirLogin!.nama,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.slate800)),
                                    const SizedBox(height: 2),
                                    Text(akunTerakhirLogin!.email,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.slate400)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right,
                                  color: AppColors.slate400),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}