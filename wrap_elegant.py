import re

with open('lib/features/pdf_engine/document_pdf_generator.dart', 'r', encoding='utf-8') as f:
    content = f.read()

pattern = r"(\s*)pw\.Row\(\s*crossAxisAlignment: pw\.CrossAxisAlignment\.end,\s*children: \[\s*if \(stampBytes != null && doc\.showStamp\)"

replacement = r"""\1pw.Expanded(
\1  flex: 4,
\1  child: pw.Row(
\1    mainAxisAlignment: pw.MainAxisAlignment.end,
\1    crossAxisAlignment: pw.CrossAxisAlignment.end,
\1    children: [
\1      if (stampBytes != null && doc.showStamp)"""

content = re.sub(pattern, replacement, content)

pattern2 = r"(pw\.Text\(\s*'Authorized Signature',\s*style: pw\.TextStyle\(fontSize: 10, color: primaryColor\),\s*\),\s*],\s*\),\s*],\s*\)),(\s*],\s*\),)"
replacement2 = r"\1,\n          ),\2"

content = re.sub(pattern2, replacement2, content)

with open('lib/features/pdf_engine/document_pdf_generator.dart', 'w', encoding='utf-8') as f:
    f.write(content)
