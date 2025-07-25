import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  const Loading({super.key});
  @override
  Widget build(BuildContext context) {
    //ScaffoldMessenger.of(context).hideCurrentSnackBar();
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}
