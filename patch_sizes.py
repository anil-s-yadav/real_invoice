import re

with open('d:/real_invoice/lib/features/documents/presentation/dummy_templates/elegant_center_dummy.dart', 'r') as f:
    content = f.read()

content = content.replace('width: 48,', 'width: 32,')
content = content.replace('height: 48,', 'height: 32,')

with open('d:/real_invoice/lib/features/documents/presentation/dummy_templates/elegant_center_dummy.dart', 'w') as f:
    f.write(content)

with open('d:/real_invoice/lib/features/pdf_engine/document_pdf_generator.dart', 'r') as f:
    pdf_content = f.read()

# Only replace the logo dimension inside _buildElegantCenter
target = '''            pw.ClipOval(
              child: pw.Container(
                width: 48,
                height: 48,'''
replacement = '''            pw.ClipOval(
              child: pw.Container(
                width: 32,
                height: 32,'''
pdf_content = pdf_content.replace(target, replacement)

with open('d:/real_invoice/lib/features/pdf_engine/document_pdf_generator.dart', 'w') as f:
    f.write(pdf_content)

print("Updated sizes")