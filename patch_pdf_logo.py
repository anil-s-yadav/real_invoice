import re

with open('d:/real_invoice/lib/features/pdf_engine/document_pdf_generator.dart', 'r') as f:
    content = f.read()

old_pdf_header = '''    return [
      if (logoBytes != null)
        pw.Center(
          child: pw.Container(
            height: 60,
            margin: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Image(pw.MemoryImage(logoBytes)),
          ),
        ),
      pw.Center(
        child: pw.Text(
          profile.businessName,
          style: pw.TextStyle(
            fontSize: 32,
            color: primaryColor,
          ),
        ),
      ),'''

new_pdf_header = '''    return [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          if (logoBytes != null) ...[
            pw.ClipOval(
              child: pw.Container(
                width: 48,
                height: 48,
                child: pw.Image(pw.MemoryImage(logoBytes), fit: pw.BoxFit.cover),
              ),
            ),
            pw.SizedBox(width: 16),
          ],
          pw.Text(
            profile.businessName,
            style: pw.TextStyle(
              fontSize: 32,
              color: primaryColor,
            ),
          ),
        ],
      ),'''

content = content.replace(old_pdf_header, new_pdf_header)

with open('d:/real_invoice/lib/features/pdf_engine/document_pdf_generator.dart', 'w') as f:
    f.write(content)

print("Updated PDF layout")