import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:voczilla/core/utils/localization.dart';
import '../../../core/utils/enum.dart';
import '../../../core/utils/getFontForLanguage.dart';
import '../../../data/repository/vocabulaire_repository.dart';
import '../../../global.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_bloc.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_event.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_state.dart';
import '../../theme/appColors.dart';
import '../statistical/card_home_statisctical_widget.dart';
import 'ElevatedButtonCardHome.dart';
import 'custom_ribbon.dart';

class CardHome extends StatefulWidget {
  final String title;
  final bool editMode;
  final EdgeInsetsGeometry paddingLevelBar;
  final Color backgroundColor;
  final int? vocabulaireBegin;
  final int? vocabulaireEnd;
  final bool ownListShare;
  final bool isListShare;
  final bool isListPerso;
  final bool isListTheme;
  final dynamic list;
  final String guid;
  final int nbVocabulaire;
  final String keyStringTest;
  final String listName;
  final bool isListEnd;


  CardHome({

    this.nbVocabulaire=0,
    required this.title,
    this.vocabulaireBegin,
    this.vocabulaireEnd,
    this.editMode = false,
    this.isListPerso = false,
    this.isListTheme = false,
    this.ownListShare = false,
    this.isListShare = false,
    this.guid ="",
    this.list,
    this.backgroundColor = AppColors.colorTextTitle,
    this.paddingLevelBar = const EdgeInsets.all(0),
    required this.keyStringTest,
    required this.listName,
    required this.isListEnd
  });

  @override
  State<CardHome> createState() => _CardHomeState();
}

class _CardHomeState extends State<CardHome> {
  final _vocabulaireRepository = VocabulaireRepository();

  @override
  Widget build(BuildContext context) {
    String local = Localizations.localeOf(context).languageCode;


        return LayoutBuilder(builder: (context, constraints) {
          double widthWidget = constraints.maxWidth;

          // Le contenu de la carte est maintenant construit ici
          Widget cardCore = BoxCardHome(context: context, widthWidget: widthWidget, local: local, isListEnd: widget.isListEnd);

          // On applique le ruban si nécessaire
          if (widget.isListShare && !widget.ownListShare) {
            cardCore = CustomRibbon(
                color: Colors.blue,
                child: cardCore,
                title: Text(
                  context.loc.card_home_share.toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            );
          } else if (widget.isListEnd) {
            cardCore = CustomRibbon(
                color: Colors.green,
                child: cardCore,
                title: Text(
                  context.loc.card_home_finished.toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold),
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
            );
          }

          // On utilise un Stack pour superposer l'icône par-dessus la carte (avec ou sans ruban)
          return Stack(
            clipBehavior: Clip.none,
            children: [
              cardCore,
              // L'icône est maintenant ici, au-dessus de tout
              if(!widget.isListPerso && widget.listName.startsWith("top") && widget.isListEnd)
                Positioned(
                  top: -5, // Dépasse de 10px en haut
                  right: -5, // Dépasse de 10px à droite
                  child: SvgPicture.asset(
                    "assets/svg/achievement-award-medal-icon.svg",
                    height: 40,
                  ),
                ),
            ],
          );
        });

  }

  Card BoxCardHome({required BuildContext context,required bool isListEnd, required double widthWidget, required String local}){
    return Card(
      color: isListEnd  ? Colors.grey.shade400 : widget.backgroundColor,
      child: Column( // Le contenu principal de la carte
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  widget.title.toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: getFontForLanguage(
                    codelang: Localizations.localeOf(context).languageCode,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    // Tu peux ajouter fontWeight si besoin
                  ).copyWith(
                    color: widget.backgroundColor == Colors.white ? Colors.black : Colors.white,
                  ),
                ),
              ),

             if(widget.nbVocabulaire==0 && widget.isListPerso)...[
               Container(
                 height: 80,
                 padding: EdgeInsets.only(left:5, right:5),
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Text(
                       context.loc.no_vocabulary_in_my_list,
                       style: TextStyle(
                         color: Colors.white,
                       ),
                       textAlign: TextAlign.center,
                       maxLines: 2,
                       overflow: TextOverflow.ellipsis,
                     ),
                   ],
                 ),
               )
             ],

