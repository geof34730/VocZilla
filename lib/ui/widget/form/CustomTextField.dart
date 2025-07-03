import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final String? keyForShoot;

   CustomTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.keyForShoot
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.all(5.0),
        constraints: BoxConstraints(maxWidth: 400),
        child: TextField(
          key: keyForShoot != null ? ValueKey<String>(keyForShoot!) : key,
          controller: controller,
          decoration: InputDecoration(
            labelText: labelText,
            hintText: hintText,
          ),
      ),
    );
  }
}
