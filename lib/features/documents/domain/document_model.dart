import 'dart:convert';
import 'dart:math';
import '../../../core/widgets/status_badge.dart';
import '../../customers/domain/customer_model.dart';
import 'document_item_model.dart';
import 'payment_record_model.dart';

enum DocumentType {
  invoice,
  quotation,
  receipt,
  proforma,
}

extension DocumentTypeX on DocumentType {
  String get displayName {
    switch (this) {
      case DocumentType.invoice:
        return 'Invoice';
      case DocumentType.quotation:
        return 'Quotation';
      case DocumentType.receipt:
        return 'Receipt';
      case DocumentType.proforma:
        return 'Proforma Invoice';
    }
  }

  String get prefix {
    switch (this) {
      case DocumentType.invoice:
        return 'INV-';
      case DocumentType.quotation:
        return 'EST-';
      case DocumentType.receipt:
        return 'REC-';
      case DocumentType.proforma:
        return 'PRO-';
    }
  }
}

enum DiscountType { percentage, fixed }

class DocumentModel {
  final String id;
  final String docNumber;
  final DocumentType docType;
  final String? customerId;
  final Customer? customerSnapshot;
  final DateTime issueDate;
  final DateTime dueDate;
  final DocumentStatus status;
  final List<DocumentItem> items;
  final List<PaymentRecord> payments;
  final double overallDiscountValue;
  final DiscountType overallDiscountType;
  final String templateId; // 'modern_crimson', 'minimal', 'professional', 'elegant', 'compact', 'bold'
  final String? notes;
  final String? terms;
  final String? relatedDocId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DocumentModel({
    required this.id,
    required this.docNumber,
    required this.docType,
    this.customerId,
    this.customerSnapshot,
    required this.issueDate,
    required this.dueDate,
    this.status = DocumentStatus.draft,
    this.items = const [],
    this.payments = const [],
    this.overallDiscountValue = 0.0,
    this.overallDiscountType = DiscountType.percentage,
    this.templateId = 'modern_crimson',
    this.notes,
    this.terms,
    this.relatedDocId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Raw sum of all items' gross amount (qty * price)
  double get grossSubtotal => items.fold(0.0, (sum, item) => sum + item.grossAmount);

  /// Line-level discounts total
  double get itemDiscountsTotal => items.fold(0.0, (sum, item) => sum + item.discountAmount);

  /// Subtotal after item-level discounts
  double get subtotal => grossSubtotal - itemDiscountsTotal;

  /// Overall document-level discount
  double get overallDiscountAmount {
    if (overallDiscountType == DiscountType.percentage) {
      return subtotal * (overallDiscountValue / 100.0);
    } else {
      return min(overallDiscountValue, subtotal);
    }
  }

  /// Taxable amount after overall discount
  double get taxableAmount => max(0.0, subtotal - overallDiscountAmount);

  /// Total tax calculated across items
  double get totalTaxAmount => items.fold(0.0, (sum, item) => sum + item.taxAmount);

  /// Net amount before roundoff
  double get rawTotalAmount => taxableAmount + totalTaxAmount;

  /// Round-off adjustment to nearest integer (standard in Indian invoices)
  double get roundOff => (rawTotalAmount.roundToDouble() - rawTotalAmount);

  /// Final payable total amount
  double get totalAmount => rawTotalAmount + roundOff;

  /// Total amount collected
  double get totalPaid => payments.fold(0.0, (sum, p) => sum + p.amount);

  /// Remaining amount due
  double get balanceDue => max(0.0, totalAmount - totalPaid);

  /// Effective status considering dates and payments
  DocumentStatus get calculatedStatus {
    if (status == DocumentStatus.cancelled) return DocumentStatus.cancelled;
    if (docType == DocumentType.quotation) {
      return status; // Can be draft, sent, accepted
    }
    if (docType == DocumentType.receipt) {
      return DocumentStatus.paid;
    }
    if (totalPaid >= totalAmount && totalAmount > 0) {
      return DocumentStatus.paid;
    }
    if (totalPaid > 0) {
      return DocumentStatus.partial;
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDueDate = DateTime(dueDate.year, dueDate.month, dueDate.day);
    if (status != DocumentStatus.draft && targetDueDate.isBefore(today)) {
      return DocumentStatus.overdue;
    }
    return status;
  }

  DocumentModel copyWith({
    String? id,
    String? docNumber,
    DocumentType? docType,
    String? customerId,
    Customer? customerSnapshot,
    DateTime? issueDate,
    DateTime? dueDate,
    DocumentStatus? status,
    List<DocumentItem>? items,
    List<PaymentRecord>? payments,
    double? overallDiscountValue,
    DiscountType? overallDiscountType,
    String? templateId,
    String? notes,
    String? terms,
    String? relatedDocId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DocumentModel(
      id: id ?? this.id,
      docNumber: docNumber ?? this.docNumber,
      docType: docType ?? this.docType,
      customerId: customerId ?? this.customerId,
      customerSnapshot: customerSnapshot ?? this.customerSnapshot,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      items: items ?? this.items,
      payments: payments ?? this.payments,
      overallDiscountValue: overallDiscountValue ?? this.overallDiscountValue,
      overallDiscountType: overallDiscountType ?? this.overallDiscountType,
      templateId: templateId ?? this.templateId,
      notes: notes ?? this.notes,
      terms: terms ?? this.terms,
      relatedDocId: relatedDocId ?? this.relatedDocId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'docNumber': docNumber,
      'docType': docType.name,
      'customerId': customerId,
      'customerSnapshot': customerSnapshot != null ? jsonEncode(customerSnapshot!.toMap()) : null,
      'issueDate': issueDate.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'status': status.name,
      'overallDiscountValue': overallDiscountValue,
      'overallDiscountType': overallDiscountType.name,
      'templateId': templateId,
      'notes': notes,
      'terms': terms,
      'relatedDocId': relatedDocId,
      'subtotal': subtotal,
      'taxAmount': totalTaxAmount,
      'roundOff': roundOff,
      'totalAmount': totalAmount,
      'amountPaid': totalPaid,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory DocumentModel.fromMap(
    Map<String, dynamic> map, {
    List<DocumentItem> items = const [],
    List<PaymentRecord> payments = const [],
  }) {
    Customer? snapshot;
    final customerRaw = map['customerSnapshot'] as String?;
    if (customerRaw != null && customerRaw.isNotEmpty) {
      try {
        snapshot = Customer.fromMap(jsonDecode(customerRaw) as Map<String, dynamic>);
      } catch (_) {}
    }

    return DocumentModel(
      id: map['id'] as String,
      docNumber: map['docNumber'] as String? ?? 'INV-0001',
      docType: DocumentType.values.firstWhere(
        (e) => e.name == map['docType'],
        orElse: () => DocumentType.invoice,
      ),
      customerId: map['customerId'] as String?,
      customerSnapshot: snapshot,
      issueDate: DateTime.tryParse(map['issueDate'] as String? ?? '') ?? DateTime.now(),
      dueDate: DateTime.tryParse(map['dueDate'] as String? ?? '') ?? DateTime.now().add(const Duration(days: 15)),
      status: DocumentStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => DocumentStatus.draft,
      ),
      items: items,
      payments: payments,
      overallDiscountValue: (map['overallDiscountValue'] as num?)?.toDouble() ?? 0.0,
      overallDiscountType: DiscountType.values.firstWhere(
        (e) => e.name == map['overallDiscountType'],
        orElse: () => DiscountType.percentage,
      ),
      templateId: map['templateId'] as String? ?? 'modern_crimson',
      notes: map['notes'] as String?,
      terms: map['terms'] as String?,
      relatedDocId: map['relatedDocId'] as String?,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
