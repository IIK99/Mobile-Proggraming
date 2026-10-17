import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/app_toast.dart';
import 'login_page.dart';

/// Halaman Profil Pengguna pada Ikmal_apps
/// Menampilkan identitas pengguna yang sedang login dan fitur ganti foto profil
/// yang tersimpan secara permanen (persistent) menggunakan SharedPreferences.
class IkmalProfilePage extends StatefulWidget {
  final String username;
  final String namaLengkap;
  final bool isTab;
  final VoidCallback? onProfileUpdated;

  const IkmalProfilePage({
    super.key,
    required this.username,
    required this.namaLengkap,
    this.isTab = false,
    this.onProfileUpdated,
  });

  @override
  State<IkmalProfilePage> createState() => _IkmalProfilePageState();
}

class _IkmalProfilePageState extends State<IkmalProfilePage> {
  String? _profileBase64;
  bool _isLoadingPhoto = true;

  String get _storageKey =>
      'profile_photo_${widget.username.trim().toLowerCase()}';

  @override
  void initState() {
    super.initState();
    _loadSavedProfilePhoto();
  }

  /// Memuat foto profil yang tersimpan dari SharedPreferences agar tidak hilang saat ganti tab/logout
  Future<void> _loadSavedProfilePhoto() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_storageKey);
      if (saved != null && mounted) {
        setState(() {
          _profileBase64 = saved;
        });
      }
    } catch (e) {
      debugPrint('Error loading saved profile photo: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPhoto = false;
        });
      }
    }
  }

  /// Memilih dan mengganti foto profil dari galeri serta menyimpannya secara permanen
  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    // Kompresi resolusi agar hemat memori, cepat dimuat, dan aman disimpan di SharedPreferences
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 600,
      maxHeight: 600,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    final bytes = await pickedFile.readAsBytes();
    final base64String = base64Encode(bytes);

    // 1. Simpan ke SharedPreferences secara persisten dengan kunci username normalisasi
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, base64String);
    } catch (e) {
      debugPrint('Gagal menyimpan foto profil ke prefs: $e');
    }

    // 2. Salin ke folder assets/images/ secara otomatis jika di Desktop/Mobile
    if (!kIsWeb) {
      final possibleDirs = [
        Directory(r'i:\Mobile Proggraming\exercise_01\assets\images'),
        Directory('assets/images'),
        Directory('${Directory.current.path}/assets/images'),
      ];
      for (final dir in possibleDirs) {
        try {
          if (!dir.existsSync()) {
            dir.createSync(recursive: true);
          }
          final dest = File('${dir.path}/profile_${pickedFile.name}');
          await File(pickedFile.path).copy(dest.path);
        } catch (e) {
          debugPrint('Catatan salin foto profil ke ${dir.path}: $e');
        }
      }
    }

    setState(() {
      _profileBase64 = base64String;
    });

    // Panggil callback agar header Dashboard juga langsung diperbarui tanpa delay
    widget.onProfileUpdated?.call();

    if (mounted) {
      AppToast.show(context, 'Foto profil berhasil diperbarui dan tersimpan!');
    }
  }

  /// Menghapus foto profil dan mengembalikan avatar ke ikon default.
  Future<void> _deleteProfilePhoto() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Foto Profil'),
        content: const Text(
          'Foto profil akan dihapus dan diganti dengan avatar default. Lanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);

      if (!mounted) return;
      setState(() {
        _profileBase64 = null;
      });

      widget.onProfileUpdated?.call();
      AppToast.show(context, 'Foto profil berhasil dihapus.');
    } catch (e) {
      debugPrint('Gagal menghapus foto profil: $e');
      if (mounted) {
        AppToast.show(context, 'Foto profil gagal dihapus.');
      }
    }
  }

  Widget _buildAvatar() {
    ImageProvider? imageProvider;

    if (_profileBase64 != null) {
      try {
        imageProvider = MemoryImage(base64Decode(_profileBase64!));
      } catch (_) {
        imageProvider = null;
      }
    }

    return GestureDetector(
      onTap: _pickProfileImage,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blueAccent, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: imageProvider,
              child: (_isLoadingPhoto || imageProvider == null)
                  ? const Icon(Icons.person, size: 70, color: Colors.blueAccent)
                  : null,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Colors.blueAccent,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      // Hanya tampilkan AppBar jika dibuka standalone (bukan sebagai tab di dalam Dashboard)
      appBar: widget.isTab
          ? null
          : AppBar(
              title: const Text(
                'Profil Pengguna',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
            ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Avatar Profil Pengguna (bisa diklik untuk ganti foto)
            Center(child: _buildAvatar()),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: _pickProfileImage,
              icon: const Icon(Icons.photo_camera, size: 18),
              label: const Text('Ganti Foto Profil'),
            ),
            if (_profileBase64 != null) ...[
              TextButton.icon(
                onPressed: _deleteProfilePhoto,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Hapus Foto Profil'),
                style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
              ),
            ],
            const SizedBox(height: 10),
            Text(
              widget.namaLengkap.isNotEmpty
                  ? widget.namaLengkap
                  : widget.username,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '@${widget.username}',
              style: const TextStyle(fontSize: 15, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // Kartu Informasi Akun
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.badge,
                        color: Colors.blueAccent,
                      ),
                      title: const Text('Nama Lengkap'),
                      subtitle: Text(
                        widget.namaLengkap.isNotEmpty
                            ? widget.namaLengkap
                            : '-',
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(
                        Icons.person_pin,
                        color: Colors.blueAccent,
                      ),
                      title: const Text('Username'),
                      subtitle: Text(widget.username),
                    ),
                    const Divider(),
                    const ListTile(
                      leading: Icon(Icons.apps, color: Colors.blueAccent),
                      title: Text('Nama Aplikasi'),
                      subtitle: Text('Ikmal_apps (Portal Berita)'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Tombol Logout
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: const Text('Konfirmasi Logout'),
                      content: const Text(
                        'Apakah Anda yakin ingin keluar dari Ikmal_apps?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Batal'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pop(ctx);
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const IkmalLoginPage(),
                              ),
                              (route) => false,
                            );
                          },
                          child: const Text('Logout'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('LOGOUT / KELUAR'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
