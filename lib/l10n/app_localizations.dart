import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_et.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_no.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sv.dart';
import 'app_localizations_uk.dart';
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
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('et'),
    Locale('fr'),
    Locale('it'),
    Locale('no'),
    Locale('pl'),
    Locale('pt'),
    Locale('ru'),
    Locale('sv'),
    Locale('uk'),
    Locale('zh')
  ];

  /// No description provided for @app_release_note.
  ///
  /// In en, this message translates to:
  /// **'Deployment of the first version of VocZilla'**
  String get app_release_note;

  /// No description provided for @app_title.
  ///
  /// In en, this message translates to:
  /// **'VocZilla'**
  String get app_title;

  /// No description provided for @app_subtitle.
  ///
  /// In en, this message translates to:
  /// **'English vocabulary'**
  String get app_subtitle;

  /// No description provided for @app_description.
  ///
  /// In en, this message translates to:
  /// **'VocZilla is the perfect app to expand your English vocabulary, no matter your level. Discover thousands of words categorized by theme, play fun quizzes, track your progress, and challenge your friends!'**
  String get app_description;

  /// No description provided for @app_short_description.
  ///
  /// In en, this message translates to:
  /// **'Learn and review English vocabulary!'**
  String get app_short_description;

  /// No description provided for @app_keywords.
  ///
  /// In en, this message translates to:
  /// **'vocabulary, learning, english, words, language, dictation, pronunciation, quiz, memory, learn, easy, listening'**
  String get app_keywords;

  /// No description provided for @app_feature_graphic_title.
  ///
  /// In en, this message translates to:
  /// **'Improve your English vocabulary'**
  String get app_feature_graphic_title;

  /// No description provided for @app_feature_graphic_FeatureItem1.
  ///
  /// In en, this message translates to:
  /// **'5,600 words'**
  String get app_feature_graphic_FeatureItem1;

  /// No description provided for @app_feature_graphic_FeatureItem2.
  ///
  /// In en, this message translates to:
  /// **'Interactive audio quizzes and tests'**
  String get app_feature_graphic_FeatureItem2;

  /// No description provided for @app_feature_graphic_FeatureItem3.
  ///
  /// In en, this message translates to:
  /// **'Track your progress in real time'**
  String get app_feature_graphic_FeatureItem3;

  /// No description provided for @app_feature_graphic_FeatureItem4.
  ///
  /// In en, this message translates to:
  /// **'Personalized and shareable lists'**
  String get app_feature_graphic_FeatureItem4;

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
  /// **'Suite'**
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

  /// No description provided for @home_title_progresse.
  ///
  /// In en, this message translates to:
  /// **'My Titan Progress'**
  String get home_title_progresse;

  /// No description provided for @home_title_my_list_perso.
  ///
  /// In en, this message translates to:
  /// **'My personal lists'**
  String get home_title_my_list_perso;

  /// No description provided for @home_title_list_defined.
  ///
  /// In en, this message translates to:
  /// **'From little monster to Titan'**
  String get home_title_list_defined;

  /// No description provided for @home_description_list_perso.
  ///
  /// In en, this message translates to:
  /// **'Create and customize your own vocabulary lists to effectively learn and review the words of your choice.'**
  String get home_description_list_perso;

  /// No description provided for @home_title_classement.
  ///
  /// In en, this message translates to:
  /// **'TeamZilla Ranking'**
  String get home_title_classement;

  /// No description provided for @home_notlogged_accroche1.
  ///
  /// In en, this message translates to:
  /// **'Boost your English!'**
  String get home_notlogged_accroche1;

  /// No description provided for @home_notlogged_accroche2.
  ///
  /// In en, this message translates to:
  /// **'Do you want to enrich your English vocabulary?'**
  String get home_notlogged_accroche2;

  /// No description provided for @home_notlogged_accroche3.
  ///
  /// In en, this message translates to:
  /// **'Access to '**
  String get home_notlogged_accroche3;

  /// No description provided for @home_notlogged_accroche4.
  ///
  /// In en, this message translates to:
  /// **'5,600 essential words'**
  String get home_notlogged_accroche4;

  /// No description provided for @home_notlogged_accroche5.
  ///
  /// In en, this message translates to:
  /// **'sorted by frequency of use to learn the words that really matter.'**
  String get home_notlogged_accroche5;

  /// No description provided for @home_notlogged_accroche6.
  ///
  /// In en, this message translates to:
  /// **'Fast and effective method'**
  String get home_notlogged_accroche6;

  /// No description provided for @home_notlogged_accroche7.
  ///
  /// In en, this message translates to:
  /// **'Learn the most useful words first'**
  String get home_notlogged_accroche7;

  /// No description provided for @home_notlogged_accroche8.
  ///
  /// In en, this message translates to:
  /// **'Optimized memorization to progress quickly'**
  String get home_notlogged_accroche8;

  /// No description provided for @home_notlogged_accroche9.
  ///
  /// In en, this message translates to:
  /// **'Ready to master the language of Shakespeare?'**
  String get home_notlogged_accroche9;

  /// No description provided for @home_notlogged_button_go.
  ///
  /// In en, this message translates to:
  /// **'Here we go!'**
  String get home_notlogged_button_go;

  /// No description provided for @freetrial_info1.
  ///
  /// In en, this message translates to:
  /// **'Your \$daysFreeTrial free trial period has ended'**
  String get freetrial_info1;

  /// No description provided for @freetrial_info2.
  ///
  /// In en, this message translates to:
  /// **'Join us and unlock a world of possibilities with our exclusive memberships!'**
  String get freetrial_info2;

  /// No description provided for @mois.
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get mois;

  /// No description provided for @annee.
  ///
  /// In en, this message translates to:
  /// **'year'**
  String get annee;

  /// No description provided for @abonnement_mensuel.
  ///
  /// In en, this message translates to:
  /// **'Monthly Subscription'**
  String get abonnement_mensuel;

  /// No description provided for @abonnement_annuel.
  ///
  /// In en, this message translates to:
  /// **'Annual Subscription'**
  String get abonnement_annuel;

  /// No description provided for @abonnement_descriptif_mensuel.
  ///
  /// In en, this message translates to:
  /// **'Free as a bird: cancel whenever you want.'**
  String get abonnement_descriptif_mensuel;

  /// No description provided for @abonnement_descriptif_annuel.
  ///
  /// In en, this message translates to:
  /// **'Enjoy your experience to the fullest while saving money.'**
  String get abonnement_descriptif_annuel;

  /// No description provided for @button_sabonner.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get button_sabonner;

  /// No description provided for @login_se_connecter.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get login_se_connecter;

  /// No description provided for @login_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get login_email;

  /// No description provided for @login_entrer_email.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get login_entrer_email;

  /// No description provided for @login_prenom.
  ///
  /// In en, this message translates to:
  /// **'First name'**
  String get login_prenom;

  /// No description provided for @login_entrer_prenom.
  ///
  /// In en, this message translates to:
  /// **'Enter your first name'**
  String get login_entrer_prenom;

  /// No description provided for @login_nom.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get login_nom;

  /// No description provided for @login_entrer_nom.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get login_entrer_nom;

  /// No description provided for @login_pseudo.
  ///
  /// In en, this message translates to:
  /// **'Pseudonym'**
  String get login_pseudo;

  /// No description provided for @login_entrer_pseudo.
  ///
  /// In en, this message translates to:
  /// **'Enter your nickname'**
  String get login_entrer_pseudo;

  /// No description provided for @login_mot_de_passe.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get login_mot_de_passe;

  /// No description provided for @login_entrer_mot_de_passe.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get login_entrer_mot_de_passe;

  /// No description provided for @login_ou_connecter_vous_avec.
  ///
  /// In en, this message translates to:
  /// **'Or connect with'**
  String get login_ou_connecter_vous_avec;

  /// No description provided for @login_avec_google.
  ///
  /// In en, this message translates to:
  /// **'With Google'**
  String get login_avec_google;

  /// No description provided for @login_avec_facebook.
  ///
  /// In en, this message translates to:
  /// **'With Facebook'**
  String get login_avec_facebook;

  /// No description provided for @login_avec_apple.
  ///
  /// In en, this message translates to:
  /// **'With Apple'**
  String get login_avec_apple;

  /// No description provided for @login_no_compte.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get login_no_compte;

  /// No description provided for @login_inscrivez_vous.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get login_inscrivez_vous;

  /// No description provided for @login_sinscrire.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get login_sinscrire;

  /// No description provided for @login_ou_inscrivez_vous_avec.
  ///
  /// In en, this message translates to:
  /// **'Or register with'**
  String get login_ou_inscrivez_vous_avec;

  /// No description provided for @email_validation_merci_register.
  ///
  /// In en, this message translates to:
  /// **'Thank you for signing up!'**
  String get email_validation_merci_register;

  /// No description provided for @email_validation_msg_email_send.
  ///
  /// In en, this message translates to:
  /// **'A verification email has been sent to your email address'**
  String get email_validation_msg_email_send;

  /// No description provided for @email_validation_instruction.
  ///
  /// In en, this message translates to:
  /// **'Please check your inbox and follow the instructions to validate your email address. This will allow us to confirm your registration and give you access to all the features of our service.'**
  String get email_validation_instruction;

  /// No description provided for @email_validation_help.
  ///
  /// In en, this message translates to:
  /// **'If you don\'t see the email in your inbox, consider checking your spam or junk folder.'**
  String get email_validation_help;

  /// No description provided for @email_validation_merci_register2.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your trust!'**
  String get email_validation_merci_register2;

  /// No description provided for @send_mail.
  ///
  /// In en, this message translates to:
  /// **'Receive a new verification email'**
  String get send_mail;

  /// No description provided for @personnalisation_step1_title_list.
  ///
  /// In en, this message translates to:
  /// **'Title of your list'**
  String get personnalisation_step1_title_list;

  /// No description provided for @personnalisation_step1_color_choice.
  ///
  /// In en, this message translates to:
  /// **'Choose the color from your list'**
  String get personnalisation_step1_color_choice;

  /// No description provided for @profil_update_title.
  ///
  /// In en, this message translates to:
  /// **'Update your profile'**
  String get profil_update_title;

  /// No description provided for @profil_complete_registration_title.
  ///
  /// In en, this message translates to:
  /// **'Complete your registration'**
  String get profil_complete_registration_title;

  /// No description provided for @widget_dialogHelper_showfreetrialdialog_description1.
  ///
  /// In en, this message translates to:
  /// **'Take advantage of your free trial period!'**
  String get widget_dialogHelper_showfreetrialdialog_description1;

  /// No description provided for @widget_dialogHelper_showfreetrialdialog_description2.
  ///
  /// In en, this message translates to:
  /// **'Welcome! You are currently enjoying a free trial period of'**
  String get widget_dialogHelper_showfreetrialdialog_description2;

  /// No description provided for @widget_dialogHelper_showfreetrialdialog_days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get widget_dialogHelper_showfreetrialdialog_days;

  /// No description provided for @widget_dialogHelper_showfreetrialdialog_description3.
  ///
  /// In en, this message translates to:
  /// **'to discover all the features of our application.'**
  String get widget_dialogHelper_showfreetrialdialog_description3;

  /// No description provided for @widget_dialogHelper_showfreetrialdialog_description4.
  ///
  /// In en, this message translates to:
  /// **'You have left'**
  String get widget_dialogHelper_showfreetrialdialog_description4;

  /// No description provided for @widget_dialogHelper_showfreetrialdialog_description5.
  ///
  /// In en, this message translates to:
  /// **'free trials'**
  String get widget_dialogHelper_showfreetrialdialog_description5;

  /// No description provided for @widget_dialogHelper_showfreetrialdialog_description6.
  ///
  /// In en, this message translates to:
  /// **'Don\'t let your experience stop! Choose the subscription that suits you and continue enjoying without interruption.'**
  String get widget_dialogHelper_showfreetrialdialog_description6;

  /// No description provided for @widget_dialogHelper_showfreetrialdialog_later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get widget_dialogHelper_showfreetrialdialog_later;

  /// No description provided for @widget_congratulation_bravo.
  ///
  /// In en, this message translates to:
  /// **'Bravo'**
  String get widget_congratulation_bravo;

  /// No description provided for @widget_congratulation_message.
  ///
  /// In en, this message translates to:
  /// **'you have finished learning this List'**
  String get widget_congratulation_message;

  /// No description provided for @widget_radiochoicevocabularylearnedornot_choice1.
  ///
  /// In en, this message translates to:
  /// **'To learn'**
  String get widget_radiochoicevocabularylearnedornot_choice1;

  /// No description provided for @widget_radiochoicevocabularylearnedornot_choice2.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get widget_radiochoicevocabularylearnedornot_choice2;

  /// No description provided for @title_create_personal_list.
  ///
  /// In en, this message translates to:
  /// **'Create a custom list'**
  String get title_create_personal_list;

  /// No description provided for @title_app_update.
  ///
  /// In en, this message translates to:
  /// **'Update available!'**
  String get title_app_update;

  /// No description provided for @title_subscription.
  ///
  /// In en, this message translates to:
  /// **'Our Subscriptions'**
  String get title_subscription;

  /// No description provided for @by_themes.
  ///
  /// In en, this message translates to:
  /// **'Par themes'**
  String get by_themes;

  /// No description provided for @no_vocabulary_in_my_list.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have any vocabulary in this list. Add some by editing the list.'**
  String get no_vocabulary_in_my_list;

  /// No description provided for @anonymous_user.
  ///
  /// In en, this message translates to:
  /// **'Anonymous user'**
  String get anonymous_user;

  /// No description provided for @alert_message_email_verify_send.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent!'**
  String get alert_message_email_verify_send;

  /// No description provided for @alert_message_email_send_error.
  ///
  /// In en, this message translates to:
  /// **'Error sending email.'**
  String get alert_message_email_send_error;

  /// No description provided for @auth_error_deconnect.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while logging out.'**
  String get auth_error_deconnect;

  /// No description provided for @auth_error_connect.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred while connecting.'**
  String get auth_error_connect;

  /// No description provided for @auth_error_register_unknown.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred during registration.'**
  String get auth_error_register_unknown;

  /// No description provided for @auth_error_create_user.
  ///
  /// In en, this message translates to:
  /// **'User creation failed.'**
  String get auth_error_create_user;

  /// No description provided for @auth_error_update_profil.
  ///
  /// In en, this message translates to:
  /// **'Error updating profile.'**
  String get auth_error_update_profil;

  /// No description provided for @auth_error_facebook.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred with Facebook login.'**
  String get auth_error_facebook;

  /// No description provided for @auth_error_google.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred with Google login.'**
  String get auth_error_google;

  /// No description provided for @auth_error_apple.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred with Apple login.'**
  String get auth_error_apple;

  /// No description provided for @auth_error_echoue.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed, please try again'**
  String get auth_error_echoue;

  /// No description provided for @firebase_error_message_too_many_requests.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Try again later.'**
  String get firebase_error_message_too_many_requests;

  /// No description provided for @firebase_error_message_default.
  ///
  /// In en, this message translates to:
  /// **'An unknown error has occurred.'**
  String get firebase_error_message_default;

  /// No description provided for @firebase_error_message_invalid_email.
  ///
  /// In en, this message translates to:
  /// **'The email address is malformed.'**
  String get firebase_error_message_invalid_email;

  /// No description provided for @firebase_error_message_user_disabled.
  ///
  /// In en, this message translates to:
  /// **'This user account has been disabled.'**
  String get firebase_error_message_user_disabled;

  /// No description provided for @firebase_error_message_invalid_credential.
  ///
  /// In en, this message translates to:
  /// **'The email or password is incorrect.'**
  String get firebase_error_message_invalid_credential;

  /// No description provided for @firebase_error_message_email_already_in_use.
  ///
  /// In en, this message translates to:
  /// **'The email address is already used by another account.'**
  String get firebase_error_message_email_already_in_use;

  /// No description provided for @firebase_error_message_operation_not_allowed.
  ///
  /// In en, this message translates to:
  /// **'This operation is not permitted.'**
  String get firebase_error_message_operation_not_allowed;

  /// No description provided for @firebase_error_message_weak_password.
  ///
  /// In en, this message translates to:
  /// **'The password is too weak.'**
  String get firebase_error_message_weak_password;

  /// No description provided for @firebase_error_message_account_exists_with_different_credential.
  ///
  /// In en, this message translates to:
  /// **'An account already exists with the same email address but different credentials.'**
  String get firebase_error_message_account_exists_with_different_credential;

  /// No description provided for @firebase_error_message_error_generic.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error has occurred. Please try again.'**
  String get firebase_error_message_error_generic;

  /// No description provided for @auth_success_update_profile.
  ///
  /// In en, this message translates to:
  /// **'Profile successfully updated!'**
  String get auth_success_update_profile;

  /// No description provided for @vocabulaire_success_delete_list.
  ///
  /// In en, this message translates to:
  /// **'List deleted successfully.'**
  String get vocabulaire_success_delete_list;

  /// No description provided for @update_app_text_1.
  ///
  /// In en, this message translates to:
  /// **'A new version of Voczilla is available with significant improvements, new features and bug fixes for an even better experience'**
  String get update_app_text_1;

  /// No description provided for @update_app_text_2.
  ///
  /// In en, this message translates to:
  /// **'Don\'t miss out on the latest news!'**
  String get update_app_text_2;

  /// No description provided for @update_app_text_3.
  ///
  /// In en, this message translates to:
  /// **'Click below to update now'**
  String get update_app_text_3;

  /// No description provided for @update_app_text_4.
  ///
  /// In en, this message translates to:
  /// **'Update VocZilla'**
  String get update_app_text_4;

  /// No description provided for @update_app_text_5.
  ///
  /// In en, this message translates to:
  /// **'Thank you for being part of the Voczilla community'**
  String get update_app_text_5;

  /// No description provided for @drawer_my_profil.
  ///
  /// In en, this message translates to:
  /// **'My profile'**
  String get drawer_my_profil;

  /// No description provided for @drawer_disconnect.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get drawer_disconnect;

  /// No description provided for @drawer_free_trial.
  ///
  /// In en, this message translates to:
  /// **'My trial period'**
  String get drawer_free_trial;

  /// No description provided for @drawer_free_trial_day.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get drawer_free_trial_day;

  /// No description provided for @drawer_free_trial_days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get drawer_free_trial_days;

  /// No description provided for @drawer_free_trial_restants.
  ///
  /// In en, this message translates to:
  /// **'remaining'**
  String get drawer_free_trial_restants;

  /// No description provided for @drawer_free_trial_restant.
  ///
  /// In en, this message translates to:
  /// **'remaining'**
  String get drawer_free_trial_restant;

  /// No description provided for @erreur_de_chargement_du_profil.
  ///
  /// In en, this message translates to:
  /// **'Profile loading error'**
  String get erreur_de_chargement_du_profil;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @card_home_user_day.
  ///
  /// In en, this message translates to:
  /// **'days)'**
  String get card_home_user_day;

  /// No description provided for @card_home_user_liste_perso.
  ///
  /// In en, this message translates to:
  /// **'list(s) Lost'**
  String get card_home_user_liste_perso;

  /// No description provided for @card_home_share.
  ///
  /// In en, this message translates to:
  /// **'shared'**
  String get card_home_share;

  /// No description provided for @card_home_mot.
  ///
  /// In en, this message translates to:
  /// **'against'**
  String get card_home_mot;

  /// No description provided for @card_home_reessayer.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get card_home_reessayer;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en', 'es', 'et', 'fr', 'it', 'no', 'pl', 'pt', 'ru', 'sv', 'uk', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'et': return AppLocalizationsEt();
    case 'fr': return AppLocalizationsFr();
    case 'it': return AppLocalizationsIt();
    case 'no': return AppLocalizationsNo();
    case 'pl': return AppLocalizationsPl();
    case 'pt': return AppLocalizationsPt();
    case 'ru': return AppLocalizationsRu();
    case 'sv': return AppLocalizationsSv();
    case 'uk': return AppLocalizationsUk();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
