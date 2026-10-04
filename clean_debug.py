import re

with open('lib/features/pdf_engine/document_pdf_generator.dart', 'r', encoding='utf-8') as f:
    content = f.read()

pattern = r"if \(stampBytes == null\)\s*pw\.Text\('STAMP IS NULL!', style: pw\.TextStyle\(color: PdfColors\.red\)\),\s*if \(stampBytes != null && !doc\.showStamp\)\s*pw\.Text\('STAMP IS HIDDEN \(doc\.showStamp=false\)!', style: pw\.TextStyle\(color: PdfColors\.orange\)\),\s*if \(stampBytes != null && doc\.showStamp\)"

replacement = r"if (stampBytes != null && doc.showStamp)"

content = re.sub(pattern, replacement, content)

with open('lib/features/pdf_engine/document_pdf_generator.dart', 'w', encoding='utf-8') as f:
    f.write(content)
