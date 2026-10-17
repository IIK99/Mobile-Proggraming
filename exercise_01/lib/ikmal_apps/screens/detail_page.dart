import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/news_model.dart';
import '../widgets/app_image.dart';
import '../widgets/app_toast.dart';

/// Halaman Detail Berita untuk Ikmal_apps
/// Menampilkan gambar (AppImage), judul, konten, metadata, serta aksi tombol favorit.
class IkmalDetailPage extends StatefulWidget {
  final NewsModel news;
  final VoidCallback? onFavoriteChanged;

  const IkmalDetailPage({
    super.key,
    required this.news,
    this.onFavoriteChanged,
  });

  @override
  State<IkmalDetailPage> createState() => _IkmalDetailPageState();
}

class _IkmalDetailPageState extends State<IkmalDetailPage> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.news.isFavorite;
  }

  /// Menampilkan AlertDialog konfirmasi ("Yakin ingin menambahkan ke favorit?")
  void _showConfirmFavoriteDialog() {
    final bool newFavoriteStatus = !_isFavorite;
    final String actionText = newFavoriteStatus
        ? 'Yakin ingin menambahkan ke favorit?'
        : 'Yakin ingin menghapus dari favorit?';

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                newFavoriteStatus ? Icons.favorite : Icons.favorite_border,
                color: Colors.redAccent,
              ),
              const SizedBox(width: 8),
              const Text('Konfirmasi'),
            ],
          ),
          content: Text(
            actionText,
            style: const TextStyle(fontSize: 15),
          ),
          actions: [
            // Pilihan BATAL
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            // Pilihan YA
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _toggleFavorite(newFavoriteStatus);
              },
              child: const Text('Ya'),
            ),
          ],
        );
      },
    );
  }

  /// Menjalankan pembaruan data favorit ke database SQLite & menampilkan notifikasi tunggal
  Future<void> _toggleFavorite(bool status) async {
    if (widget.news.id != null) {
      await DatabaseHelper.instance.toggleFavorite(widget.news.id!, status);
    }

    setState(() {
      _isFavorite = status;
    });

    if (widget.onFavoriteChanged != null) {
      widget.onFavoriteChanged!();
    }

    final String message = status
        ? 'Berita berhasil ditambahkan ke favorit!'
        : 'Berita telah dihapus dari daftar favorit.';

    // Notifikasi melayang bersih gaya login
    if (mounted) {
      AppToast.show(context, message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Detail Berita',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.redAccent : Colors.white,
            ),
            tooltip: _isFavorite ? 'Hapus dari Favorit' : 'Tambah ke Favorit',
            onPressed: _showConfirmFavoriteDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =============================================================
            // Gambar Utama dari Asset Lokal maupun Browsed File
            // =============================================================
            AppImage(
              imagePath: widget.news.gambar,
              width: double.infinity,
              height: 240,
              fit: BoxFit.cover,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informasi Tambahan (Kategori, Tanggal, Penulis)
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.news.kategori,
                          style: const TextStyle(
                            color: Colors.blueAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        widget.news.tanggal,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Penulis Berita
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.blueAccent,
                        child: Icon(Icons.person, size: 14, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Oleh: ${widget.news.penulis}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 28),

                  // Judul Berita
                  Text(
                    widget.news.judul,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Deskripsi/Isi Berita Lengkap
                  Text(
                    widget.news.isi,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF334155),
                      height: 1.6,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Tombol Aksi Tambah ke Favorit dengan Konfirmasi
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _showConfirmFavoriteDialog,
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.white,
                      ),
                      label: Text(
                        _isFavorite
                            ? 'HAPUS DARI FAVORIT'
                            : 'TAMBAH KE FAVORIT',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isFavorite
                            ? Colors.redAccent
                            : Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
