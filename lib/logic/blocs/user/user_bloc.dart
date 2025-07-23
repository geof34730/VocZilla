import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as context;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vobzilla/data/repository/user_repository.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/vocabulary_user.dart';
import '../../../data/services/vocabulaires_service.dart';
import '../vocabulaire_user/vocabulaire_user_bloc.dart';
import '../vocabulaire_user/vocabulaire_user_state.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository repository;
  UserBloc(this.repository) : super(UserInitial()) {
    on<CheckUserStatus>(_onCheckUserStatus);
    on<LoadUserData>(_onLoadUserData);
  }



  Future<void> _onLoadUserData(LoadUserData event, Emitter<UserState> emit) async {
    emit(UserLoading());
    try {
      final userData = await repository.fetchUserData(event.userId);

      // Attends le résultat du Future avant de l'ajouter
      var themes = await VocabulaireService().getThemesData();
      userData["ListTheme"] = themes.map((theme) => theme.toJson()).toList();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('UserData', jsonEncode(userData));
      Logger.Pink.log(jsonEncode(userData));
      emit(UserLoaded(userData));
    } catch (e) {
      Logger.Red.log("Error loading user data: $e");
      emit(UserError(e.toString()));
    }
  }



  Future<void> _onCheckUserStatus(CheckUserStatus event,
      Emitter<UserState> emit) async {
    // On vérifie si un utilisateur est authentifié avant de vérifier son statut
    if (FirebaseAuth.instance.currentUser != null && FirebaseAuth.instance.currentUser!.emailVerified) {
      final isSubscribed = await userRepository.checkSubscriptionStatus();

      Logger.Blue.log('BLOC isSubscribed: $isSubscribed');

      final DateTime? trialEndDate = await userRepository.getTrialEndDate();
      final int trialLeftDays = await userRepository.getLeftDaysEndDate();

      DateTime now = DateTime.now().toUtc();
      bool isFreeTrialPeriod = trialEndDate != null && trialEndDate.isAfter(now);
      if (isSubscribed) {
        print("UserFreeTrialPeriodEndAndSubscribed");
        emit(UserFreeTrialPeriodEndAndSubscribed());
      } else {
        if (isFreeTrialPeriod) {
          print("UserFreeTrialPeriodAndNotSubscribed");
          emit(UserFreeTrialPeriodAndNotSubscribed(trialLeftDays));
        }
        else{
          print("UserFreeTrialPeriodEndAndNotSubscribed");
          emit(UserFreeTrialPeriodEndAndNotSubscribed());
        }
      }
    } else {
      // Si aucun utilisateur n'est connecté, on émet un état initial pour réinitialiser.
      emit(UserInitial());
    }
  }
}


