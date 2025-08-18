import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vobzilla/core/utils/localization.dart';

import '../../../core/utils/getFontForLanguage.dart';
import '../../widget/form/FormProfilUpdate.dart';


class ProfileUpdateScreen extends StatefulWidget {
  const ProfileUpdateScreen({super.key});

  @override
  State<ProfileUpdateScreen> createState() => _ProfileUpdateScreenState();
}

class _ProfileUpdateScreenState extends State<ProfileUpdateScreen> {
  @override
  @override
  Widget build(BuildContext context) {
    return Column(
        key: ValueKey('screenUpdateProfil'),
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.only(top:20),
            child:Text(context.loc.profil_update_title,
                style: getFontForLanguage(
                  codelang: Localizations.localeOf(context).languageCode,
                  fontSize: 25,
                )
            ),
          ),
          FormProfilUpdate()
        ]
    );
  }
}
