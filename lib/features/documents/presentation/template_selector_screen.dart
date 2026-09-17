import 'package:flutter/material.dart';
import '../../pdf_engine/template_registry.dart';
import 'widgets/template_thumbnail_card.dart';

class TemplateSelectorScreen extends StatelessWidget {
  final String initialTemplateId;

  const TemplateSelectorScreen({
    super.key,
    required this.initialTemplateId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Template Gallery'),
        elevation: 0,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75, // Standard A4 proportion
          crossAxisSpacing: 16,
          mainAxisSpacing: 24,
        ),
        itemCount: TemplateRegistry.allTemplates.length,
        itemBuilder: (context, index) {
          final t = TemplateRegistry.allTemplates[index];
          final isSelected = t.id == initialTemplateId;

          return TemplateThumbnailCard(
            template: t,
            isSelected: isSelected,
            onTap: () {
              Navigator.of(context).pop(t.id);
            },
          );
        },
      ),
    );
  }
}
