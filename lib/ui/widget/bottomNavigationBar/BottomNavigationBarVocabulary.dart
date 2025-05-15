import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/core/utils/localization.dart';
import 'package:vobzilla/data/repository/vocabulaires_repository.dart';
import 'package:vobzilla/ui/theme/appColors.dart';

import '../../../core/utils/logger.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_bloc.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_state.dart';

class BottomNavigationBarVocabulary extends StatelessWidget implements PreferredSizeWidget {
  final int itemSelected;

  const BottomNavigationBarVocabulary({super.key,  required this.itemSelected});

  @override
  Widget build(BuildContext context) {
    VocabulairesRepository _vocabulairesRepository=VocabulairesRepository(context: context);
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
                      _vocabulairesRepository.goVocabulairesTop(vocabulaireBegin: state.data.vocabulaireBegin, vocabulaireEnd: state.data.vocabulaireEnd, titleList: state.data.titleList.toUpperCase());
                      Navigator.pushReplacementNamed(context, '/vocabulary/list');
                      break;
                    case 1:
                      _vocabulairesRepository.goVocabulairesTop(isVocabularyNotLearned:true,vocabulaireBegin: state.data.vocabulaireBegin, vocabulaireEnd: state.data.vocabulaireEnd, titleList: state.data.titleList.toUpperCase());
                      Navigator.pushReplacementNamed(context, '/vocabulary/learn');
                      break;
                    case 2:
                      _vocabulairesRepository.goVocabulairesTop(vocabulaireBegin: state.data.vocabulaireBegin, vocabulaireEnd: state.data.vocabulaireEnd, titleList: state.data.titleList.toUpperCase());
                      Navigator.pushReplacementNamed(
                          context, '/vocabulary/voicedictation');
                      break;
                    case 3:
                      _vocabulairesRepository.goVocabulairesTop(vocabulaireBegin: state.data.vocabulaireBegin, vocabulaireEnd: state.data.vocabulaireEnd, titleList: state.data.titleList.toUpperCase());
                      Navigator.pushReplacementNamed(
                          context, '/vocabulary/pronunciation');
                      break;
                    case 4:
                      _vocabulairesRepository.goVocabulairesTop(isVocabularyNotLearned:true,vocabulaireBegin: state.data.vocabulaireBegin, vocabulaireEnd: state.data.vocabulaireEnd, titleList: state.data.titleList.toUpperCase());
                      Navigator.pushReplacementNamed(context, '/vocabulary/quizz');
                      break;
                    case 5:
                      Navigator.pushReplacementNamed(context, '/vocabulary/statistical');
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
