import 'package:equatable/equatable.dart';
import '../../business_profile/domain/business_profile_model.dart';
import '../../documents/data/document_repository.dart';
import '../../documents/domain/document_model.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  final SummaryStats stats;
  final List<DocumentModel> recentDocuments;
  final BusinessProfile profile;

  const HomeLoaded({
    required this.stats,
    required this.recentDocuments,
    required this.profile,
  });

  @override
  List<Object?> get props => [stats, recentDocuments, profile];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object?> get props => [message];
}
