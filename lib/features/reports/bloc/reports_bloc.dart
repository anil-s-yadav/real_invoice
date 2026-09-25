import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../documents/data/document_repository.dart';
import '../../documents/domain/document_model.dart';
import '../domain/analytics_data_models.dart';

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

class LoadAnalyticsEvent extends ReportsEvent {
  final TimeFilterPreset preset;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final String? businessGstin;

  const LoadAnalyticsEvent({
    this.preset = TimeFilterPreset.thisYear,
    this.customStartDate,
    this.customEndDate,
    this.businessGstin,
  });

  @override
  List<Object?> get props => [preset, customStartDate, customEndDate, businessGstin];
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
  final AnalyticsData data;

  const ReportsLoaded({
    required this.stats,
    required this.documents,
    required this.data,
  });

  @override
  List<Object?> get props => [stats, documents, data];
}

class ReportsError extends ReportsState {
  final String message;
  const ReportsError(this.message);

  @override
  List<Object?> get props => [message];
}

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final DocumentRepository documentRepository;

  ReportsBloc({required this.documentRepository})
    : super(const ReportsInitial()) {
    on<GenerateReportEvent>(_onGenerateReport);
    on<LoadAnalyticsEvent>(_onLoadAnalytics);
  }

  Future<void> _onGenerateReport(
    GenerateReportEvent event,
    Emitter<ReportsState> emit,
  ) async {
    emit(const ReportsLoading());
    try {
      final stats = await documentRepository.getSummaryStats();
      final allDocs = await documentRepository.getAllDocuments();
      final data = AnalyticsData.compute(
        allDocuments: allDocs,
        preset: TimeFilterPreset.custom,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(ReportsLoaded(stats: stats, documents: allDocs, data: data));
    } catch (e) {
      emit(ReportsError(e.toString()));
    }
  }

  Future<void> _onLoadAnalytics(
    LoadAnalyticsEvent event,
    Emitter<ReportsState> emit,
  ) async {
    emit(const ReportsLoading());
    try {
      final now = DateTime.now();
      DateTime startDate;
      DateTime endDate;

      if (event.preset == TimeFilterPreset.custom &&
          event.customStartDate != null &&
          event.customEndDate != null) {
        startDate = event.customStartDate!;
        endDate = event.customEndDate!;
      } else {
        startDate = _getStartOfPeriod(event.preset, now);
        endDate = _getEndOfPeriod(event.preset, now);
      }

      final stats = await documentRepository.getSummaryStats();
      final allDocs = await documentRepository.getAllDocuments();

      final data = AnalyticsData.compute(
        allDocuments: allDocs,
        preset: event.preset,
        startDate: startDate,
        endDate: endDate,
        businessGstin: event.businessGstin,
      );

      emit(ReportsLoaded(stats: stats, documents: allDocs, data: data));
    } catch (e) {
      emit(ReportsError(e.toString()));
    }
  }

  DateTime _getStartOfPeriod(TimeFilterPreset preset, DateTime now) {
    switch (preset) {
      case TimeFilterPreset.thisMonth:
        return DateTime(now.year, now.month, 1);
      case TimeFilterPreset.thisQuarter:
        final quarterMonth = ((now.month - 1) ~/ 3) * 3 + 1;
        return DateTime(now.year, quarterMonth, 1);
      case TimeFilterPreset.thisYear:
        return now.month >= 4
            ? DateTime(now.year, 4, 1)
            : DateTime(now.year - 1, 4, 1);
      case TimeFilterPreset.allTime:
        return DateTime(2000, 1, 1);
      case TimeFilterPreset.custom:
        return DateTime(now.year, 1, 1);
    }
  }

  DateTime _getEndOfPeriod(TimeFilterPreset preset, DateTime now) {
    switch (preset) {
      case TimeFilterPreset.thisMonth:
        return DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      case TimeFilterPreset.thisQuarter:
        final quarterEndMonth = ((now.month - 1) ~/ 3) * 3 + 3;
        return DateTime(now.year, quarterEndMonth + 1, 0, 23, 59, 59);
      case TimeFilterPreset.thisYear:
        final fyStartYear = now.month >= 4 ? now.year : now.year - 1;
        return DateTime(fyStartYear + 1, 3, 31, 23, 59, 59);
      case TimeFilterPreset.allTime:
        return DateTime(2100, 1, 1);
      case TimeFilterPreset.custom:
        return DateTime(now.year, now.month, now.day, 23, 59, 59);
    }
  }
}
