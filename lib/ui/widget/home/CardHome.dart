import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/utils/enum.dart';
import '../../../data/models/vocabulary_user.dart';
import '../../../data/repository/vocabulaire_repository.dart';
import '../../../data/repository/vocabulaire_user_repository.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_bloc.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_event.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_bloc.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_event.dart';
import '../../theme/appColors.dart';

import '../statistical/card_home_statisctical_widget.dart';
import 'ElevatedButtonCardHome.dart';
import 'package:ribbon_widget/ribbon_widget.dart';

class CardHome extends StatelessWidget {
  final String title;
  final bool editMode;
  final EdgeInsetsGeometry paddingLevelBar;
  final Color backgroundColor;
  final int? vocabulaireBegin;
  final int? vocabulaireEnd;
  final bool ownListShare;
  final bool isListShare;
  final bool isListPero;
  final ListPerso? listPerso;
  final String guid;
  final int nbVocabulaire;
  VocabulaireUserRepository _vocabulaireUserRepository = VocabulaireUserRepository();

  CardHome({
    this.nbVocabulaire=0,
    required this.title,
    this.vocabulaireBegin,
    this.vocabulaireEnd,
    this.editMode = false,
    this.isListPero = false,
    this.ownListShare = false,
    this.isListShare = false,
    this.guid ="",
    this.listPerso,
    this.backgroundColor = AppColors.colorTextTitle,
    this.paddingLevelBar = const EdgeInsets.all(0),
  });
  final _vocabulaireRepository=VocabulaireRepository();

  String? guidListPerso = null;

