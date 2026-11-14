import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'config/supabase_config.dart';
import 'auth/login_page.dart';
import 'pages/home.dart';
import 'config/firebase_options.dart'; // pastikan file ini dibuat via `flutterfire configure`

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  // Inisialisasi Firebase (Tahap 7 PDF Modul)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0284C7)),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

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
          // KUNCI: Arahkan ke HomePage (bukan TodoPage langsung)
          return const HomePage();
        }
        return const LoginPage();
      },
    );
  }
}
