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
  TextStyle? _titleStyle; // Stocke le style pour éviter de le recalculer

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // On calcule le style une fois ici, car il dépend du contexte (pour la langue).
    if (_titleStyle == null) {
      _titleStyle = getFontForLanguage(
        codelang: Localizations.localeOf(context).languageCode,
        fontSize: 25,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // On enveloppe avec SingleChildScrollView pour éviter les problèmes de dépassement
    // lorsque le clavier apparaît.
    return SingleChildScrollView(
      child: Column(
          key: const ValueKey('screenUpdateProfil'),
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
              child: Text(context.loc.profil_update_title, style: _titleStyle),
            ),
            const FormProfilUpdate()
          ]),
    );
  }
}
