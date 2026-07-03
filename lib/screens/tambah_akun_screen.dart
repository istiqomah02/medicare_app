import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/user_model.dart';

class TambahAkunScreen extends StatelessWidget {
  const TambahAkunScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  const _SectionLabel(text: 'AKUN TERSIMPAN'),
                  _buildDaftarAkun(context),
                  const SizedBox(height: 20),
                  _buildTambahBaru(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(4, 6, 20, 14),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 20, color: AppColors.slate800),
          ),
          const SizedBox(width: 4),
          const Text('Pilih Akun',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.slate800,
                  letterSpacing: -0.4)),
        ],
      ),
    );
  }

  Widget _buildDaftarAkun(BuildContext context) {
    return ValueListenableBuilder<List<UserAccount>>(
      valueListenable: daftarAkunNotifier,
      builder: (context, daftar, _) {
        return ValueListenableBuilder<UserAccount?>(
          valueListenable: currentUserNotifier,
          builder: (context, akunAktif, _) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.slate100, width: 0.5),
              ),
              child: Column(
                children: daftar.asMap().entries.map((entry) {
                  final i = entry.key;
                  final akun = entry.value;
                  final isLast = i == daftar.length - 1;
                  final aktif = akunAktif != null &&
                      akunAktif.email.toLowerCase() ==
                          akun.email.toLowerCase();

                  return Column(
                    children: [
                      InkWell(
                        onTap: aktif
                            ? null
                            : () async {
                                await simpanAkunLogin(akun.email);
                                if (context.mounted) Navigator.pop(context);
                              },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
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
                                  child: Text(akun.inisial,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(akun.nama,
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.slate800)),
                                    const SizedBox(height: 2),
                                    Text(akun.email,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.slate400)),
                                  ],
                                ),
                              ),
                              if (aktif)
                                const Icon(Icons.check_circle_rounded,
                                    color: AppColors.slate800, size: 20)
                              else
                                const Icon(Icons.chevron_right,
                                    color: AppColors.slate400),
                            ],
                          ),
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
          },
        );
      },
    );
  }

  Widget _buildTambahBaru(BuildContext context) {
    return InkWell(
      onTap: () => _showTambahAkunDialog(context),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.slate100, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.slate100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add_rounded,
                  color: AppColors.slate800, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Tambah Akun Baru',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate800)),
            ),
            const Icon(Icons.chevron_right, color: AppColors.slate400),
          ],
        ),
      ),
    );
  }

  void _showTambahAkunDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const _TambahAkunDialog(),
    );
  }
}

class _TambahAkunDialog extends StatefulWidget {
  const _TambahAkunDialog();

  @override
  State<_TambahAkunDialog> createState() => _TambahAkunDialogState();
}

class _TambahAkunDialogState extends State<_TambahAkunDialog> {
  final _emailCon = TextEditingController();
  final _sandiCon = TextEditingController();
  bool _showSandi = false;
  bool _isLoading = false;
  String? _errorText;

  // Dijadikan async karena tambahAkunTanpaLogin sekarang Future
  Future<void> _simpan() async {
    final email = _emailCon.text.trim();
    final sandi = _sandiCon.text.trim();

    if (email.isEmpty || sandi.isEmpty) {
      setState(() => _errorText = 'Email dan kata sandi harus diisi');
      return;
    }
    if (!email.contains('@')) {
      setState(() => _errorText = 'Format email tidak valid');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    final berhasil = await tambahAkunTanpaLogin(email, sandi);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (!berhasil) {
      setState(() => _errorText = 'Akun dengan email ini sudah ada');
      return;
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Akun berhasil ditambahkan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.slate800,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.person_add_alt_1_rounded,
                      color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text('Tambah Akun Baru',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.slate800)),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close_rounded,
                      color: AppColors.slate400, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Masukkan email & kata sandi akun keluarga yang ingin ditambahkan',
              style: TextStyle(
                  fontSize: 12.5, color: AppColors.slate400, height: 1.4),
            ),
            const SizedBox(height: 18),
            _buildLabel('EMAIL'),
            const SizedBox(height: 6),
            _buildBoxedField(
              child: TextField(
                controller: _emailCon,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate800),
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: 'contoh@gmail.com',
                  hintStyle: TextStyle(color: AppColors.slate400),
                ),
              ),
            ),
            const SizedBox(height: 14),
            _buildLabel('KATA SANDI'),
            const SizedBox(height: 6),
            _buildBoxedField(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _sandiCon,
                      obscureText: !_showSandi,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.slate800),
                      decoration: const InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: 'Masukkan sandi',
                        hintStyle: TextStyle(color: AppColors.slate400),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _showSandi = !_showSandi),
                    child: Icon(
                      _showSandi
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: AppColors.slate400,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 10),
              Text(_errorText!,
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.red400,
                      fontWeight: FontWeight.w600)),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.slate800,
                      side: const BorderSide(color: AppColors.slate100),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Batal',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _simpan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.slate800,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Simpan',
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 13)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(text,
      style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: AppColors.slate400,
          letterSpacing: 0.6));

  Widget _buildBoxedField({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.slate100, width: 1),
      ),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.slate400,
              letterSpacing: 0.8)),
    );
  }
}