import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_theme.dart';
import 'models/obat_model.dart';
import 'models/user_model.dart';
import 'screens/splash_screen.dart';
import 'screens/beranda_screen.dart';
import 'screens/jadwal_screen.dart';
import 'screens/riwayat_screen.dart';
import 'screens/pengaturan_screen.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://bgfetforflgfjrcbajyp.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJnZmV0Zm9yZmxnZmpyY2JhanlwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI5ODc5MDYsImV4cCI6MjA5ODU2MzkwNn0.APewImr5TGqhQemDoCgPwMrjP5xiQZq-fBgNtRiK-1s',
  );

  initDummyData();
  await muatAnggotaKeluargaDariDB();
  await muatSemuaAkunDariDB();

  if (daftarAkun.isNotEmpty) {
    akunTerakhirLogin = daftarAkun.first;
    currentUserNotifier.value = daftarAkun.first;
    print('DEBUG main: user aktif = ${daftarAkun.first.email}');
    await muatObatDariDB(daftarAkun.first.email);
  } else {
    await simpanAkunLogin('cahyaniarum@gmail.com', nama: 'Nayla');
    print('DEBUG main: fallback login cahyaniarum@gmail.com');
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MediCareApp());
}

final supabase = Supabase.instance.client;

class MediCareApp extends StatelessWidget {
  const MediCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediCare',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  late final List<Widget> _pages = [
    const BerandaScreen(),
    const JadwalScreen(),
    RiwayatScreen(
      onKembali: () => setState(() => _currentIndex = 0),
    ),
    const PengaturanScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.slate200, width: 0.5),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          selectedItemColor: AppColors.slate800,
          unselectedItemColor: AppColors.slate400,
          backgroundColor: Colors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined),
              activeIcon: Icon(Icons.calendar_today),
              label: 'Jadwal',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Riwayat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Pengaturan',
            ),
          ],
        ),
      ),
    );
  }
}
