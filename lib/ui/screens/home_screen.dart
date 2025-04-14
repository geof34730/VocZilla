import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vobzilla/data/repository/vocabulaires_repository.dart';
import 'package:vobzilla/ui/widget/elements/home/CardHome.dart';
import '../../core/utils/ui.dart';
import '../../logic/blocs/vocabulaires/vocabulaires_bloc.dart';

import '../widget/elements/LevelChart.dart';
import '../widget/elements/home/CardClassementGamer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  final bool listePerso = true;


  @override
  Widget build(BuildContext context) {



    return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                "Ma progression de titan",
                style: TextStyle(
                    fontSize: 25,
                    fontFamily: GoogleFonts.titanOne().fontFamily)
            ),
            Container(
              width:double.infinity,
              child: LevelChart(
                level: 27,
                levelMax: 100,
              ),
            ),
            Row(
              children: [
                Text(
                    "Mes listes persos",
                    style: TextStyle(
                        fontSize: 25,
                        fontFamily: GoogleFonts.titanOne().fontFamily
                    )
                ),
                if(listePerso)...[
                    Padding(
                      padding: EdgeInsets.only(left: 0),
                      child: ElevatedButton(
                        onPressed: () {
                          print('Button Pressed');
                        },
                        style: ElevatedButton.styleFrom(
                          shape: CircleBorder(),
                          elevation: 2,
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.all(0),
                        ),
                        child: Icon(Icons.add, size: 25, color: Colors.white), // Utiliser une icône ou un texte court
                      ),
                    )
                ],
              ]
            ),
          if(!listePerso)...[
            Card(
              color: Colors.blueGrey,
              child: ListTile(
                title: Padding(
                  padding: EdgeInsets.only(top: 10, left: 5, right: 5),
                    child:Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Créez et personnalisez vos propres listes de vocabulaire pour apprendre et réviser efficacement les mots de votre choix.",
                          textAlign: TextAlign.center,
                          style:TextStyle(
                              height: 1.2,
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              fontFamily: GoogleFonts.roboto().fontFamily
                            ),
                        ),
                        Center(
                          child:ElevatedButton(
                            onPressed: () {
                              print('Button Pressed');
                            },
                            style: ElevatedButton.styleFrom(
                              shape: CircleBorder(),
                              elevation: 2,
                              backgroundColor: Colors.blue,
                              padding: EdgeInsets.all(0),
                            ),
                            child: Icon(Icons.add, size: 30, color: Colors.white), // Utiliser une icône ou un texte court
                          ),
                        ),
                      ]
                  ) ,
                )
              ),
            ),
          ],
           if(listePerso)...[
              HorizontalScrollViewCardHome(
                itemWidth: itemWidthListPerso(context: context, nbList: 3),
                children: [
                      CardHome(
                        title: "list 1",
                        backgroundColor: Colors.purple,
                        editMode: true,
                        paddingLevelBar: EdgeInsets.only(top:5),
                      ),
                      CardHome(
                        title: "list 2",
                        backgroundColor: Colors.blue,
                        editMode: true,
                        paddingLevelBar: EdgeInsets.only(top:5),
                      ),
                      CardHome(
                        title: "list 2",
                        backgroundColor: Colors.blue,
                        editMode: true,
                        paddingLevelBar: EdgeInsets.only(top:5),
                      ),
                      CardHome(
                        title: "list 2",
                        backgroundColor: Colors.blue,
                        editMode: true,
                        paddingLevelBar: EdgeInsets.only(top:5),
                      ),
                    ],
                  ),
           ],
            Text(
              "De Petit Monstre à Titan",
              style: TextStyle(
                fontSize: 25,
                fontFamily: GoogleFonts.titanOne().fontFamily)
            ),
            HorizontalScrollViewCardHome(
                children: [
                CardHome(
                  title: "TOP 20",
                  paddingLevelBar: EdgeInsets.only(bottom: 10,top:5),
                ),
                CardHome(
                  title: "TOP 20 / 50",
                  paddingLevelBar: EdgeInsets.only(bottom: 10,top:5),
                ),
                CardHome(
                    title: "TOP 50 / 100",
                    paddingLevelBar: EdgeInsets.only(bottom: 10,top:5),
                  ),
              ]
            ),

            Text(
                "Classement TeamZilla",
                style: TextStyle(
                    fontSize: 25,
                    fontFamily: GoogleFonts.titanOne().fontFamily)
            ),

            CardClassementGamer(position: 1),
            CardClassementGamer(position: 2),
            CardClassementGamer(position: 3),
            Text(
                "Par themes",
                style: TextStyle(
                    fontSize: 25,
                    fontFamily: GoogleFonts.titanOne().fontFamily)
            ),
            HorizontalScrollViewCardHome(
                children: [
                  CardHome(
                    title: "Sport",
                    paddingLevelBar: EdgeInsets.only(bottom: 10,top:5),
                  ),
                  CardHome(
                    title: "Voyage",
                    paddingLevelBar: EdgeInsets.only(bottom: 10,top:5),
                  ),
                  CardHome(
                    title: "Business",
                    paddingLevelBar: EdgeInsets.only(bottom: 10,top:5),
                  ),
                  CardHome(
                    title: "Cuisine",
                    paddingLevelBar: EdgeInsets.only(bottom: 10,top:5),
                  ),
                  CardHome(
                    title: "Culture",
                    paddingLevelBar: EdgeInsets.only(bottom: 10,top:5),
                  ),
                ]
            ),
          ]

    );
  }
}
