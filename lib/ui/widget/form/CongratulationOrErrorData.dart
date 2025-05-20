


import 'package:flutter/material.dart';
import 'package:vobzilla/core/utils/localization.dart';

Widget CongratulationOrErrorData({required int vocabulaireConnu,required BuildContext context}){

   if(vocabulaireConnu==0) {
     return Column(
         children: [
           Padding(
               padding: EdgeInsets.only(top: 40),
               child: Text("✅ Bravo !!!",
                 style: TextStyle(
                     color: Colors.green,
                     fontSize: 35,
                     fontWeight: FontWeight.bold
                 ),
               )
           ),
           Text("vous avez terminé d'apprendre cette Liste",
             style: TextStyle(
               color: Colors.green,
               fontSize: 20,

             ),

           )
         ]
     );
   }
   else{

   return Center(child: Text(context.loc.no_vocabulary_items_found));
   }

}
