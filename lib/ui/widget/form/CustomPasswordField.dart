
import 'package:flutter/material.dart';

class CustomPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final String? keyForShoot;

  const CustomPasswordField({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    this.keyForShoot
  }) : super(key: key);

  @override
  _CustomPasswordFieldState createState() => _CustomPasswordFieldState();
}

class _CustomPasswordFieldState extends State<CustomPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  EdgeInsets.all(5.0),
      constraints: BoxConstraints(maxWidth: 400),// Apply margin of 5
      child: TextField(
        key: widget.keyForShoot != null ? ValueKey<String>(widget.keyForShoot!) : widget.key,
        controller: widget.controller,
        obscureText: _obscureText,
        decoration: InputDecoration(
          constraints: BoxConstraints(maxWidth: 400),
          labelText: widget.labelText,
          hintText: widget.hintText,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureText ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                _obscureText = !_obscureText;
              });
            },
          ),
        ),
      ),
    );
  }
}
