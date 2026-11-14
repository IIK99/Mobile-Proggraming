import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/auth/login_page.dart';
import '../lib/auth/register_page.dart';

void main() {
  testWidgets('LoginPage tampil dengan tombol masuk', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    expect(find.text('Masuk Akun Mahasiswa'), findsOneWidget);
    expect(find.text('Masuk Sekarang'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets('Validasi form login kosong', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    await tester.tap(find.text('Masuk Sekarang'));
    await tester.pump();

    expect(find.text('Email wajib diisi'), findsOneWidget);
    expect(find.text('Password wajib diisi'), findsOneWidget);
  });

  testWidgets('RegisterPage punya 3 field', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterPage()));

    expect(find.text('Daftar Akun Mahasiswa'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(3));
  });

  testWidgets('Konfirmasi password tidak cocok memunculkan error',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterPage()));

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email Mahasiswa'),
      'budi@mhs.kampus.ac.id',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      '123456',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Konfirmasi Password'),
      '654321',
    );

    await tester.tap(find.text('Daftar Akun'));
    await tester.pump();

    expect(find.text('Konfirmasi password tidak cocok'), findsOneWidget);
  });
}