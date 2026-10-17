import 'package:flutter/material.dart';

/// Helper Toast Kustom menyerupai gaya di lib/login/login.dart.
/// Menampilkan notifikasi melayang di bagian atas dengan ikon, warna latar informatif,
/// serta pembersihan otomatis agar tidak saling menimpa/tumpang tindih.
class AppToast {
  static OverlayEntry? _activeEntry;

  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 2),
  }) {
    // 1. Bersihkan notifikasi sebelumnya jika masih tampil
    try {
      _activeEntry?.remove();
    } catch (_) {}
    _activeEntry = null;

    final overlay = Overlay.of(context);
    final topPadding = MediaQuery.of(context).padding.top;

    final entry = OverlayEntry(
      builder: (ctx) => Positioned(
        top: topPadding + 16,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: isError ? Colors.red.shade700 : Colors.green.shade700,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  isError ? Icons.error_outline : Icons.check_circle_outline,
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    _activeEntry = entry;
    overlay.insert(entry);

    Future.delayed(duration, () {
      if (_activeEntry == entry) {
        try {
          entry.remove();
        } catch (_) {}
        _activeEntry = null;
      }
    });
  }
}