              if((widget.isListPerso ? widget.nbVocabulaire>0 : true))...[
                Wrap(
                alignment: WrapAlignment.center,
                verticalDirection: VerticalDirection.down,
                spacing: 10.0,
                runSpacing: 0.0,
                children: [
                  // Le SvgPicture a été déplacé en dehors de ce Wrap
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButtonCardHome(
                        valueKey: "buttonList${widget.keyStringTest}",
                        colorIcon: isListEnd ? Colors.green.shade300 : Colors.green,
                        onClickButton: () {
                          _vocabulaireRepository.goVocabulaires(local:local,vocabulaireEnd: widget.vocabulaireEnd,vocabulaireBegin: widget.vocabulaireBegin,guid: widget.guid,context: context,titleList: widget.title,isListPerso:widget.isListPerso,isListTheme:widget.isListTheme  );
                          Navigator.pushNamed(context, '/vocabulary/list/${widget.keyStringTest}');
                        },
                        iconContent: Icons.list,
                        context: context,
                        iconSize: IconSize.bigIcon,
                      ),
                      ElevatedButtonCardHome(
                        valueKey: 'buttonLearn${widget.keyStringTest}',
                        colorIcon: isListEnd ? Colors.green.shade300 : Colors.green,
                        onClickButton: () {
                          _vocabulaireRepository.goVocabulaires(local:local,isVocabularyNotLearned:true,vocabulaireEnd: widget.vocabulaireEnd,vocabulaireBegin: widget.vocabulaireBegin,guid: widget.guid,context: context,titleList: widget.title,isListPerso:widget.isListPerso,isListTheme:widget.isListTheme );
                          Navigator.pushNamed(context, '/vocabulary/learn/${widget.keyStringTest}');
                        },
                        iconContent: Icons.school_rounded,
                        context: context,
                        iconSize: IconSize.bigIcon,
                      ),
                      ElevatedButtonCardHome(
                        valueKey: 'buttonVoiceDictation${widget.keyStringTest}',
                        colorIcon: isListEnd ? Colors.green.shade300 : Colors.green,
                        onClickButton: () {
                          _vocabulaireRepository.goVocabulaires(local:local,vocabulaireEnd: widget.vocabulaireEnd,vocabulaireBegin: widget.vocabulaireBegin,guid: widget.guid,context: context,titleList: widget.title,isListPerso:widget.isListPerso,isListTheme:widget.isListTheme );
                          Navigator.pushNamed(context, '/vocabulary/voicedictation/${widget.keyStringTest}');
                        },
                        iconContent: Icons.play_circle,
                        context: context,
                        iconSize: IconSize.bigIcon,
                      ),
                      ElevatedButtonCardHome(
                        valueKey: 'buttonPrononciation${widget.keyStringTest}',
                        colorIcon: isListEnd ? Colors.green.shade300 : Colors.green,
                        onClickButton: () {
                          _vocabulaireRepository.goVocabulaires(local:local,vocabulaireEnd: widget.vocabulaireEnd,vocabulaireBegin: widget.vocabulaireBegin,guid: widget.guid,context: context,titleList: widget.title,isListPerso:widget.isListPerso,isListTheme:widget.isListTheme );
                          Navigator.pushNamed(context, '/vocabulary/pronunciation/${widget.keyStringTest}');
                        },
                        iconContent: Icons.mic,
                        context: context,
                        iconSize: IconSize.bigIcon,
                      ),
                      ElevatedButtonCardHome(
                        valueKey: 'buttonQuizz${widget.keyStringTest}',
                        colorIcon: isListEnd ? Colors.green.shade300 : Colors.green,
                        onClickButton: () {
                          _vocabulaireRepository.goVocabulaires(local:local,isVocabularyNotLearned:true,vocabulaireEnd: widget.vocabulaireEnd,vocabulaireBegin: widget.vocabulaireBegin,guid: widget.guid,context: context,titleList: widget.title,isListPerso:widget.isListPerso,isListTheme:widget.isListTheme );
                          Navigator.pushNamed(context, '/vocabulary/quizz/${widget.keyStringTest}');
                        },
                        iconContent: Icons.assignment,
                        context: context,
                        iconSize: IconSize.bigIcon,
                      ),
                    ],
                  ),
                ],
              ),
                  Padding(
                    padding:EdgeInsets.only(top:5,bottom:widget.editMode ? 0 : 8,left:10,right:10),
                    child:CardHomeStatisticalWidget(
                        listName: widget.listName,
                        widthWidget: widthWidget,
                        list: widget.list,
                        isListTheme: widget.isListPerso,
                        isListPerso: widget.isListTheme,
                        vocabulaireBegin: widget.vocabulaireBegin,
                        vocabulaireEnd: widget.vocabulaireEnd,
                        barColorProgress: Colors.green,
                        barColorLeft:  Colors.orange ,
                        paddingLevelBar: widget.paddingLevelBar,
                        local:local
                      ),
                  )
              ],

              if (widget.editMode) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left:15),
                      child:Text("${widget.nbVocabulaire} ${context.loc.card_home_mot}",
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
                        if (widget.ownListShare) ...[
                          ElevatedButtonCardHome(
                            valueKey: 'buttonPersoStep1${widget.keyStringTest}',
                            colorIcon: Colors.green,
                            onClickButton: () {
                              print(widget.guid);
                              Navigator.pushNamed(context, '/personnalisation/step1/${widget.guid}');
                            },
                            iconContent: Icons.edit,
                            context: context,
                          ),
                        ],
                        ElevatedButtonCardHome(
                          valueKey: "buttonDeletePerso${widget.keyStringTest}",
                          colorIcon: Colors.red,
                          onClickButton: () {
                            if(testScreenShot) {
                              BlocProvider.of<VocabulaireUserBloc>(context).add(DeleteListPerso(listPersoGuid: widget.guid, local:local));
                            }
                            else {
                              showDialog(
                                context: context,
                                builder: (BuildContext dialogContext) {
                                  return AlertDialog(
                                    title: Text(context.loc
                                        .alert_dialogue_suppression_list_title),

                                    content: Text("${context.loc
                                        .alert_dialogue_suppression_list_question
                                        .replaceAll("?", "")} ${widget.title} ?"),
                                    actions: <Widget>[
                                      OutlinedButton(
                                        child: Text(context.loc.non),
                                        onPressed: () {
                                          Navigator.of(dialogContext).pop();
                                        },
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.grey.shade700,
                                          side: BorderSide(
                                              color: Colors.grey.shade400),
                                        ),
                                      ),
                                      ElevatedButton(
                                        child: Text(context.loc.oui),
                                        onPressed: () {
                                          BlocProvider.of<VocabulaireUserBloc>(context).add(DeleteListPerso(listPersoGuid: widget.guid, local: local));
                                          Navigator.of(dialogContext).pop();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          iconContent: Icons.delete,
                          context: context,
                        ),
                        /*ElevatedButtonCardHome(
                          valueKey: 'buttonSharePerso${widget.keyStringTest}',
                          colorIcon: Colors.blue,
                          onClickButton: () {
                            _vocabulaireUserRepository.shareListPerso(guid: widget.guid);
                          },
                          iconContent: Icons.share,
                          context: context,
                        ),*/
                        ElevatedButtonCardHome(
                          valueKey: 'buttonSharePerso${widget.keyStringTest}',
                          colorIcon: Colors.blue,
                          onClickButton: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext dialogContext) {
                                return AlertDialog(
                                  title: Text(context.loc.information),
                                  content: Text(context.loc.share_list_perso_alert_disponible),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text("OK"),
                                      onPressed: () {
                                        Navigator.of(dialogContext).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
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
