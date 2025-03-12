import 'package:flutter/material.dart';

class ResponsiveContent{
  final BuildContext context;
  ResponsiveContent({
    required this.context
  });

  double widthBlockHome(){
    if(typeScreenBreakpoint()=="tablette"){
      return ((MediaQuery.of(context).size.width)/2)-30;
    }
    if(typeScreenBreakpoint()=="mobile"){
      return ((MediaQuery.of(context).size.width))-30;
    }
    return ((MediaQuery.of(context).size.width)/2)-30;
  }

  double sizeFlex({required int flexNumber}){
    final unitSize;
    if(MediaQuery.of(context).size.width>1280){
      unitSize=(1280/12);

    }
    else{
      unitSize=(MediaQuery.of(context).size.width/12);

    }


    return (unitSize*flexNumber);
  }

  String typeScreenBreakpoint (){
    const kMobileBreakpoint = 576;
    const kTabletBreakpoint = 1024;

    if(MediaQuery.of(context).size.width<=kMobileBreakpoint){
      return "mobile";
    }
    else{
      return "tablette";
    }
  }

  dynamic choseSize({required dynamic mobileSize, required otherSize}){
    if(typeScreenBreakpoint()=="tablette"){
      return otherSize;
    }
    else{
      return mobileSize;
    }
  }

  int getFlexListePerso({required int lenghtVerbs,required int numVerb}) =>((lenghtVerbs==1) ? 12 : ((lenghtVerbs==numVerb+1) ? ((numVerb.isEven) ? 12 : 6 ) : 6));


}
