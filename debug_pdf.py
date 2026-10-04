import re

with open('lib/features/pdf_engine/document_pdf_generator.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Instead of blindly replacing, let's inject a fallback right before the signature block
# In the children: [ of the Signature row

pattern = r"if \(stampBytes != null && doc\.showStamp\)"
replacement = r"""if (stampBytes == null)
                  pw.Text('STAMP IS NULL!', style: pw.TextStyle(color: PdfColors.red)),
                if (stampBytes != null && !doc.showStamp)
                  pw.Text('STAMP IS HIDDEN (doc.showStamp=false)!', style: pw.TextStyle(color: PdfColors.orange)),
                if (stampBytes != null && doc.showStamp)"""
                
content = re.sub(pattern, replacement, content)

with open('lib/features/pdf_engine/document_pdf_generator.dart', 'w', encoding='utf-8') as f:
    f.write(content)
