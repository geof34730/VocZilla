import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repository/leaderboard_repository.dart';
import 'leaderboard_event.dart';
import 'leaderboard_state.dart';

class LeaderboardBloc extends Bloc<LeaderboardEvent, LeaderboardState> {
  final LeaderboardRepository leaderboardRepository;

  LeaderboardBloc({required this.leaderboardRepository}) : super(LeaderboardInitial()) {
    on<FetchLeaderboard>(_onFetchLeaderboard);
  }

  Future<void> _onFetchLeaderboard(
      FetchLeaderboard event,
      Emitter<LeaderboardState> emit,
      ) async {
    emit(LeaderboardLoading());
    try {
      final users = await leaderboardRepository.fetchTop3();
      emit(LeaderboardLoaded(users));
    } catch (e) {
      emit(LeaderboardError(e.toString()));
    }
  }
}
