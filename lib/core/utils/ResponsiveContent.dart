
import 'package:flutter/material.dart';

class ResponsiveContent{
  final BuildContext context;
  ResponsiveContent({
    required this.context
  });





  int getFlexListePerso({required int lenghtVerbs,required int numVerb}) =>((lenghtVerbs==1) ? 12 : ((lenghtVerbs==numVerb+1) ? ((numVerb.isEven) ? 12 : 6 ) : 6));


}
