import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:voczilla/data/models/vocabulary_user.dart';
import 'package:voczilla/data/repository/vocabulaire_user_repository.dart';
import 'package:voczilla/logic/blocs/vocabulaire_user/vocabulaire_user_bloc.dart';
import 'package:voczilla/logic/blocs/vocabulaire_user/vocabulaire_user_event.dart';
import 'package:voczilla/logic/blocs/vocabulaire_user/vocabulaire_user_state.dart';

import '../../core/utils/logger.dart';

final _db = FirebaseFirestore.instance;

/// Récupère la liste partagée depuis Firestore par son GUID
Future<Map<String, dynamic>?> getSharedListFromFirestore(String guid) async {
  final doc = await _db.collection('listsPerso').doc(guid).get();
  Logger.Yellow.log(doc);
  if (!doc.exists) return null;
  final data = doc.data()!;
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


      await VocabulaireUserRepository().addListPersoShareTemp(
        listPerso: dataListPerso,
        local: "fr",
      );
      if (mounted) {

        Future.delayed(Duration(seconds: 4)).then((value ) =>{
          Navigator.of(context).pushNamedAndRemoveUntil("/", (route) => false)


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
            return Center(
              child: Text("Liste introuvable ou accès non autorisé.\n${widget.guidlist}"),
            );
          }
          final title = (data['title'] ?? 'Sans titre').toString();

          // Déclenche l'import et la navigation une seule fois
          _handleImportAndNavigation(data);

          return Center(child: Text("Nom de la liste : $title"));
        },

    );
  }
}
