import re

with open('d:/real_invoice/lib/features/documents/presentation/dummy_template_widget.dart', 'r') as f:
    content = f.read()

# Extract the methods
classic_free = re.search(r'Widget _buildClassicFree\(\) \{(.*?)\n  \}', content, re.DOTALL).group(1)
premium_modern = re.search(r'Widget _buildPremiumModern\(\) \{(.*?)\n  \}', content, re.DOTALL).group(1)
elegant_center = re.search(r'Widget _buildElegantCenter\(\) \{(.*?)\n  \}', content, re.DOTALL).group(1)

template = '''import 'package:flutter/material.dart';
import '../domain/document_model.dart';
import 'dummy_template_utils.dart';

Widget build{name}(DocumentType documentType) {{
{body}
}}
'''

with open('d:/real_invoice/lib/features/documents/presentation/dummy_templates/classic_free_dummy.dart', 'w') as f:
    f.write(template.format(name='ClassicFreeDummy', body=classic_free.replace('_text', 'buildDummyText')))

with open('d:/real_invoice/lib/features/documents/presentation/dummy_templates/premium_modern_dummy.dart', 'w') as f:
    f.write(template.format(name='PremiumModernDummy', body=premium_modern.replace('_text', 'buildDummyText')))

with open('d:/real_invoice/lib/features/documents/presentation/dummy_templates/elegant_center_dummy.dart', 'w') as f:
    f.write(template.format(name='ElegantCenterDummy', body=elegant_center.replace('_text', 'buildDummyText')))

# Rewrite dummy_template_widget.dart
new_main = '''import 'package:flutter/material.dart';
import '../../pdf_engine/template_registry.dart';
import '../domain/document_model.dart';
import 'dummy_templates/classic_free_dummy.dart';
import 'dummy_templates/premium_modern_dummy.dart';
import 'dummy_templates/elegant_center_dummy.dart';

class DummyTemplateWidget extends StatelessWidget {
  final String templateId;
  final DocumentType documentType;

  const DummyTemplateWidget({super.key, required this.templateId, this.documentType = DocumentType.invoice});

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: 595,
        height: 842,
        child: _buildTemplate(),
      ),
    );
  }

  Widget _buildTemplate() {
    switch (templateId) {
      case TemplateRegistry.premiumModern:
        return buildPremiumModernDummy(documentType);
      case TemplateRegistry.elegantCenter:
        return buildElegantCenterDummy(documentType);
      case TemplateRegistry.freeClassic:
      default:
        return buildClassicFreeDummy(documentType);
    }
  }
}
'''
with open('d:/real_invoice/lib/features/documents/presentation/dummy_template_widget.dart', 'w') as f:
    f.write(new_main)
print("Splitting complete")