import 'package:flutter/material.dart';

class PageBasicList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Basic List'), backgroundColor: Colors.blue),
      body: ListView(
        children: <Widget>[
          ListTile(leading: Icon(Icons.access_alarm), title: Text('Alarm')),
          ListTile(leading: Icon(Icons.phone), title: Text('Phone')),
          ListTile(leading: Icon(Icons.camera), title: Text('Camera')),
          ListTile(leading: Icon(Icons.message), title: Text('Message')),
        ],
      ),
    );
  }
}
