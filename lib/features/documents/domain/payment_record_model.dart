class PaymentRecord {
  final String id;
  final String documentId;
  final DateTime paymentDate;
  final double amount;
  final String paymentMethod; // UPI, Cash, Bank Transfer, Cheque, Card
  final String? referenceNumber; // e.g. UTR / UPI Ref / Cheque No
  final String? notes;
  final DateTime createdAt;

  const PaymentRecord({
    required this.id,
    required this.documentId,
    required this.paymentDate,
    required this.amount,
    this.paymentMethod = 'UPI',
    this.referenceNumber,
    this.notes,
    required this.createdAt,
  });

  PaymentRecord copyWith({
    String? id,
    String? documentId,
    DateTime? paymentDate,
    double? amount,
    String? paymentMethod,
    String? referenceNumber,
    String? notes,
    DateTime? createdAt,
  }) {
    return PaymentRecord(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      paymentDate: paymentDate ?? this.paymentDate,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'documentId': documentId,
      'paymentDate': paymentDate.toIso8601String(),
      'amount': amount,
      'paymentMethod': paymentMethod,
      'referenceNumber': referenceNumber,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PaymentRecord.fromMap(Map<String, dynamic> map) {
    return PaymentRecord(
      id: map['id'] as String,
      documentId: map['documentId'] as String? ?? '',
      paymentDate: DateTime.tryParse(map['paymentDate'] as String? ?? '') ?? DateTime.now(),
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: map['paymentMethod'] as String? ?? 'UPI',
      referenceNumber: map['referenceNumber'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
