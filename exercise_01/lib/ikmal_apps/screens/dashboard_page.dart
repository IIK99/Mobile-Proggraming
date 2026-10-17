import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../db/database_helper.dart';
import '../models/news_model.dart';
import 'crud_page.dart';
import 'detail_page.dart';
import 'favorites_page.dart';
import 'profile_page.dart';
import '../widgets/app_image.dart';

/// ===========================================================================
/// HALAMAN DASHBOARD UTAMA (Ikmal_apps)
/// ===========================================================================
/// a. Memiliki Header (AppBar dengan logo & nama aplikasi), Body (konten scrollable),
///    dan Footer (BottomNavigationBar untuk menu navigasi).
/// b. Bagian Body/Dashboard WAJIB DAPAT DI-SCROLL dan WAJIB MENGGUNAKAN StatefulWidget.
///
/// 1. State Dinamis & Asynchronous: Data list berita diambil dari database SQLite lokal
///    secara asynchronous pada metode initState() dan perlu diperbarui melalui setState()
///    setiap kali terjadi perubahan (tambah berita, edit, hapus, atau ubah status favorit).
/// 2. Interaktivitas UI: Pengguna dapat memfilter berita berdasarkan kategori secara
///    real-time, yang mana widget harus merender ulang daftar data terpilih.
/// 3. Navigasi Footer: BottomNavigationBar memerlukan penyimpanan state indeks aktif
///    (_currentBottomIndex) untuk berpindah antara halaman Berita, CRUD, Favorit, dan Profil.
/// ===========================================================================
class IkmalDashboardPage extends StatefulWidget {
  final String username;
  final String namaLengkap;

  const IkmalDashboardPage({
    super.key,
    required this.username,
    required this.namaLengkap,
  });

  @override
  State<IkmalDashboardPage> createState() => _IkmalDashboardPageState();
}

class _IkmalDashboardPageState extends State<IkmalDashboardPage> {
  /// Indeks aktif pada Footer (BottomNavigationBar)
  int _currentBottomIndex = 0;

  /// Daftar seluruh berita dari SQLite
  List<NewsModel> _allNews = [];

  /// Daftar berita yang sedang ditampilkan setelah filter
  List<NewsModel> _filteredNews = [];

  /// Status loading data dari SQLite
  bool _isLoading = true;

  /// Kategori yang sedang dipilih
  String _selectedCategory = 'Semua';

  /// Daftar kategori berita
  final List<String> _categories = [
    'Semua',
    'Lingkungan',
    'Bencana',
    'Internasional',
    'Nasional',
    'Pendidikan',
  ];

  String? _profilePhotoBase64;

  @override
  void initState() {
    super.initState();
    _fetchNewsFromDatabase();
    _loadProfilePhoto();
  }

