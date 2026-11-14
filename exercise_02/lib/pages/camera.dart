import 'dart:io';

import 'package:flutter/foundation.dart'; // Tambahkan ini untuk kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  XFile? foto;
  String status = 'Belum ada foto';
  bool loading = false;

  Future<void> ambilFoto() async {
    try {
      final hasil = await ImagePicker().pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 75,
      );
      if (!mounted) return;
      setState(() {
        foto = hasil;
        status = hasil == null
            ? 'Pengambilan dibatalkan'
            : 'Foto siap diunggah';
      });
    } catch (e) {
      if (mounted) setState(() => status = 'Kamera gagal: $e');
    }
  }

  Future<void> unggah() async {
    if (foto == null || loading) return;

    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) return;

    setState(() => loading = true);
    try {
      final path = '${user.id}/${DateTime.now().microsecondsSinceEpoch}.jpg';
      final bytes = await foto!.readAsBytes();

      // Gunakan uploadBinary agar kompatibel untuk Web maupun Mobile
      await client.storage
          .from('todo-images')
          .uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );
      if (mounted) setState(() => status = 'Upload berhasil!');
    } catch (e) {
      if (mounted) setState(() => status = 'Upload gagal: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (foto != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: kIsWeb
                    ? Image.network(foto!.path, height: 200, fit: BoxFit.cover)
                    : Image.file(
                        File(foto!.path),
                        height: 200,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(height: 12),
            ],
            Text(status, style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: ambilFoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Ambil Foto'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: foto == null || loading ? null : unggah,
              icon: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_upload),
              label: const Text('Upload ke Supabase'),
            ),
          ],
        ),
      ),
    );
  }
}
