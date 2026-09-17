import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_typography.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final Widget? prefix;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;

  const AppTextField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefix,
    this.suffix,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTypography.titleSmall.copyWith(
            color: AppColors.textPrimary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          autofocus: autofocus,
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            helperText: helperText,
            errorText: errorText,
            prefixIcon: prefix,
            suffixIcon: suffix,
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppDimensions.lg,
              vertical: maxLines > 1 ? AppDimensions.md : 14,
            ),
          ),
        ),
      ],
    );
  }
}
