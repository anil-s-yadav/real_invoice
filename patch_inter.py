with open('d:/real_invoice/lib/features/pdf_engine/document_pdf_generator.dart', 'r', encoding='utf-8') as f:
    content = f.read()

start_marker = '  static pw.Widget _buildPaymentDetails('
end_marker = '  static pw.Widget _buildTable('

start_pos = content.find(start_marker)
end_pos = content.find(end_marker)

new_method = """  static pw.Widget _buildPaymentDetails(
    DocumentModel doc,
    BusinessProfile profile, {
    PdfColor? primaryColor,
  }) {
    PaymentDetail? bankDetail;
    if (doc.selectedBankDetailId != null && doc.selectedBankDetailId != 'none') {
      try {
        bankDetail = profile.paymentDetails.firstWhere(
          (p) => p.id == doc.selectedBankDetailId,
        );
      } catch (_) {}
    }
    if (bankDetail == null &&
        doc.selectedBankDetailId != 'none' &&
        profile.bankName != null &&
        profile.bankName!.trim().isNotEmpty &&
        profile.accountNumber != null &&
        profile.accountNumber!.trim().isNotEmpty) {
      bankDetail = PaymentDetail(
        id: 'legacy',
        type: 'Bank',
        title: profile.bankName!,
        details: profile.accountNumber!,
        extra: profile.ifscCode,
      );
    }
    if (bankDetail == null && doc.selectedBankDetailId != 'none') {
      final banks = profile.paymentDetails
          .where((p) => p.type == 'Bank')
          .toList();
      if (banks.isNotEmpty) bankDetail = banks.first;
    }

    PaymentDetail? upiDetail;
    if (doc.selectedUpiDetailId != null && doc.selectedUpiDetailId != 'none') {
      try {
        upiDetail = profile.paymentDetails.firstWhere(
          (p) => p.id == doc.selectedUpiDetailId,
        );
      } catch (_) {}
    }
    if (upiDetail == null &&
        doc.selectedUpiDetailId != 'none' &&
        profile.upiId != null &&
        profile.upiId!.trim().isNotEmpty) {
      upiDetail = PaymentDetail(
        id: 'legacy_upi',
        type: 'UPI',
        title: 'UPI',
        details: profile.upiId!,
      );
    }
    if (upiDetail == null && doc.selectedUpiDetailId != 'none') {
      final upis = profile.paymentDetails
          .where((p) => p.type == 'UPI')
          .toList();
      if (upis.isNotEmpty) upiDetail = upis.first;
    }

    final hasBank = bankDetail != null;
    final hasUpi = upiDetail != null;

    if (!doc.includePaymentDetails || doc.docType == DocumentType.receipt) return pw.SizedBox();
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
                  if (bankDetail.extra != null && bankDetail.extra!.trim().isNotEmpty)
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

"""

content = content[:start_pos] + new_method + content[end_pos:]

with open('d:/real_invoice/lib/features/pdf_engine/document_pdf_generator.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("Restored interpolations!")