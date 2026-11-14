import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'todo_page.dart';
import 'camera.dart';
import 'location.dart';
import 'notification.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('To-Do Supabase'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async => Supabase.instance.client.auth.signOut(),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(icon: Icon(Icons.task), text: 'Tugas'),
              Tab(icon: Icon(Icons.camera_alt), text: 'Kamera'),
              Tab(icon: Icon(Icons.location_on), text: 'GPS'),
              Tab(icon: Icon(Icons.notifications), text: 'Notifikasi'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            TodoPage(),
            CameraPage(),
            LocationPage(),
            NotificationPage(),
          ],
        ),
      ),
    );
  }
}
