import 'dart:io' show File;
import 'dart:typed_data' show Uint8List;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../app_theme.dart';
import '../models/user_model.dart';

class EditProfilScreen extends StatefulWidget {
  const EditProfilScreen({super.key});

  @override
  State<EditProfilScreen> createState() => _EditProfilScreenState();
}

class _EditProfilScreenState extends State<EditProfilScreen> {
  final _namaController = TextEditingController();

  // Untuk Android/iOS/Desktop: dipakai sebagai path file
  String? _fotoPath;
  // Untuk Web: dipakai sebagai bytes gambar
  Uint8List? _fotoBytes;

  @override
  void initState() {
    super.initState();
    _namaController.text = currentUserNotifier.value?.nama ?? '';
    _fotoPath = fotoProfilNotifier.value;
    _fotoBytes = fotoProfilBytesNotifier.value;
  }

  Future<void> _pilihFoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;

    if (kIsWeb) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _fotoBytes = bytes;
        _fotoPath = picked.path;
      });
      fotoProfilBytesNotifier.value = bytes; // supaya halaman Pengaturan ikut update
    } else {
      setState(() => _fotoPath = picked.path);
    }

    fotoProfilNotifier.value = picked.path;
  }

  ImageProvider? _buildFotoProvider() {
    if (kIsWeb) {
      if (_fotoBytes != null) return MemoryImage(_fotoBytes!);
      return null;
    } else {
      if (_fotoPath != null) return FileImage(File(_fotoPath!));
      return null;
    }
  }

  void _simpan() {
    final nama = _namaController.text.trim();
    if (nama.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Nama tidak boleh kosong')));
      return;
    }

    ubahNamaProfil(nama);

    Navigator.pop(context);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Profil berhasil diperbarui')));
  }

  @override
  Widget build(BuildContext context) {
    final fotoProvider = _buildFotoProvider();

    return Scaffold(
      backgroundColor: AppColors.slate50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.slate800, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Profil',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.slate800)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 8),

            // ── Foto Profil ──
            Center(
              child: GestureDetector(
                onTap: _pilihFoto,
                child: Stack(
                  children: [
                    Container(
                      width: 90, height: 90,
                      decoration: BoxDecoration(
                        color: AppColors.slate800,
                        shape: BoxShape.circle,
                        image: fotoProvider != null
                            ? DecorationImage(image: fotoProvider, fit: BoxFit.cover)
                            : null,
                      ),
                      child: fotoProvider == null
                          ? Center(
                              child: Text(
                                currentUserNotifier.value?.inisial ?? '?',
                                style: const TextStyle(
                                  color: Colors.white, fontSize: 28, fontWeight: FontWeight.w700),
                              ))
                          : null,
                    ),
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.slate800,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: _pilihFoto,
                child: const Text('Ubah Foto Profil',
                    style: TextStyle(
                      color: AppColors.slate800, fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ),

            const SizedBox(height: 20),

            // ── Form Nama ──
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
                  const Text('NAMA',
                      style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700,
                        color: AppColors.slate400, letterSpacing: 0.6)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _namaController,
                    style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.slate800),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      hintText: 'Masukkan nama Anda',
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
                onPressed: _simpan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.slate800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('Simpan Perubahan',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}