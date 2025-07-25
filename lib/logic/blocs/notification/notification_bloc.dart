import 'package:flutter_bloc/flutter_bloc.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(NotificationInitial()) {
    on<ShowNotification>((event, emit) {
      // Émet un nouvel état pour afficher la notification
      emit(NotificationVisible(
        message: event.message,
        backgroundColor: event.backgroundColor,
      ));
    });

    on<NotificationDismissed>((event, emit) {
      // Retourne à l'état initial une fois la notification traitée
      emit(NotificationInitial());
    });
  }
}



