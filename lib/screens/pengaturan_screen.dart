import 'dart:io' show File;
import 'dart:typed_data' show Uint8List;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/user_model.dart';
import 'login_screen.dart';
import 'edit_profil_screen.dart';
import 'ubah_kata_sandi_screen.dart';
import 'kelola_akun_screen.dart';

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
                  _buildProfilCard(context),
                  const SizedBox(height: 4),
                  _buildAkunCard(context),
                  const SizedBox(height: 4),
                  _buildNotifCard(),
                  const SizedBox(height: 4),
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
<<<<<<< HEAD
      child: const Text('Pengaturan',
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.slate800,
              letterSpacing: -0.4)),
=======
      child: const Text(
        'Pengaturan',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.slate800,
          letterSpacing: -0.4,
        ),
      ),
>>>>>>> fd75939c4a7ac12299f63ac3c5805c9b4d479688
    );
  }

  Widget _buildProfilCard(BuildContext context) {
    return ValueListenableBuilder<UserAccount?>(
      valueListenable: currentUserNotifier,
      builder: (context, akun, _) {
        final nama  = akun?.nama    ?? 'Tamu';
        final email = akun?.email   ?? '-';
        final inisial = akun?.inisial ?? '?';
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditProfilScreen()),
          ),
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
<<<<<<< HEAD
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
=======
                ValueListenableBuilder<String?>(
                  valueListenable: fotoProfilNotifier,
                  builder: (_, path, __) {
                    return ValueListenableBuilder<Uint8List?>(
                      valueListenable: fotoProfilBytesNotifier,
                      builder: (_, bytes, __) {
                        ImageProvider? provider;
                        if (kIsWeb) {
                          if (bytes != null) provider = MemoryImage(bytes);
                        } else {
                          if (path != null) provider = FileImage(File(path));
                        }
                        return Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.slate800,
                            borderRadius: BorderRadius.circular(12),
                            image: provider != null
                                ? DecorationImage(image: provider, fit: BoxFit.cover)
                                : null,
                          ),
                          child: provider == null
                              ? Center(
                                  child: Text(inisial,
                                      style: const TextStyle(
                                        color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)))
                              : null,
                        );
                      },
                    );
                  },
>>>>>>> fd75939c4a7ac12299f63ac3c5805c9b4d479688
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(nama,
                          style: const TextStyle(
<<<<<<< HEAD
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.slate800)),
                      const SizedBox(height: 2),
                      Text(email,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.slate400)),
=======
                            fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.slate800)),
                      const SizedBox(height: 2),
                      Text(email,
                          style: const TextStyle(fontSize: 12, color: AppColors.slate400)),
>>>>>>> fd75939c4a7ac12299f63ac3c5805c9b4d479688
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

  Widget _buildAkunCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.slate100, width: 0.5),
      ),
      child: Column(
        children: [
          _buildMenuRow(
            icon: Icons.lock_outline_rounded,
            iconBg: const Color(0xFF7EA8D8),
            title: 'Ubah Kata Sandi',
            sub: 'Ganti kata sandi akun Anda',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UbahKataSandiScreen()),
            ),
          ),
          const Divider(height: 0.5, indent: 16, endIndent: 16, color: AppColors.slate100),
          _buildMenuRow(
            icon: Icons.manage_accounts_rounded,
            iconBg: const Color(0xFFB5C99A),
            title: 'Kelola Akun',
            sub: 'Akun tersimpan & profil',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const KelolaAkunScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuRow({
    required IconData icon,
    required Color iconBg,
    required String title,
    required String sub,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.slate800)),
                  const SizedBox(height: 2),
                  Text(sub, style: const TextStyle(fontSize: 12, color: AppColors.slate400)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.slate400),
          ],
        ),
      ),
    );
  }

  Widget _buildNotifCard() {
    final items = [
      _NotifItem(icon: Icons.notifications_rounded, color: const Color(0xFFB5C99A),
          title: 'Pengingat Minum Obat', sub: '15 menit sebelumnya'),
      _NotifItem(icon: Icons.priority_high_rounded, color: const Color(0xFFD4B96A),
          title: 'Pengingat Stok Abis', sub: 'Saat stok < 7 hari'),
      _NotifItem(icon: Icons.people_alt_rounded, color: AppColors.purple200,
          title: 'Notifikasi Keluarga', sub: 'Update status anggota'),
    ];
    return _NotifikasiCard(items: items);
  }

  Widget _buildKeluar(BuildContext context) {
    return GestureDetector(
      onTap: () => _showKonfirmasiKeluar(context),
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
<<<<<<< HEAD
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.red200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout_rounded,
                  color: Colors.white, size: 20),
=======
              width: 40, height: 40,
              decoration: BoxDecoration(color: AppColors.red200, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
>>>>>>> fd75939c4a7ac12299f63ac3c5805c9b4d479688
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('KELUAR',
                  style: TextStyle(
<<<<<<< HEAD
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.red400,
                      letterSpacing: 0.5)),
=======
                    fontSize: 15, fontWeight: FontWeight.w700,
                    color: AppColors.red400, letterSpacing: 0.5)),
>>>>>>> fd75939c4a7ac12299f63ac3c5805c9b4d479688
            ),
            const Icon(Icons.chevron_right, color: AppColors.red400),
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
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
=======
  void _showKonfirmasiKeluar(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Yakin mau keluar?',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.slate800)),
        content: const Text(
          'Kamu perlu masuk lagi untuk mengakses akun ini.',
          style: TextStyle(fontSize: 13, color: AppColors.slate400),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        actions: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.slate800,
                side: const BorderSide(color: AppColors.slate100),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Batal',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // tutup dialog dulu
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.red400,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Ya, Keluar',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            ),
          ),
        ],
      ),
>>>>>>> fd75939c4a7ac12299f63ac3c5805c9b4d479688
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
          final i    = entry.key;
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
                          color: item.color, borderRadius: BorderRadius.circular(10)),
                      child: Icon(item.icon, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title,
                              style: const TextStyle(
<<<<<<< HEAD
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.slate800)),
=======
                                fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.slate800)),
>>>>>>> fd75939c4a7ac12299f63ac3c5805c9b4d479688
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
