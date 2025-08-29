import 'package:flutter/cupertino.dart';
import 'package:vobzilla/core/utils/localization.dart';

getTypeDetaiVocabulaire({required String typeDetail, required BuildContext context}){



  switch (typeDetail.trim()) {
    case 'Adjectif':
      return context.loc.vocabulaire_type_adjectif;
    case 'Adverbe':
      return context.loc.vocabulaire_type_adverbe;
    case 'Adverbe interrogatif':
      return context.loc.vocabulaire_type_adverbeInterrogatif;
    case 'Conjonction':
      return context.loc.vocabulaire_type_conjonction;
    case 'Déterminant':
      return context.loc.vocabulaire_type_determinant;
    case 'Interjection':
      return context.loc.vocabulaire_type_interjection;
    case 'Nom':
      return context.loc.vocabulaire_type_nom;
    case 'Numéral':
      return context.loc.vocabulaire_type_numeral;
    case 'Pronom':
      return context.loc.vocabulaire_type_pronom;
    case 'Préposition':
      return context.loc.vocabulaire_type_preposition;
    case 'verbe modal':
      return context.loc.vocabulaire_type_verbeModal;
    case "verbe à l'infinitif":
      return context.loc.vocabulaire_type_verbeInfinitif;
    default:
      return context.loc.vocabulaire_type_inconnu;
  }



}


