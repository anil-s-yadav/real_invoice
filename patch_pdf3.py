import re

with open('d:/real_invoice/lib/features/pdf_engine/document_pdf_generator.dart', 'r') as f:
    content = f.read()

target = '''          if (selectedTemplate == TemplateRegistry.premiumModern) {
            return _buildPremiumModern(
              context,
              document,
              profile,
              logoBytes: logoBytes,
              signatureBytes: signatureBytes,
            );
          }'''

replacement = '''          if (selectedTemplate == TemplateRegistry.premiumModern) {
            return _buildPremiumModern(
              context,
              document,
              profile,
              logoBytes: logoBytes,
              signatureBytes: signatureBytes,
            );
          }
          if (selectedTemplate == TemplateRegistry.elegantCenter) {
            return _buildElegantCenter(
              context,
              document,
              profile,
              logoBytes: logoBytes,
              signatureBytes: signatureBytes,
            );
          }'''

content = content.replace(target, replacement)

with open('d:/real_invoice/lib/features/pdf_engine/document_pdf_generator.dart', 'w') as f:
    f.write(content)
print("Updated route")