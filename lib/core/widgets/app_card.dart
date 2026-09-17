import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final Border? border;
  final BorderRadius? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.onTap,
    this.border,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppDimensions.roundedLg;
    final bg = backgroundColor ?? AppColors.surface;

    final borderSide = border != null ? border!.top : const BorderSide(color: AppColors.border, width: 1);

    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: borderSide,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppDimensions.lg),
          child: child,
        ),
      ),
    );
  }
}
