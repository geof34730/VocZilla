import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../theme/appColors.dart';

import 'ElevatedButtonCardHome.dart';
import '../LevelChart.dart';

class CardHome extends StatefulWidget {
  final String title;
  final bool editMode;
  final EdgeInsetsGeometry paddingLevelBar;
  final Color backgroundColor;
  CardHome({ required this.title, this.editMode = false,this.backgroundColor = AppColors.colorTextTitle,  this.paddingLevelBar = const EdgeInsets.all(0)}) ;
  @override
  _CardHomeState createState() => _CardHomeState();
}

class _CardHomeState extends State<CardHome> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double widthWidget = constraints.maxWidth;
      return Container(
        width:widthWidget,
        child: Card(
          color: widget.backgroundColor,
          child: Column(
            children: [
              Text(
                widget.title.toUpperCase(),
                textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 24,
                      fontFamily: GoogleFonts.titanOne().fontFamily,
                      color: Colors.white
                  )
              ),

              Wrap(
                alignment: WrapAlignment.center,
                verticalDirection: VerticalDirection.down,
                spacing: 10.0,
                // gap between adjacent chips
                runSpacing: 0.0,
                // gap between lines
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButtonCardHome(
                          colorIcon: Colors.green,
                          onClickButton: (){},
                          iconContent:  Icons.school,
                          context: context,
                          iconSize: IconSize.bigIcon,
                      ),
                      ElevatedButtonCardHome(
                          colorIcon: Colors.green,
                          onClickButton: (){},
                          iconContent:  Icons.quiz,
                          context: context,
                          iconSize: IconSize.bigIcon,
                      ),
                      ElevatedButtonCardHome(
                          colorIcon: Colors.green,
                          onClickButton: (){},
                          iconContent:  Icons.visibility,
                          context: context,
                          iconSize: IconSize.bigIcon,
                      ),
                      ElevatedButtonCardHome(
                          colorIcon: Colors.green,
                          onClickButton: (){},
                          iconContent:  Icons.voice_chat,
                          context: context,
                          iconSize: IconSize.bigIcon,
                      ),
                      ElevatedButtonCardHome(
                          colorIcon: Colors.orange,
                          onClickButton: (){},
                          iconContent:  Icons.show_chart,
                          context: context,
                          iconSize: IconSize.bigIcon,
                      ),
                  ],
                  ),
                ],
              ),

              Container(
                width:widthWidget*0.80,
                child: LevelChart(
                  level: 80,
                  levelMax: 100,
                  imageCursor:false,
                  padding:widget.paddingLevelBar,
                  barColorProgress: widget.backgroundColor == Colors.green ? Colors.white : Colors.green,
                  barColorLeft: widget.backgroundColor == Colors.white ? Colors.orange : Colors.white,
                ),
              ),

            if (widget.editMode) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButtonCardHome(
                        colorIcon: Colors.green,
                        onClickButton: (){},
                        iconContent:  Icons.edit,
                        context: context
                    ),
                    ElevatedButtonCardHome(
                        colorIcon: Colors.red,
                        onClickButton: (){},
                        iconContent:  Icons.delete,
                        context: context
                    ),
                    ElevatedButtonCardHome(
                        colorIcon: Colors.blue,
                        onClickButton: (){},
                        iconContent:  Icons.share,
                        context: context
                    ),
                  ],
                )
               ]
            ],
          ),
        ),
      );
    });
  }
}
