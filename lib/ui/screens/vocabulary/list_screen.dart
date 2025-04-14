import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/logic/cubit/localization_cubit.dart';

import '../../../logic/blocs/vocabulaires/vocabulaires_bloc.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_state.dart';


class ListScreen extends StatelessWidget {



  @override
  Widget build(BuildContext context) {
    var currentLocale = BlocProvider.of<LocalizationCubit>(context).state;
    return BlocBuilder<VocabulairesBloc, VocabulairesState>(
      builder: (context, state) {
        if (state is VocabulairesLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is VocabulairesLoaded) {
          final data = state.data;
          print("data: $data");

          return SingleChildScrollView(
            child: Column(
              children: data.map<Widget>((Vocabulaire) {
                return Text("${Vocabulaire['EN']} : ${Vocabulaire['FR']}");
              }).toList(),
            ),
          );
        } else if (state is VocabulairesError) {
          return Center(child: Text("Erreur de chargement"));
        } else {
          return Center(child: Text("État inconnu")); // fallback
        }
      },
    );
  }



}
