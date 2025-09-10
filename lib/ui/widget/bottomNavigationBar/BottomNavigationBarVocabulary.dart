import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voczilla/core/utils/localization.dart';
import 'package:voczilla/data/repository/vocabulaire_repository.dart';
import 'package:voczilla/ui/theme/appColors.dart';

import '../../../core/utils/logger.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_bloc.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_state.dart';

class BottomNavigationBarVocabulary extends StatelessWidget implements PreferredSizeWidget {
  final int itemSelected;
  final String local;
  final String? listName ;

  const BottomNavigationBarVocabulary({super.key,  required this.itemSelected, required this.local, required this.listName});

  @override
  Widget build(BuildContext context) {
    VocabulaireRepository _vocabulaireRepository=VocabulaireRepository();
    return Container(
        decoration: BoxDecoration(
        boxShadow: <BoxShadow>[
          BoxShadow(
          color: Colors.black54,
          blurRadius: 5.0,
          offset: Offset(0.0, 0.75)
        )
      ],
    ),
    child:BlocBuilder<VocabulairesBloc, VocabulairesState>(
      builder: (context, state) {
          if (state is VocabulairesLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is VocabulairesLoaded) {

            return BottomNavigationBar(
                backgroundColor: AppColors.cardBackground,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                iconSize: 40,
                type: BottomNavigationBarType.fixed,
                // Change to fixed for better control
                selectedIconTheme: IconThemeData(color: Colors.white),
                unselectedIconTheme: IconThemeData(color: Colors.black54),
                selectedItemColor: Colors.black,
                unselectedItemColor: Colors.black,
                selectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                items: <BottomNavigationBarItem>[
                  _buildBottomNavigationBarItem(
                      Icons.list, context.loc.liste_title, 0),
                  _buildBottomNavigationBarItem(
                      Icons.school_rounded, context.loc.apprendre_title, 1),
                  _buildBottomNavigationBarItem(
                      Icons.play_circle, context.loc.dictation_title, 2),
                  _buildBottomNavigationBarItem(
                      Icons.mic, context.loc.pronunciation_title, 3),
                  _buildBottomNavigationBarItem(
                      Icons.assignment, context.loc.tester_title, 4),
                  //_buildBottomNavigationBarItem(Icons.bar_chart, context.loc.statistiques_title, 5),
                ],
                currentIndex: itemSelected,
                // Set the initial selected index

                onTap: (value) {
                  switch (value) {
                    case 0:
                      _vocabulaireRepository.goVocabulairesWithState(state:state, context:context, local: local);
                      Navigator.pushReplacementNamed(context, '/vocabulary/list${addListName(listName:listName)}');
                      break;
                    case 1:
                      _vocabulaireRepository.goVocabulairesWithState(state:state, context:context, isVocabularyNotLearned: true, local: local);
                      Navigator.pushReplacementNamed(context, '/vocabulary/learn${addListName(listName:listName)}');
                      break;
                    case 2:
                      _vocabulaireRepository.goVocabulairesWithState(state:state, context:context, local: local);
                      Navigator.pushReplacementNamed(context, '/vocabulary/voicedictation${addListName(listName:listName)}');
                      break;
                    case 3:
                      _vocabulaireRepository.goVocabulairesWithState(state:state, context:context, local: local);
                      Navigator.pushReplacementNamed( context, '/vocabulary/pronunciation${addListName(listName:listName)}');
                      break;
                    case 4:
                      _vocabulaireRepository.goVocabulairesWithState(state:state, context:context, isVocabularyNotLearned: true, local: local);
                      Navigator.pushReplacementNamed(context, '/vocabulary/quizz${addListName(listName:listName)}');
                      break;
                    case 5:
                      _vocabulaireRepository.goVocabulairesWithState(state:state, context:context, local: local);
                      Navigator.pushReplacementNamed(context, '/vocabulary/statistical${addListName(listName:listName)}');
                      break;
                  }
                },
              );
          } else if (state is VocabulairesError) {
            return Center(child: Text(context.loc.error_loading));
          } else {
            return Center(child: Text(context.loc.unknown_error)); // fallback
          }
        }
      )
   );
  }


  addListName({required String? listName}){


    return '/$listName';
  }

  BottomNavigationBarItem _buildBottomNavigationBarItem(IconData icon, String label, int index) {
    return BottomNavigationBarItem(
      icon: Container(
        decoration: BoxDecoration(
          color: index == itemSelected ? Colors.green : Colors.white, // Change index to currentIndex
          shape: BoxShape.circle,
        ),
        padding: EdgeInsets.all(4.0), // Add padding for the background
        child: Icon(icon),
      ),
      label: label,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);


}
