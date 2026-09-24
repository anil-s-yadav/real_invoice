import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_typography.dart';

enum AppButtonVariant { primary, secondary, outline, text, danger }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final double? height;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final double buttonHeight = height ?? AppDimensions.buttonHeight;

    Color bgColor;
    Color fgColor;
    BorderSide? borderSide;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final surfaceVariant =
        isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant;
    final border = isDark ? AppColors.darkBorder : AppColors.border;

    switch (variant) {
      case AppButtonVariant.primary:
        bgColor = AppColors.primary;
        fgColor = Colors.white;
        borderSide = BorderSide.none;
        break;
      case AppButtonVariant.secondary:
        bgColor = surfaceVariant;
        fgColor = textPrimary;
        borderSide = BorderSide.none;
        break;
      case AppButtonVariant.outline:
        bgColor = Colors.transparent;
        fgColor = textPrimary;
        borderSide = BorderSide(color: border, width: 1.2);
        break;
      case AppButtonVariant.text:
        bgColor = Colors.transparent;
        fgColor = AppColors.primary;
        borderSide = BorderSide.none;
        break;
      case AppButtonVariant.danger:
        bgColor = isDark ? const Color(0xFF450A0A) : AppColors.statusOverdueBg;
        fgColor = isDark ? const Color(0xFFFCA5A5) : AppColors.statusOverdueText;
        borderSide = BorderSide(
          color: isDark ? const Color(0xFF7F1D1D) : AppColors.statusOverdueBorder,
          width: 1,
        );
        break;
    }

    Widget content;
    if (isLoading) {
      content = SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(fgColor),
        ),
      );
    } else {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: fgColor),
            const SizedBox(width: AppDimensions.sm),
          ],
          Flexible(
            child: Text(
              label,
              style: AppTypography.labelLarge.copyWith(
                color: fgColor,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
    }

    final button = Material(
      color: onPressed != null ? bgColor : bgColor.withValues(alpha: 0.5),
      borderRadius: AppDimensions.roundedMd,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: AppDimensions.roundedMd,
        child: Container(
          height: buttonHeight,
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg),
          decoration: BoxDecoration(
            borderRadius: AppDimensions.roundedMd,
            border: borderSide != BorderSide.none
                ? Border.fromBorderSide(borderSide)
                : null,
          ),
          alignment: Alignment.center,
          child: content,
        ),
      ),
    );

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
