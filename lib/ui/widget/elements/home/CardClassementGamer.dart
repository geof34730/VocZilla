import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:google_fonts/google_fonts.dart';
import '../LevelChart.dart';

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
                  child: LevelChart(
                      level: 20,
                      levelMax: 100,
                      barColorProgress: Colors.white
                  ),
                ),
              ],
            ),
          )
      );
    });
  }
}
