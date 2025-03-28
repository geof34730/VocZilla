import 'package:vobzilla/data/repository/auth_repository.dart';
import '../../global.dart';
class UserRepository {
  Future<DateTime?> getDaysEndFreetrial() async {
    DateTime? endDateFreeTrial;
    await AuthRepository().getUser().then((value) => endDateFreeTrial = value.metadata.creationTime?.add(Duration(days: daysFreeTrial)));
    return endDateFreeTrial;
  }

  Future<int> getLeftDaysFreeTrial() async {
    final now = DateTime.now();
    final endDate = await getDaysEndFreetrial();
    if (endDate == null) {
      return 0;
    }
    final difference = endDate.difference(now).inDays;
    return difference;
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

  Future<int> getLeftDaysEndDate() async {
    //retourne le nombre de jour de l'essai gratuit
    return await UserRepository().getLeftDaysFreeTrial();
  }

}
