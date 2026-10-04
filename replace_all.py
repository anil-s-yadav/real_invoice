import re

with open('lib/features/pdf_engine/document_pdf_generator.dart', 'r', encoding='utf-8') as f:
    content = f.read()

pattern = r"if \(signatureBytes != null\)\s*pw\.Column\(\s*children: \[\s*pw\.Image\(pw\.MemoryImage\(signatureBytes\), height: (\d+)\),\s*([\s\S]*?)pw\.Text\(\s*'Authorized Signature',\s*style: pw\.TextStyle\(([\s\S]*?)\),\s*\),\s*\],\s*\),"

def repl(m):
    height = m.group(1)
    divider = m.group(2)
    style = m.group(3)
    return f'''pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                if (stampBytes != null && doc.showStamp)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(right: 20),
                    child: pw.Image(pw.MemoryImage(stampBytes), height: 50),
                  ),
                if (signatureBytes != null && doc.showSignature)
                  pw.Column(
                    children: [
                      pw.Image(pw.MemoryImage(signatureBytes), height: {height}),
                      {divider}pw.Text(
                        'Authorized Signature',
                        style: pw.TextStyle({style}),
                      ),
                    ],
                  ),
              ],
            ),'''

content = re.sub(pattern, repl, content)

with open('lib/features/pdf_engine/document_pdf_generator.dart', 'w', encoding='utf-8') as f:
    f.write(content)
