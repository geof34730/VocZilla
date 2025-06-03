import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/utils/logger.dart';
import '../models/vocabulary_user.dart';

class VocabulaireService {


  Future<List<dynamic>> getAllData() async {
    try {
      // Lire le fichier JSON depuis les assets
      final String response = await rootBundle.loadString('assets/data/list-vocabulaire.json');
      // Décoder le JSON
      //Logger.Green.log(response);

      final List<dynamic> jsonData = json.decode(response);

      return jsonData;
    } catch (e) {
      // Gérer les erreurs de lecture ou de décodage
      Logger.Red.log('Erreur lors de la lecture du fichier JSON: $e');
      return [];
    }
  }

  Future<List<ListTheme>> getThemesData() async {
    try {
      final String response = await rootBundle.loadString('assets/data/list-themes.json');
      final List<dynamic> jsonData = json.decode(response);

      // Convert each dynamic object to a ListTheme object
      final List<ListTheme> themes = jsonData.map((themeData) => ListTheme.fromJson(themeData)).toList();

      return themes;
    } catch (e) {
      Logger.Red.log('Erreur lors de la lecture du fichier JSON : $e');
      return [];
    }
  }

}
