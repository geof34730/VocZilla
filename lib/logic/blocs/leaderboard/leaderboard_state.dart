// lib/logic/blocs/leaderboard/leaderboard_state.dart
import 'package:equatable/equatable.dart';
import 'package:vobzilla/data/models/leaderboard_data.dart'; // Assurez-vous que le chemin est correct

// Classe de base abstraite pour tous les états.
abstract class LeaderboardState extends Equatable {
  const LeaderboardState();

  @override
  List<Object> get props => [];
}

// État initial, avant tout chargement.
class LeaderboardInitial extends LeaderboardState {}

// État de chargement, pendant l'appel réseau.
class LeaderboardLoading extends LeaderboardState {}

// État de succès, contenant les données prêtes à être affichées.
class LeaderboardLoaded extends LeaderboardState {
  final LeaderboardData leaderboardData;

  const LeaderboardLoaded(this.leaderboardData);

  @override
  List<Object> get props => [leaderboardData];
}

// État d'erreur, contenant un message à afficher.
class LeaderboardError extends LeaderboardState {
  final String message;

  const LeaderboardError(this.message);

  @override
  List<Object> get props => [message];
}
