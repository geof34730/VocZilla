import 'package:flutter/material.dart';

class LevelChart extends StatefulWidget {
  final int levelMax;
  final int level;
  final bool imageCursor;
  final EdgeInsetsGeometry padding;
  Color barColorProgress;
  Color barColorLeft;

  LevelChart({
    required this.level,
    required this.levelMax,
    this.imageCursor = true,
    this.padding = const EdgeInsets.all(0),
    this.barColorProgress = Colors.green,
    this.barColorLeft = Colors.orange,
  });
  @override
  _LevelChartState createState() => _LevelChartState();
}

class _LevelChartState extends State<LevelChart> {
  @override
  Widget build(BuildContext context) {
    double positionTop = widget.imageCursor ? 25 :0;
    double heightContainer = widget.imageCursor ? 48 : 20;
    int percentageProgression = ((widget.level / widget.levelMax) * 100).round();
    return Padding(
        padding: widget.padding,
        child:LayoutBuilder(builder: (context, constraints) {
          double widthWidget = constraints.maxWidth; // Obtenez la largeur disponible
          final ratioSize = widthWidget / MediaQuery.of(context).size.width;
          double positionZilla= ((widget.level>94) ? (94/ widget.levelMax) : (widget.level / widget.levelMax)) * widthWidget -((40 * ratioSize) * ratioSize).round();
          return Container(
              width: widthWidget,
              height: heightContainer * ratioSize,
              child: Stack(children: [
                Positioned(
                  top: positionTop * ratioSize,
                  child: Container(
                    height: 20 * ratioSize,
                    width: widthWidget,
                    decoration: BoxDecoration(
                      color: widget.barColorLeft,
                      borderRadius: BorderRadius.circular(12 * ratioSize),
                    ),
                  ),
                ),
                Positioned(
                  top: positionTop * ratioSize,
                  child: Container(
                    height: 20 * ratioSize,
                    width: ((widget.level / widget.levelMax) * widthWidget <20) ? 20 : (widget.level / widget.levelMax) * widthWidget,
                    //(widget.level / widget.levelMax) * widthWidget,
                    decoration: BoxDecoration(
                      color: widget.barColorProgress,
                      borderRadius: BorderRadius.circular(15 * ratioSize),
                    ),
                    child:Padding(
                        padding: EdgeInsets.only(right:18*ratioSize),
                        child:Text(
                          (widget.level<6 ? '' : percentageProgression.toString() + "%"),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: (widget.barColorProgress == Colors.white) ? Colors.black : Colors.white,
                            fontSize: 13 * ratioSize,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                    ),
                  )
                ),
                if(widget.imageCursor)...[
                  Positioned(
                    left: positionZilla<0 ? 0 : positionZilla,
                    top: 0 * ratioSize,
                    child: Image.asset(
                      "assets/brand/logo_landing.png",
                      width: 80 * ratioSize,
                    ),
                  ),
                ]
              ]
              )
          );
      }
    ));
  }
}
