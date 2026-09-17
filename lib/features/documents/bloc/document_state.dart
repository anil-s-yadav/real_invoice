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
  final int? monthFilter;
  final int? yearFilter;
  final DocumentModel? resultingDocument;

  const DocumentLoaded(
    this.documents, {
    this.typeFilter,
    this.statusFilter,
    this.searchQuery = '',
    this.monthFilter,
    this.yearFilter,
    this.resultingDocument,
  });

  @override
  List<Object?> get props => [
    documents,
    typeFilter,
    statusFilter,
    searchQuery,
    monthFilter,
    yearFilter,
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
    int? monthFilter,
    int? yearFilter,
    DocumentModel? resultingDocument,
  }) : super(
          documents,
          typeFilter: typeFilter,
          statusFilter: statusFilter,
          searchQuery: searchQuery,
          monthFilter: monthFilter,
          yearFilter: yearFilter,
          resultingDocument: resultingDocument,
        );

  @override
  List<Object?> get props => [
    message,
    documents,
    typeFilter,
    statusFilter,
    searchQuery,
    monthFilter,
    yearFilter,
    resultingDocument,
  ];
}

class DocumentError extends DocumentState {
  final String message;

  const DocumentError(this.message);

  @override
  List<Object?> get props => [message];
}
