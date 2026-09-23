import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../documents/domain/document_model.dart';

class TemplateInfo {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color accentColor;

  const TemplateInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.accentColor,
  });
}

class TemplateRegistry {
  TemplateRegistry._();

  static const String modernCrimson = 'modern_crimson';
  static const String sunsetOrange = 'sunset_orange';
  static const String minimal = 'minimal';
  static const String corporate = 'corporate';
  static const String elegant = 'elegant';
  static const String compact = 'compact';
  static const String bold = 'bold';

  static const List<TemplateInfo> allTemplates = [
    TemplateInfo(
      id: modernCrimson,
      name: 'Modern Crimson',
      description:
          'Signature invoz layout with refined crimson accents and carded totals.',
      icon: Icons.auto_awesome,
      accentColor: AppColors.primary,
    ),
    TemplateInfo(
      id: sunsetOrange,
      name: 'Sunset Orange',
      description:
          'Warm peach quotation layout with carded party boxes, bold orange header, and signature seal.',
      icon: Icons.wb_sunny_outlined,
      accentColor: Color(0xFFF26522),
    ),
    TemplateInfo(
      id: minimal,
      name: 'Classic Minimal',
      description:
          'Ultra-clean monochrome with generous whitespace and Swiss typography.',
      icon: Icons.crop_square,
      accentColor: AppColors.textPrimary,
    ),
    TemplateInfo(
      id: corporate,
      name: 'Corporate Professional',
      description:
          'Formal business grid with full GST, HSN/SAC columns, and bank details.',
      icon: Icons.business_center_outlined,
      accentColor: Color(0xFF1E3A8A),
    ),
    TemplateInfo(
      id: elegant,
      name: 'Artisan Elegant',
      description:
          'Warm editorial styling with refined serif headings and subtle dividers.',
      icon: Icons.palette_outlined,
      accentColor: Color(0xFF78350F),
    ),
    TemplateInfo(
      id: compact,
      name: 'Compact Slip',
      description:
          'High-density single-page format for service visits, trade work, and repairs.',
      icon: Icons.receipt_outlined,
      accentColor: Color(0xFF374151),
    ),
    TemplateInfo(
      id: bold,
      name: 'Bold Editorial',
      description:
          'High-contrast dark header band with punchy amounts and authoritative branding.',
      icon: Icons.view_headline,
      accentColor: Color(0xFF0F172A),
    ),
  ];

  static TemplateInfo getById(String id) {
    return allTemplates.firstWhere(
      (t) => t.id == id,
      orElse: () => allTemplates.first,
    );
  }

  static List<TemplateInfo> getTemplatesFor(DocumentType type) {
    switch (type) {
      case DocumentType.invoice:
        return [
          getById(modernCrimson),
          getById(corporate),
          getById(minimal),
          getById(bold),
          getById(elegant),
        ];
      case DocumentType.quotation:
        return [
          getById(sunsetOrange),
          getById(modernCrimson),
          getById(corporate),
          getById(minimal),
          getById(bold),
        ];
      case DocumentType.receipt:
        return [
          getById(compact),
          getById(minimal),
          getById(modernCrimson),
          getById(corporate),
          getById(elegant),
        ];
      case DocumentType.proforma:
        return [
          getById(corporate),
          getById(modernCrimson),
          getById(bold),
          getById(minimal),
          getById(elegant),
        ];
    }
  }
}
