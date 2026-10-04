import re

with open('lib/features/pdf_engine/document_pdf_generator.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Fetch stamp bytes
content = content.replace(
    'final Uint8List? signatureBytes = profile.signaturePath != null\n        ? await _fetchImageBytes(profile.signaturePath!)\n        : null;',
    'final Uint8List? signatureBytes = profile.signaturePath != null\n        ? await _fetchImageBytes(profile.signaturePath!)\n        : null;\n    final Uint8List? stampBytes = profile.stampPath != null\n        ? await _fetchImageBytes(profile.stampPath!)\n        : null;'
)

# 2. Pass stampBytes to all 3 builders
content = content.replace('signatureBytes: signatureBytes,\n              );', 'signatureBytes: signatureBytes,\n                stampBytes: stampBytes,\n              );')
content = content.replace('signatureBytes: signatureBytes,\n            );', 'signatureBytes: signatureBytes,\n              stampBytes: stampBytes,\n            );')

# 3. Add to builder signatures
content = content.replace('Uint8List? signatureBytes,\n    }) {', 'Uint8List? signatureBytes,\n      Uint8List? stampBytes,\n    }) {')

# 4. Replace rendering logic in Classic
classic_sig_pattern = r"if \(signatureBytes != null\)\s*pw\.Column\(\s*children: \[\s*pw\.Image\(pw\.MemoryImage\(signatureBytes\), height: 40\),\s*pw\.SizedBox\(height: 4\),\s*pw\.Container\(width: 120, height: 1\.5, color: borderColor\),\s*pw\.SizedBox\(height: 4\),\s*pw\.Text\(\s*'Authorized Signature',\s*style: pw\.TextStyle\(\s*fontSize: 9,\s*fontWeight: pw\.FontWeight\.bold,\s*color: primaryColor,\s*\),\s*\),\s*\],\s*\),"
classic_sig_replacement = r"""pw.Row(
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
                      pw.Image(pw.MemoryImage(signatureBytes), height: 40),
                      pw.SizedBox(height: 4),
                      pw.Container(width: 120, height: 1.5, color: borderColor),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Authorized Signature',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
              ],
            ),"""
content = re.sub(classic_sig_pattern, classic_sig_replacement, content)

# 5. Replace rendering logic in Premium
premium_sig_pattern = r"if \(signatureBytes != null\)\s*pw\.Column\(\s*children: \[\s*pw\.Image\(pw\.MemoryImage\(signatureBytes\), height: 50\),\s*pw\.Container\(\s*width: 150,\s*child: pw\.Divider\(color: primaryColor\),\s*\),\s*pw\.Text\(\s*'Authorized Signature',\s*style: pw\.TextStyle\(\s*fontSize: 10,\s*color: primaryColor,\s*\),\s*\),\s*\],\s*\),"
premium_sig_replacement = r"""pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                if (stampBytes != null && doc.showStamp)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(right: 20),
                    child: pw.Image(pw.MemoryImage(stampBytes), height: 60),
                  ),
                if (signatureBytes != null && doc.showSignature)
                  pw.Column(
                    children: [
                      pw.Image(pw.MemoryImage(signatureBytes), height: 50),
                      pw.Container(
                        width: 150,
                        child: pw.Divider(color: primaryColor),
                      ),
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
            ),"""
content = re.sub(premium_sig_pattern, premium_sig_replacement, content)

# 6. Replace rendering logic in Elegant
elegant_sig_pattern = r"if \(signatureBytes != null\)\s*pw\.Column\(\s*children: \[\s*pw\.Image\(pw\.MemoryImage\(signatureBytes\), height: 50\),\s*pw\.Container\(\s*width: 150,\s*child: pw\.Divider\(color: primaryColor\),\s*\),\s*pw\.Text\(\s*'Authorized Signature',\s*style: pw\.TextStyle\(fontSize: 10, color: primaryColor\),\s*\),\s*\],\s*\),"
elegant_sig_replacement = r"""pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                if (stampBytes != null && doc.showStamp)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(right: 20),
                    child: pw.Image(pw.MemoryImage(stampBytes), height: 60),
                  ),
                if (signatureBytes != null && doc.showSignature)
                  pw.Column(
                    children: [
                      pw.Image(pw.MemoryImage(signatureBytes), height: 50),
                      pw.Container(
                        width: 150,
                        child: pw.Divider(color: primaryColor),
                      ),
                      pw.Text(
                        'Authorized Signature',
                        style: pw.TextStyle(fontSize: 10, color: primaryColor),
                      ),
                    ],
                  ),
              ],
            ),"""
content = re.sub(elegant_sig_pattern, elegant_sig_replacement, content)

with open('lib/features/pdf_engine/document_pdf_generator.dart', 'w', encoding='utf-8') as f:
    f.write(content)
