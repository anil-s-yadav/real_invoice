import re

with open('d:/real_invoice/lib/features/pdf_engine/document_pdf_generator.dart', 'r') as f:
    content = f.read()

# Add Logo
logo_code = '''    return [
      if (logoBytes != null)
        pw.Center(
          child: pw.Container(
            height: 60,
            margin: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Image(pw.MemoryImage(logoBytes)),
          ),
        ),
      pw.Center('''
content = content.replace('''    return [
      pw.Center(''', logo_code)

# Replace Notes with Row(Notes, Payment, Signature)
old_notes_code = '''      pw.Spacer(),
      if (doc.notes != null && doc.notes!.isNotEmpty) ...[
        pw.Text('Notes', style: pw.TextStyle(color: primaryColor, fontWeight: pw.FontWeight.bold, fontSize: 11)),
        pw.SizedBox(height: 8),
        pw.Text(doc.notes!, style: const pw.TextStyle(fontSize: 11)),
      ],'''

new_notes_code = '''      pw.Spacer(),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (doc.notes != null && doc.notes!.isNotEmpty) ...[
                  pw.Text('Notes', style: pw.TextStyle(color: primaryColor, fontWeight: pw.FontWeight.bold, fontSize: 11)),
                  pw.SizedBox(height: 4),
                  pw.Text(doc.notes!, style: const pw.TextStyle(fontSize: 11)),
                  pw.SizedBox(height: 16),
                ],
                _buildPaymentDetails(doc, profile, primaryColor: primaryColor),
              ],
            ),
          ),
          if (signatureBytes != null)
            pw.Column(
              children: [
                pw.Image(pw.MemoryImage(signatureBytes), height: 50),
                pw.Container(width: 150, child: pw.Divider(color: primaryColor)),
                pw.Text('Authorized Signature', style: pw.TextStyle(fontSize: 10, color: primaryColor)),
              ],
            ),
        ],
      ),'''

content = content.replace(old_notes_code, new_notes_code)

with open('d:/real_invoice/lib/features/pdf_engine/document_pdf_generator.dart', 'w') as f:
    f.write(content)

print("Updated PDF generator")