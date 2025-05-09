import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/vocabulary_user.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_bloc.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_event.dart';
import '../../../logic/blocs/vocabulaire_user/vocabulaire_user_state.dart';


class HomelistPerso extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VocabulaireUserBloc, VocabulaireUserState>(
      builder: (context, state) {
        if (state is VocabulaireUserLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is VocabulaireUserLoaded) {
          final userData = state.userData;
          return SizedBox(
            height: 100, // Définissez la hauteur souhaitée
            child: ListView.builder(
              itemCount: userData.listPerso.length,
              itemBuilder: (context, index) {
                final listPerso = userData.listPerso[index];
                return ListTile(
                  title: Text(listPerso.title),
                  subtitle: Text('Couleur: ${listPerso.color}'),
                  // Ajoutez plus d'éléments UI si nécessaire
                );
              },
            ),
          );
        } else if (state is VocabulaireUserError) {
          return Center(child: Text('Erreur: ${state.message}'));
        }
        return Center(child: Text('Aucune donnée disponible'));
      },
    );
  }
}

