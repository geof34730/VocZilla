// lib/logic/blocs/leaderboard/leaderboard_bloc.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vobzilla/data/models/leaderboard_data.dart';
import '../../../data/repository/leaderboard_repository.dart';
import 'leaderboard_event.dart';
import 'leaderboard_state.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final LeaderboardRepository leaderboardRepository;

  LeaderboardBloc({required this.leaderboardRepository})
  // 1. On instancie la classe d'état initial
      : super(LeaderboardInitial()) {
    // 2. On écoute le type d'événement spécifique : FetchLeaderboard
    on<FetchLeaderboard>(_onFetchLeaderboard);
  }

  /// Méthode privée pour gérer la logique de récupération des données.
  Future<void> _onFetchLeaderboard(
      FetchLeaderboard event, // L'événement contient l'ID
      Emitter<LeaderboardState> emit,
      ) async {
    // 3. On instancie les classes d'état concrètes
    emit(LeaderboardLoading());
    try {
      final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
      final leaderboardData = await leaderboardRepository.fetchLeaderboardData(currentUserId: currentUserId ?? '', local:event.local);
      emit(LeaderboardLoaded(leaderboardData));
    } catch (e) {
      emit(LeaderboardError(e.toString()));
    }
  }
}
