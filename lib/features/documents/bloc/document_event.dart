import 'package:equatable/equatable.dart';
import '../../../core/widgets/status_badge.dart';
import '../domain/document_model.dart';

abstract class DocumentEvent extends Equatable {
  const DocumentEvent();

  @override
  List<Object?> get props => [];
}

class LoadDocumentsEvent extends DocumentEvent {
  final DocumentType? type;
  final DocumentStatus? status;
  final String searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadDocumentsEvent({
    this.type,
    this.status,
    this.searchQuery = '',
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [type, status, searchQuery, startDate, endDate];
}

class SaveDocumentEvent extends DocumentEvent {
  final DocumentModel document;

  const SaveDocumentEvent(this.document);

  @override
  List<Object?> get props => [document];
}

class DeleteDocumentEvent extends DocumentEvent {
  final String id;

  const DeleteDocumentEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class RecordPaymentEvent extends DocumentEvent {
  final String documentId;
  final double amount;
  final String paymentMethod;
  final String? referenceNumber;
  final String? notes;
  final bool generateReceipt;

  const RecordPaymentEvent({
    required this.documentId,
    required this.amount,
    required this.paymentMethod,
    this.referenceNumber,
    this.notes,
    this.generateReceipt = true,
  });

  @override
  List<Object?> get props => [
    documentId,
    amount,
    paymentMethod,
    referenceNumber,
    notes,
    generateReceipt,
  ];
}

class ConvertQuotationEvent extends DocumentEvent {
  final String quotationId;

  const ConvertQuotationEvent(this.quotationId);

  @override
  List<Object?> get props => [quotationId];
}
