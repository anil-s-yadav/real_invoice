import re

with open('d:/real_invoice/lib/features/pdf_engine/document_pdf_generator.dart', 'r') as f:
    content = f.read()

# 1. Hide payment details for receipts
target_hide = '''    if (!doc.includePaymentDetails) return pw.SizedBox();'''
replace_hide = '''    if (!doc.includePaymentDetails || doc.docType == DocumentType.receipt) return pw.SizedBox();'''
content = content.replace(target_hide, replace_hide)

# 2. Add am to UPI URI (there are two places because of ternary operator)
target_upi = '''data: 'upi://pay?pa=&pn=','''
replace_upi = '''data: 'upi://pay?pa=&pn=&am=','''
content = content.replace(target_upi, replace_upi)

with open('d:/real_invoice/lib/features/pdf_engine/document_pdf_generator.dart', 'w') as f:
    f.write(content)
print("Updated PDF generator for amount and receipt hiding")