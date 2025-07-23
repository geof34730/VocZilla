import 'package:vobzilla/core/utils/logger.dart';
import 'package:vobzilla/data/models/vocabulary_user.dart';

import '../../../data/models/vocabulary_bloc_local.dart';

abstract class VocabulaireUserEvent {}

class CheckVocabulaireUserStatus extends VocabulaireUserEvent {}



class LoadVocabulaireUserData extends VocabulaireUserEvent {
  final VocabulaireUser data;
  LoadVocabulaireUserData(this.data);
}

class DeleteListPerso extends VocabulaireUserEvent {
  final String listPersoGuid;
  DeleteListPerso(this.listPersoGuid);
}

class AddListPerso extends VocabulaireUserEvent {
  final ListPerso listPerso;
  AddListPerso(this.listPerso);
}

class UpdateListPerso extends VocabulaireUserEvent {
  final ListPerso listPerso;
  UpdateListPerso(this.listPerso);
}

class AddVocabulaireListPerso extends VocabulaireUserEvent {
  final String guidListPerso;
  final String guidVocabulaire;
  AddVocabulaireListPerso({required this.guidListPerso, required  this.guidVocabulaire});
}

class DeleteVocabulaireListPerso extends VocabulaireUserEvent {
  final String guidListPerso;
  final String guidVocabulaire;
  DeleteVocabulaireListPerso({required this.guidListPerso, required  this.guidVocabulaire});
}
class VocabulaireUserUpdate extends VocabulaireUserEvent {
  final Map<String, dynamic> userData;
  VocabulaireUserUpdate(this.userData);
}



