import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/document_repository.dart';
import '../domain/document_model.dart';
import 'document_event.dart';
import 'document_state.dart';

class DocumentBloc extends Bloc<DocumentEvent, DocumentState> {
  final DocumentRepository repository;

  DocumentBloc({required this.repository}) : super(const DocumentInitial()) {
    on<LoadDocumentsEvent>(_onLoadDocuments);
    on<SaveDocumentEvent>(_onSaveDocument);
    on<DeleteDocumentEvent>(_onDeleteDocument);
    on<RecordPaymentEvent>(_onRecordPayment);
    on<ConvertQuotationEvent>(_onConvertQuotation);
  }

  Future<void> _onLoadDocuments(
    LoadDocumentsEvent event,
    Emitter<DocumentState> emit,
  ) async {
    emit(const DocumentLoading());
    try {
      final documents = await repository.getAllDocuments(
        type: event.type,
        status: event.status,
        searchQuery: event.searchQuery,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(
        DocumentLoaded(
          documents,
          typeFilter: event.type,
          statusFilter: event.status,
          searchQuery: event.searchQuery,
          startDateFilter: event.startDate,
          endDateFilter: event.endDate,
        ),
      );
    } catch (e) {
      emit(DocumentError(e.toString()));
    }
  }

  Future<void> _onSaveDocument(
    SaveDocumentEvent event,
    Emitter<DocumentState> emit,
  ) async {
    try {
      await repository.saveDocument(event.document);
      final currentLoaded = state is DocumentLoaded
          ? state as DocumentLoaded
          : null;
      final documents = await repository.getAllDocuments(
        type: currentLoaded?.typeFilter,
        status: currentLoaded?.statusFilter,
        searchQuery: currentLoaded?.searchQuery,
        startDate: currentLoaded?.startDateFilter,
        endDate: currentLoaded?.endDateFilter,
      );
      emit(
        DocumentLoaded(
          documents,
          typeFilter: currentLoaded?.typeFilter,
          statusFilter: currentLoaded?.statusFilter,
          searchQuery: currentLoaded?.searchQuery ?? '',
          startDateFilter: currentLoaded?.startDateFilter,
          endDateFilter: currentLoaded?.endDateFilter,
        ),
      );
    } catch (e) {
      emit(DocumentError(e.toString()));
    }
  }

  Future<void> _onDeleteDocument(
    DeleteDocumentEvent event,
    Emitter<DocumentState> emit,
  ) async {
    try {
      await repository.deleteDocument(event.id);
      final currentLoaded = state is DocumentLoaded
          ? state as DocumentLoaded
          : null;
      final documents = await repository.getAllDocuments(
        type: currentLoaded?.typeFilter,
        status: currentLoaded?.statusFilter,
        searchQuery: currentLoaded?.searchQuery,
        startDate: currentLoaded?.startDateFilter,
        endDate: currentLoaded?.endDateFilter,
      );
      emit(
        DocumentLoaded(
          documents,
          typeFilter: currentLoaded?.typeFilter,
          statusFilter: currentLoaded?.statusFilter,
          searchQuery: currentLoaded?.searchQuery ?? '',
          startDateFilter: currentLoaded?.startDateFilter,
          endDateFilter: currentLoaded?.endDateFilter,
        ),
      );
    } catch (e) {
      emit(DocumentError(e.toString()));
    }
  }

  Future<void> _onRecordPayment(
    RecordPaymentEvent event,
    Emitter<DocumentState> emit,
  ) async {
    try {
      DocumentModel? receiptDoc;
      if (event.generateReceipt) {
        receiptDoc = await repository.createReceiptFromInvoice(
          invoiceId: event.documentId,
          amount: event.amount,
          paymentMethod: event.paymentMethod,
          referenceNumber: event.referenceNumber,
          notes: event.notes,
        );
      } else {
        await repository.recordPayment(
          documentId: event.documentId,
          amount: event.amount,
          paymentMethod: event.paymentMethod,
          referenceNumber: event.referenceNumber,
          notes: event.notes,
        );
      }

      final currentLoaded = state is DocumentLoaded
          ? state as DocumentLoaded
          : null;
      final documents = await repository.getAllDocuments(
        type: currentLoaded?.typeFilter,
        status: currentLoaded?.statusFilter,
        searchQuery: currentLoaded?.searchQuery,
        startDate: currentLoaded?.startDateFilter,
        endDate: currentLoaded?.endDateFilter,
      );
      emit(
        DocumentActionSuccess(
          'Payment recorded',
          documents: documents,
          typeFilter: currentLoaded?.typeFilter,
          statusFilter: currentLoaded?.statusFilter,
          searchQuery: currentLoaded?.searchQuery ?? '',
          startDateFilter: currentLoaded?.startDateFilter,
          endDateFilter: currentLoaded?.endDateFilter,
          resultingDocument: receiptDoc,
        ),
      );
    } catch (e) {
      emit(DocumentError(e.toString()));
    }
  }

  Future<void> _onConvertQuotation(
    ConvertQuotationEvent event,
    Emitter<DocumentState> emit,
  ) async {
    try {
      final invoice = await repository.convertQuotationToInvoice(
        event.quotationId,
      );
      final currentLoaded = state is DocumentLoaded
          ? state as DocumentLoaded
          : null;
      final documents = await repository.getAllDocuments(
        type: currentLoaded?.typeFilter,
        status: currentLoaded?.statusFilter,
        searchQuery: currentLoaded?.searchQuery,
        startDate: currentLoaded?.startDateFilter,
        endDate: currentLoaded?.endDateFilter,
      );
      emit(
        DocumentActionSuccess(
          'Quotation converted to Invoice',
          documents: documents,
          typeFilter: currentLoaded?.typeFilter,
          statusFilter: currentLoaded?.statusFilter,
          searchQuery: currentLoaded?.searchQuery ?? '',
          startDateFilter: currentLoaded?.startDateFilter,
          endDateFilter: currentLoaded?.endDateFilter,
          resultingDocument: invoice,
        ),
      );
    } catch (e) {
      emit(DocumentError(e.toString()));
    }
  }
}
