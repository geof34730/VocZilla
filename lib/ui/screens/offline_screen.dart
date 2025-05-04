import 'package:flutter/material.dart';
import 'package:vobzilla/core/utils/localization.dart';

class OfflineScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.offline_title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color:Colors.black
          ),
        ),
      ),
      body: Center(
        child: Text(
          context.loc.offline_description,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
