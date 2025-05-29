import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vobzilla/core/utils/localization.dart';
import 'package:vobzilla/ui/theme/appColors.dart';
import '../../../data/repository/vocabulaire_repository.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_bloc.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_event.dart';

class RadioChoiceVocabularyLearnedOrNot extends StatelessWidget {
  final VocabulaireRepository vocabulaireRepository;
  final dynamic state;
  final int vocabulaireConnu; // 0: à apprendre, 1: tous/appris
  final String? guidListPerso;

  const RadioChoiceVocabularyLearnedOrNot({
    Key? key,
    required this.vocabulaireRepository,
    required this.state,
    required this.vocabulaireConnu,
    this.guidListPerso
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white38,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildChoiceButton(
            context: context,
            label: context.loc.widget_radiochoicevocabularylearnedornot_choice1,
            icon: Icons.menu_book_rounded,
            isSelected: vocabulaireConnu == 0,
            onTap: () {
              if(guidListPerso != null) {
                BlocProvider.of<VocabulairesBloc>(context).add(getAllVocabulaire(true, guidListPerso!));
              }
              else {
                vocabulaireRepository.goVocabulairesWithState(
                  context: context,
                  isVocabularyNotLearned: true,
                  state: state,
                );
              }
            },
          ),
          const SizedBox(width: 8),
          _buildChoiceButton(
            context: context,
            label: context.loc.widget_radiochoicevocabularylearnedornot_choice2,
            icon: null,
            isSelected: vocabulaireConnu == 1,
            onTap: () {
              if(guidListPerso != null) {
                BlocProvider.of<VocabulairesBloc>(context).add(getAllVocabulaire(false, guidListPerso!));
              }
              else {
                vocabulaireRepository.goVocabulairesWithState(
                  context: context,
                  isVocabularyNotLearned: false,
                  state: state,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceButton({
    required BuildContext context,
    required String label,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20, color: Colors.white),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
                fontSize: 11
              ),
            ),
          ],
        ),
      ),
    );
  }
}
