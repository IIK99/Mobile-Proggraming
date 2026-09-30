import 'package:flutter/material.dart';

class GestureDetectorPage extends StatefulWidget {
  const GestureDetectorPage({super.key});

  @override
  State<GestureDetectorPage> createState() => _GestureDetectorPageState();
}

class _GestureDetectorPageState extends State<GestureDetectorPage> {
  String _text = 'Tekan tombol di bawah ini';
  Color _color = Colors.blue;
  int _tapCount = 0;

  void _set(String text, Color color) => setState(() {
    _text = text;
    _color = color;
    _tapCount++;
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pertemuan 5 - GestureDetector")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_text, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => _set('Tombol ditekan', Colors.green),
              onDoubleTap: () => _set('Tombol double tap', Colors.orange),
              onLongPress: () => _set('Tombol ditekan lama', Colors.red),
              child: Container(
                width: 200,
                height: 50,
                color: _color,
                alignment: Alignment.center,
                child: const Text(
                  'Tekan Saya',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Jumlah tap: $_tapCount',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
