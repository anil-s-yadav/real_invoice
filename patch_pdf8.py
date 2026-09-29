import re

with open('d:/real_invoice/lib/features/pdf_engine/document_pdf_generator.dart', 'r') as f:
    content = f.read()

target_pattern = r'    return pw\.Container\(.*?    \);[\s]*\}[\s]*static List<pw\.Widget> _buildElegantCenter'

replacement = '''    return pw.Container(
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            children: [
              pw.Container(
                width: 60,
                height: 60,
                padding: const pw.EdgeInsets.all(4),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                  border: pw.Border.all(color: PdfColors.grey400, width: 1),
                ),
                child: hasUpi 
                    ? pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: 'upi://pay?pa=${upiDetail!.details}&pn=${Uri.encodeComponent(profile.businessName)}&am=${doc.totalAmount}',
                      )
                    : pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: 'https://invoz.com',
                      ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Scan to Pay',
                style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          ),
          pw.SizedBox(width: 16),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'PAYMENT DETAILS',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 0.6,
                    color: primaryColor ?? PdfColors.grey800,
                  ),
                ),
                pw.SizedBox(height: 6),
                if (hasUpi)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 4),
                    child: pw.Text(
                      'UPI (${upiDetail!.title}): ${upiDetail.details}',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                if (hasBank) ...[
                  pw.Text(
                    'Bank: ${bankDetail!.title}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 1),
                  pw.Text(
                    'A/C: ${bankDetail.details}',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                  if (bankDetail.extra != null && bankDetail.extra!.isNotEmpty)
                    pw.Text(
                      'IFSC: ${bankDetail.extra}',
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static List<pw.Widget> _buildElegantCenter'''

# Python re.sub uses \ as an escape char. So we must escape any backslashes in replacement string.
replacement = replacement.replace('\\', '\\\\')

new_content = re.sub(target_pattern, replacement, content, flags=re.DOTALL)
if new_content == content:
    print("WARNING: Substitution failed!")
else:
    print("SUCCESS: Substituted!")

with open('d:/real_invoice/lib/features/pdf_engine/document_pdf_generator.dart', 'w') as f:
    f.write(new_content)