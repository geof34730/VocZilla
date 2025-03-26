import 'package:vobzilla/data/repository/auth_repository.dart';
import '../../global.dart';


class UserRepository {
  Future<DateTime?> getDaysEndFreetrial() async {
    DateTime? EndDateFreeTrial;
    await AuthRepository().getUser().then((value) => EndDateFreeTrial = value.metadata.creationTime?.add(Duration(days: daysFreeTrial)));
    print("****** creationTime: $EndDateFreeTrial");
    return EndDateFreeTrial;
  }

  Future<int> getLeftDaysFreeTrial() async {
    final now = DateTime.now();
    final endDate = await getDaysEndFreetrial();
    if (endDate == null) {
      return 0;
    }
    final difference = endDate.difference(now).inDays;
    print("****** difference: $difference");
    return difference;
  }
}
