import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../documents/domain/document_model.dart';

class TemplateInfo {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color accentColor;
  final String thumbnailAssetPath;
  final bool isPremium;

  const TemplateInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.thumbnailAssetPath,
    required this.isPremium,
  });
}

class TemplateRegistry {
  TemplateRegistry._();

  static const String freeClassic = 'free_classic';
  static const String premiumModern = 'premium_modern';

  static const List<TemplateInfo> allTemplates = [
    TemplateInfo(
      id: freeClassic,
      name: 'Classic Free',
      description: 'A clean, professional standard layout that covers all basics.',
      icon: Icons.article_outlined,
      accentColor: AppColors.textPrimary,
      thumbnailAssetPath: 'assets/images/templates/free_template_thumb.png',
      isPremium: false,
    ),
    TemplateInfo(
      id: premiumModern,
      name: 'Modern Pro',
      description: 'Sleek, colored headers with premium typography and card styling.',
      icon: Icons.auto_awesome,
      accentColor: AppColors.primary,
      thumbnailAssetPath: 'assets/images/templates/paid_template_thumb.png',
      isPremium: true,
    ),
  ];

  static TemplateInfo getById(String id) {
    return allTemplates.firstWhere(
      (t) => t.id == id,
      orElse: () => allTemplates.first,
    );
  }

  static List<TemplateInfo> getTemplatesFor(DocumentType type) {
    // Both Free and Paid apply to all 4 document types.
    return allTemplates;
  }
}
