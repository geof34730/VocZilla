import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vobzilla/core/utils/localization.dart';

import '../../../core/utils/getFontForLanguage.dart';
import '../../backgroundBlueLinear.dart';
import '../../widget/form/FormProfilUpdate.dart';


class ProfileUpdateGafaScreen extends StatefulWidget {
  const ProfileUpdateGafaScreen({super.key});

  @override
  State<ProfileUpdateGafaScreen> createState() => _ProfileUpdateGafaScreenState();
}

class _ProfileUpdateGafaScreenState extends State<ProfileUpdateGafaScreen> {

  @override
  Widget build(BuildContext context) {
    return BackgroundBlueLinear(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.only(top:20),
            child:Text("context.loc.profil_complete_registration_title",
                style: getFontForLanguage(
                  codelang: Localizations.localeOf(context).languageCode,
                  fontSize: 25,
                ),
            ),
          ),
          FormProfilUpdate()
        ]
        )
    );
  }
}
