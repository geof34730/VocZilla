import 'package:voczilla/core/utils/logger.dart';
import 'package:voczilla/data/models/vocabulary_user.dart';

import '../../../data/models/vocabulary_bloc_local.dart';

abstract class VocabulaireUserEvent {}

class CheckVocabulaireUserStatus extends VocabulaireUserEvent {
  final String local;
  CheckVocabulaireUserStatus({required this.local});
}

class VocabulaireUserRefresh extends VocabulaireUserEvent {
  final String local;
  VocabulaireUserRefresh({ required this.local});

}

class LoadVocabulaireUserData extends VocabulaireUserEvent {
  final VocabulaireUser data;
  final String local;
  LoadVocabulaireUserData({required this.data, required this.local});
}

class DeleteListPerso extends VocabulaireUserEvent {
  final String listPersoGuid;
  final String local;
  DeleteListPerso({required this.listPersoGuid, required this.local});
}

class AddListPerso extends VocabulaireUserEvent {
  final ListPerso listPerso;
  final String local;
  AddListPerso({required this.listPerso,  required this.local});
}

class UpdateListPerso extends VocabulaireUserEvent {
  final ListPerso listPerso;
  final String local;
  UpdateListPerso({required this.listPerso,  required this.local});
}

class AddVocabulaireListPerso extends VocabulaireUserEvent {
  final String guidListPerso;
  final String guidVocabulaire;
  final String local;
  AddVocabulaireListPerso({required this.guidListPerso, required  this.guidVocabulaire,  required this.local});
}

class DeleteVocabulaireListPerso extends VocabulaireUserEvent {
  final String guidListPerso;
  final String guidVocabulaire;
  final String local;
  DeleteVocabulaireListPerso({required this.guidListPerso, required  this.guidVocabulaire,required this.local});
}
class VocabulaireUserUpdate extends VocabulaireUserEvent {
  final Map<String, dynamic> userData;
  VocabulaireUserUpdate({required this.userData});
}
class VocabulaireUserBlocErrorCleared extends VocabulaireUserEvent {}
