import re

with open('lib/features/documents/domain/document_model.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Add field
content = content.replace('final String? relatedDocId;', 'final String? relatedDocId;\n  final bool enableRoundOff;')
content = content.replace('this.relatedDocId,', 'this.relatedDocId,\n    this.enableRoundOff = true,')

# Update getters
getters_pattern = r"double get rawTotalAmount => taxableAmount \+ totalTaxAmount \+ shippingCharges;\n\n\s*/// Round-off adjustment to nearest integer \(standard in Indian invoices\)\n\s*double get roundOff => \(rawTotalAmount\.roundToDouble\(\) - rawTotalAmount\);\n\n\s*/// Final payable total amount\n\s*double get totalAmount => rawTotalAmount \+ roundOff;"
getters_replacement = r"double get rawTotalAmount => taxableAmount + totalTaxAmount + shippingCharges;\n\n  /// Round-off adjustment to nearest integer (standard in Indian invoices)\n  double get roundOff => enableRoundOff ? (rawTotalAmount.roundToDouble() - rawTotalAmount) : 0.0;\n\n  /// Final payable total amount\n  double get totalAmount => rawTotalAmount + roundOff;"
content = re.sub(getters_pattern, getters_replacement, content)

# Update toMap
content = content.replace("'relatedDocId': relatedDocId,", "'relatedDocId': relatedDocId,\n      'enableRoundOff': enableRoundOff,")

# Update fromMap
content = content.replace("relatedDocId: map['relatedDocId'] as String?,", "relatedDocId: map['relatedDocId'] as String?,\n      enableRoundOff: map['enableRoundOff'] as bool? ?? true,")

# Update copyWith
content = content.replace("String? relatedDocId,", "String? relatedDocId,\n    bool? enableRoundOff,")
content = content.replace("relatedDocId: relatedDocId ?? this.relatedDocId,", "relatedDocId: relatedDocId ?? this.relatedDocId,\n      enableRoundOff: enableRoundOff ?? this.enableRoundOff,")

with open('lib/features/documents/domain/document_model.dart', 'w', encoding='utf-8') as f:
    f.write(content)
