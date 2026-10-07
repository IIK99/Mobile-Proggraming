import 'package:flutter/material.dart';

import '../pertemuan_03/exercise_01.dart';
import '../pertemuan_04/toast_alert.dart';

import 'package:exercise_01/pertemuan_05/gesture_detector.dart';
import 'package:exercise_01/pertemuan_06/form.dart';

class MateriPage extends StatefulWidget {
  const MateriPage({super.key});

  @override
  State<MateriPage> createState() => _MateriPageState();
}

class _MateriPageState extends State<MateriPage> {
  // List pertemuan. Setiap menambah pertemuan baru, tambahkan ke list ini.
  final List<String> pertemuanList = [
    'Pertemuan 3',
    'Pertemuan 4',
    'Pertemuan 5',
    'Pertemuan 6',
  ];

  void _navigateToPertemuan(BuildContext context, String pertemuan) {
    // Percabangan switch case untuk navigasi berdasarkan nama pertemuan
    switch (pertemuan) {
      case 'Pertemuan 3':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PageBasicList()),
        );
        break;
      case 'Pertemuan 4':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PageToastAlert()),
        );
        break;
      case 'Pertemuan 5':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const GestureDetectorPage()),
        );
        break;
      case 'Pertemuan 6':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FormPage()),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Materi untuk $pertemuan belum tersedia')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 kolom
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: pertemuanList.length,
        itemBuilder: (context, index) {
          final pertemuan = pertemuanList[index];
          return InkWell(
            onTap: () => _navigateToPertemuan(context, pertemuan),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.folder, size: 60, color: Colors.blueAccent),
                  const SizedBox(height: 10),
                  Text(
                    pertemuan,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
