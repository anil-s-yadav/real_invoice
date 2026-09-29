import re

with open('d:/real_invoice/lib/features/pdf_engine/document_pdf_generator.dart', 'r') as f:
    content = f.read()

# Replace _buildPaymentDetails
target = '''    return pw.Container(
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (hasUpi)
            pw.BarcodeWidget(
              barcode: pw.Barcode.qrCode(),
              data: 'upi://pay?pa=&pn=',
              width: 55,
              height: 55,
            ),
          if (hasUpi && hasBank) pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Payment Details',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor ?? PdfColors.grey700,
                  ),
                ),
                pw.SizedBox(height: 4),
                if (hasBank) ...[
                  pw.Text('Bank: ', style: const pw.TextStyle(fontSize: 10)),
                  pw.Text('A/C No: ', style: const pw.TextStyle(fontSize: 10)),
                  if (bankDetail.extra != null && bankDetail.extra!.isNotEmpty)
                    pw.Text('IFSC: ', style: const pw.TextStyle(fontSize: 10)),
                ],
                if (hasUpi)
                  pw.Text('UPI: ', style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );'''

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
                        data: 'upi://pay?pa=&pn=',
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
                      'UPI (): ',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                if (hasBank) ...[
                  pw.Text(
                    'Bank: ',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 1),
                  pw.Text(
                    'A/C: ',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                  if (bankDetail.extra != null && bankDetail.extra!.isNotEmpty)
                    pw.Text(
                      'IFSC: ',
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );'''

content = content.replace(target, replacement)

with open('d:/real_invoice/lib/features/pdf_engine/document_pdf_generator.dart', 'w') as f:
    f.write(content)
print("Updated payment details in PDF generator")