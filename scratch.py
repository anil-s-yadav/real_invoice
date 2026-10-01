import re

filepath = 'lib/features/pdf_engine/document_pdf_generator.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Add import
if 'payment_detail_model.dart' not in content:
    content = re.sub(r'import \'package:pdf/widgets\.dart\' as pw;', r'import \'package:pdf/widgets.dart\' as pw;\nimport \'../settings/domain/payment_detail_model.dart\';', content)

# 2. Add payments to generate method signature
content = re.sub(
    r'static Future<Uint8List> generate\(\{\s*required DocumentModel document,\s*required BusinessProfile profile,',
    r'static Future<Uint8List> generate({\n    required DocumentModel document,\n    required BusinessProfile profile,\n    required List<PaymentDetail> payments,',
    content
)

# 3 & 4. Add payments to _buildTemplate signatures and calls
for tpl in ['_buildFreeClassic', '_buildPremiumModern', '_buildElegantCenter']:
    # signature
    content = re.sub(
        r'(' + tpl + r'\(\s*pw\.Context context,\s*DocumentModel doc,\s*BusinessProfile profile,\s*\{)(\s*Uint8List\?\s*logoBytes,)',
        r'\1\n    required List<PaymentDetail> payments,\2',
        content,
        flags=re.DOTALL
    )
    # call site inside generate
    content = re.sub(
        r'(' + tpl + r'\(\s*context,\s*document,\s*profile,)',
        r'\1 payments: payments,',
        content
    )

# 5. Add payments to _buildPaymentDetails signature
content = re.sub(
    r'static pw\.Widget _buildPaymentDetails\(\s*DocumentModel doc,\s*BusinessProfile profile,\s*\{\s*PdfColor\?\s*primaryColor,\s*\}\)',
    r'static pw.Widget _buildPaymentDetails(DocumentModel doc, List<PaymentDetail> payments, BusinessProfile profile, {PdfColor? primaryColor})',
    content,
    flags=re.DOTALL
)

# 6. Pass payments to _buildPaymentDetails calls
content = re.sub(
    r'_buildPaymentDetails\(\s*doc,\s*profile,\s*primaryColor:\s*primaryColor\s*\)',
    r'_buildPaymentDetails(doc, payments, profile, primaryColor: primaryColor)',
    content,
    flags=re.DOTALL
)

# Also fix the fallback inside _buildPaymentDetails to use `payments` instead of `profile.paymentDetails`
content = content.replace('profile.paymentDetails.firstWhere', 'payments.firstWhere')
content = content.replace('profile.paymentDetails\n', 'payments\n')
content = content.replace('profile.paymentDetails\r\n', 'payments\r\n')
content = content.replace('profile.paymentDetails.where', 'payments.where')
content = content.replace('profile.paymentDetails', 'payments')

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
print('Updated document_pdf_generator.dart cleanly')
