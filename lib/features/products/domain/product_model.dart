class ProductItem {
  final String id;
  final String title;
  final String? description;
  final double unitPrice;
  final String unit; // e.g. "hrs", "pcs", "service", "days", "kg"
  final double defaultTaxPercent;
  final String? hsnSacCode;
  final DateTime createdAt;

  const ProductItem({
    required this.id,
    required this.title,
    this.description,
    required this.unitPrice,
    this.unit = 'pcs',
    this.defaultTaxPercent = 18.0,
    this.hsnSacCode,
    required this.createdAt,
  });

  ProductItem copyWith({
    String? id,
    String? title,
    String? description,
    double? unitPrice,
    String? unit,
    double? defaultTaxPercent,
    String? hsnSacCode,
    DateTime? createdAt,
  }) {
    return ProductItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      unitPrice: unitPrice ?? this.unitPrice,
      unit: unit ?? this.unit,
      defaultTaxPercent: defaultTaxPercent ?? this.defaultTaxPercent,
      hsnSacCode: hsnSacCode ?? this.hsnSacCode,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'unitPrice': unitPrice,
      'unit': unit,
      'defaultTaxPercent': defaultTaxPercent,
      'hsnSacCode': hsnSacCode,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ProductItem.fromMap(Map<String, dynamic> map) {
    return ProductItem(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0.0,
      unit: map['unit'] as String? ?? 'pcs',
      defaultTaxPercent: (map['defaultTaxPercent'] as num?)?.toDouble() ?? 18.0,
      hsnSacCode: map['hsnSacCode'] as String?,
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
