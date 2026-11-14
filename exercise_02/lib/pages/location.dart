import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  String _info = 'Belum ada lokasi';
  bool _isLoading = false;

  Future<void> _ambilLokasi() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Cek apakah layanan lokasi (GPS) aktif
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Layanan lokasi/GPS belum aktif. Silakan aktifkan.');
      }

      // 2. Cek izin lokasi
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Izin lokasi ditolak oleh pengguna.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Izin lokasi ditolak permanen. Buka pengaturan aplikasi untuk mengizinkan.',
        );
      }

      // 3. Ambil posisi GPS terbaru
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );

      if (mounted) {
        setState(() {
          _info =
              'Latitude: ${position.latitude}\n'
              'Longitude: ${position.longitude}\n'
              'Akurasi: ${position.accuracy.toStringAsFixed(2)} meter';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _info = 'Error: ${e.toString().replaceAll('Exception: ', '')}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_on, size: 64, color: Color(0xFF0284C7)),
            const SizedBox(height: 16),
            Text(
              _info,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _ambilLokasi,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
              label: Text(_isLoading ? 'Mengambil GPS...' : 'Ambil GPS'),
            ),
          ],
        ),
      ),
    );
  }
}
