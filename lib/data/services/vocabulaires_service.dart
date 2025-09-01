import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/utils/logger.dart';
import '../../global.dart';
import '../models/vocabulary_user.dart';

class VocabulaireService {


  Future<List<dynamic>> getAllData({required String local}) async {
    try {
      // Lire le fichier JSON depuis les assets
      final String response = await rootBundle.loadString('assets/data/vocabulaires/${local.toLowerCase()}.json');
      final List<dynamic> jsonData = json.decode(response) as List;

      return jsonData.map((item) {
        if (item is! Map<String, dynamic>) return item;

        final updatedItem = Map<String, dynamic>.from(item);

        // Traiter le champ 'EN' : supprimer le préfixe "to " et mettre la première lettre en majuscule.
        if (updatedItem['EN'] is String) {
          String enValue = updatedItem['EN'];
          if (resetTo) {
            if (enValue.toLowerCase().startsWith('to ')) {
              enValue = enValue.toLowerCase().replaceFirst('to ', '');
            }
            if (enValue.isNotEmpty) {
              updatedItem['EN'] = '${enValue[0].toUpperCase()}${enValue.substring(1)}';
            }
          }
        }

        // Traiter le champ 'TRAD' : mettre la première lettre en majuscule.
        if (updatedItem['TRAD'] is String && (updatedItem['TRAD'] as String).isNotEmpty) {
           String tradValue = updatedItem['TRAD'];
          if (resetTo) {
            if (tradValue.toLowerCase().startsWith('to ')) {
              tradValue = tradValue.toLowerCase().replaceFirst('to ', '');
            }
          }
          updatedItem['TRAD'] = '${tradValue[0].toUpperCase()}${tradValue.substring(1)}';
        }
        return updatedItem;
      }).toList();
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
