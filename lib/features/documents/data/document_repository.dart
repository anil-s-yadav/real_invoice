import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/database_tables.dart';
import '../../../core/widgets/status_badge.dart';
import '../domain/document_item_model.dart';
import '../domain/document_model.dart';
import '../domain/payment_record_model.dart';

class SummaryStats {
  final double unpaidTotal;
  final int unpaidCount;
  final double overdueTotal;
  final int overdueCount;
  final double paidTotal;
  final int paidCount;
  final int draftCount;

  const SummaryStats({
    this.unpaidTotal = 0.0,
    this.unpaidCount = 0,
    this.overdueTotal = 0.0,
    this.overdueCount = 0,
    this.paidTotal = 0.0,
    this.paidCount = 0,
    this.draftCount = 0,
  });
}

class DocumentRepository {
  final AppDatabase _appDatabase;
  final _uuid = const Uuid();

  DocumentRepository({AppDatabase? appDatabase})
      : _appDatabase = appDatabase ?? AppDatabase.instance;

  Future<List<DocumentModel>> getAllDocuments({
    DocumentType? type,
    DocumentStatus? status,
    String? searchQuery,
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await _appDatabase.database;

    final whereClauses = <String>[];
    final whereArgs = <dynamic>[];

    if (type != null) {
      whereClauses.add('docType = ?');
      whereArgs.add(type.name);
    }

    if (status != null) {
      whereClauses.add('status = ?');
      whereArgs.add(status.name);
    }

    if (startDate != null) {
      whereClauses.add('issueDate >= ?');
      whereArgs.add(startDate.toIso8601String());
    }
    
    if (endDate != null) {
      whereClauses.add('issueDate <= ?');
      // Add 1 day and subtract 1 millisecond to include the entire end date
      final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59, 999);
      whereArgs.add(endOfDay.toIso8601String());
    }

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      whereClauses.add('(docNumber LIKE ? OR customerSnapshot LIKE ? OR notes LIKE ?)');
      final q = '%${searchQuery.trim()}%';
      whereArgs.addAll([q, q, q]);
    }

    final where = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

    final docRows = await db.query(
      DatabaseTables.documents,
      where: where,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'issueDate DESC, createdAt DESC',
      limit: limit,
    );

    final List<DocumentModel> results = [];
    for (final row in docRows) {
      final docId = row['id'] as String;

      final itemRows = await db.query(
        DatabaseTables.documentItems,
        where: 'documentId = ?',
        whereArgs: [docId],
      );
      final items = itemRows.map((m) => DocumentItem.fromMap(m)).toList();

      final paymentRows = await db.query(
        DatabaseTables.paymentRecords,
        where: 'documentId = ?',
        whereArgs: [docId],
        orderBy: 'paymentDate DESC',
      );
      final payments = paymentRows.map((m) => PaymentRecord.fromMap(m)).toList();

      results.add(DocumentModel.fromMap(row, items: items, payments: payments));
    }

