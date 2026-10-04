import re

with open('lib/features/pdf_engine/document_pdf_generator.dart', 'r', encoding='utf-8') as f:
    content = f.read()

stamp_pattern = r"if \(stampBytes != null && doc\.showStamp\)\s*pw\.Padding\(\s*padding: const pw\.EdgeInsets\.only\(right: 20\),\s*child: pw\.Image\(pw\.MemoryImage\(stampBytes\), height: \d+\),\s*\),"
stamp_replacement = r"""if (stampBytes != null && doc.showStamp)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(right: 20),
                    child: pw.Column(
                      children: [
                        pw.Image(pw.MemoryImage(stampBytes), height: 50),
                        pw.SizedBox(height: 4),
                        pw.Container(
                          width: 150,
                          child: pw.Divider(color: primaryColor),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Stamp',
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),"""

content = re.sub(stamp_pattern, stamp_replacement, content)

with open('lib/features/pdf_engine/document_pdf_generator.dart', 'w', encoding='utf-8') as f:
    f.write(content)
