import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vobzilla/core/utils/localization.dart';
import 'package:vobzilla/logic/cubit/localization_cubit.dart';
import 'package:vobzilla/ui/widget/elements/home/CardHome.dart';

import '../widget/elements/LevelChart.dart';
import '../widget/form/CustomTextZillaField.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  TextEditingController custaomTextZillaController  = TextEditingController();
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
              level: 18,
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
                  child: Icon(Icons.add, size: 25, color: Colors.white,), // Utiliser une icône ou un texte court
                ),
              )
            ],
          ),

          CardHome(
            title: "list 1",
            backgroundColor: Colors.orange,
            editMode: true,
            paddingLevelBar: EdgeInsets.only(top:5),
          ),


          Text(
            "De Petit Monstre à Titan",
            style: TextStyle(
              fontSize: 25,
              fontFamily: GoogleFonts.titanOne().fontFamily)
          ),
          CardHome(
            title: "TOP 50",
            paddingLevelBar: EdgeInsets.only(bottom: 10,top:5),
          ),



          Text(
              "Par themes",
              style: TextStyle(
                  fontSize: 25,
                  fontFamily: GoogleFonts.titanOne().fontFamily)
          ),
          CardHome(
            title: "Sport",
            paddingLevelBar: EdgeInsets.only(bottom: 10,top:5),
          ),
          CardHome(
            title: "Voyage",
            paddingLevelBar: EdgeInsets.only(bottom: 10,top:5),
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
}