  /// Memuat foto profil pengguna yang tersimpan di SharedPreferences
  Future<void> _loadProfilePhoto() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'profile_photo_${widget.username.trim().toLowerCase()}';
      final saved = prefs.getString(key);
      if (mounted) {
        setState(() {
          _profilePhotoBase64 = saved;
        });
      }
    } catch (e) {
      debugPrint('Error loading dashboard profile photo: $e');
    }
  }

  /// Mengambil data berita dari SQLite
  Future<void> _fetchNewsFromDatabase() async {
    setState(() {
      _isLoading = true;
    });

    final data = await DatabaseHelper.instance.getAllNews();

    setState(() {
      _allNews = data;
      _applyCategoryFilter(_selectedCategory);
      _isLoading = false;
    });
  }

  /// Memfilter berita berdasarkan kategori
  void _applyCategoryFilter(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'Semua') {
        _filteredNews = List.from(_allNews);
      } else {
        _filteredNews = _allNews
            .where(
              (item) => item.kategori.toLowerCase() == category.toLowerCase(),
            )
            .toList();
      }
    });
  }

  /// =========================================================================
  /// BODY KONTEN UTAMA DASHBOARD (Scrollable)
  /// =========================================================================
  Widget _buildDashboardBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _fetchNewsFromDatabase,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===============================================================
            // Menampilkan identitas pengguna sesuai saat login & foto profil aktif
            // ===============================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blueAccent, Color(0xFF1E88E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white,
                      backgroundImage: _profilePhotoBase64 != null
                          ? MemoryImage(base64Decode(_profilePhotoBase64!))
                          : null,
                      child: _profilePhotoBase64 == null
                          ? const Icon(
                              Icons.person,
                              size: 34,
                              color: Colors.blueAccent,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selamat Datang,',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        Text(
                          widget.namaLengkap.isNotEmpty
                              ? widget.namaLengkap
                              : widget.username,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'User ID: @${widget.username}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    tooltip: 'Segarkan Berita',
                    onPressed: _fetchNewsFromDatabase,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ===============================================================
            // KONTEN HIGHLIGHT / HEADLINE BERITA DARI ASSET LOKAL
            // ===============================================================
            if (_allNews.isNotEmpty) ...[
              const Text(
                'Berita Utama Terkini',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () {
                  // Navigasi ke Halaman Detail menggunakan Navigator.push
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => IkmalDetailPage(
                        news: _allNews.first,
                        onFavoriteChanged: _fetchNewsFromDatabase,
                      ),
                    ),
                  ).then((_) => _fetchNewsFromDatabase());
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        child: AppImage(
                          imagePath: _allNews.first.gambar,
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _allNews.first.kategori.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _allNews.first.judul,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 13,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _allNews.first.penulis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.calendar_today,
                                  size: 13,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _allNews.first.tanggal,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ===============================================================
            // FILTER KATEGORI BERITA
            // ===============================================================
            const Text(
              'Kategori Informasi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: Colors.blueAccent,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onSelected: (_) => _applyCategoryFilter(cat),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // ===============================================================
            // Tampilkan data dalam bentuk list (ListView.builder)
            // menggunakan data dari asset lokal (assets/images/)
            // ===============================================================
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daftar Berita Terbaru',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                Text(
                  '${_filteredNews.length} artikel',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (_filteredNews.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                alignment: Alignment.center,
                child: const Text(
                  'Tidak ada berita dalam kategori ini.',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredNews.length,
                itemBuilder: (context, index) {
                  final newsItem = _filteredNews[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        // Klik Detail menggunakan Navigator.push
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => IkmalDetailPage(
                              news: newsItem,
                              onFavoriteChanged: _fetchNewsFromDatabase,
                            ),
                          ),
                        ).then((_) => _fetchNewsFromDatabase());
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Thumbnail Gambar Berita dari Asset Lokal maupun Browsed File
                            AppImage(
                              imagePath: newsItem.gambar,
                              width: 95,
                              height: 95,
                              fit: BoxFit.cover,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            const SizedBox(width: 12),
                            // Informasi Konten Berita
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blueAccent.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          newsItem.kategori,
                                          style: const TextStyle(
                                            color: Colors.blueAccent,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      if (newsItem.isFavorite)
                                        const Icon(
                                          Icons.favorite,
                                          size: 16,
                                          color: Colors.redAccent,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    newsItem.judul,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 11,
                                        color: Colors.grey.shade600,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        newsItem.tanggal,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Navigasi ke sub-halaman (dengan isTab: true agar tidak ada AppBar ganda)
    final List<Widget> pages = [
      _buildDashboardBody(),
      IkmalCrudPage(onDataChanged: _fetchNewsFromDatabase, isTab: true),
      const IkmalFavoritesPage(isTab: true),
      IkmalProfilePage(
        username: widget.username,
        namaLengkap: widget.namaLengkap,
        isTab: true,
        onProfileUpdated: _loadProfilePhoto,
      ),
    ];

    // Judul AppBar dinamis sesuai tab aktif
    Widget appBarTitle;
    switch (_currentBottomIndex) {
      case 1:
        appBarTitle = const Text(
          'Kelola Data Berita (CRUD)',
          style: TextStyle(fontWeight: FontWeight.bold),
        );
        break;
      case 2:
        appBarTitle = const Text(
          'Berita Favorit Saya',
          style: TextStyle(fontWeight: FontWeight.bold),
        );
        break;
      case 3:
        appBarTitle = const Text(
          'Profil Pengguna',
          style: TextStyle(fontWeight: FontWeight.bold),
        );
        break;
      default:
        appBarTitle = Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                'assets/images/logo.png',
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.newspaper, color: Colors.white),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Ikmal_apps',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      // =====================================================================
      // HEADER TUNGGAL: Tanpa back button keluar folder projek (hanya back di dalam projek)
      // =====================================================================
      appBar: AppBar(
        automaticallyImplyLeading: false, // Menghilangkan tombol back keluar folder projek
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 2,
        title: appBarTitle,
        actions: [
          // Tombol CRUD jika sedang di tab berita
          if (_currentBottomIndex == 0)
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Kelola Berita (CRUD)',
              onPressed: () {
                setState(() {
                  _currentBottomIndex = 1;
                });
              },
            ),
          // Tombol keluar aplikasi menuju folder materi
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Keluar ke Menu Materi',
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),

      body: IndexedStack(
        index: _currentBottomIndex,
        children: pages,
      ),

      // =====================================================================
      // FOOTER / MENU NAVIGASI (BottomNavigationBar)
      // =====================================================================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentBottomIndex,
        onTap: (index) {
          setState(() {
            _currentBottomIndex = index;
          });
          _loadProfilePhoto();
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Berita',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_note_outlined),
            activeIcon: Icon(Icons.edit_note),
            label: 'Kelola (CRUD)',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Favorit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
