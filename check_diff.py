user_code = '''static pw.Widget _buildPaymentDetails(
    DocumentModel doc,
    List<PaymentDetail> payments,
    BusinessProfile profile, {
    PdfColor? primaryColor,
  }) {
    PaymentDetail? bankDetail;
    if (doc.selectedBankDetailId != null &&
        doc.selectedBankDetailId != 'none') {
      try {
        bankDetail = payments.firstWhere(
          (p) => p.id == doc.selectedBankDetailId,
        );
      } catch (_) {}
    }

    if (bankDetail == null && doc.selectedBankDetailId != 'none') {
      final banks = payments.where((p) => p.type == 'Bank').toList();
      if (banks.isNotEmpty) bankDetail = banks.first;
    }

    PaymentDetail? upiDetail;
    if (doc.selectedUpiDetailId != null && doc.selectedUpiDetailId != 'none') {
      try {
        upiDetail = payments.firstWhere((p) => p.id == doc.selectedUpiDetailId);
      } catch (_) {}
    }

    if (upiDetail == null && doc.selectedUpiDetailId != 'none') {
      final upis = payments.where((p) => p.type == 'UPI').toList();
      if (upis.isNotEmpty) upiDetail = upis.first;
    }

    final hasBank = bankDetail != null;
    final hasUpi = upiDetail != null;

    if (!doc.includePaymentDetails || doc.docType == DocumentType.receipt) {
      return pw.SizedBox();
    }
    if (!hasBank && !hasUpi) return pw.SizedBox();

    return pw.Container(
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
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(6),
                  ),
                  border: pw.Border.all(color: PdfColors.grey400, width: 1),
                ),
                child: hasUpi
                    ? pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data:
                            'upi://pay?pa=&pn=&am=',
                      )
                    : pw.BarcodeWidget(
                        barcode: pw.Barcode.qrCode(),
                        data: 'https://invoice-c1603.web.app',
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
          pw.SizedBox(width: 6),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'PAYMENT DETAILS',
                  style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    letterSpacing: 0.6,
                    color: primaryColor ?? PdfColors.grey800,
                  ),
                ),
                pw.SizedBox(height: 4),
                if (hasUpi)
                  pw.Text(
                    'UPI: ',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700,
                    ),
                  ),

                if (hasBank) ...[
                  pw.Text(
                    'Bank: ',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700,
                    ),
                  ),

                  pw.Text(
                    'A/C: ',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey700,
                    ),
                  ),
                  if (bankDetail.extra != null &&
                      bankDetail.extra!.trim().isNotEmpty)
                    pw.Text(
                      'IFSC: ',
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey700,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }'''

with open('lib/features/pdf_engine/document_pdf_generator.dart', 'r', encoding='utf-8') as f:
    content = f.read()

import textwrap
if textwrap.dedent(user_code).strip() in textwrap.dedent(content).strip():
    print("MATCH: The user's code is already exactly what is in the file!")
else:
    print("NO MATCH: Differences found.")
