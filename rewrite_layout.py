import re

with open('lib/features/pdf_engine/document_pdf_generator.dart', 'r', encoding='utf-8') as f:
    content = f.read()

pattern_classic = r"pw\.Expanded\(\s*child: _buildPaymentDetails\([\s\S]*?primaryColor: primaryColor,\s*\),\s*\),\s*pw\.Row\(\s*crossAxisAlignment: pw\.CrossAxisAlignment\.end,\s*children: \[\s*if \(stampBytes != null && doc\.showStamp\)\s*pw\.Padding\(\s*padding: const pw\.EdgeInsets\.only\(right: 20\),\s*child: pw\.Column\([\s\S]*?pw\.Text\(\s*'Company Stamp',[\s\S]*?\),\s*\]\s*\),\s*\),\s*if \(signatureBytes != null && doc\.showSignature\)\s*pw\.Column\([\s\S]*?pw\.Text\(\s*'Authorized Signature',[\s\S]*?\),\s*\]\s*\),\s*\]\s*\),"

replacement = r"""pw.Expanded(
              child: _buildPaymentDetails(
                doc,
                payments,
                profile,
                primaryColor: primaryColor,
              ),
            ),
            pw.Expanded(
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  if (stampBytes != null && doc.showStamp)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(right: 20),
                      child: pw.Column(
                        children: [
                          pw.Image(pw.MemoryImage(stampBytes), height: 50),
                          pw.SizedBox(height: 4),
                          pw.Container(
                            width: 120,
                            child: pw.Divider(color: primaryColor),
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            'Company Stamp',
                            style: pw.TextStyle(
                              fontSize: 10,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (signatureBytes != null && doc.showSignature)
                    pw.Column(
                      children: [
                        pw.Image(pw.MemoryImage(signatureBytes), height: 50),
                        pw.SizedBox(height: 4),
                        pw.Container(
                          width: 120,
                          child: pw.Divider(color: primaryColor),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Authorized Signature',
                          style: pw.TextStyle(
                            fontSize: 10,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),"""

content = re.sub(pattern_classic, replacement, content)

with open('lib/features/pdf_engine/document_pdf_generator.dart', 'w', encoding='utf-8') as f:
    f.write(content)
