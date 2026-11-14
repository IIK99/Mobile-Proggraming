import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  String _status = 'Belum diaktifkan';
  String? _token;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Mendengarkan notifikasi yang masuk saat aplikasi terbuka (Foreground)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.notification?.title ?? 'Notifikasi Baru';
      final body = message.notification?.body ?? '';

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title: $body'),
            backgroundColor: const Color(0xFF0284C7),
          ),
        );
      }
    });
  }

  Future<void> _aktifkanNotifikasi() async {
    setState(() => _isLoading = true);
    try {
      final fcm = FirebaseMessaging.instance;

      // 1. Minta izin notifikasi (Android 13+ / iOS)
      NotificationSettings settings = await fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        if (mounted) {
          setState(() => _status = 'Izin notifikasi ditolak oleh pengguna.');
        }
        return;
      }

      // 2. Ambil token FCM perangkat
      final token = await fcm.getToken();
      if (mounted) {
        setState(() {
          _token = token;
          _status = token != null
              ? 'FCM Aktif! Token perangkat berhasil didapatkan.'
              : 'Gagal mendapatkan token FCM.';
        });
      }
    } catch (e) {
      if (mounted) setState(() => _status = 'Error FCM: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.notifications_active_outlined,
                size: 64,
                color: Color(0xFF0284C7),
              ),
              const SizedBox(height: 16),
              Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (_token != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    'Token FCM:\n$_token',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _aktifkanNotifikasi,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.notifications_active),
                label: Text(
                  _isLoading ? 'Memproses...' : 'Aktifkan Notifikasi',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
