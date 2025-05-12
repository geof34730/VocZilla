import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/utils/enum.dart';
import '../../../../data/repository/vocabulaires_repository.dart';
import '../../../theme/appColors.dart';

import '../../statistical/card_home_statisctical_widget.dart';
import 'ElevatedButtonCardHome.dart';
import '../LevelChart.dart';

class CardHome extends StatelessWidget {
  final String title;
  final bool editMode;
  final EdgeInsetsGeometry paddingLevelBar;
  final Color backgroundColor;
  final int vocabulaireBegin;
  final int vocabulaireEnd;


  CardHome({
    required this.title,
    required this.vocabulaireBegin,
    required this.vocabulaireEnd,
    this.editMode = false,
    this.backgroundColor = AppColors.colorTextTitle,
    this.paddingLevelBar = const EdgeInsets.all(0),
  });

  @override
  Widget build(BuildContext context) {
    final _vocabulairesRepository=VocabulairesRepository(context:context);
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
                          _vocabulairesRepository.goVocabulairesTop(vocabulaireBegin: vocabulaireBegin, vocabulaireEnd: vocabulaireEnd, titleList: title.toUpperCase());
                          Navigator.pushNamed(context, '/vocabulary/list');
                        },
                        iconContent: Icons.list,
                        context: context,
                        iconSize: IconSize.bigIcon,
                      ),
                      ElevatedButtonCardHome(
                        colorIcon: Colors.green,
                        onClickButton: () {
                          _vocabulairesRepository.goVocabulairesTop(vocabulaireBegin: vocabulaireBegin, vocabulaireEnd: vocabulaireEnd, titleList: title.toUpperCase());
                          Navigator.pushNamed(context, '/vocabulary/learn');
                        },
                        iconContent: Icons.school_rounded,
                        context: context,
                        iconSize: IconSize.bigIcon,
                      ),
                      ElevatedButtonCardHome(
                        colorIcon: Colors.green,
                        onClickButton: () {
                          _vocabulairesRepository.goVocabulairesTop(vocabulaireBegin: vocabulaireBegin, vocabulaireEnd: vocabulaireEnd, titleList: title.toUpperCase());
                          Navigator.pushNamed(context, '/vocabulary/voicedictation');
                        },
                        iconContent: Icons.play_circle,
                        context: context,
                        iconSize: IconSize.bigIcon,
                      ),
                      ElevatedButtonCardHome(
                        colorIcon: Colors.green,
                        onClickButton: () {
                          _vocabulairesRepository.goVocabulairesTop(vocabulaireBegin: vocabulaireBegin, vocabulaireEnd: 49, titleList: title.toUpperCase());
                          Navigator.pushNamed(context, '/vocabulary/pronunciation');
                        },
                        iconContent: Icons.mic,
                        context: context,
                        iconSize: IconSize.bigIcon,
                      ),
                      ElevatedButtonCardHome(
                        colorIcon: Colors.green,
                        onClickButton: () {
                          _vocabulairesRepository.goVocabulairesTop(vocabulaireBegin: vocabulaireBegin, vocabulaireEnd: vocabulaireEnd, titleList: title.toUpperCase());
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
                    ElevatedButtonCardHome(
                      colorIcon: Colors.green,
                      onClickButton: () {},
                      iconContent: Icons.edit,
                      context: context,
                    ),
                    ElevatedButtonCardHome(
                      colorIcon: Colors.red,
                      onClickButton: () {},
                      iconContent: Icons.delete,
                      context: context,
                    ),
                    ElevatedButtonCardHome(
                      colorIcon: Colors.blue,
                      onClickButton: () {},
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
