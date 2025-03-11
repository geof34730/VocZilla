import 'package:flutter/material.dart';

class LevelChart extends StatefulWidget {
  final int levelMax;
  final int level;

  LevelChart({
    required this.level,
    required this.levelMax,
  });

  @override
  _LevelChartState createState() => _LevelChartState();
}

class _LevelChartState extends State<LevelChart> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 20,
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(12),
        ),
      child: Row(
        children: [
          Container(
            width: (widget.level / widget.levelMax) * 100,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),

            child: Image.asset("assets/brand/logo_landing.png"),
          ),
        ],
      ),
    );
  }
}
