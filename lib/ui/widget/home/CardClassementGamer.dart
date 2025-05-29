import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/multi_segment_linear_indicator.dart';
import '../statistical/LevelChart.dart';

class CardClassementGamer extends StatelessWidget {
  final int position;


  CardClassementGamer({
    required this.position,

  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double widthWidget = constraints.maxWidth;
      return Card(
          color: Colors.green,
          child: ListTile(
            leading:SizedBox(
              width: 20,
              child:Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children:
                  [
                    Text(
                        position.toString(),
                        style: TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                            fontFamily: GoogleFonts.titanOne().fontFamily
                        )
                    ),
                  ]
              ),
            ),
            title:Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Avatar(
                      radius: 15,
                      name: 'GeofMix',
                      fontsize: 20,
                    ),
                    SizedBox(width: 8), // Ajoutez un espacement entre l'avatar et le texte
                    Expanded(
                      child: Text(
                        "GeofMix",
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontFamily: GoogleFonts.titanOne().fontFamily,
                        ),
                      ),
                    ),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                              '25 jour(s)',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,

                              )
                          ),
                          Text(
                              '5 liste(s) Perso',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,

                              )
                          ),
                        ]
                    ),
                  ],
                ),
                Container(
                  width:double.infinity,
                  child:  LayoutBuilder(
                    builder: (context, constraints) {
                      return getLinearPercentIndicator(
                        percentage: 0.5,
                        width:constraints.maxWidth
                       );
                      }
                    )
                )
              ],
            ),
          )
      );
    });
  }

  dynamic getLinearPercentIndicator({required double percentage , required double width}){
    return Center(
        child:Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: width,
              height: 20.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                color: Colors.grey
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: MultiSegmentLinearIndicator(
                  padding: EdgeInsets.zero,
                  width: double.infinity,
                  lineHeight: 20.0,
                  segments: [
                    SegmentLinearIndicator(
                      percent: max(0.05,percentage),
                      color: Colors.white,
                      enableStripes: true,

                    ),
                    SegmentLinearIndicator(
                      percent: 1.0 - max(0.05,percentage),
                      color: Colors.orange,
                    ),
                  ],
                  barRadius: Radius.circular(5.0),
                ),
              ),
            ),
            Padding(
                padding: EdgeInsets.only(left:getPositionLeftCursor(
                    percentage: percentage,
                    width: width
                )),
                child:Row(
                  children: [
                    if(percentage>0.2)...[
                      Container(
                        padding: EdgeInsets.only(right:5),
                        width: 60,
                        child:Text(
                            "${(percentage * 100).toStringAsFixed(1)}%",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            )
                        ),
                      )
                    ],
                    Image.asset("assets/brand/logo_landing.png",
                      width: 80,
                    ),
                    if(percentage<=0.2)...[
                      Text(
                        "${(percentage * 100).toStringAsFixed(1)}%",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ]
                  ],
                )
            )
          ],
        )
    );
  }

  double getPositionLeftCursor({required double percentage, required double width}){
    double position = width * percentage - (percentage > 0.2 ? 120 : 40);
    return max(0, min(position, width - 140));
  }
}
