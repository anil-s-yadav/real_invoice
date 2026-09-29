import 'package:flutter_bloc/flutter_bloc.dart';
import '../../subscriptions/bloc/subscription_bloc.dart';
import '../../subscription/presentation/subscription_screen.dart';
import '../domain/document_model.dart';
import 'package:flutter/material.dart';
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
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 60 : 10),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: isDefault ? null : () {
              if (template.isPremium) {
                final subState = context.read<SubscriptionBloc>().state;
                if (subState.plan?.isFree ?? true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Premium template. Please upgrade your plan.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                  );
                  return;
                }
              }
              onSetDefault();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDefault ? Colors.grey : AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              isDefault ? 'Already Default Template' : 'Set as Default',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
