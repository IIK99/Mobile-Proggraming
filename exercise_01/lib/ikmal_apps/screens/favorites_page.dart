import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/news_model.dart';
import '../widgets/app_image.dart';
import 'detail_page.dart';

/// Halaman Daftar Berita Favorit untuk Ikmal_apps
/// Menampilkan artikel-artikel yang telah ditandai sebagai favorit oleh pengguna.
class IkmalFavoritesPage extends StatefulWidget {
  final bool isTab;

  const IkmalFavoritesPage({
    super.key,
    this.isTab = false,
  });

  @override
  State<IkmalFavoritesPage> createState() => _IkmalFavoritesPageState();
}

class _IkmalFavoritesPageState extends State<IkmalFavoritesPage> {
  List<NewsModel> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper.instance.getFavoriteNews();
    setState(() {
      _favorites = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bodyContent = _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _favorites.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 70,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Belum ada berita favorit',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Buka salah satu berita di Dashboard lalu klik tombol "Tambah ke Favorit".',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _favorites.length,
                itemBuilder: (context, index) {
                  final item = _favorites[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(10),
                      leading: AppImage(
                        imagePath: item.gambar,
                        width: 65,
                        height: 65,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      title: Text(
                        item.judul,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${item.kategori} • ${item.tanggal}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      trailing: const Icon(
                        Icons.favorite,
                        color: Colors.redAccent,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => IkmalDetailPage(
                              news: item,
                              onFavoriteChanged: _loadFavorites,
                            ),
                          ),
                        ).then((_) => _loadFavorites());
                      },
                    ),
                  );
                },
              );

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      // Hanya tampilkan AppBar jika dibuka standalone (bukan sebagai tab di dalam Dashboard)
      appBar: widget.isTab
          ? null
          : AppBar(
              title: const Text(
                'Berita Favorit Saya',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
            ),
      body: bodyContent,
    );
  }
}
