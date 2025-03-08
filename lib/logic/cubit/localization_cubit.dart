import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocalizationCubit extends Cubit<Locale> {
  LocalizationCubit() : super(PlatformDispatcher.instance.locale);
  void changeLocale(String languageCode) {
    FirebaseAuth.instance.setLanguageCode(languageCode);
    emit(Locale(languageCode));
  }
}
