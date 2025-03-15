import 'package:flutter/material.dart';


void ErrorMessage({required BuildContext context, required String message}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
        showCloseIcon: true,
        content: Text(
          message,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        )),
  );
}
