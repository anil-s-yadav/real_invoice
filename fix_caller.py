import re

with open('lib/features/pdf_engine/document_pdf_generator.dart', 'r', encoding='utf-8') as f:
    content = f.read()

pattern = r"return _buildFreeClassic\(\s*context,\s*document,\s*profile,\s*payments: payments,\s*logoBytes: logoBytes,\s*signatureBytes: signatureBytes,\s*\);"
replacement = r"""return _buildFreeClassic(
            context,
            document,
            profile,
            payments: payments,
            logoBytes: logoBytes,
            signatureBytes: signatureBytes,
            stampBytes: stampBytes,
          );"""

content = re.sub(pattern, replacement, content)

with open('lib/features/pdf_engine/document_pdf_generator.dart', 'w', encoding='utf-8') as f:
    f.write(content)
