import re

with open('lib/features/customers/domain/customer_model.dart', 'r') as f:
    content = f.read()

content = content.replace('final String? gstin;', 'final String? gstin;\n  final String? cin;\n  final String? contactPerson;\n  final String? website;')
content = content.replace('this.gstin,', 'this.gstin,\n    this.cin,\n    this.contactPerson,\n    this.website,')
content = content.replace('String? gstin,', 'String? gstin,\n    String? cin,\n    String? contactPerson,\n    String? website,')
content = content.replace('gstin: gstin ?? this.gstin,', 'gstin: gstin ?? this.gstin,\n      cin: cin ?? this.cin,\n      contactPerson: contactPerson ?? this.contactPerson,\n      website: website ?? this.website,')
content = content.replace("'gstin': gstin,", "'gstin': gstin,\n      'cin': cin,\n      'contactPerson': contactPerson,\n      'website': website,")
content = content.replace("gstin: map['gstin'] as String?,", "gstin: map['gstin'] as String?,\n      cin: map['cin'] as String?,\n      contactPerson: map['contactPerson'] as String?,\n      website: map['website'] as String?,")

with open('lib/features/customers/domain/customer_model.dart', 'w') as f:
    f.write(content)
