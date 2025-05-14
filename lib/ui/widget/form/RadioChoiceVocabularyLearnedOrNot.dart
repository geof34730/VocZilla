import 'package:flutter/material.dart';

import '../../../data/repository/vocabulaires_repository.dart';

class RadioChoiceVocabularyLearnedOrNot extends StatelessWidget {
  final VocabulairesRepository vocabulairesRepository;
  final dynamic state;
  final int vocabulaireConnu;

  RadioChoiceVocabularyLearnedOrNot({
    Key? key,
    required this.vocabulairesRepository,
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
            vocabulairesRepository.goVocabulairesTop(
                isVocabularyNotLearned:true,
                vocabulaireBegin: state.data["vocabulaireBegin"] as int,
                vocabulaireEnd: state.data["vocabulaireEnd"] as int ,
                titleList: state.data["titleList"] as String
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
            vocabulairesRepository.goVocabulairesTop(
                isVocabularyNotLearned:false,
                vocabulaireBegin: state.data["vocabulaireBegin"] as int,
                vocabulaireEnd: state.data["vocabulaireEnd"] as int ,
                titleList: state.data["titleList"] as String
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
