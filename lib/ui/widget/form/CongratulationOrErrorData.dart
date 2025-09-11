import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:voczilla/core/utils/localization.dart';

class CongratulationOrErrorData extends StatefulWidget {
  final int vocabulaireConnu;

  const CongratulationOrErrorData({super.key, required this.vocabulaireConnu});

  @override
  State<CongratulationOrErrorData> createState() => _CongratulationOrErrorDataState();
}

class _CongratulationOrErrorDataState extends State<CongratulationOrErrorData> {

  late final ConfettiController controller;

  @override
  void initState() {
    super.initState();
    if (widget.vocabulaireConnu == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          controller = Confetti.launch(
            context,
            options: const ConfettiOptions(
                particleCount: 250,
                spread: 90,
                y: 0.5
            ),
          );
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.kill();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.vocabulaireConnu == 0) {
      return Column(children: [
        Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Text("✅ ${context.loc.widget_congratulation_bravo} !!!",
                style: const TextStyle(
                    color: Colors.green,
                    fontSize: 35,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center)),
        Text(
          context.loc.widget_congratulation_message,
          style: const TextStyle(
              color: Colors.green,
              fontSize: 20,
              height: 1
          ),
          textAlign: TextAlign.center,
        )
      ]);
    } else {
      return Center(child: Text(context.loc.no_vocabulary_items_found));
    }
  }
}
