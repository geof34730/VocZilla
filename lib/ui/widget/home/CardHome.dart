import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/utils/enum.dart';
import '../../../data/repository/vocabulaire_repository.dart';
import '../../../data/repository/vocabulaire_user_repository.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_bloc.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_event.dart';
import '../../theme/appColors.dart';

import '../statistical/card_home_statisctical_widget.dart';
import 'ElevatedButtonCardHome.dart';
import '../elements/LevelChart.dart';

class CardHome extends StatelessWidget {
  final String title;
  final bool editMode;
  final EdgeInsetsGeometry paddingLevelBar;
  final Color backgroundColor;
  final int vocabulaireBegin;
  final int vocabulaireEnd;
  final bool ownListShare;
  final String guid;
  VocabulaireUserRepository _vocabulaireUserRepository = VocabulaireUserRepository();

  CardHome({
    required this.title,
    required this.vocabulaireBegin,
    required this.vocabulaireEnd,
    this.editMode = false,
    this.ownListShare = false,
    this.guid ="",
    this.backgroundColor = AppColors.colorTextTitle,
    this.paddingLevelBar = const EdgeInsets.all(0),
  });

  @override
  Widget build(BuildContext context) {
    final _vocabulaireRepository=VocabulaireRepository();
    return LayoutBuilder(builder: (context, constraints) {
      double widthWidget = constraints.maxWidth;
      return Container(
        width: widthWidget,
        child: Card(
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
                          _vocabulaireRepository.goVocabulairesTop(context:context,vocabulaireBegin: vocabulaireBegin, vocabulaireEnd: vocabulaireEnd, titleList: title.toUpperCase());
                          Navigator.pushNamed(context, '/vocabulary/list');
                        },
                        iconContent: Icons.list,
                        context: context,
                        iconSize: IconSize.bigIcon,
                      ),
                      ElevatedButtonCardHome(
                        colorIcon: Colors.green,
                        onClickButton: () {
                          _vocabulaireRepository.goVocabulairesTop(context:context,isVocabularyNotLearned:true,vocabulaireBegin: vocabulaireBegin, vocabulaireEnd: vocabulaireEnd, titleList: title.toUpperCase());
                          Navigator.pushNamed(context, '/vocabulary/learn');
                        },
                        iconContent: Icons.school_rounded,
                        context: context,
                        iconSize: IconSize.bigIcon,
                      ),
                      ElevatedButtonCardHome(
                        colorIcon: Colors.green,
                        onClickButton: () {
                          _vocabulaireRepository.goVocabulairesTop(context:context,vocabulaireBegin: vocabulaireBegin, vocabulaireEnd: vocabulaireEnd, titleList: title.toUpperCase());
                          Navigator.pushNamed(context, '/vocabulary/voicedictation');
                        },
                        iconContent: Icons.play_circle,
                        context: context,
                        iconSize: IconSize.bigIcon,
                      ),
                      ElevatedButtonCardHome(
                        colorIcon: Colors.green,
                        onClickButton: () {
                          _vocabulaireRepository.goVocabulairesTop(context:context,vocabulaireBegin: vocabulaireBegin, vocabulaireEnd: 49, titleList: title.toUpperCase());
                          Navigator.pushNamed(context, '/vocabulary/pronunciation');
                        },
                        iconContent: Icons.mic,
                        context: context,
                        iconSize: IconSize.bigIcon,
                      ),
                      ElevatedButtonCardHome(
                        colorIcon: Colors.green,
                        onClickButton: () {
                          _vocabulaireRepository.goVocabulairesTop(context:context,isVocabularyNotLearned:true,vocabulaireBegin: vocabulaireBegin, vocabulaireEnd: vocabulaireEnd, titleList: title.toUpperCase());
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

              CardHomeStatisticalWidget(
                widthWidget: widthWidget,
                vocabulaireBegin: vocabulaireBegin,
                vocabulaireEnd: vocabulaireEnd,
                barColorProgress: backgroundColor == Colors.green ? Colors.white : Colors.green,
                barColorLeft: backgroundColor == Colors.white ? Colors.orange : Colors.white,
                paddingLevelBar: paddingLevelBar,
              ),
              if (editMode) ...[
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
            ],
          ),
        ),
      );
    });
  }
}
