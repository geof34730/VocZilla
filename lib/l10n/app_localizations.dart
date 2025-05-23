import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_et.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_no.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('et'),
    Locale('fr'),
    Locale('it'),
    Locale('no'),
    Locale('pt'),
    Locale('zh')
  ];

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Good morning !'**
  String get hello;

  /// No description provided for @change_language.
  ///
  /// In en, this message translates to:
  /// **'Change language'**
  String get change_language;

  /// No description provided for @my_purchase.
  ///
  /// In en, this message translates to:
  /// **'My subscription'**
  String get my_purchase;

  /// No description provided for @dictation_title.
  ///
  /// In en, this message translates to:
  /// **'Voice dictation'**
  String get dictation_title;

  /// No description provided for @dictation_label_text_field.
  ///
  /// In en, this message translates to:
  /// **'Listen and type the text'**
  String get dictation_label_text_field;

  /// No description provided for @statistiques_title.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistiques_title;

  /// No description provided for @liste_title.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get liste_title;

  /// No description provided for @tester_title.
  ///
  /// In en, this message translates to:
  /// **'Evaluation'**
  String get tester_title;

  /// No description provided for @apprendre_title.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get apprendre_title;

  /// No description provided for @language_locale.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language_locale;

  /// No description provided for @language_anglais.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language_anglais;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'To research'**
  String get search;

  /// No description provided for @audios.
  ///
  /// In en, this message translates to:
  /// **'Audios'**
  String get audios;

  /// No description provided for @no_results.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get no_results;

  /// No description provided for @learn_view_carte.
  ///
  /// In en, this message translates to:
  /// **'Click on the map to see the answer'**
  String get learn_view_carte;

  /// No description provided for @button_next.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get button_next;

  /// No description provided for @error_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading error'**
  String get error_loading;

  /// No description provided for @unknown_error.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknown_error;

  /// No description provided for @no_vocabulary_items_found.
  ///
  /// In en, this message translates to:
  /// **'No vocabulary items found'**
  String get no_vocabulary_items_found;

  /// No description provided for @pronunciation_title.
  ///
  /// In en, this message translates to:
  /// **'Pronunciation'**
  String get pronunciation_title;

  /// No description provided for @pronunciation_success.
  ///
  /// In en, this message translates to:
  /// **'Bravo !'**
  String get pronunciation_success;

  /// No description provided for @pronunciation_error.
  ///
  /// In en, this message translates to:
  /// **'Hmm, that\'s not quite right. Try again.'**
  String get pronunciation_error;

  /// No description provided for @pronunciation_i_heard_you_say.
  ///
  /// In en, this message translates to:
  /// **'I heard you say'**
  String get pronunciation_i_heard_you_say;

  /// No description provided for @pronunciation_description_action.
  ///
  /// In en, this message translates to:
  /// **'Press the microphone to speak and check your pronunciation.'**
  String get pronunciation_description_action;

  /// No description provided for @pronunciation_error1.
  ///
  /// In en, this message translates to:
  /// **'Failed to initialize speech recognition'**
  String get pronunciation_error1;

  /// No description provided for @pronunciation_error2.
  ///
  /// In en, this message translates to:
  /// **'Error during initialization'**
  String get pronunciation_error2;

  /// No description provided for @pronunciation_error3.
  ///
  /// In en, this message translates to:
  /// **'Error starting listening'**
  String get pronunciation_error3;

  /// No description provided for @pronunciation_error4.
  ///
  /// In en, this message translates to:
  /// **'Voice recognition is not ready.'**
  String get pronunciation_error4;

  /// No description provided for @pronunciation_error5.
  ///
  /// In en, this message translates to:
  /// **'Microphone permission denied'**
  String get pronunciation_error5;

  /// No description provided for @offline_title.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline_title;

  /// No description provided for @offline_description.
  ///
  /// In en, this message translates to:
  /// **'You do not have an internet connection. Please connect to the internet to continue.'**
  String get offline_description;

  /// No description provided for @quizz_progression_title.
  ///
  /// In en, this message translates to:
  /// **'My progress on this list'**
  String get quizz_progression_title;

  /// No description provided for @quizz_en.
  ///
  /// In en, this message translates to:
  /// **'In'**
  String get quizz_en;

  /// No description provided for @quizz_saisie_in.
  ///
  /// In en, this message translates to:
  /// **'Enter the translation in'**
  String get quizz_saisie_in;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es', 'et', 'fr', 'it', 'no', 'pt', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'et': return AppLocalizationsEt();
    case 'fr': return AppLocalizationsFr();
    case 'it': return AppLocalizationsIt();
    case 'no': return AppLocalizationsNo();
    case 'pt': return AppLocalizationsPt();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
