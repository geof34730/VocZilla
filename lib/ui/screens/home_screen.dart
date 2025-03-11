import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:vobzilla/core/utils/localization.dart';
import 'package:vobzilla/logic/cubit/localization_cubit.dart';

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
          LevelChart(
            level: 20,
            levelMax: 20,
          ),
          Text(
              "Mes listes persos",
              style: TextStyle(
                  fontSize: 25,
                  fontFamily: GoogleFonts.titanOne().fontFamily)
          ),

          Container(
            child: Card(
              child: Column(
                children: [

                  Text(
                    "TOP 20",
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "lorem ipsum donor",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          Text(
            "De Petit Monstre à Titan",
            style: TextStyle(
              fontSize: 25,
              fontFamily: GoogleFonts.titanOne().fontFamily)
          ),
          Container(
            child: Card(
              child: Column(
                children: [
                  Text(
                    "TOP 20",
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "lorem ipsum donor",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          CustomTextZillaField(
            ControlerField: custaomTextZillaController,
            labelText: 'Prénom',
            hintText: 'Entrez votre prénom',
            resulteField: 'coco',
            voidCallBack: () => {
              print('***************************ok retour')
            },
          ),

          Text(
              "À REVISER",
              style: TextStyle(
                  fontSize: 25,
                  fontFamily: GoogleFonts.titanOne().fontFamily)
          ),
          Container(
            child: Card(
              child: Column(
                children: [

                  Text(
                    "TOP 20",
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "lorem ipsum donor",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          Text(
              "Par themes",
              style: TextStyle(
                  fontSize: 25,
                  fontFamily: GoogleFonts.titanOne().fontFamily)
          ),
          Container(
            child: Card(
              child: Column(
                children: [

                  Text(
                    "TOP 20",
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "lorem ipsum donor",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ]);
  }
}
