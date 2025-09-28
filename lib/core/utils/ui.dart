import 'package:flutter/material.dart';
import 'package:horizontal_scroll_view/horizontal_scroll_view.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'logger.dart';


Widget HorizontalScrollViewCardHome({required List<Widget> children,  double itemWidth = 340}) {
  return HorizontalScrollView(
      itemWidth: itemWidth,
      crossAxisSpacing: 8.0,
      alignment: CrossAxisAlignment.center,
      children: children
  );
}
double itemWidthListPerso({required int nbList, required BuildContext context}) {
  double largeurCard = 340;
  double space = 8;
  if(nbList == 1){
    largeurCard = MediaQuery.sizeOf(context).width-(space*2);
  }
  if(nbList == 2){
    largeurCard = (MediaQuery.sizeOf(context).width/2)-(space*2);
  }
  if(nbList > 2){
    largeurCard = 340;
  }
  if(largeurCard < 340){
    largeurCard = 340;
  }
  return largeurCard;
}



