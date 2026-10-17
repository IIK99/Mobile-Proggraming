import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Helper Widget untuk menampilkan gambar secara konsisten di seluruh Ikmal_apps.
/// Mendukung:
/// 1. Data Base64 (data:image/...;base64,...)
/// 2. Web Blob URL / Network URL (blob:http://... atau https://...)
/// 3. File Lokal Disk (File(path)) jika di Mobile/Desktop
/// 4. Asset Lokal (assets/images/...)
class AppImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const AppImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: Colors.grey.shade400,
          size: (height != null && height! < 50) ? 20 : 36,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trimmed = imagePath.trim();

    // 1. Format Base64 Data URI
    if (trimmed.startsWith('data:image') || trimmed.startsWith('base64:')) {
      try {
        final cleanBase64 =
            trimmed.contains(',') ? trimmed.split(',').last : trimmed.replaceFirst('base64:', '');
        // Bersihkan seluruh spasi/newline agar base64Decode tidak pernah error
        final normalized = cleanBase64.replaceAll(RegExp(r'\s+'), '');
        final bytes = base64Decode(normalized);
        return _wrapBorder(
          Image.memory(
            bytes,
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (ctx, err, stack) => _buildPlaceholder(),
          ),
        );
      } catch (_) {
        return _wrapBorder(_buildPlaceholder());
      }
    }

    // 2. Format Web Blob URL atau URL Jaringan
    if (trimmed.startsWith('blob:') || trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return _wrapBorder(
        Image.network(
          trimmed,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (ctx, err, stack) => _buildPlaceholder(),
        ),
      );
    }

    // 3. File Lokal pada Disk (Mobile / Desktop)
    if (!kIsWeb && File(trimmed).existsSync()) {
      return _wrapBorder(
        Image.file(
          File(trimmed),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (ctx, err, stack) => _buildPlaceholder(),
        ),
      );
    }

    // 4. Asset Lokal (assets/images/...) dengan kandidat fallback berantai otomatis
    final candidates = _buildAssetCandidates(trimmed);
    return _wrapBorder(_buildAssetWithFallbackChain(candidates, 0));
  }

  /// Membuat daftar variasi path asset (spasi, garis bawah, URL encoded)
  List<String> _buildAssetCandidates(String original) {
    final list = <String>[original];

    // Variasi penamaan file Karhutla
    if (original.toLowerCase().contains('kebakaran')) {
      list.add('assets/images/kebakaran hutan.jpg');
      list.add('assets/images/kebakaran_hutan.jpg');
      list.add('assets/images/kebakaran%20hutan.jpg');
    }

    // Variasi penamaan file Cover Berita
    if (original.toLowerCase().contains('cover')) {
      list.add('assets/images/cover_berita.jpeg');
      list.add('assets/images/cover berita.jpeg');
      list.add('assets/images/cover%20berita.jpeg');
    }

    // Variasi umum spasi <-> underscore <-> %20
    if (original.contains(' ')) {
      list.add(original.replaceAll(' ', '_'));
      list.add(original.replaceAll(' ', '%20'));
    }
    if (original.contains('_')) {
      list.add(original.replaceAll('_', ' '));
      list.add(original.replaceAll('_', '%20'));
    }
    if (original.contains('%20')) {
      list.add(original.replaceAll('%20', ' '));
      list.add(original.replaceAll('%20', '_'));
    }

    // Fallback aset yang pasti ada dalam aplikasi
    list.add('assets/images/cover_berita.jpeg');
    list.add('assets/images/cover berita.jpeg');

    return list.toSet().toList();
  }

  /// Membangun Image.asset dengan recursive fallback jika variasi sebelumnya gagal
  Widget _buildAssetWithFallbackChain(List<String> candidates, int index) {
    if (index >= candidates.length) {
      return _buildPlaceholder();
    }

    return Image.asset(
      candidates[index],
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return _buildAssetWithFallbackChain(candidates, index + 1);
      },
    );
  }

  Widget _wrapBorder(Widget child) {
    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: child,
      );
    }
    return child;
  }
}
