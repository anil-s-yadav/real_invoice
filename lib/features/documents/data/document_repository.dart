import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../domain/document_item_model.dart';
import '../domain/document_model.dart';
import '../domain/payment_record_model.dart';
import '../../settings/data/invoice_settings_repository.dart';
import '../../../core/widgets/status_badge.dart';

class SummaryStats {
  final double unpaidTotal;
  final int unpaidCount;
  final double overdueTotal;
  final int overdueCount;
  final double paidTotal;
  final int paidCount;

  const SummaryStats({
    this.unpaidTotal = 0.0,
    this.unpaidCount = 0,
    this.overdueTotal = 0.0,
    this.overdueCount = 0,
    this.paidTotal = 0.0,
    this.paidCount = 0,
  });
}

class DocumentRepository {
  static const String _activeProfileKey = 'active_profile_id';
  final _uuid = const Uuid();

  String get _userId {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return user.uid;
  }

  Future<String> _getCompanyId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeProfileKey) ?? 'default_profile';
  }

  Future<CollectionReference<Map<String, dynamic>>> _getDocumentsRef() async {
    final companyId = await _getCompanyId();
    return FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('companies')
        .doc(companyId)
        .collection('documents');
  }

  Future<List<DocumentModel>> getAllDocuments({
    DocumentType? type,
    DocumentStatus? status,
    String? searchQuery,
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
    bool forceSync = false,
  }) async {
    try {
      final ref = await _getDocumentsRef();
      Query<Map<String, dynamic>> query = ref;

      if (type != null) {
        query = query.where('docType', isEqualTo: type.name);
      }
      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }
      if (startDate != null) {
        query = query.where('issueDate', isGreaterThanOrEqualTo: startDate.toIso8601String());
      }
      if (endDate != null) {
        final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999);
        query = query.where('issueDate', isLessThanOrEqualTo: endOfDay.toIso8601String());
      }
      
      query = query.orderBy('issueDate', descending: true);
      if (limit != null) {
        query = query.limit(limit);
      }

      QuerySnapshot<Map<String, dynamic>> snapshot;
      try {
        snapshot = await query.get(GetOptions(source: forceSync ? Source.server : Source.cache));
        if (snapshot.docs.isEmpty && !forceSync) {
          snapshot = await query.get(const GetOptions(source: Source.server));
        }
      } catch (_) {
        snapshot = await query.get(const GetOptions(source: Source.server));
      }
      var docs = snapshot.docs.map((doc) => DocumentModel.fromMap(doc.data())).toList();

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim().toLowerCase();
        docs = docs.where((doc) {
          return doc.docNumber.toLowerCase().contains(q) ||
                 (doc.customerSnapshot?.name.toLowerCase().contains(q) ?? false) ||
                 (doc.notes?.toLowerCase().contains(q) ?? false);
        }).toList();
      }

      return docs;
    } catch (e) {
      print('Error getting documents: $e');
      return [];
    }
  }

  Future<DocumentModel?> getDocumentById(String id) async {
    final ref = await _getDocumentsRef();
    final doc = await ref.doc(id).get();
    if (!doc.exists) return null;
    return DocumentModel.fromMap(doc.data()!);
  }

  Future<void> saveDocument(DocumentModel document) async {
    final ref = await _getDocumentsRef();
    await ref.doc(document.id).set(document.toMap(), SetOptions(merge: true));
  }

  Future<void> deleteDocument(String id) async {
    final ref = await _getDocumentsRef();
    await ref.doc(id).delete();
  }

  Future<void> updateDocumentStatus(String id, DocumentStatus newStatus) async {
    final ref = await _getDocumentsRef();
    await ref.doc(id).update({
      'status': newStatus.name,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> recordPayment({
    required String documentId,
    required double amount,
    required String paymentMethod,
    String? referenceNumber,
    String? notes,
    DateTime? paymentDate,
  }) async {
    final ref = await _getDocumentsRef();
    final doc = await ref.doc(documentId).get();
    if (!doc.exists) return;

    final document = DocumentModel.fromMap(doc.data()!);
    final now = DateTime.now();

    final payment = PaymentRecord(
      id: _uuid.v4(),
      documentId: documentId,
      paymentDate: paymentDate ?? now,
      amount: amount,
      paymentMethod: paymentMethod,
      referenceNumber: referenceNumber,
      notes: notes,
      createdAt: now,
    );

    final updatedPayments = List<PaymentRecord>.from(document.payments)..add(payment);
    final totalPaid = updatedPayments.fold<double>(0.0, (sum, p) => sum + p.amount);

    DocumentStatus newStatus;
    if (totalPaid >= document.totalAmount && document.totalAmount > 0) {
      newStatus = DocumentStatus.paid;
    } else if (totalPaid > 0) {
      newStatus = DocumentStatus.partial;
    } else {
      newStatus = DocumentStatus.sent;
    }

    await ref.doc(documentId).update({
      'payments': updatedPayments.map((e) => e.toMap()).toList(),
      'amountPaid': totalPaid,
      'status': newStatus.name,
      'updatedAt': now.toIso8601String(),
    });
  }

  Future<String> getNextDocumentNumber(DocumentType type) async {
    final settingsRepo = InvoiceSettingsRepository();
    final customPrefix = await settingsRepo.getPrefixForType(type);
    final includeYear = await settingsRepo.getIncludeYear();
    final padding = await settingsRepo.getPaddingDigits();
    
    final currentYear = DateTime.now().year;
    final prefix = includeYear ? '$customPrefix$currentYear-' : customPrefix;

    try {
      final ref = await _getDocumentsRef();
      final querySnapshot = await ref
          .where('docType', isEqualTo: type.name)
          // Note: Firestore string matching for prefixes
          .where('docNumber', isGreaterThanOrEqualTo: prefix)
          .where('docNumber', isLessThan: '$prefix\uf8ff')
          .orderBy('docNumber', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return '$prefix${1.toString().padLeft(padding, '0')}';
      }

      final lastNumberStr = querySnapshot.docs.first.data()['docNumber'] as String;
      final suffix = lastNumberStr.replaceFirst(prefix, '');
      final number = int.tryParse(suffix) ?? 0;
      final nextNumber = (number + 1).toString().padLeft(padding, '0');
      return '$prefix$nextNumber';
    } catch (e) {
      print('Error getting next doc number: $e');
      return '$prefix${1.toString().padLeft(padding, '0')}';
    }
  }

  Future<DocumentModel> convertProformaToInvoice(String proformaId) async {
    final proforma = await getDocumentById(proformaId);
    if (proforma == null) throw Exception('Proforma not found');

    await updateDocumentStatus(proformaId, DocumentStatus.accepted);
    final nextInvoiceNumber = await getNextDocumentNumber(DocumentType.invoice);
    final now = DateTime.now();

    final newInvoiceId = _uuid.v4();
    final newItems = proforma.items.map((item) {
      return item.copyWith(id: _uuid.v4(), documentId: newInvoiceId);
    }).toList();

    final invoice = DocumentModel(
      id: newInvoiceId,
      docNumber: nextInvoiceNumber,
      docType: DocumentType.invoice,
      customerId: proforma.customerId,
      customerSnapshot: proforma.customerSnapshot,
      issueDate: now,
      dueDate: now.add(const Duration(days: 7)),
      items: newItems,
      overallDiscountValue: proforma.overallDiscountValue,
      overallDiscountType: proforma.overallDiscountType,
      status: DocumentStatus.sent,
      templateId: proforma.templateId,
      notes: proforma.notes,
      terms: proforma.terms,
      selectedBankDetailId: proforma.selectedBankDetailId,
      selectedUpiDetailId: proforma.selectedUpiDetailId,
      poNumber: proforma.poNumber,
      subject: proforma.subject,
      shippingCharges: proforma.shippingCharges,
      includePaymentDetails: proforma.includePaymentDetails,
      relatedDocId: proformaId,
      createdAt: now,
      updatedAt: now,
    );

    await saveDocument(invoice);
    return invoice;
  }

  Future<DocumentModel> convertQuotationToInvoice(String quotationId) async {
    final quotation = await getDocumentById(quotationId);
    if (quotation == null) throw Exception('Quotation not found');

    await updateDocumentStatus(quotationId, DocumentStatus.accepted);
    final nextInvoiceNumber = await getNextDocumentNumber(DocumentType.invoice);
    final now = DateTime.now();

    final newInvoiceId = _uuid.v4();
    final newItems = quotation.items.map((item) {
      return item.copyWith(id: _uuid.v4(), documentId: newInvoiceId);
    }).toList();

    final invoice = DocumentModel(
      id: newInvoiceId,
      docNumber: nextInvoiceNumber,
      docType: DocumentType.invoice,
      customerId: quotation.customerId,
      customerSnapshot: quotation.customerSnapshot,
      issueDate: now,
      dueDate: now.add(const Duration(days: 15)),
      status: DocumentStatus.sent,
      items: newItems,
      payments: const [],
      overallDiscountValue: quotation.overallDiscountValue,
      overallDiscountType: quotation.overallDiscountType,
      templateId: quotation.templateId,
      notes: quotation.notes,
      terms: quotation.terms,
      relatedDocId: quotationId,
      createdAt: now,
      updatedAt: now,
    );

    await saveDocument(invoice);
    return invoice;
  }

  Future<DocumentModel> createReceiptFromInvoice({
    required String invoiceId,
    required double amount,
    required String paymentMethod,
    String? referenceNumber,
    String? notes,
  }) async {
    final invoice = await getDocumentById(invoiceId);
    if (invoice == null) throw Exception('Invoice not found');

    final now = DateTime.now();
    await recordPayment(
      documentId: invoiceId,
      amount: amount,
      paymentMethod: paymentMethod,
      referenceNumber: referenceNumber,
      notes: notes,
      paymentDate: now,
    );

    final nextReceiptNumber = await getNextDocumentNumber(DocumentType.receipt);
    final receiptId = _uuid.v4();

    final receiptItem = DocumentItem(
      id: _uuid.v4(),
      documentId: receiptId,
      title: 'Payment for Invoice ${invoice.docNumber}',
      description: referenceNumber != null && referenceNumber.isNotEmpty
          ? 'Ref / UTR: $referenceNumber via $paymentMethod'
          : 'Payment via $paymentMethod',
      quantity: 1,
      unit: 'payment',
      unitPrice: amount,
      discountPercent: 0,
      taxPercent: 0,
    );

    final receiptPayment = PaymentRecord(
      id: _uuid.v4(),
      documentId: receiptId,
      paymentDate: now,
      amount: amount,
      paymentMethod: paymentMethod,
      referenceNumber: referenceNumber,
      notes: notes,
      createdAt: now,
    );

    final receipt = DocumentModel(
      id: receiptId,
      docNumber: nextReceiptNumber,
      docType: DocumentType.receipt,
      customerId: invoice.customerId,
      customerSnapshot: invoice.customerSnapshot,
      issueDate: now,
      dueDate: now,
      status: DocumentStatus.paid,
      items: [receiptItem],
      payments: [receiptPayment],
      templateId: invoice.templateId,
      notes: notes ?? 'Received with thanks.',
      terms: 'This is a computer generated receipt.',
      relatedDocId: invoiceId,
      createdAt: now,
      updatedAt: now,
    );

    await saveDocument(receipt);
    return receipt;
  }

  Future<SummaryStats> getSummaryStats() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day).toIso8601String();

    try {
      final ref = await _getDocumentsRef();
      final snapshot = await ref.where('docType', isEqualTo: DocumentType.invoice.name).get();
      
      double unpaidTotal = 0;
      int unpaidCount = 0;
      double overdueTotal = 0;
      int overdueCount = 0;
      double paidTotal = 0;
      int paidCount = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final status = data['status'] as String? ?? '';
        final total = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;
        final paid = (data['amountPaid'] as num?)?.toDouble() ?? 0.0;
        final dueDate = data['dueDate'] as String? ?? '';
        final remaining = (total - paid).clamp(0.0, double.infinity);

        if (status == DocumentStatus.paid.name || remaining <= 0) {
          paidTotal += paid;
          paidCount++;
        } else {
          unpaidTotal += remaining;
          unpaidCount++;

          if (dueDate.isNotEmpty && dueDate.compareTo(today) < 0) {
            overdueTotal += remaining;
            overdueCount++;
          }
        }
      }

      return SummaryStats(
        unpaidTotal: unpaidTotal,
        unpaidCount: unpaidCount,
        overdueTotal: overdueTotal,
        overdueCount: overdueCount,
        paidTotal: paidTotal,
        paidCount: paidCount,
      );
    } catch (e) {
      print('Error getting stats: $e');
      return const SummaryStats();
    }
  }
}
