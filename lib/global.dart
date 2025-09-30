import 'package:cloud_functions/cloud_functions.dart';

const String titleApp="VocZilla";
const int titleAppCute1=3;
String versionApp="1.0.0";

// Instance globale pour Cloud Functions
final functions = FirebaseFunctions.instanceFor(region: 'us-central1');

int globalCountVocabulaireAll=4399;
bool debugMode=false;
bool statistiqueGoogleAnalytics=false;
//bool byPasSubscription = true;
bool testScreenShot = false;
const String idSubscriptionMensuel = 'mensuel_voczilla_076d28df';
const String idSubscriptionAnnuel = 'annuel_voczilla_076d28df';
//final int daysFreeTrial= byPasSubscription ? 2000 :7;
const resetTo=true;
bool forFeatureGraphic = false;
bool changeVocabulaireSinceVisiteHome = false;

//const  String serveurUrl="http://192.168.0.34:8080";
const  String serveurUrl="https://subscription-v1-275313479574.europe-central2.run.app";

final String serverSubcriptionStaturUrl = '$serveurUrl/verify-subscription';
final String serverVocabulaireUserUrl = '$serveurUrl/vocabulaires-user';
final String serverLeaderBoardUrl = '$serveurUrl/api/leaderboard/top3';
final String serverRankCurrentUser = '$serveurUrl/api/leaderboard/ranking';

const String ANDROID_APP_STORE_URL="https://play.google.com/store/apps/details?id=com.geoffreypetain.voczilla.voczilla";
const String IOS_APP_STORE_URL="https://apps.apple.com/us/app/com.geoffreypetain.voczilla.voczilla/6742488058";

