import re

# Update dummy_template_utils.dart
with open('d:/real_invoice/lib/features/documents/presentation/dummy_templates/dummy_template_utils.dart', 'r') as f:
    content = f.read()

content = content.replace('Widget buildDummyPaymentDetails({Color primary = Colors.black87}) {', 
'''import '../domain/document_model.dart';

Widget buildDummyPaymentDetails({Color primary = Colors.black87, DocumentType? type}) {
  if (type == DocumentType.receipt) return const SizedBox();''')

with open('d:/real_invoice/lib/features/documents/presentation/dummy_templates/dummy_template_utils.dart', 'w') as f:
    f.write(content)

# Update the 3 dummy files
files = [
    'd:/real_invoice/lib/features/documents/presentation/dummy_templates/classic_free_dummy.dart',
    'd:/real_invoice/lib/features/documents/presentation/dummy_templates/premium_modern_dummy.dart',
    'd:/real_invoice/lib/features/documents/presentation/dummy_templates/elegant_center_dummy.dart'
]

for file in files:
    with open(file, 'r') as f:
        c = f.read()
    c = c.replace('buildDummyPaymentDetails(primary:', 'buildDummyPaymentDetails(type: documentType, primary:')
    with open(file, 'w') as f:
        f.write(c)

print("Updated dummy files")