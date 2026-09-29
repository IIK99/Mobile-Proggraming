import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


class PageToastAlert extends StatelessWidget {
  const PageToastAlert({super.key});

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: const Color.fromARGB(255, 1, 179, 255),
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Toast Alert'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                showToast("This is a toast message");
              },
              child: const Text('Show Toast'),
            ),
            ElevatedButton(
              onPressed: () {
                showToast("Another toast message");
              },
              child: const Text('Show Another Toast'),
            )
          ],
        ),
      ),
    );
  }
}