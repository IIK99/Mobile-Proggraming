import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../widgets/app_toast.dart';
import 'dashboard_page.dart';
import 'register_page.dart';

/// Halaman Login untuk Ikmal_apps (Aplikasi Berita)
/// Memenuhi ketentuan (Identitas & Aset Lokal) dan (Autentikasi SQLite & Validasi Form).
class IkmalLoginPage extends StatefulWidget {
  const IkmalLoginPage({super.key});

  @override
  State<IkmalLoginPage> createState() => _IkmalLoginPageState();
}

class _IkmalLoginPageState extends State<IkmalLoginPage> {
  /// GlobalKey untuk mengelola status validasi Form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// Controller untuk menangkap inputan dari pengguna
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  /// State untuk menyembunyikan/menampilkan teks password
  bool _obscurePassword = true;

  /// State indikator loading saat proses pengecekan database SQLite
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// =========================================================================
  /// METHOD actionLogin()
  /// Memvalidasi form menggunakan _formKey, mengecek kecocokan user di SQLite,
  /// menampilkan Toast jika sukses, dan menampilkan AlertDialog jika gagal.
  /// =========================================================================
  Future<void> actionLogin() async {
    // 1. Validasi TextFormField
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    try {
      // 2. Koneksi ke Database SQLite untuk memeriksa kredensial pengguna
      final user = await DatabaseHelper.instance.getUser(username, password);

      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      if (user != null) {
        // Tampilkan notifikasi Toast melayang bersih gaya login
        AppToast.show(context, "Login berhasil! Selamat datang.");

        // Arahkan ke Halaman Dashboard dengan membawa identitas pengguna
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => IkmalDashboardPage(
              username: user.username,
              namaLengkap: user.namaLengkap,
            ),
          ),
        );
      } else {
        // Jika salah, tampilkan AlertDialog dengan tombol OK
        _showLoginFailedDialog();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showLoginFailedDialog(customMessage: 'Terjadi kesalahan sistem: $e');
    }
  }

  /// Menampilkan AlertDialog saat login gagal
  void _showLoginFailedDialog({String? customMessage}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 28),
              SizedBox(width: 8),
              Text(
                'Login Gagal',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            customMessage ?? 'Username atau password salah',
            style: const TextStyle(fontSize: 15),
          ),
          actions: [
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
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Navigasi ke halaman registrasi akun baru
  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const IkmalRegisterPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: const Text(
          'Ikmal_apps — Login Berita',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Foto profil/logo tema berita dari asset lokal
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.newspaper,
                        size: 60,
                        color: Colors.blueAccent,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ikmal_apps',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Portal Informasi & Berita Terkini',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),

              // Form login dengan GlobalKey<FormState> & TextFormField
              Card(
                elevation: 4,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Silakan Masuk',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Input Field: Username
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            hintText: 'Masukkan username',
                            prefixIcon: const Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Username tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Input Field: Password
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Minimal 6 karakter',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password tidak boleh kosong';
                            }
                            if (value.length < 6) {
                              return 'Password minimal 6 karakter';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Tombol Aksi Login (memanggil method actionLogin())
                        ElevatedButton(
                          onPressed: _isLoading ? null : actionLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'LOGIN',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Informasi akun default bawaan database
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.blueAccent),
                    SizedBox(width: 6),
                    Text(
                      'Akun Default: Ikmal | Password: Password123',
                      style: TextStyle(fontSize: 12, color: Colors.blueAccent),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Opsi untuk menuju halaman registrasi
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Belum memiliki akun? '),
                  TextButton(
                    onPressed: _goToRegister,
                    child: const Text(
                      'Daftar di sini',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
