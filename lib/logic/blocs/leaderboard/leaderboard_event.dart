// lib/logic/blocs/leaderboard/leaderboard_event.dart
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Classe de base abstraite pour tous les événements du Leaderboard.
// Elle étend Equatable pour permettre la comparaison de valeur.
abstract class LeaderboardEvent extends Equatable {
  const LeaderboardEvent();

  @override
  List<Object> get props => [];
}

// L'événement concret qui sera déclenché par l'UI pour demander les données.
// Il contient l'ID de l'utilisateur nécessaire à la requête.
class FetchLeaderboard extends LeaderboardEvent {
  final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

  FetchLeaderboard();

// On ajoute currentUserId aux props pour que deux événements avec le même ID
// soient considérés comme égaux.
  @override
  List<Object> get props => currentUserId != null ? [currentUserId!] : [];
}
