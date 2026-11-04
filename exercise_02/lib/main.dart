// Titik masuk utama aplikasi, inisialisasi Supabase, dan gerbang auth.

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';
import 'login_page.dart';
import 'todo_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(const TodoMahasiswaApp());
}

class TodoMahasiswaApp extends StatelessWidget {
  const TodoMahasiswaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List Mahasiswa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0284C7),
        ),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

/// Gerbang auth: tampilkan LoginPage kalau belum ada session,
/// atau TodoPage kalau user sudah login.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final session = snapshot.data?.session;
        if (session != null) {
          return const TodoPage();
        }
        return const LoginPage();
      },
    );
  }
}