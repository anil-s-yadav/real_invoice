class DocumentItem {
  final String id;
  final String documentId;
  final String? productId;
  final String title;
  final String? description;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double discountPercent;
  final double taxPercent;
  final String? hsnSacCode;

  const DocumentItem({
    required this.id,
    required this.documentId,
    this.productId,
    required this.title,
    this.description,
    this.quantity = 1.0,
    this.unit = 'pcs',
    required this.unitPrice,
    this.discountPercent = 0.0,
    this.taxPercent = 0.0,
    this.hsnSacCode,
  });

  /// Base price before discount and tax: qty * unitPrice
  double get grossAmount => quantity * unitPrice;

  /// Discount amount on this item: gross * (discountPercent / 100)
  double get discountAmount => grossAmount * (discountPercent / 100.0);

  /// Taxable amount after item discount
  double get taxableAmount => grossAmount - discountAmount;

  /// Tax amount for this item
  double get taxAmount => taxableAmount * (taxPercent / 100.0);

  /// Total amount for this line item (taxable + tax)
  double get lineTotal => taxableAmount + taxAmount;

  DocumentItem copyWith({
    String? id,
    String? documentId,
    String? productId,
    String? title,
    String? description,
    double? quantity,
    String? unit,
    double? unitPrice,
    double? discountPercent,
    double? taxPercent,
    String? hsnSacCode,
  }) {
    return DocumentItem(
      id: id ?? this.id,
      documentId: documentId ?? this.documentId,
      productId: productId ?? this.productId,
      title: title ?? this.title,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
      discountPercent: discountPercent ?? this.discountPercent,
      taxPercent: taxPercent ?? this.taxPercent,
      hsnSacCode: hsnSacCode ?? this.hsnSacCode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'documentId': documentId,
      'productId': productId,
      'title': title,
      'description': description,
      'quantity': quantity,
      'unit': unit,
      'unitPrice': unitPrice,
      'discountPercent': discountPercent,
      'taxPercent': taxPercent,
      'hsnSacCode': hsnSacCode,
      'lineTotal': lineTotal,
    };
  }

  factory DocumentItem.fromMap(Map<String, dynamic> map) {
    return DocumentItem(
      id: map['id'] as String,
      documentId: map['documentId'] as String? ?? '',
      productId: map['productId'] as String?,
      title: map['title'] as String? ?? '',
      description: map['description'] as String?,
      quantity: (map['quantity'] as num?)?.toDouble() ?? 1.0,
      unit: map['unit'] as String? ?? 'pcs',
      unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0.0,
      discountPercent: (map['discountPercent'] as num?)?.toDouble() ?? 0.0,
      taxPercent: (map['taxPercent'] as num?)?.toDouble() ?? 0.0,
      hsnSacCode: map['hsnSacCode'] as String?,
    );
  }
}
