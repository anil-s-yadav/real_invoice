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
  final List<DocumentType> supportedTypes;

  const TemplateInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.thumbnailAssetPath,
    required this.isPremium,
    this.supportedTypes = const [
      DocumentType.invoice,
      DocumentType.quotation,
      DocumentType.proforma,
      DocumentType.receipt,
    ],
  });
}

class TemplateRegistry {
  TemplateRegistry._();

  static const String freeClassic = 'free_classic';
  static const String premiumModern = 'premium_modern';
  static const String elegantCenter = 'elegant_center';

  static const List<TemplateInfo> allTemplates = [
    TemplateInfo(
      id: freeClassic,
      name: 'Classic Free',
      description: 'A clean, professional standard layout that covers all basics.',
      icon: Icons.article_outlined,
      accentColor: AppColors.textPrimary,
      thumbnailAssetPath: 'assets/images/templates/free_template_thumb.png',
      isPremium: false,
      // By default, Classic Free supports all document types.
    ),
    TemplateInfo(
      id: premiumModern,
      name: 'Modern Pro',
      description: 'Sleek, colored headers with premium typography and card styling.',
      icon: Icons.auto_awesome,
      accentColor: AppColors.primary,
      thumbnailAssetPath: 'assets/images/templates/paid_template_thumb.png',
      isPremium: true,
      // Example: supports everything EXCEPT receipt
      supportedTypes: [
        DocumentType.invoice,
        DocumentType.quotation,
        DocumentType.proforma,
      ],
    ),
    TemplateInfo(
      id: elegantCenter,
      name: 'Elegant Center',
      description: 'A beautiful centered layout with clean borders and modern typography.',
      icon: Icons.format_align_center,
      accentColor: Color(0xFF0D47A1),
      thumbnailAssetPath: 'assets/images/templates/elegant_center_thumb.png',
      isPremium: true,
      // Let's assume elegantCenter supports all types for now
    ),
  ];

  static TemplateInfo getById(String id) {
    return allTemplates.firstWhere(
      (t) => t.id == id,
      orElse: () => allTemplates.first,
    );
  }

  static List<TemplateInfo> getTemplatesFor(DocumentType type) {
    return allTemplates.where((t) => t.supportedTypes.contains(type)).toList();
  }
}