import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';

class UpdateScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update Available')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('A new version of the app is available.'),
            ElevatedButton(
              onPressed: () {
                InAppUpdate.performImmediateUpdate();
              },
              child: Text('Update Now'),
            ),
          ],
        ),
      ),
    );
  }
}



