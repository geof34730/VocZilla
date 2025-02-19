import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:vobzilla/core/utils/localization.dart';
import 'package:vobzilla/logic/cubit/localization_cubit.dart';
import 'package:vobzilla/ui/layout.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var currentLocale = BlocProvider.of<LocalizationCubit>(context).state;

    return Layout(
      child: Center(
        child:Column(
          children: [
            ElevatedButton(
              onPressed: () {
                var cubit = context.read<LocalizationCubit>();
                String newLanguage = currentLocale.languageCode == 'en' ? 'fr' : 'en';
                cubit.changeLocale(newLanguage);
              },
              child: Text(context.loc.change_language), // Affichage dynamique du texte du bouton
            ),
            Text(context.loc.change_language),
          ],
        )
      ),
    );
  }
}
