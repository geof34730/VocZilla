import 'package:flutter/material.dart';
import 'package:horizontal_scroll_view/horizontal_scroll_view.dart';

HorizontalScrollView HorizontalScrollViewCardHome({required List<Widget> children,  double itemWidth = 320}) {
  return HorizontalScrollView(
      itemWidth: itemWidth,
      crossAxisSpacing: 8.0,
      alignment: CrossAxisAlignment.center,
      children: children
  );
}
double itemWidthListPerso({required int nbList, required BuildContext context}) {
  double largeurCard = 320;
  double space = 8;
  if(nbList == 1){
    largeurCard = MediaQuery.sizeOf(context).width-(space*2);
  }
  if(nbList == 2){
    largeurCard = (MediaQuery.sizeOf(context).width/2)-(space*2);
  }
  if(nbList > 2){
    largeurCard = 320;
  }
  if(largeurCard < 320){
    largeurCard = 320;
  }
  return largeurCard;
}
