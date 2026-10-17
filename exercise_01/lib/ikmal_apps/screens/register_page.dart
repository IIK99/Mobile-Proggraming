import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/user_model.dart';
import '../widgets/app_toast.dart';

/// Halaman Registrasi Akun Pengguna Baru untuk Ikmal_apps
/// Memenuhi ketentuan method actionRegistrasi dan validasi form menggunakan SQLite.
class IkmalRegisterPage extends StatefulWidget {
  const IkmalRegisterPage({super.key});

  @override
  State<IkmalRegisterPage> createState() => _IkmalRegisterPageState();
}

class _IkmalRegisterPageState extends State<IkmalRegisterPage> {
  /// GlobalKey untuk memvalidasi form registrasi
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();

  /// Controller untuk field input registrasi
  final TextEditingController _namaLengkapController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  /// State obscure password
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  /// State indikator loading
  bool _isLoading = false;

  @override
  void dispose() {
    _namaLengkapController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// =========================================================================
  /// METHOD actionRegistrasi()
  /// Memvalidasi input registrasi, memeriksa duplikasi username pada SQLite,
  /// serta menyimpan data akun baru ke database SQLite.
  /// =========================================================================
  Future<void> actionRegistrasi() async {
    // 1. Memeriksa validasi form (tidak boleh kosong, password min 6)
    if (!_registerFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final namaLengkap = _namaLengkapController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    try {
      // 2. Cek apakah username sudah dipakai di database SQLite
      final isTaken = await DatabaseHelper.instance.isUsernameTaken(username);
      if (isTaken) {
        setState(() {
          _isLoading = false;
        });

        if (!mounted) return;
        AppToast.show(
          context,
          'Username sudah terdaftar! Gunakan username lain.',
          isError: true,
        );
        return;
      }

      // 3. Simpan data pengguna baru ke SQLite
      final newUser = UserModel(
        username: username,
        password: password,
        namaLengkap: namaLengkap,
      );

      await DatabaseHelper.instance.insertUser(newUser);

      setState(() {
        _isLoading = false;
      });

      if (!mounted) return;

      // 4. Beri notifikasi toast gaya login & kembalikan ke halaman login
      AppToast.show(context, "Registrasi berhasil! Silakan login.");

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (!mounted) return;
      AppToast.show(context, 'Gagal registrasi: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: const Text(
          'Daftar Akun Ikmal_apps',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Card(
                elevation: 4,
                shadowColor: Colors.black12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _registerFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Buat Akun Baru',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Isi data di bawah untuk mendaftarkan akun di SQLite',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        const SizedBox(height: 20),

                        // Field Nama Lengkap
                        TextFormField(
                          controller: _namaLengkapController,
                          decoration: InputDecoration(
                            labelText: 'Nama Lengkap',
                            hintText: 'Contoh: Muhammad Ikmal',
                            prefixIcon: const Icon(Icons.badge_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Nama lengkap tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Field Username
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            hintText: 'Masukkan username unik',
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
                            if (value.trim().length < 3) {
                              return 'Username minimal 3 karakter';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Field Password
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
                        const SizedBox(height: 16),

                        // Field Konfirmasi Password
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: 'Konfirmasi Password',
                            hintText: 'Ulangi password',
                            prefixIcon: const Icon(Icons.lock_reset),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
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
                              return 'Konfirmasi password tidak boleh kosong';
                            }
                            if (value != _passwordController.text) {
                              return 'Konfirmasi password tidak cocok';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        // Tombol actionRegistrasi
                        ElevatedButton(
                          onPressed: _isLoading ? null : actionRegistrasi,
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
                                  'DAFTAR SEKARANG',
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Sudah punya akun? '),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Kembali ke Login',
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
