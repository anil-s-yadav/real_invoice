import re

with open('d:/real_invoice/lib/features/pdf_engine/document_pdf_generator.dart', 'r') as f:
    content = f.read()

# Find the end of DocumentPdfGenerator class
# Wait, the class ends at the end of the file except for the static method I added at the end.
# I will just remove the last method, and insert it before the last closing brace of the class.

# Let's remove the static _buildElegantCenter from the bottom first
content = re.sub(r'  static List<pw\.Widget> _buildElegantCenter.*', '', content, flags=re.DOTALL)

elegant_func = '''
  static List<pw.Widget> _buildElegantCenter(
    pw.Context context,
    DocumentModel doc,
    BusinessProfile profile, {
    Uint8List? logoBytes,
    Uint8List? signatureBytes,
  }) {
    final title = doc.docType.displayName.toUpperCase();
    final primaryColor = PdfColor.fromHex('#0D47A1');
    final lightBlue = PdfColor.fromHex('#D6E4F0');

    final cName = doc.customerSnapshot?.name ?? 'Unknown Customer';
    final cEmail = doc.customerSnapshot?.email ?? '';
    final cPhone = doc.customerSnapshot?.phone ?? '';

    return [
      pw.Center(
        child: pw.Text(
          profile.businessName,
          style: pw.TextStyle(
            fontSize: 32,
            color: primaryColor,
          ),
        ),
      ),
      pw.SizedBox(height: 16),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          if (profile.address != null && profile.address!.isNotEmpty)
            pw.Text(profile.address!, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
          if (profile.address != null && profile.phone != null && profile.address!.isNotEmpty && profile.phone!.isNotEmpty)
            pw.Text('   |   ', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
          if (profile.phone != null && profile.phone!.isNotEmpty)
            pw.Text(profile.phone!, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
          if (profile.phone != null && profile.email != null && profile.phone!.isNotEmpty && profile.email!.isNotEmpty)
            pw.Text('   |   ', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
          if (profile.email != null && profile.email!.isNotEmpty)
            pw.Text(profile.email!, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
        ],
      ),
      pw.SizedBox(height: 12),
      pw.Container(height: 2, color: lightBlue),
      pw.SizedBox(height: 32),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Paid By', style: pw.TextStyle(color: primaryColor, fontWeight: pw.FontWeight.bold, fontSize: 11)),
              pw.SizedBox(height: 6),
              pw.Text(cName, style: const pw.TextStyle(fontSize: 11)),
              pw.SizedBox(height: 6),
              if (cEmail.isNotEmpty)
                pw.Text(cEmail, style: const pw.TextStyle(fontSize: 11)),
            ],
          ),
          pw.Text(title, style: pw.TextStyle(color: primaryColor, fontWeight: pw.FontWeight.bold, fontSize: 28)),
        ],
      ),
      pw.SizedBox(height: 32),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Booking Details', style: pw.TextStyle(color: primaryColor, fontWeight: pw.FontWeight.bold, fontSize: 11)),
                pw.SizedBox(height: 8),
                pw.Row(children: [ pw.SizedBox(width: 100, child: pw.Text('Issue Date', style: const pw.TextStyle(fontSize: 11))), pw.Text(DateFormatter.format(doc.issueDate), style: const pw.TextStyle(fontSize: 11)) ]),
                pw.SizedBox(height: 6),
                pw.Row(children: [ pw.SizedBox(width: 100, child: pw.Text('Due Date', style: const pw.TextStyle(fontSize: 11))), pw.Text(DateFormatter.format(doc.dueDate), style: const pw.TextStyle(fontSize: 11)) ]),
              ],
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Row(children: [ pw.SizedBox(width: 80, child: pw.Text('Receipt #', style: pw.TextStyle(color: primaryColor, fontWeight: pw.FontWeight.bold, fontSize: 11))), pw.Text(doc.docNumber, style: const pw.TextStyle(fontSize: 11)) ]),
              pw.SizedBox(height: 6),
              pw.Row(children: [ pw.SizedBox(width: 80, child: pw.Text('Receipt Date', style: pw.TextStyle(color: primaryColor, fontWeight: pw.FontWeight.bold, fontSize: 11))), pw.Text(DateFormatter.format(doc.issueDate), style: const pw.TextStyle(fontSize: 11)) ]),
            ],
          ),
        ],
      ),
      pw.SizedBox(height: 24),
      pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: primaryColor),
        ),
        child: pw.Column(
          children: [
            pw.Container(
              color: primaryColor,
              padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: pw.Row(
                children: [
                  pw.Expanded(flex: 1, child: pw.Text('Quantity', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10))),
                  pw.Expanded(flex: 3, child: pw.Text('Description', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10))),
                  pw.Expanded(flex: 2, child: pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text('Unit Price', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10)))),
                  pw.Expanded(flex: 2, child: pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text('Amount', style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10)))),
                ],
              ),
            ),
            ...doc.items.map((item) {
              return pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                child: pw.Row(
                  children: [
                    pw.Expanded(flex: 1, child: pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text(item.quantity.toString(), style: const pw.TextStyle(fontSize: 11)))),
                    pw.SizedBox(width: 20),
                    pw.Expanded(flex: 3, child: pw.Text(item.title, style: const pw.TextStyle(fontSize: 11))),
                    pw.Expanded(flex: 2, child: pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text(CurrencyFormatter.format(item.unitPrice, symbol: 'Rs.'), style: const pw.TextStyle(fontSize: 11)))),
                    pw.Expanded(flex: 2, child: pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text(CurrencyFormatter.format(item.lineTotal, symbol: 'Rs.'), style: const pw.TextStyle(fontSize: 11)))),
                  ],
                ),
              );
            }),
            pw.Container(height: 1, color: primaryColor),
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: pw.Row(
                children: [
                  pw.Expanded(flex: 4, child: pw.SizedBox()),
                  pw.Expanded(flex: 2, child: pw.Text('Subtotal', style: const pw.TextStyle(fontSize: 11))),
                  pw.Expanded(flex: 2, child: pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text(CurrencyFormatter.format(doc.subtotal, symbol: 'Rs.'), style: const pw.TextStyle(fontSize: 11)))),
                ],
              ),
            ),
            if (doc.totalTaxAmount > 0)
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: pw.Row(
                  children: [
                    pw.Expanded(flex: 4, child: pw.SizedBox()),
                    pw.Expanded(flex: 2, child: pw.Text('Tax', style: const pw.TextStyle(fontSize: 11))),
                    pw.Expanded(flex: 2, child: pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text(CurrencyFormatter.format(doc.totalTaxAmount, symbol: 'Rs.'), style: const pw.TextStyle(fontSize: 11)))),
                  ],
                ),
              ),
            if (doc.overallDiscountAmount > 0)
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                child: pw.Row(
                  children: [
                    pw.Expanded(flex: 4, child: pw.SizedBox()),
                    pw.Expanded(flex: 2, child: pw.Text('Discount', style: const pw.TextStyle(fontSize: 11))),
                    pw.Expanded(flex: 2, child: pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text('-' + CurrencyFormatter.format(doc.overallDiscountAmount, symbol: 'Rs.'), style: const pw.TextStyle(fontSize: 11)))),
                  ],
                ),
              ),
            pw.Container(height: 1, color: primaryColor),
            pw.Container(
              color: lightBlue,
              padding: const pw.EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              child: pw.Row(
                children: [
                  pw.Expanded(flex: 4, child: pw.SizedBox()),
                  pw.Expanded(flex: 2, child: pw.Text('Total', style: pw.TextStyle(color: primaryColor, fontWeight: pw.FontWeight.bold, fontSize: 12))),
                  pw.Expanded(flex: 2, child: pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text(CurrencyFormatter.format(doc.totalAmount, symbol: 'Rs.'), style: pw.TextStyle(color: primaryColor, fontWeight: pw.FontWeight.bold, fontSize: 12)))),
                ],
              ),
            ),
          ],
        ),
      ),
      pw.Spacer(),
      if (doc.notes != null && doc.notes!.isNotEmpty) ...[
        pw.Text('Notes', style: pw.TextStyle(color: primaryColor, fontWeight: pw.FontWeight.bold, fontSize: 11)),
        pw.SizedBox(height: 8),
        pw.Text(doc.notes!, style: const pw.TextStyle(fontSize: 11)),
      ],
    ];
  }
}'''

# Replace the last closing brace with elegant_func
content = content.rstrip()
if content.endswith('}'):
    content = content[:-1] + elegant_func

with open('d:/real_invoice/lib/features/pdf_engine/document_pdf_generator.dart', 'w') as f:
    f.write(content)
print("Updated PDF Generator inside class")