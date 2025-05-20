import 'package:flutter/material.dart';

import '../../../core/utils/logger.dart';
import '../../../data/repository/vocabulaire_repository.dart';

class RadioChoiceVocabularyLearnedOrNot extends StatelessWidget {
  final VocabulaireRepository vocabulaireRepository;
  final dynamic state;
  final int vocabulaireConnu;

  RadioChoiceVocabularyLearnedOrNot({
    Key? key,
    required this.vocabulaireRepository,
    required this.state,
    required this.vocabulaireConnu
  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return  Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: () {
            vocabulaireRepository.goVocabulairesTop(
                context:context,
                isVocabularyNotLearned:true,
                vocabulaireBegin: state.data.vocabulaireBegin,
                vocabulaireEnd: state.data.vocabulaireEnd,
                titleList: state.data.titleList
            );
          },
          child: Row(
            children: [
              Radio<int>(
                value: 0,
                groupValue: vocabulaireConnu,
                onChanged: (int? value) {

                },
              ),
              Text("vocabulaire encore à apprendre"),
            ],
          ),
        ),
        SizedBox(width: 16),
        InkWell(
          onTap: () {
            vocabulaireRepository.goVocabulairesTop(
                context:context,
                isVocabularyNotLearned:false,
                vocabulaireBegin: state.data.vocabulaireBegin,
                vocabulaireEnd: state.data.vocabulaireEnd ,
                titleList: state.data.titleList
            );
            // reset();
          },
          child: Row(
            children: [
              Radio<int>(
                value: 1,
                groupValue: vocabulaireConnu,
                onChanged: (int? value) {
                },
              ),
              Text("tous les vocabulaires"),
            ],
          ),
        ),
      ],
    );
  }
}
