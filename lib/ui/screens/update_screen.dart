import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vobzilla/core/utils/localization.dart';
import 'package:vobzilla/data/repository/vocabulaire_repository.dart';
import 'package:vobzilla/ui/widget/home/CardHome.dart';
import 'package:vobzilla/ui/widget/home/HomeListTheme.dart';
import 'package:vobzilla/ui/widget/statistical/global_statisctical_widget.dart';
import '../../core/utils/ui.dart';
import '../../data/repository/vocabulaire_user_repository.dart';
import '../../global.dart';
import '../../logic/blocs/vocabulaires/vocabulaires_bloc.dart';

import '../widget/statistical/LevelChart.dart';
import '../widget/home/CardClassementGamer.dart';
import '../widget/home/HomeListPerso.dart';

class UpdateScreen extends StatelessWidget {
  const UpdateScreen({super.key});


  Future<void> _launchStore() async {
    final String url = Platform.isAndroid
        ? ANDROID_APP_STORE_URL
        : IOS_APP_STORE_URL;

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          Padding(
            padding: EdgeInsets.only(top:20, bottom: 0,left:20,right:20),
            child:Text(
              "Une nouvelle version de Voczilla est disponible avec des améliorations importantes, de nouvelles fonctionnalités et des corrections de bugs pour une expérience encore meilleure",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16
              )
            ),
          ),

          Padding(
            padding: EdgeInsets.only(top:10, bottom: 10),
            child:Text("🎉 Ne manquez pas les nouveautés !",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),

            ),
          ),

          Text("Cliquez ci-dessous pour mettre à jour maintenant"),
          ElevatedButton(
              onPressed: _launchStore,
              child: Text("Mettre à jour VocZilla")
          ),

          Padding(
            padding: EdgeInsets.only(top:20, bottom: 10),
            child:Text("Merci de faire partie de la communauté Voczilla 💜",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)


            )
          ),


        ]

    );
  }
}
