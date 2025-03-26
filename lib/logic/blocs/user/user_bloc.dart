import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/data/repository/user_repository.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc() : super(UserInitial()) {
    on<CheckUserStatus>(_onCheckUserStatus);
  }

  Future<void> _onCheckUserStatus(CheckUserStatus event, Emitter<UserState> emit) async {
    // Implémentez votre logique pour vérifier le statut d'abonnement de l'utilisateur
    // Par exemple, vous pouvez vérifier si l'utilisateur est abonné ou en période d'essai
    final isSubscribed = await checkSubscriptionStatus();
    final DateTime? trialEndDate = await getTrialEndDate();
    print(DateTime.now().isBefore(trialEndDate!));
    if (isSubscribed) {
      emit(UserSubscribed());
    } else if (DateTime.now().isBefore(trialEndDate)) {
      emit(UserOnFreeTrial(trialEndDate));
    } else {
      emit(UserNotSubscribed());
    }
  }

  Future<bool> checkSubscriptionStatus() async {
    // Implémentez la logique pour vérifier si l'utilisateur est abonné

    return false; // Exemple : retourner false pour non abonné
  }

  Future<DateTime?> getTrialEndDate() async {
    //retourne la date de fin de l'essai gratuit
    final endDate = await UserRepository().getDaysEndFreetrial();
    return endDate;
  }
}
