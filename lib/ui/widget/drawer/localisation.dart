import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:vobzilla/ui/theme/appColors.dart';
import 'package:vobzilla/logic/cubit/localization_cubit.dart';
import 'package:vobzilla/core/utils/localization.dart';


class drawerLocalisation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero
      ),
      //width: MediaQuery.of(context).size.width,
      elevation: 5,
      shadowColor: Colors.grey,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppColors.primary,
            ),
            child: Text("${context.loc.change_language} : ${Localizations.localeOf(context).languageCode}"),
          ),
          ...AppLocalizations.supportedLocales.map((locale) {
            return ListTile(
              title: Text(locale.languageCode), // Afficher le code de langue
              onTap: () {
                context.read<LocalizationCubit>().changeLocale(locale.languageCode);
              },
            );
          }),
        ],
      ),
    );
  }
}
