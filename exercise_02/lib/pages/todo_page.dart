// Implementasi CRUD To-Do List Mahasiswa via REST API (package:http) + JSON Parsing

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List<Map<String, dynamic>> _todos = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  final _addFormKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _courseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchTodos();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _courseController.dispose();
    super.dispose();
  }

  User? get _currentUser => Supabase.instance.client.auth.currentUser;

  /// Ambil access token terbaru; refresh dulu kalau sudah expired
  /// supaya request REST tidak ditolak 401.
  Future<String?> _freshAccessToken() async {
    final auth = Supabase.instance.client.auth;
    var session = auth.currentSession;
    if (session == null) return null;

    // Refresh kalau token hampir/ sudah kedaluwarsa.
    if (session.isExpired) {
      try {
        final res = await auth.refreshSession();
        session = res.session;
      } catch (_) {
        return null;
      }
    }
    return session?.accessToken;
  }

  // ===================== READ (GET) =====================
  Future<void> fetchTodos() async {
    final token = await _freshAccessToken();
    if (token == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final uri = Uri.parse(
        '${SupabaseConfig.todoEndpoint}?select=*&order=created_at.desc',
      );

      final response = await http.get(
        uri,
        headers: SupabaseConfig.getHeader(token),
      );

      if (response.statusCode == 200) {
        final List<dynamic> decodedJson = jsonDecode(response.body);
        setState(() {
          _todos = decodedJson
              .map((item) => Map<String, dynamic>.from(item as Map))
              .toList();
        });
      } else {
        setState(() {
          _errorMessage =
              'Gagal memuat data (Kode HTTP: ${response.statusCode}).';
        });
      }
    } on SocketException {
      setState(() {
        _errorMessage =
            'Tidak ada koneksi internet. Periksa Wi-Fi atau paket data Anda.';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan saat memuat tugas: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ===================== CREATE (POST) =====================
  Future<void> addTodo() async {
    if (!_addFormKey.currentState!.validate()) return;

    final token = await _freshAccessToken();
    final user = _currentUser;
    if (token == null || user == null) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final uri = Uri.parse(SupabaseConfig.todoEndpoint);

      final String requestBody = jsonEncode({
        'title': _titleController.text.trim(),
        'course': _courseController.text.trim(),
        'is_done': false,
        'user_id': user.id,
      });

      final response = await http.post(
        uri,
        headers: SupabaseConfig.getHeader(token),
        body: requestBody,
      );

      if (response.statusCode == 201 && response.body.isNotEmpty) {
        final List<dynamic> createdList = jsonDecode(response.body);
        if (createdList.isEmpty) {
          _showSnackBar(
            'Tugas gagal disimpan (kemungkinan diblokir RLS).',
            isError: true,
          );
          return;
        }
        final newTodo = Map<String, dynamic>.from(createdList.first as Map);

        setState(() {
          _todos.insert(0, newTodo);
          _titleController.clear();
          _courseController.clear();
        });
        _showSnackBar('Tugas berhasil ditambahkan!');
      } else {
        _showSnackBar(
          'Gagal menambah tugas (Kode HTTP: ${response.statusCode})',
          isError: true,
        );
      }
    } on SocketException {
      _showSnackBar('Koneksi internet terputus saat menyimpan.', isError: true);
    } catch (e) {
      _showSnackBar('Terjadi kesalahan: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // ================ UPDATE STATUS (PATCH) ================
  Future<void> toggleTodoStatus(Map<String, dynamic> todo) async {
    final token = await _freshAccessToken();
    if (token == null) return;

    final int id = todo['id'] as int;
    final bool newStatus = !(todo['is_done'] as bool);

    try {
      final uri = Uri.parse('${SupabaseConfig.todoEndpoint}?id=eq.$id');

      final response = await http.patch(
        uri,
        headers: SupabaseConfig.getHeader(token),
        body: jsonEncode({'is_done': newStatus}),
      );

      // Cek bahwa server benar-benar mengembalikan baris yang terupdate.
      // Dengan Prefer: return=representation, array kosong = RLS blokir / tidak ada baris.
      final ok = (response.statusCode == 200 || response.statusCode == 204) &&
          (response.statusCode == 204 ||
              (response.body.isNotEmpty &&
                  jsonDecode(response.body) is List &&
                  (jsonDecode(response.body) as List).isNotEmpty));

      if (ok) {
        setState(() {
          final index = _todos.indexWhere((item) => item['id'] == id);
          if (index != -1) {
            _todos[index]['is_done'] = newStatus;
          }
          _errorMessage = null;
        });
      } else {
        _showSnackBar(
          'Gagal memperbarui status (Kode: ${response.statusCode})',
          isError: true,
        );
      }
    } on SocketException {
      _showSnackBar('Tidak ada koneksi internet.', isError: true);
    } catch (e) {
      _showSnackBar('Gagal mengubah status: $e', isError: true);
    }
  }

  // ================ UPDATE DATA (PATCH) ================
  Future<void> updateTodoContent(
    int id,
    String newTitle,
    String newCourse,
  ) async {
    final token = await _freshAccessToken();
    if (token == null) return;

    try {
      final uri = Uri.parse('${SupabaseConfig.todoEndpoint}?id=eq.$id');

      final response = await http.patch(
        uri,
        headers: SupabaseConfig.getHeader(token),
        body: jsonEncode({
          'title': newTitle.trim(),
          'course': newCourse.trim(),
        }),
      );

      final ok = (response.statusCode == 200 || response.statusCode == 204);
      if (ok) {
        setState(() {
          final index = _todos.indexWhere((item) => item['id'] == id);
          if (index != -1) {
            _todos[index]['title'] = newTitle.trim();
            _todos[index]['course'] = newCourse.trim();
          }
        });
        _showSnackBar('Tugas berhasil diperbarui!');
      } else {
        _showSnackBar(
          'Gagal menyimpan perubahan (Kode: ${response.statusCode})',
          isError: true,
        );
      }
    } on SocketException {
      _showSnackBar('Tidak ada koneksi internet.', isError: true);
    } catch (e) {
      _showSnackBar('Gagal mengedit tugas: $e', isError: true);
    }
  }

  // ===================== DELETE =====================
  Future<void> deleteTodo(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Tugas?'),
        content: const Text('Tugas yang dihapus tidak dapat dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB91C1C),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final token = await _freshAccessToken();
    if (token == null) return;

    try {
      final uri = Uri.parse('${SupabaseConfig.todoEndpoint}?id=eq.$id');

      final response = await http.delete(
        uri,
        headers: SupabaseConfig.getHeader(token),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          _todos.removeWhere((item) => item['id'] == id);
        });
        _showSnackBar('Tugas berhasil dihapus.');
      } else {
        _showSnackBar(
          'Gagal menghapus tugas (Kode: ${response.statusCode})',
          isError: true,
        );
      }
    } on SocketException {
      _showSnackBar('Tidak ada koneksi internet.', isError: true);
    } catch (e) {
      _showSnackBar('Gagal menghapus tugas: $e', isError: true);
    }
  }

  Future<void> _showEditDialog(Map<String, dynamic> todo) async {
    final editFormKey = GlobalKey<FormState>();
    final editTitleCtrl = TextEditingController(text: todo['title'] as String);
    final editCourseCtrl = TextEditingController(
      text: (todo['course'] ?? 'Umum') as String,
    );

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Tugas Kuliah'),
          content: Form(
            key: editFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: editTitleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Judul Tugas',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().length < 3) {
                      return 'Judul minimal 3 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: editCourseCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Mata Kuliah',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Mata kuliah wajib diisi';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                if (editFormKey.currentState!.validate()) {
                  Navigator.pop(dialogContext);
                  updateTodoContent(
                    todo['id'] as int,
                    editTitleCtrl.text,
                    editCourseCtrl.text,
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    // ✅ Dispose controller setelah dialog selesai.
    editTitleCtrl.dispose();
    editCourseCtrl.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? const Color(0xFFB91C1C) : const Color(0xFF0F172A),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final completedCount =
        _todos.where((item) => item['is_done'] == true).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'To-Do Mahasiswa',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              _currentUser?.email ?? '',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Muat Ulang Data (GET)',
            onPressed: _isLoading ? null : fetchTodos,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Keluar Akun',
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Form(
              key: _addFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Tugas Baru',
                      hintText: 'Contoh: Laporan Praktikum API Pertemuan 8',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama tugas tidak boleh kosong';
                      }
                      if (value.trim().length < 3) {
                        return 'Nama tugas minimal 3 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _courseController,
                          decoration: const InputDecoration(
                            labelText: 'Mata Kuliah',
                            hintText: 'Contoh: Mobile Programming',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Mata kuliah wajib diisi';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        height: 48,
                        child: FilledButton.icon(
                          onPressed: (_isSubmitting || _isLoading)
                              ? null
                              : addTodo,
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.add),
                          label: Text(_isSubmitting ? ' Proses...' : 'Tambah'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ${_todos.length} tugas',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'Selesai: $completedCount / ${_todos.length}',
                  style: const TextStyle(
                    color: Color(0xFF0284C7),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildTodoContent()),
        ],
      ),
    );
  }

  Widget _buildTodoContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 12),
            Text('Mengambil data dari REST API...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                size: 48,
                color: Color(0xFFB91C1C),
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFB91C1C)),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: fetchTodos,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_todos.isEmpty) {
      // ✅ Tetap bisa pull-to-refresh walau kosong.
      return RefreshIndicator(
        onRefresh: fetchTodos,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 80),
            Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Belum ada tugas kuliah.\nTambahkan tugas pertamamu pada form di atas!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: fetchTodos,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        itemCount: _todos.length,
        itemBuilder: (context, index) {
          final todo = _todos[index];
          final bool isDone = todo['is_done'] == true;
          final rawCourse = (todo['course'] as String?)?.trim();
          final course =
              (rawCourse == null || rawCourse.isEmpty) ? 'Umum' : rawCourse;

          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            child: ListTile(
              leading: Checkbox(
                value: isDone,
                onChanged: (_) => toggleTodoStatus(todo),
              ),
              title: Text(
                todo['title'].toString(),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                  color: isDone ? Colors.black45 : Colors.black87,
                ),
              ),
              subtitle: Text(
                course,
                style: const TextStyle(fontSize: 12),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Edit Tugas',
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () => _showEditDialog(todo),
                  ),
                  IconButton(
                    tooltip: 'Hapus Tugas',
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Color(0xFFB91C1C),
                    ),
                    onPressed: () => deleteTodo(todo['id'] as int),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}