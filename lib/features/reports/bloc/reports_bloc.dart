import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../documents/data/document_repository.dart';
import '../../documents/domain/document_model.dart';

abstract class ReportsEvent extends Equatable {
  const ReportsEvent();

  @override
  List<Object?> get props => [];
}

class GenerateReportEvent extends ReportsEvent {
  final DateTime startDate;
  final DateTime endDate;

  const GenerateReportEvent({required this.startDate, required this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

abstract class ReportsState extends Equatable {
  const ReportsState();

  @override
  List<Object?> get props => [];
}

class ReportsInitial extends ReportsState {
  const ReportsInitial();
}

class ReportsLoading extends ReportsState {
  const ReportsLoading();
}

class ReportsLoaded extends ReportsState {
  final SummaryStats stats;
  final List<DocumentModel> documents;

  const ReportsLoaded({required this.stats, required this.documents});

  @override
  List<Object?> get props => [stats, documents];
}

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final DocumentRepository documentRepository;

  ReportsBloc({required this.documentRepository})
    : super(const ReportsInitial()) {
    on<GenerateReportEvent>((event, emit) async {
      emit(const ReportsLoading());
      try {
        final stats = await documentRepository.getSummaryStats();
        final documents = await documentRepository.getAllDocuments(type: DocumentType.invoice);
        emit(ReportsLoaded(stats: stats, documents: documents));
      } catch (e) {
        emit(const ReportsInitial());
      }
    });
  }
}
