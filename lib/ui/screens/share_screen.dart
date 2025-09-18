import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voczilla/core/utils/localization.dart';
import 'package:voczilla/logic/blocs/vocabulaire_user/vocabulaire_user_bloc.dart';
import 'package:voczilla/data/models/vocabulary_user.dart';
import 'package:voczilla/ui/widget/home/HomeClassement.dart';
import 'package:voczilla/ui/widget/home/HomeListTheme.dart';
import 'package:voczilla/ui/widget/statistical/global_statisctical_widget.dart';

import '../../core/utils/logger.dart';
import '../../core/utils/ui.dart';
import '../../global.dart';
import '../../logic/blocs/vocabulaire_user/vocabulaire_user_event.dart';
import '../../logic/blocs/vocabulaire_user/vocabulaire_user_state.dart';
import '../widget/form/swichListFinished.dart';
import '../widget/home/CarHomeListDefinied.dart';
import '../widget/home/TitleWidget.dart';
import '../widget/home/HomeListPerso.dart';


// Créez une instance de FirebaseFunctions
final FirebaseFunctions functions = FirebaseFunctions.instance;

// Fonction pour récupérer la liste
final _db = FirebaseFirestore.instance;

/// Lit la liste publique (ou appartenant à l’utilisateur connecté) par son GUID
Future<Map<String, dynamic>?> getSharedListFromFirestore(String guid) async {
  final doc = await _db.collection('listsPerso').doc(guid).get();

  if (!doc.exists) return null;

  final data = doc.data()!;

  // Optionnel: si tu veux filtrer côté client (au cas où tes rules seraient plus ouvertes)
  // if (data['isListShare'] != true) return null;

  return data;
}

class ShareScreen extends StatelessWidget {
  final String guidlist;
  const ShareScreen({super.key, required this.guidlist});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: getSharedListFromFirestore(guidlist), // <-- Firestore direct
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          // Message d’erreur plus parlant
          return Center(child: Text("Erreur: ${snapshot.error}"));
        }

        final data = snapshot.data;
        if (data == null) {
          return Center(child: Text("Liste introuvable ou accès non autorisé.\n$guidlist"));
        }

        // ⚠️ Ton champ s’appelle sûrement "title" et pas "name"
        final title = (data['title'] ?? data['name'] ?? 'Sans titre').toString();

        return Center(child: Text("Nom de la liste : $title"));
      },
    );
  }
}

//6e7cf30a-47b8-4128-8223-7a749801178e
