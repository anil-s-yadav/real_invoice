import '../domain/document_model.dart';
import 'package:flutter/material.dart';
import 'package:invoz/features/documents/domain/document_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../business_profile/domain/business_profile_model.dart';
import 'dummy_template_widget.dart';
import '../../pdf_engine/template_registry.dart';

class TemplatePreviewScreen extends StatelessWidget {
  final TemplateInfo template;
  final DocumentType documentType;
  final BusinessProfile profile;
  final bool isDefault;
  final VoidCallback onSetDefault;
  final bool showPaymentDetails;

  const TemplatePreviewScreen({
    super.key,
    required this.template,
    required this.documentType,
    required this.profile,
    required this.isDefault,
    required this.onSetDefault,
    this.showPaymentDetails = true,
  });

  static Future<void> show({
    required BuildContext context,
    required TemplateInfo template,
    required DocumentType documentType,
    required BusinessProfile profile,
    required bool isDefault,
    required VoidCallback onSetDefault,
    bool showPaymentDetails = true,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => TemplatePreviewScreen(
          template: template,
          documentType: documentType,
          profile: profile,
          isDefault: isDefault,
          onSetDefault: onSetDefault,
          showPaymentDetails: showPaymentDetails,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkCanvas : AppColors.canvas,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkCanvas : AppColors.canvas,
        foregroundColor: isDark
            ? AppColors.darkTextPrimary
            : AppColors.textPrimary,
        elevation: 0,
        title: Column(
          children: [
            Text(
              template.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            Text(
              '${documentType.displayName} Template Preview',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Close',
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: isDark ? AppColors.darkCanvas : AppColors.canvas,
              child: InteractiveViewer(
                minScale: 1.0,
                maxScale: 4.0,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1 / 1.414, // A4 ratio
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(15),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRect(
                        child: DummyTemplateWidget(templateId: template.id, documentType: documentType),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
