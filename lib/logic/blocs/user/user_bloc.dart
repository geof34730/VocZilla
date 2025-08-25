import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vobzilla/data/repository/user_repository.dart';
import '../../../core/utils/logger.dart';
import '../../../data/services/vocabulaires_service.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository repository;
  UserBloc(this.repository) : super(UserInitial()) {
    on<InitializeUserSession>(_onInitializeUserSession);
  }

  Future<void> _onInitializeUserSession(
      InitializeUserSession event, Emitter<UserState> emit) async {
    // 1. Assurer qu'un utilisateur est connecté
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      Logger.Pink.log("UserInitial: No authenticated user.");
      emit(UserInitial());
      return;
    }

    emit(UserLoading());

    try {
      // 2. Charger toutes les données en parallèle pour plus d'efficacité
      final results = await Future.wait([
        repository.fetchUserData(firebaseUser.uid),
        VocabulaireService().getThemesData(),
        userRepository.checkSubscriptionStatus(),
        userRepository.getTrialEndDate(),
        userRepository.getLeftDaysEndDate(),
      ]);

      final userData = results[0] as Map<String, dynamic>;
      final themes = results[1] as List<dynamic>;
      final isSubscribed = results[2] as bool;
      final trialEndDate = results[3] as DateTime?;
      final trialLeftDays = results[4] as int;

      // 3. Enrichir les données utilisateur et les sauvegarder
      userData["ListTheme"] = themes.map((theme) => theme.toJson()).toList();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userData', jsonEncode(userData));

      // 4. Déterminer le statut de la période d'essai
      final now = DateTime.now().toUtc();
      final bool isTrialActive =
          trialEndDate != null && trialEndDate.isAfter(now);

      // 5. Émettre l'état final et complet
      Logger.Green.log(
          "UserSessionLoaded: isSubscribed=$isSubscribed, isTrialActive=$isTrialActive, daysLeft=$trialLeftDays");
      emit(UserSessionLoaded(
        userData: userData,
        isSubscribed: isSubscribed,
        isTrialActive: isTrialActive,
        trialDaysLeft: trialLeftDays,
      ));
    } catch (e) {
      Logger.Red.log("Error initializing user session: $e");
      emit(UserError(e.toString()));
    }
  }
}
