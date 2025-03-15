import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/appColors.dart';
import '../../enum.dart';
import 'ElevatedButtonCardHome.dart';
import '../LevelChart.dart';

class CardHome extends StatelessWidget {
  final String title;
  final bool editMode;
  final EdgeInsetsGeometry paddingLevelBar;
  final Color backgroundColor;

  CardHome({
    required this.title,
    this.editMode = false,
    this.backgroundColor = AppColors.colorTextTitle,
    this.paddingLevelBar = const EdgeInsets.all(0),
  });

  @override
  Widget build(BuildContext context) {
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
                        onClickButton: () {},
                        iconContent: Icons.school_rounded,
                        context: context,
                        iconSize: IconSize.bigIcon,
                      ),
                      ElevatedButtonCardHome(
                        colorIcon: Colors.green,
                        onClickButton: () {},
                        iconContent: Icons.quiz_rounded,
                        context: context,
                        iconSize: IconSize.bigIcon,
                      ),
                      ElevatedButtonCardHome(
                        colorIcon: Colors.green,
                        onClickButton: () {},
                        iconContent: Icons.visibility,
                        context: context,
                        iconSize: IconSize.bigIcon,
                      ),
                      ElevatedButtonCardHome(
                        colorIcon: Colors.green,
                        onClickButton: () {},
                        iconContent: Icons.playlist_play_outlined,
                        context: context,
                        iconSize: IconSize.bigIcon,
                      ),
                      ElevatedButtonCardHome(
                        colorIcon: Colors.orange,
                        onClickButton: () {},
                        iconContent: Icons.bar_chart,
                        context: context,
                        iconSize: IconSize.bigIcon,
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                width: widthWidget * 0.80,
                child: LevelChart(
                  level: 65,
                  levelMax: 100,
                  imageCursor: false,
                  padding: paddingLevelBar,
                  barColorProgress: backgroundColor == Colors.green ? Colors.white : Colors.green,
                  barColorLeft: backgroundColor == Colors.white ? Colors.orange : Colors.white,
                ),
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
