import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import '../../data/repository/vocabulaire_user_repository.dart';
import '../../global.dart';
import '../../logic/blocs/vocabulaire_user/vocabulaire_user_event.dart';
import '../../logic/blocs/vocabulaire_user/vocabulaire_user_state.dart';
import '../widget/form/swichListFinished.dart';
import '../widget/home/CarHomeListDefinied.dart';
import '../widget/home/TitleWidget.dart';
import '../widget/home/HomeListPerso.dart';
import 'package:flutter/scheduler.dart';



// Fonction pour récupérer la liste
final _db = FirebaseFirestore.instance;

/// Lit la liste publique (ou appartenant à l’utilisateur connecté) par son GUID
Future<Map<String, dynamic>?> getSharedListFromFirestore(String guid) async {
  final doc = await _db.collection('listsPerso').doc(guid).get();
  Logger.Yellow.log(doc);
  if (!doc.exists) return null;

  final data = doc.data()!;

  // Optionnel: si tu veux filtrer côté client (au cas où tes rules seraient plus ouvertes)
  // if (data['isListShare'] != true) return null;
  Logger.Yellow.log(data);
  return data;
}



class ShareScreen extends StatefulWidget {
  final String guidlist;
  const ShareScreen({super.key, required this.guidlist});

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  late Future<Map<String, dynamic>?> _future;
  bool _imported = false;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _future = getSharedListFromFirestore(widget.guidlist);
  }

  void _handleImportAndNavigation(Map<String, dynamic> data) async {
    if (_imported) return;
    _imported = true;

    var dataListPerso = ListPerso.fromJson(data);
    dataListPerso = dataListPerso.copyWith(ownListShare: false);
    Logger.Yellow.log(dataListPerso);

    // Ajoute la liste partagée en local (si elle n'existe pas déjà)
    await VocabulaireUserRepository().addListPersoShareTemp(listPerso: dataListPerso, local: "fr");

    final isAuthenticated = FirebaseAuth.instance.currentUser != null;
    if (isAuthenticated) {
      // Import et rafraîchit le bloc

      if (mounted) {
        context.read<VocabulaireUserBloc>().add(CheckVocabulaireUserStatus(local: "fr"));
      }
    }
    if (mounted) {
        Future.delayed(Duration(seconds: 10)).then((_) {
          Navigator.pushReplacementNamed(context, "/");
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Text("Chargement..."));
        }
        if (snapshot.hasError) {
          return Center(child: Text("Erreur: ${snapshot.error}"));
        }
        final data = snapshot.data;
        if (data == null) {
          return Center(child: Text("Liste introuvable ou accès non autorisé.\n${widget.guidlist}"));
        }
        final title = (data['title'] ?? 'Sans titre').toString();

        // Déclenche l'import et la navigation une seule fois
        _handleImportAndNavigation(data);

        return Center(child: Text("Nom de la liste : $title"));
      },
    );
  }
}



/*
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
          return Center(child: Text("Erreur: ${snapshot.error}"));
        }

        final data = snapshot.data;
        if (data == null) {
          return Center(child: Text("Liste introuvable ou accès non autorisé.\n$guidlist"));
        }
        final title = (data['title']  ?? 'Sans titre').toString();
        var dataListPerso = ListPerso.fromJson(data);
        dataListPerso= dataListPerso.copyWith(ownListShare: false);
        Logger.Yellow.log(dataListPerso);
        VocabulaireUserRepository().addListPersoShareTemp(listPerso: dataListPerso, local: "fr");

        Navigator.pushReplacementNamed(context, "/");

        return Center(child: Text("Nom de la liste : $title"));
      },
    );
  }
}*/

//409fcd6a-a6ff-48e1-9459-10f0f746dddf
