import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:voczilla/data/models/vocabulary_user.dart';
import 'package:voczilla/data/repository/vocabulaire_user_repository.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
            return LoaderList();
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


          // Déclenche l'import et la navigation une seule fois
          _handleImportAndNavigation(data);
          return LoaderList();

        },

    );
  }

  Widget LoaderList(){
     return Padding(
          padding: EdgeInsets.only(top:150),
         child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              LoadingAnimationWidget.dotsTriangle(
                color: Colors.blue,
                size: 150.0,
              ),
              Padding(
                  padding: EdgeInsets.only(top: 10.0, left: 15.0, right: 30.0),
                  child: Text(
                    "Chargement de votre liste personnalis\u00e9e partag\u00e9e.",
                    textAlign: TextAlign.center,
                  )
              )
            ],
         )
     );

  }

}
