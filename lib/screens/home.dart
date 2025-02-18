import 'package:flutter/material.dart';
import '../ui/layout.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Layout(
      child: Center(
        child: Text('AppBar avec Bloc pour gérer 2 endDrawers'),
      ),
    );
  }
}
