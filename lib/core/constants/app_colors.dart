import 'package:flutter/material.dart';

/// invoz "Deep Indigo" Color Palette
/// Trustworthy, professional, modern, and calm.
class AppColors {
  AppColors._();

  // Primary Indigo Brand
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryDark = Color(0xFF3730A3);
  static const Color primaryLight = Color(0xFFEEF2FF);
  static const Color primaryHover = Color(0xFF4338CA);

  // Light Mode Surfaces (Clean white and cool slate backgrounds)
  static const Color canvas = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F5F9);
  static const Color surfaceSubtle = Color(0xFFF8FAFC);

  // Light Mode Borders (Subtle slate grays)
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderSubtle = Color(0xFFF1F5F9);
  static const Color borderStrong = Color(0xFFCBD5E1);

  // Light Mode Text
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Dark Mode Surfaces (Slate/Navy based)
  static const Color darkCanvas = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceVariant = Color(0xFF334155);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkBorderSubtle = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // Semantic Status Colors
  // Paid (Green)
  static const Color statusPaidText = Color(0xFF047857);
  static const Color statusPaidBg = Color(0xFFECFDF5);
  static const Color statusPaidBorder = Color(0xFFA7F3D0);

  // Sent / Pending (Amber)
  static const Color statusSentText = Color(0xFFB45309);
  static const Color statusSentBg = Color(0xFFFFFBEB);
  static const Color statusSentBorder = Color(0xFFFDE68A);

  // Draft (Gray)
  static const Color statusDraftText = Color(0xFF475569);
  static const Color statusDraftBg = Color(0xFFF1F5F9);
  static const Color statusDraftBorder = Color(0xFFCBD5E1);

  // Partial (Amber/Orange)
  static const Color statusPartialText = Color(0xFFC2410C);
  static const Color statusPartialBg = Color(0xFFFFEDD5);
  static const Color statusPartialBorder = Color(0xFFFDBA74);

  // Overdue (Red)
  static const Color statusOverdueText = Color(0xFFB91C1C);
  static const Color statusOverdueBg = Color(0xFFFEF2F2);
  static const Color statusOverdueBorder = Color(0xFFFECACA);

  // Accepted (Teal)
  static const Color statusAcceptedText = Color(0xFF0F766E);
  static const Color statusAcceptedBg = Color(0xFFF0FDFA);
  static const Color statusAcceptedBorder = Color(0xFF99F6E4);

  // Accents
  static const Color accentNavy = Color(0xFF1E293B);
  static const Color accentGold = Color(0xFFD97706);
  static const Color premiumGold = Color(
    0xFFDAA520,
  ); // Darker, rich goldenrod for premium features
}
