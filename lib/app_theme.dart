import 'package:flutter/material.dart';

class AppColors {
  // Slate
  static const Color slate50 = Color(0xFFF7F9FC);
  static const Color slate100 = Color(0xFFE2E8F0);
  static const Color slate400 = Color(0xFFA0AEC0);
  static const Color slate600 = Color(0xFF718096);
  static const Color slate800 = Color(0xFF2D3748);
  static const Color slate900 = Color(0xFF4A5568);

  // Purple (Keluarga accent)
  static const Color purple50 = Color(0xFFEEEDFE);
  static const Color purple200 = Color(0xFFAFA9EC);
  static const Color purple400 = Color(0xFF7F77DD);
  static const Color purple600 = Color(0xFF534AB7);
  static const Color purple900 = Color(0xFF26215C);

  // Green (Sudah / stok aman)
  static const Color green50 = Color(0xFFEAF3DE);
  static const Color green400 = Color(0xFF639922);
  static const Color green600 = Color(0xFF3B6D11);

  // Amber (Belum / tunda)
  static const Color amber50 = Color(0xFFFAEEDA);
  static const Color amber400 = Color(0xFFBA7517);
  static const Color amber600 = Color(0xFF854F0B);

  // Red (Terlewat / stok habis)
  static const Color red50 = Color(0xFFFCEBEB);
  static const Color red200 = Color(0xFFF09595);
  static const Color red400 = Color(0xFFE24B4A);
  static const Color red700 = Color(0xFFA32D2D);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: false,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: AppColors.slate50,
      colorScheme: const ColorScheme.light(
        primary: AppColors.slate900,
        secondary: AppColors.purple400,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.slate800,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.slate800,
          letterSpacing: -0.4,
        ),
      ),
    );
  }
}