  @override
  Widget build(BuildContext context) {
    if (listPerso != null) {
      guidListPerso = listPerso?.guid;
    }
    return LayoutBuilder(builder: (context, constraints) {
      double widthWidget = constraints.maxWidth;
      return  (isListShare  && !ownListShare
          ?
          Ribbon(
              nearLength: 35.00,
              farLength: 50.00,
              title: 'partagée'.toUpperCase(),
              titleStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.bold
              ),
              color: Colors.blue,
              child:Container(
                  width: widthWidget,
                  child:BoxCardHome(context: context, widthWidget: widthWidget)
                )
          )
          :
          Container(
            width: widthWidget,
            child:BoxCardHome(context: context, widthWidget: widthWidget)
          )
        );
    });
  }

  Card BoxCardHome({required BuildContext context, required double widthWidget}){
    return Card(
      color: backgroundColor,
      child: Column(
        children: [
          Text(
            title.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontFamily: GoogleFonts.titanOne().fontFamily,
              color: backgroundColor == Colors.white ? Colors.black : Colors.white,
            ),
          ),

         if(nbVocabulaire==0 && isListPero)...[
           Container(
             height: 72,
             padding: EdgeInsets.only(left:5, right:5),
             child: Column(
               mainAxisAlignment: MainAxisAlignment.center,
               children: [
                 Text(
                   "Vous n'avez aucun vocabulaire dans cette liste. Ajoutez-en en modifiant la liste",
                   style: TextStyle(
                     color: Colors.white,
                   ),
                   textAlign: TextAlign.center,
                 ),
               ],
             ),
           )
         ],

          if((isListPero ? nbVocabulaire>0 : true))...[
            Wrap(
            alignment: WrapAlignment.center,
            verticalDirection: VerticalDirection.down,
            spacing: 10.0,
            runSpacing: 0.0,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButtonCardHome(
                    colorIcon: Colors.green,
                    onClickButton: () {
                      _vocabulaireRepository.goVocabulaires(vocabulaireEnd: vocabulaireEnd,vocabulaireBegin: vocabulaireBegin,guidListPerso: guidListPerso,context: context,titleList: title );
                      Navigator.pushNamed(context, '/vocabulary/list');
                    },
                    iconContent: Icons.list,
                    context: context,
                    iconSize: IconSize.bigIcon,
                  ),
                  ElevatedButtonCardHome(
                    colorIcon: Colors.green,
                    onClickButton: () {
                      _vocabulaireRepository.goVocabulaires(isVocabularyNotLearned:true,vocabulaireEnd: vocabulaireEnd,vocabulaireBegin: vocabulaireBegin,guidListPerso: guidListPerso,context: context,titleList: title );
                      Navigator.pushNamed(context, '/vocabulary/learn');
                    },
                    iconContent: Icons.school_rounded,
                    context: context,
                    iconSize: IconSize.bigIcon,
                  ),
                  ElevatedButtonCardHome(
                    colorIcon: Colors.green,
                    onClickButton: () {
                      _vocabulaireRepository.goVocabulaires(vocabulaireEnd: vocabulaireEnd,vocabulaireBegin: vocabulaireBegin,guidListPerso: guidListPerso,context: context,titleList: title );
                      Navigator.pushNamed(context, '/vocabulary/voicedictation');
                    },
                    iconContent: Icons.play_circle,
                    context: context,
                    iconSize: IconSize.bigIcon,
                  ),
                  ElevatedButtonCardHome(
                    colorIcon: Colors.green,
                    onClickButton: () {
                      _vocabulaireRepository.goVocabulaires(vocabulaireEnd: vocabulaireEnd,vocabulaireBegin: vocabulaireBegin,guidListPerso: guidListPerso,context: context,titleList: title );
                      Navigator.pushNamed(context, '/vocabulary/pronunciation');
                    },
                    iconContent: Icons.mic,
                    context: context,
                    iconSize: IconSize.bigIcon,
                  ),
                  ElevatedButtonCardHome(
                    colorIcon: Colors.green,
                    onClickButton: () {
                      _vocabulaireRepository.goVocabulaires(isVocabularyNotLearned:true,vocabulaireEnd: vocabulaireEnd,vocabulaireBegin: vocabulaireBegin,guidListPerso: guidListPerso,context: context,titleList: title );
                      Navigator.pushNamed(context, '/vocabulary/quizz');
                    },
                    iconContent: Icons.assignment,
                    context: context,
                    iconSize: IconSize.bigIcon,
                  ),
                ],
              ),
            ],
          ),
            if(isListPero)...[
              CardHomeStatisticalWidget(
                widthWidget: widthWidget,
                listPerso: listPerso,
                barColorProgress: backgroundColor == Colors.green ? Colors.white : Colors.green,
                barColorLeft: backgroundColor == Colors.white ? Colors.orange : Colors.white,
                paddingLevelBar: paddingLevelBar,
              ),
            ],
            if(!isListPero)...[
              CardHomeStatisticalWidget(
                widthWidget: widthWidget,
                vocabulaireBegin: vocabulaireBegin,
                vocabulaireEnd: vocabulaireEnd,
                barColorProgress: backgroundColor == Colors.green ? Colors.white : Colors.green,
                barColorLeft: backgroundColor == Colors.white ? Colors.orange : Colors.white,
                paddingLevelBar: paddingLevelBar,
              ),
            ]
          ],

          if (editMode) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.only(left:15),
                  child:Text("$nbVocabulaire mot(s)",
                      style:TextStyle(
                          color:Colors.white,
                          fontWeight: FontWeight.bold
                      )
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (ownListShare) ...[
                      ElevatedButtonCardHome(
                        colorIcon: Colors.green,
                        onClickButton: () {
                          _vocabulaireUserRepository.editListPerso(guid: guid);
                        },
                        iconContent: Icons.edit,
                        context: context,
                      ),
                    ],
                    ElevatedButtonCardHome(
                      colorIcon: Colors.red,
                      onClickButton: () {
                        BlocProvider.of<VocabulaireUserBloc>(context).add(DeleteListPerso(guid));
                      },
                      iconContent: Icons.delete,
                      context: context,
                    ),
                    ElevatedButtonCardHome(
                      colorIcon: Colors.blue,
                      onClickButton: () {
                        _vocabulaireUserRepository.shareListPerso(guid: guid);
                      },
                      iconContent: Icons.share,
                      context: context,
                    ),
                  ],
                ),
              ],
            )
          ],
        ],
      ),
    );
  }


}
