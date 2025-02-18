import 'dart:ui';
import 'package:flutter_bloc/flutter_bloc.dart';

class LocalizationCubit extends Cubit<Locale> {
  LocalizationCubit() : super(const Locale('en'));
  void changeLocale(String languageCode) {
    emit(Locale(languageCode));
  }
}
