class User {
  final String username;
  final String password;

  User({required this.username, required this.password});
}

class UserStore {
  UserStore._privateConstructor();
  static final UserStore instance = UserStore._privateConstructor();

  final List<User> _users = [];

  String? register(String username, String password) {
    final exists = _users.any(
      (u) => u.username.toLowerCase() == username.toLowerCase(),
    );
    if (exists) {
      return 'Username sudah terdaftar!';
    }
    _users.add(User(username: username, password: password));
    return null;
  }

  User? login(String username, String password) {
    try {
      return _users.firstWhere(
        (u) =>
            u.username.toLowerCase() == username.toLowerCase() &&
            u.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  /// Cek apakah username terdaftar
  bool isUsernameExists(String username) {
    return _users.any(
      (u) => u.username.toLowerCase() == username.toLowerCase(),
    );
  }

  int get totalUsers => _users.length;
}