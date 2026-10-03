import 'package:flutter/material.dart';
import '../../pdf_engine/template_registry.dart';
import '../domain/document_model.dart';
import 'dummy_templates/classic_free_dummy.dart';
import 'dummy_templates/premium_modern_dummy.dart';
import 'dummy_templates/elegant_center_dummy.dart';

class DummyTemplateWidget extends StatelessWidget {
  final String templateId;
  final DocumentType documentType;

  const DummyTemplateWidget({
    super.key,
    required this.templateId,
    this.documentType = DocumentType.invoice,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(width: 595, height: 842, child: _buildTemplate()),
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