    return results;
  }

  Future<DocumentModel?> getDocumentById(String id) async {
    final db = await _appDatabase.database;
    final docRows = await db.query(
      DatabaseTables.documents,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (docRows.isEmpty) return null;

    final itemRows = await db.query(
      DatabaseTables.documentItems,
      where: 'documentId = ?',
      whereArgs: [id],
    );
    final items = itemRows.map((m) => DocumentItem.fromMap(m)).toList();

    final paymentRows = await db.query(
      DatabaseTables.paymentRecords,
      where: 'documentId = ?',
      whereArgs: [id],
      orderBy: 'paymentDate DESC',
    );
    final payments = paymentRows.map((m) => PaymentRecord.fromMap(m)).toList();

    return DocumentModel.fromMap(docRows.first, items: items, payments: payments);
  }

  Future<void> saveDocument(DocumentModel document) async {
    final db = await _appDatabase.database;

    await db.transaction((txn) async {
      // 1. Save document header
      await txn.insert(
        DatabaseTables.documents,
        document.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 2. Clear existing items and insert new ones
      await txn.delete(
        DatabaseTables.documentItems,
        where: 'documentId = ?',
        whereArgs: [document.id],
      );

      for (final item in document.items) {
        await txn.insert(
          DatabaseTables.documentItems,
          item.copyWith(documentId: document.id).toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }

      // 3. Upsert payments if provided
      for (final payment in document.payments) {
        await txn.insert(
          DatabaseTables.paymentRecords,
          payment.copyWith(documentId: document.id).toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> deleteDocument(String id) async {
    final db = await _appDatabase.database;
    await db.transaction((txn) async {
      await txn.delete(
        DatabaseTables.documentItems,
        where: 'documentId = ?',
        whereArgs: [id],
      );
      await txn.delete(
        DatabaseTables.paymentRecords,
        where: 'documentId = ?',
        whereArgs: [id],
      );
      await txn.delete(
        DatabaseTables.documents,
        where: 'id = ?',
        whereArgs: [id],
      );
    });
  }

  Future<void> updateDocumentStatus(String id, DocumentStatus newStatus) async {
    final db = await _appDatabase.database;
    await db.update(
      DatabaseTables.documents,
      {'status': newStatus.name, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> recordPayment({
    required String documentId,
    required double amount,
    required String paymentMethod,
    String? referenceNumber,
    String? notes,
    DateTime? paymentDate,
  }) async {
    final db = await _appDatabase.database;
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

    await db.transaction((txn) async {
      await txn.insert(DatabaseTables.paymentRecords, payment.toMap());

      // Recalculate amount paid
      final rows = await txn.query(
        DatabaseTables.paymentRecords,
        columns: ['amount'],
        where: 'documentId = ?',
        whereArgs: [documentId],
      );
      final totalPaid = rows.fold<double>(
        0.0,
        (sum, row) => sum + ((row['amount'] as num?)?.toDouble() ?? 0.0),
      );

      final docHeader = await txn.query(
        DatabaseTables.documents,
        columns: ['totalAmount', 'status'],
        where: 'id = ?',
        whereArgs: [documentId],
      );

      if (docHeader.isNotEmpty) {
        final totalAmount = (docHeader.first['totalAmount'] as num?)?.toDouble() ?? 0.0;
        final DocumentStatus newStatus;
        if (totalPaid >= totalAmount && totalAmount > 0) {
          newStatus = DocumentStatus.paid;
        } else if (totalPaid > 0) {
          newStatus = DocumentStatus.partial;
        } else {
          newStatus = DocumentStatus.sent;
        }

        await txn.update(
          DatabaseTables.documents,
          {
            'amountPaid': totalPaid,
            'status': newStatus.name,
            'updatedAt': now.toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [documentId],
        );
      }
    });
  }

  Future<String> getNextDocumentNumber(DocumentType type) async {
    final db = await _appDatabase.database;
    final currentYear = DateTime.now().year;
    final prefix = '${type.prefix}$currentYear-';

    final results = await db.query(
      DatabaseTables.documents,
      columns: ['docNumber'],
      where: 'docType = ? AND docNumber LIKE ?',
      whereArgs: [type.name, '$prefix%'],
      orderBy: 'docNumber DESC',
      limit: 1,
    );

    if (results.isEmpty) {
      return '${prefix}0001';
    }

    final lastNumberStr = results.first['docNumber'] as String;
    final suffix = lastNumberStr.replaceFirst(prefix, '');
    final number = int.tryParse(suffix) ?? 0;
    final nextNumber = (number + 1).toString().padLeft(4, '0');
    return '$prefix$nextNumber';
  }

  Future<DocumentModel> convertQuotationToInvoice(String quotationId) async {
    final quotation = await getDocumentById(quotationId);
    if (quotation == null) {
      throw Exception('Quotation not found');
    }

    // 1. Mark quotation as accepted
    await updateDocumentStatus(quotationId, DocumentStatus.accepted);

    // 2. Generate new Invoice Number
    final nextInvoiceNumber = await getNextDocumentNumber(DocumentType.invoice);
    final now = DateTime.now();

    // 3. Create new Invoice
    final newInvoiceId = _uuid.v4();
    final newItems = quotation.items.map((item) {
      return item.copyWith(
        id: _uuid.v4(),
        documentId: newInvoiceId,
      );
    }).toList();

    final invoice = DocumentModel(
      id: newInvoiceId,
      docNumber: nextInvoiceNumber,
      docType: DocumentType.invoice,
      customerId: quotation.customerId,
      customerSnapshot: quotation.customerSnapshot,
      issueDate: now,
      dueDate: now.add(const Duration(days: 15)),
      status: DocumentStatus.draft,
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
    if (invoice == null) {
      throw Exception('Invoice not found');
    }

    final now = DateTime.now();
    // 1. Record payment on the invoice
    await recordPayment(
      documentId: invoiceId,
      amount: amount,
      paymentMethod: paymentMethod,
      referenceNumber: referenceNumber,
      notes: notes,
      paymentDate: now,
    );

    // 2. Generate receipt document
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
    final db = await _appDatabase.database;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day).toIso8601String();

    final docs = await db.query(
      DatabaseTables.documents,
      columns: ['docType', 'status', 'totalAmount', 'amountPaid', 'dueDate'],
      where: 'docType = ?',
      whereArgs: [DocumentType.invoice.name],
    );

    double unpaidTotal = 0;
    int unpaidCount = 0;
    double overdueTotal = 0;
    int overdueCount = 0;
    double paidTotal = 0;
    int paidCount = 0;
    int draftCount = 0;

    for (final doc in docs) {
      final status = doc['status'] as String;
      final total = (doc['totalAmount'] as num?)?.toDouble() ?? 0.0;
      final paid = (doc['amountPaid'] as num?)?.toDouble() ?? 0.0;
      final dueDate = doc['dueDate'] as String;
      final remaining = (total - paid).clamp(0.0, double.infinity);

      if (status == DocumentStatus.draft.name) {
        draftCount++;
      } else if (status == DocumentStatus.paid.name || remaining <= 0) {
        paidTotal += paid;
        paidCount++;
      } else {
        // Unpaid or Partial
        unpaidTotal += remaining;
        unpaidCount++;

        if (dueDate.compareTo(today) < 0) {
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
      draftCount: draftCount,
    );
  }
}
