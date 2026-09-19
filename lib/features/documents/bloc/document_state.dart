import 'package:equatable/equatable.dart';
import '../../../core/widgets/status_badge.dart';
import '../domain/document_model.dart';

abstract class DocumentState extends Equatable {
  const DocumentState();

  @override
  List<Object?> get props => [];
}

class DocumentInitial extends DocumentState {
  const DocumentInitial();
}

class DocumentLoading extends DocumentState {
  const DocumentLoading();
}

class DocumentLoaded extends DocumentState {
  final List<DocumentModel> documents;
  final DocumentType? typeFilter;
  final DocumentStatus? statusFilter;
  final String searchQuery;
  final DateTime? startDateFilter;
  final DateTime? endDateFilter;

  final DocumentModel? resultingDocument;

  const DocumentLoaded(
    this.documents, {
    this.typeFilter,
    this.statusFilter,
    this.searchQuery = '',
    this.startDateFilter,
    this.endDateFilter,

    this.resultingDocument,
  });

  @override
  List<Object?> get props => [
    documents,
    typeFilter,
    statusFilter,
    searchQuery,
    startDateFilter,
    endDateFilter,
    resultingDocument,
  ];
}

class DocumentActionSuccess extends DocumentLoaded {
  final String message;

  const DocumentActionSuccess(
    this.message, {
    required List<DocumentModel> documents,
    DocumentType? typeFilter,
    DocumentStatus? statusFilter,
    String searchQuery = '',
    DateTime? startDateFilter,
    DateTime? endDateFilter,
    DocumentModel? resultingDocument,
  }) : super(
         documents,
         typeFilter: typeFilter,
         statusFilter: statusFilter,
         searchQuery: searchQuery,
         startDateFilter: startDateFilter,
         endDateFilter: endDateFilter,
         resultingDocument: resultingDocument,
       );

  @override
  List<Object?> get props => [
    message,
    documents,
    typeFilter,
    statusFilter,
    searchQuery,
    startDateFilter,
    endDateFilter,
    resultingDocument,
  ];
}

class DocumentError extends DocumentState {
  final String message;

  const DocumentError(this.message);

  @override
  List<Object?> get props => [message];
}
