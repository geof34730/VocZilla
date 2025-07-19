import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/data/repository/user_repository.dart';
import '../../../core/utils/logger.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserInitial()) {
    on<CheckUserStatus>(_onCheckUserStatus);
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


