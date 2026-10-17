/// Model Data untuk Pengguna (User) Aplikasi Ikmal_apps
/// Digunakan untuk menyimpan informasi autentikasi dan identitas pengguna.
class UserModel {
  final int? id;
  final String username;
  final String password;
  final String namaLengkap;

  UserModel({
    this.id,
    required this.username,
    required this.password,
    required this.namaLengkap,
  });

  /// Mengonversi Objek UserModel ke format Map untuk disimpan ke database SQLite
  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'username': username,
      'password': password,
      'nama_lengkap': namaLengkap,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  /// Membuat Objek UserModel dari Map (hasil query database SQLite)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      username: map['username'] as String? ?? '',
      password: map['password'] as String? ?? '',
      namaLengkap: map['nama_lengkap'] as String? ?? '',
    );
  }
}
