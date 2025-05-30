import 'package:flutter/material.dart';

import '../../../core/utils/logger.dart';

class LevelChart extends StatefulWidget {
  final int levelMax;
  final int level;
  final bool imageCursor;
  final EdgeInsetsGeometry padding;
  Color barColorProgress;
  Color barColorLeft;

  LevelChart({
    required this.level,
    this.levelMax =100,
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
    double percentageProgression = ((widget.level / widget.levelMax) * 100);
    return Padding(
        padding: widget.padding,
        child:LayoutBuilder(builder: (context, constraints) {
          double widthWidget = constraints.maxWidth; // Obtenez la largeur disponible
          final ratioSize = widthWidget / MediaQuery.of(context).size.width;
          //final ratioSize = widthWidget / MediaQuery.of(context).size.width;

          double positionZilla= ((percentageProgression>94) ? (94/ 100) : (percentageProgression / 100)) * widthWidget -((40 * ratioSize) * ratioSize).round();
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
                    child:Padding(
                        padding: EdgeInsets.only(
                            left: widget.imageCursor ? positionZilla+(100*ratioSize) : positionZilla+(35*ratioSize),
                            top:widget.imageCursor ? 0 : 1*ratioSize
                        ),
                        child:Text(
                          (percentageProgression>25 ? '' : percentageProgression.toStringAsFixed(2) + "% "),
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            color: (widget.barColorLeft == Colors.white) ? Colors.black : Colors.white,
                            fontSize: 15 * ratioSize,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                    ),
                  ),

                ),
                Positioned(
                  top: positionTop * ratioSize,
                  child: Container(
                    height: 20 * ratioSize,
                    width: ((percentageProgression / 100) * widthWidget <20 && widget.imageCursor) ? 0 :(percentageProgression / 100) * widthWidget<0 && widget.imageCursor ? 40 *ratioSize : (percentageProgression / 100) * widthWidget ,
                    //(level / levelMax) * widthWidget,
                    decoration: BoxDecoration(
                      color: widget.barColorProgress,
                      borderRadius: BorderRadius.circular(15 * ratioSize),
                    ),
                    child:Padding(
                        padding: EdgeInsets.only(left:18*ratioSize),
                        child:Text(
                          (percentageProgression<=25 ? '' : percentageProgression.toStringAsFixed(2) + "%"),
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
                    child: Image.asset("assets/brand/logo_landing.png",
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
