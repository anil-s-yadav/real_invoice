import re

with open('lib/features/pdf_engine/document_pdf_generator.dart', 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace('Uint8List? signatureBytes,\n  }) {', 'Uint8List? signatureBytes,\n    Uint8List? stampBytes,\n  }) {')

with open('lib/features/pdf_engine/document_pdf_generator.dart', 'w', encoding='utf-8') as f:
    f.write(content)
