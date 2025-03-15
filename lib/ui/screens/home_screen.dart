import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:horizontal_scroll_view/horizontal_scroll_view.dart';

import 'package:vobzilla/core/utils/localization.dart';
import 'package:vobzilla/logic/cubit/localization_cubit.dart';
import 'package:vobzilla/ui/widget/elements/home/CardHome.dart';

import '../theme/appColors.dart';
import '../widget/elements/LevelChart.dart';
import '../widget/form/CustomTextZillaField.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  TextEditingController custaomTextZillaController  = TextEditingController();
  final bool listePerso = true;
  @override
  Widget build(BuildContext context) {
    var currentLocale = BlocProvider.of<LocalizationCubit>(context).state;
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
          /*
          CustomTextZillaField(
            ControlerField: custaomTextZillaController,
            labelText: 'Prénom',
            hintText: 'Entrez votre prénom',
            resulteField: 'coco',
            voidCallBack: () => {
              print('***************************ok retour')
            },
          ),
*/
        ]);
  }

  HorizontalScrollView HorizontalScrollViewCardHome({required List<Widget> children,  double itemWidth = 320}) {
    return HorizontalScrollView(
        itemWidth: itemWidth,
        crossAxisSpacing: 8.0,
        alignment: CrossAxisAlignment.center,
        children: children
    );
  }


  double itemWidthListPerso({required int nbList, required BuildContext context}) {
     double largeurCard = 320;
     double space = 8;
    if(nbList == 1){
      largeurCard = MediaQuery.sizeOf(context).width-(space*2);
    }
     if(nbList == 2){
       largeurCard = (MediaQuery.sizeOf(context).width/2)-(space*2);
     }
     if(nbList > 2){
       largeurCard = 320;
     }


     if(largeurCard < 320){
       largeurCard = 320;
     }
    return largeurCard;
  }

  Card CardClassementGamer({required int position}) {
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
                        level: 27,
                        levelMax: 100,
                        barColorProgress: Colors.white
                    ),
                  ),
               ],
              ),
        )
    );
  }

}
