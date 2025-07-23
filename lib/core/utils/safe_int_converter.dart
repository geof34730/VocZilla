// lib/utils/safe_int_converter.dart

import 'package:json_annotation/json_annotation.dart';

/// Un [JsonConverter] qui gère de manière robuste la conversion en `int`.
/// Il peut parser des `int`, des `double`, des `String` et même des objets
/// complexes comme `_StatisticalLength` en tentant d'accéder à une propriété `value`.
class SafeIntConverter implements JsonConverter<int, Object?> {
  const SafeIntConverter();

  @override
  int fromJson(Object? json) {
    if (json == null) {
      return 0;
    }
    if (json is int) {
      return json;
    }
    if (json is double) {
      return json.toInt();
    }
    if (json is String) {
      return int.tryParse(json) ?? 0;
    }
    // C'est ici la magie pour votre cas spécifique.
    // On vérifie le type sans l'importer (car il est privé)
    // et on essaie d'accéder à sa propriété 'value'.
    if (json.runtimeType.toString() == '_StatisticalLength') {
      try {
        // On utilise 'dynamic' pour accéder à une propriété d'un objet
        // dont on ne connaît pas le type à la compilation.
        // Vous devrez peut-être changer '.value' si la propriété a un autre nom.
        return (json as dynamic).value as int;
      } catch (e) {
        print('Could not extract int from _StatisticalLength: $e');
        return 0;
      }
    }

    // Fallback pour tout autre type inattendu.
    print('Warning: Unexpected type for SafeIntConverter: ${json.runtimeType}');
    return 0;
  }

  @override
  Object toJson(int object) {
    // La conversion inverse est simple.
    return object;
  }
}
