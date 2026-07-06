import 'package:flutter/material.dart';
import '../app_theme.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const Color purple50 = Color(0xFFEEEDFE);
  static const Color slate50 = Color(0xFFF7F9FC);

  void _goToLogin(BuildContext context, {required bool isDaftar}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(isDaftar: isDaftar),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: slate50,
      body: Stack(
        children: [
          // Gradasi lembut, sangat halus
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [purple50.withOpacity(0.6), slate50],
                  stops: const [0.0, 0.6],
                ),
              ),
            ),
          ),
          // Aksen blob super samar, biar tidak flat total
          Positioned(
            top: -80,
            right: -70,
            child: _blob(240, AppColors.purple400.withOpacity(0.08)),
          ),
          Positioned(
            bottom: -100,
            left: -80,
            child: _blob(260, AppColors.slate400.withOpacity(0.07)),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  const Spacer(flex: 4),
                  // Logo
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.slate800,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.add,
                        color: Colors.white, size: 36),
                  ),
                  const SizedBox(height: 20),
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Medi',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: AppColors.slate800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        TextSpan(
                          text: 'Care',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: AppColors.purple400,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pengingat Obat & Keluarga',
                    style: TextStyle(fontSize: 13.5, color: AppColors.slate600),
                  ),
                  const Spacer(flex: 5),

                  // Tombol Masuk & Daftar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _goToLogin(context, isDaftar: false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.slate800,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'MASUK',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _goToLogin(context, isDaftar: true),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.slate800,
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        side: const BorderSide(
                            color: AppColors.slate100, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'DAFTAR',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _blob(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}