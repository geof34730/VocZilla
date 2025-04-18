import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/core/utils/localization.dart';
import 'package:vobzilla/logic/cubit/localization_cubit.dart';

import '../../../core/utils/languageUtils.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_bloc.dart';
import '../../../logic/blocs/vocabulaires/vocabulaires_state.dart';

class QuizzScreen extends StatelessWidget {
  QuizzScreen();

  @override
  Widget build(BuildContext context) {
    var currentLocale = BlocProvider.of<LocalizationCubit>(context).state;
    return BlocBuilder<VocabulairesBloc, VocabulairesState>(
      builder: (context, state) {
        if (state is VocabulairesLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is VocabulairesLoaded) {
          final data = state.data["vocabulaireList"];
          return SingleChildScrollView(
            child: Column(
              children: (data as List?)?.map<Widget>((vocabulaire) {
                return Text("${vocabulaire['EN']} : ${vocabulaire[LanguageUtils().getSmallCodeLanguage(context: context) ]}");
              }).toList() ?? [Text(context.loc.no_vocabulary_items_found)],
            ),
          );
        } else if (state is VocabulairesError) {
          return Center(child: Text(context.loc.error_loading));
        } else {
          return Center(child: Text(context.loc.unknown_error));  // fallback
        }
      },
    );
  }
}
