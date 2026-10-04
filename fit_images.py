import re

with open('lib/features/pdf_engine/document_pdf_generator.dart', 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace("pw.Image(pw.MemoryImage(stampBytes), height: 50)", "pw.Container(width: 100, height: 50, child: pw.Image(pw.MemoryImage(stampBytes), fit: pw.BoxFit.contain))")

content = content.replace("pw.Image(pw.MemoryImage(signatureBytes), height: 50)", "pw.Container(width: 100, height: 50, child: pw.Image(pw.MemoryImage(signatureBytes), fit: pw.BoxFit.contain))")

content = content.replace("pw.Image(pw.MemoryImage(signatureBytes), height: 40)", "pw.Container(width: 100, height: 40, child: pw.Image(pw.MemoryImage(signatureBytes), fit: pw.BoxFit.contain))")

with open('lib/features/pdf_engine/document_pdf_generator.dart', 'w', encoding='utf-8') as f:
    f.write(content)
