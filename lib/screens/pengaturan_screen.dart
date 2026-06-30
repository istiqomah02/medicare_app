import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/user_model.dart';
import 'login_screen.dart';
import 'tambah_akun_screen.dart';

class PengaturanScreen extends StatelessWidget {
  const PengaturanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 32),
                children: [
                  const SizedBox(height: 12),
                  _buildProfilCard(),
                  const _SectionLabel(text: 'NOTIFIKASI'),
                  _buildNotifCard(),
                  const SizedBox(height: 12),
                  _buildKeluar(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
      child: const Text('Pengaturan',
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.slate800,
              letterSpacing: -0.4)),
    );
  }

  /// Dibungkus ValueListenableBuilder agar otomatis re-render setiap kali
  /// currentUserNotifier berubah (mis. setelah simpanAkunLogin dipanggil
  /// di login_screen.dart untuk akun lain).
  Widget _buildProfilCard() {
    return ValueListenableBuilder<UserAccount?>(
      valueListenable: currentUserNotifier,
      builder: (context, akun, _) {
        final nama = akun?.nama ?? 'Tamu';
        final email = akun?.email ?? '-';
        final inisial = akun?.inisial ?? '?';
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TambahAkunScreen()),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.slate100, width: 0.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.slate800,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(inisial,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nama,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.slate800)),
                      const SizedBox(height: 2),
                      Text(email,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.slate400)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: AppColors.slate400),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotifCard() {
    final items = [
      _NotifItem(
        icon: Icons.notifications_rounded,
        color: const Color(0xFFB5C99A),
        title: 'Pengingat Minum Obat',
        sub: '15 menit sebelumnya',
      ),
      _NotifItem(
        icon: Icons.priority_high_rounded,
        color: const Color(0xFFD4B96A),
        title: 'Pengingat Stok Abis',
        sub: 'Saat stok < 7 hari',
      ),
      _NotifItem(
        icon: Icons.people_alt_rounded,
        color: AppColors.purple200,
        title: 'Notifikasi Keluarga',
        sub: 'Update status anggota',
      ),
    ];

    return _NotifikasiCard(items: items);
  }

  Widget _buildKeluar(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFCEBEB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFF09595), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.red200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('KELUAR',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.red400,
                      letterSpacing: 0.5)),
            ),
            const Icon(Icons.chevron_right, color: AppColors.red400),
          ],
        ),
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
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.slate400,
              letterSpacing: 0.8)),
    );
  }
}

class _NotifItem {
  final IconData icon;
  final Color color;
  final String title;
  final String sub;
  _NotifItem(
      {required this.icon,
      required this.color,
      required this.title,
      required this.sub});
}

/// Kartu notifikasi dengan toggle switch yang bisa di-tap (state lokal).
class _NotifikasiCard extends StatefulWidget {
  final List<_NotifItem> items;
  const _NotifikasiCard({required this.items});

  @override
  State<_NotifikasiCard> createState() => _NotifikasiCardState();
}

class _NotifikasiCardState extends State<_NotifikasiCard> {
  late List<bool> _values;

  @override
  void initState() {
    super.initState();
    _values = List.generate(widget.items.length, (_) => true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.slate100, width: 0.5),
      ),
      child: Column(
        children: widget.items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          final isLast = i == widget.items.length - 1;
          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: item.color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.icon, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.slate800)),
                          const SizedBox(height: 2),
                          Text(item.sub,
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.slate400)),
                        ],
                      ),
                    ),
                    Switch(
                      value: _values[i],
                      onChanged: (v) => setState(() => _values[i] = v),
                      activeThumbColor: Colors.white,
                      activeTrackColor: AppColors.slate800,
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: AppColors.slate100,
                    ),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(
                    height: 0.5,
                    indent: 16,
                    endIndent: 16,
                    color: AppColors.slate100),
            ],
          );
        }).toList(),
      ),
    );
  }
}
