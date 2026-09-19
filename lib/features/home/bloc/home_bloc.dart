import 'package:flutter_bloc/flutter_bloc.dart';
import '../../business_profile/data/business_profile_repository.dart';
import '../../documents/data/document_repository.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final DocumentRepository documentRepository;
  final BusinessProfileRepository businessProfileRepository;

  HomeBloc({
    required this.documentRepository,
    required this.businessProfileRepository,
  }) : super(const HomeInitial()) {
    on<LoadHomeDataEvent>(_onLoadHomeData);
  }

  Future<void> _onLoadHomeData(
    LoadHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    try {
      final statsFuture = documentRepository.getSummaryStats();
      final recentDocsFuture = documentRepository.getAllDocuments(limit: 5);
      final profileFuture = businessProfileRepository.getProfile();

      final results = await Future.wait([
        statsFuture,
        recentDocsFuture,
        profileFuture,
      ]);

      emit(
        HomeLoaded(
          stats: results[0] as SummaryStats,
          recentDocuments: results[1] as dynamic,
          profile: results[2] as dynamic,
        ),
      );
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
