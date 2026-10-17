/// Model Data untuk Berita pada Aplikasi Berita Ikmal_apps
/// Menyimpan informasi konten berita, metadata, path asset lokal, dan status favorit.
class NewsModel {
  final int? id;
  final String judul;
  final String kategori;
  final String penulis;
  final String tanggal;
  final String gambar;
  final String isi;
  final bool isFavorite;

  NewsModel({
    this.id,
    required this.judul,
    required this.kategori,
    required this.penulis,
    required this.tanggal,
    required this.gambar,
    required this.isi,
    this.isFavorite = false,
  });

  /// Mengonversi objek NewsModel menjadi Map untuk penyimpanan database SQLite
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'judul': judul,
      'kategori': kategori,
      'penulis': penulis,
      'tanggal': tanggal,
      'gambar': gambar,
      'isi': isi,
      'is_favorite': isFavorite ? 1 : 0,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  /// Membuat objek NewsModel dari Map hasil query database SQLite
  factory NewsModel.fromMap(Map<String, dynamic> map) {
    return NewsModel(
      id: map['id'] as int?,
      judul: map['judul'] as String? ?? '',
      kategori: map['kategori'] as String? ?? 'Umum',
      penulis: map['penulis'] as String? ?? 'Redaksi',
      tanggal: map['tanggal'] as String? ?? '',
      gambar: map['gambar'] as String? ?? 'assets/images/logo.png',
      isi: map['isi'] as String? ?? '',
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
    );
  }

  /// Menggandakan objek NewsModel dengan modifikasi atribut tertentu (immutability helper)
  NewsModel copyWith({
    int? id,
    String? judul,
    String? kategori,
    String? penulis,
    String? tanggal,
    String? gambar,
    String? isi,
    bool? isFavorite,
  }) {
    return NewsModel(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      kategori: kategori ?? this.kategori,
      penulis: penulis ?? this.penulis,
      tanggal: tanggal ?? this.tanggal,
      gambar: gambar ?? this.gambar,
      isi: isi ?? this.isi,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
