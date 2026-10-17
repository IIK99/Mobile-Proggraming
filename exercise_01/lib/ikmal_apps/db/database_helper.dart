import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/user_model.dart';
import '../models/news_model.dart';

/// DatabaseHelper untuk mengelola koneksi dan operasi CRUD SQLite pada Ikmal_apps.
/// Mendukung Multiplatform secara penuh:
/// - Mobile (Android, iOS) & Desktop (Windows, Linux, macOS) menggunakan SQLite murni.
/// - Web (Chrome, Edge, Browser) menggunakan Web In-Memory Database Store yang kompatibel,
///   sehingga tidak memicu error "Unsupported operation: Platform._operatingSystem".
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor() {
    if (kIsWeb) {
      _initWebStore();
    }
  }

  // ==========================================
  // PENYIMPANAN IN-MEMORY KHUSUS FLUTTER WEB
  // ==========================================
  final List<UserModel> _webUsers = [];
  final List<NewsModel> _webNews = [];
  int _webNewsIdCounter = 1;
  int _webUserIdCounter = 1;

  void _initWebStore() {
    if (_webUsers.isNotEmpty) return;

    // Seeding user default untuk web
    // Password db mahasiswa: Ikmal.1099 (juga mendukung Password123)
    _webUsers.add(
      UserModel(
        id: _webUserIdCounter++,
        username: 'ikmal',
        password: 'Ikmal.1099',
        namaLengkap: 'Muhammad Ikmal',
      ),
    );

    _webUsers.add(
      UserModel(
        id: _webUserIdCounter++,
        username: 'admin',
        password: 'Ikmal.1099',
        namaLengkap: 'Admin Redaksi Ikmal',
      ),
    );

    // Seeding data berita awal menggunakan aset lokal
    final initialNews = _getInitialNewsData();
    for (var data in initialNews) {
      _webNews.add(
        NewsModel(
          id: _webNewsIdCounter++,
          judul: data['judul'] as String,
          kategori: data['kategori'] as String,
          penulis: data['penulis'] as String,
          tanggal: data['tanggal'] as String,
          gambar: data['gambar'] as String,
          isi: data['isi'] as String,
          isFavorite: (data['is_favorite'] as int) == 1,
        ),
      );
    }
  }

  List<Map<String, dynamic>> _getInitialNewsData() {
    return [
      {
        'judul': 'Kebakaran Hutan dan Lahan di Riau Meluas, Satgas Berupaya Padamkan Titik Api',
        'kategori': 'Lingkungan',
        'penulis': 'Ikmal Jurnalis',
        'tanggal': '17 Oktober 2026',
        'gambar': 'assets/images/kebakaran_hutan.jpg',
        'isi': 'Pekanbaru - Satuan Tugas Kebakaran Hutan dan Lahan (Satgas Karhutla) gabungan terus berjibaku memadamkan kobaran api yang melalap puluhan hektare lahan gambut di wilayah Sumatera. Kondisi cuaca panas dan kering disertai tiupan angin kencang menyebabkan titik api dengan cepat merambat ke area semak belukar lainnya. Petugas gabungan TNI, Polri, BPBD, dan relawan masyarakat peduli api berupaya membuat sekat bakar agar api tidak mendekati pemukiman warga.',
        'is_favorite': 0,
      },
      {
        'judul': 'Kabut Asap Karhutla Pekat Mulai Selimuti Pemukiman dan Lintas Perbatasan',
        'kategori': 'Bencana',
        'penulis': 'Tim Investigasi Ikmal_apps',
        'tanggal': '16 Oktober 2026',
        'gambar': 'assets/images/cover_berita.jpeg',
        'isi': 'Kabut asap tebal akibat kebakaran hutan dan lahan mulai mengganggu jarak pandang dan kualitas udara di sejumlah kabupaten. Indeks Standar Pencemar Udara (ISPU) di beberapa stasiun pemantau mencatatkan level tidak sehat. Warga diimbau untuk selalu memakai masker saat berada di luar rumah dan membatasi aktivitas berat di udara terbuka, terutama untuk anak-anak dan lansia.',
        'is_favorite': 1,
      },
      {
        'judul': 'Dampak Kabut Asap Karhutla Mulai Dirasakan Warga hingga ke Singapura',
        'kategori': 'Internasional',
        'penulis': 'Biro Regional Ikmal News',
        'tanggal': '15 Oktober 2026',
        'gambar': 'assets/images/kabut_asap_ke_singapura.jpeg',
        'isi': 'Singapura - Badan Lingkungan Nasional Singapura (NEA) melaporkan adanya peningkatan pembacaan polutan udara di beberapa distrik pulau tersebut. Kiriman kabut asap tipis terpantau terbawa oleh hembusan angin muson barat daya. Pemerintah setempat terus mengimbau kelompok rentan untuk membatasi aktivitas luar ruangan yang intensif.',
        'is_favorite': 0,
      },
      {
        'judul': 'BMKG Pantau Pergerakan Sebaran Asap Lintas Negara di Kawasan Selat Malaka',
        'kategori': 'Nasional',
        'penulis': 'Ikmal Redaksi Utama',
        'tanggal': '14 Oktober 2026',
        'gambar': 'assets/images/sebaran_asap_lintas_negara.jpeg',
        'isi': 'Berdasarkan citra satelit Himawari yang dianalisis oleh Badan Meteorologi, Klimatologi, dan Geofisika (BMKG), terdapat pola pergerakan partikel asap melintasi wilayah Selat Malaka menuju arah barat laut. Koordinasi pencegahan lintas batas negara terus dilakukan untuk menanggulangi dampak lanjutan terhadap sektor penerbangan dan pelayaran.',
        'is_favorite': 0,
      },
      {
        'judul': 'Kualitas Udara Memburuk, Sejumlah Sekolah Di Malaysia Berlakukan Pembelajaran Daring',
        'kategori': 'Pendidikan',
        'penulis': 'Ikmal Pendidikan',
        'tanggal': '13 Oktober 2026',
        'gambar': 'assets/images/malaysia_daring.webp',
        'isi': 'Mentri Pendidikan Malaysia Instruksikan Sekolah Daring Demi melindungi kesehatan peserta didik dan tenaga pengajar dari bahaya Infeksi Saluran Pernapasan Akut (ISPA), dinas pendidikan di kawasan terdampak parah memutuskan mengalihkan kegiatan belajar mengajar tatap muka menjadi pembelajaran jarak jauh secara daring hingga kondisi udara dinyatakan aman.',
        'is_favorite': 0,
      },
    ];
  }

  /// Mendapatkan instance database aktif untuk Mobile / Desktop.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Inisialisasi Database SQLite dengan perlindungan kIsWeb
  Future<Database> _initDatabase() async {
    // Platform.isWindows / Platform.isLinux HANYA BOLEH DIPANGGIL JIKA BUKAN FLUTTER WEB
    if (!kIsWeb) {
      if (Platform.isWindows || Platform.isLinux) {
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
    }

    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'ikmal_news.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  /// Pembuatan tabel SQLite awal dan penyemaian data bawaan
  Future<void> _onCreate(Database db, int version) async {
    // 1. Pembuatan Tabel Users (Autentikasi Login & Registrasi)
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        nama_lengkap TEXT NOT NULL
      )
    ''');

    // 2. Pembuatan Tabel News (Data Berita Lokal & CRUD Berita)
    await db.execute('''
      CREATE TABLE news (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        judul TEXT NOT NULL,
        kategori TEXT NOT NULL,
        penulis TEXT NOT NULL,
        tanggal TEXT NOT NULL,
        gambar TEXT NOT NULL,
        isi TEXT NOT NULL,
        is_favorite INTEGER DEFAULT 0
      )
    ''');

    // 3. Seeding User Default
    // Password db mahasiswa: Ikmal.1099
    await db.insert('users', {
      'username': 'ikmal',
      'password': 'Ikmal.1099',
      'nama_lengkap': 'Muhammad Ikmal',
    });

    await db.insert('users', {
      'username': 'admin',
      'password': 'Ikmal.1099',
      'nama_lengkap': 'Admin Redaksi Ikmal',
    });

    // 4. Seeding Data Berita Awal Menggunakan Aset Gambar Lokal
    final initialNews = _getInitialNewsData();
    for (var news in initialNews) {
      await db.insert('news', news);
    }
  }

  // ==========================================
  // OPERASI AUTENTIKASI PENGGUNA (USERS)
  // ==========================================

  /// Memasukkan data pengguna baru ke database (Registrasi)
  Future<int> insertUser(UserModel user) async {
    if (kIsWeb) {
      final newUser = UserModel(
        id: _webUserIdCounter++,
        username: user.username,
        password: user.password,
        namaLengkap: user.namaLengkap,
      );
      _webUsers.add(newUser);
      return newUser.id!;
    }

    final db = await database;
    return await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Mengecek dan mengambil data pengguna berdasarkan username dan password (Login)
  Future<UserModel?> getUser(String username, String password) async {
    final cleanUsername = username.toLowerCase().trim();

    if (kIsWeb) {
      try {
        return _webUsers.firstWhere(
          (u) =>
              u.username.toLowerCase() == cleanUsername &&
              (u.password == password ||
                  (cleanUsername == 'ikmal' && password == 'Password123') ||
                  (cleanUsername == 'ikmal' && password == 'Ikmal.1099')),
        );
      } catch (_) {
        return null;
      }
    }

    final db = await database;
    // Cek password utama
    var res = await db.query(
      'users',
      where: 'LOWER(username) = ? AND password = ?',
      whereArgs: [cleanUsername, password],
    );

    // Fallback jika user ikmal mencoba password alternatif
    if (res.isEmpty && cleanUsername == 'ikmal') {
      if (password == 'Password123' || password == 'Ikmal.1099') {
        res = await db.query(
          'users',
          where: 'LOWER(username) = ?',
          whereArgs: [cleanUsername],
        );
      }
    }

    if (res.isNotEmpty) {
      return UserModel.fromMap(res.first);
    }
    return null;
  }

  /// Memeriksa apakah username sudah pernah terdaftar sebelumnya di database
  Future<bool> isUsernameTaken(String username) async {
    final cleanUsername = username.toLowerCase().trim();

    if (kIsWeb) {
      return _webUsers.any((u) => u.username.toLowerCase() == cleanUsername);
    }

    final db = await database;
    final res = await db.query(
      'users',
      where: 'LOWER(username) = ?',
      whereArgs: [cleanUsername],
    );
    return res.isNotEmpty;
  }

  // ==========================================
  // OPERASI CRUD BERITA (NEWS)
  // ==========================================

  /// READ: Mengambil seluruh daftar berita dari database
  Future<List<NewsModel>> getAllNews() async {
    if (kIsWeb) {
      return List<NewsModel>.from(_webNews.reversed);
    }

    final db = await database;
    final res = await db.query('news', orderBy: 'id DESC');
    return res.map((e) => NewsModel.fromMap(e)).toList();
  }

  /// READ: Mengambil daftar berita favorit saja
  Future<List<NewsModel>> getFavoriteNews() async {
    if (kIsWeb) {
      return _webNews.where((n) => n.isFavorite).toList().reversed.toList();
    }

    final db = await database;
    final res = await db.query(
      'news',
      where: 'is_favorite = 1',
      orderBy: 'id DESC',
    );
    return res.map((e) => NewsModel.fromMap(e)).toList();
  }

  /// READ: Mengambil detail satu berita berdasarkan ID
  Future<NewsModel?> getNewsById(int id) async {
    if (kIsWeb) {
      try {
        return _webNews.firstWhere((n) => n.id == id);
      } catch (_) {
        return null;
      }
    }

    final db = await database;
    final res = await db.query('news', where: 'id = ?', whereArgs: [id]);
    if (res.isNotEmpty) {
      return NewsModel.fromMap(res.first);
    }
    return null;
  }

  /// CREATE: Menambahkan berita baru ke database
  Future<int> insertNews(NewsModel news) async {
    if (kIsWeb) {
      final newNews = news.copyWith(id: _webNewsIdCounter++);
      _webNews.add(newNews);
      return newNews.id!;
    }

    final db = await database;
    return await db.insert('news', news.toMap());
  }

  /// UPDATE: Memperbarui data berita yang sudah ada di database
  Future<int> updateNews(NewsModel news) async {
    if (kIsWeb) {
      final index = _webNews.indexWhere((n) => n.id == news.id);
      if (index != -1) {
        _webNews[index] = news;
        return 1;
      }
      return 0;
    }

    final db = await database;
    return await db.update(
      'news',
      news.toMap(),
      where: 'id = ?',
      whereArgs: [news.id],
    );
  }

  /// DELETE: Menghapus berita dari database berdasarkan ID
  Future<int> deleteNews(int id) async {
    if (kIsWeb) {
      _webNews.removeWhere((n) => n.id == id);
      return 1;
    }

    final db = await database;
    return await db.delete('news', where: 'id = ?', whereArgs: [id]);
  }

  /// UPDATE FAVORITE: Mengubah status favorit berita
  Future<int> toggleFavorite(int id, bool isFavorite) async {
    if (kIsWeb) {
      final index = _webNews.indexWhere((n) => n.id == id);
      if (index != -1) {
        _webNews[index] = _webNews[index].copyWith(isFavorite: isFavorite);
        return 1;
      }
      return 0;
    }

    final db = await database;
    return await db.update(
      'news',
      {'is_favorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
