import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_typography.dart';

enum DocumentStatus { sent, partial, paid, overdue, accepted, cancelled }

extension DocumentStatusX on DocumentStatus {
  String get displayName {
    switch (this) {
      case DocumentStatus.sent:
        return 'SENT';
      case DocumentStatus.partial:
        return 'PARTIAL';
      case DocumentStatus.paid:
        return 'PAID';
      case DocumentStatus.overdue:
        return 'OVERDUE';
      case DocumentStatus.accepted:
        return 'ACCEPTED';
      case DocumentStatus.cancelled:
        return 'CANCELLED';
    }
  }

  Color get textColor {
    switch (this) {
      case DocumentStatus.paid:
        return AppColors.statusPaidText;
      case DocumentStatus.sent:
        return AppColors.statusSentText;
      case DocumentStatus.partial:
        return AppColors.statusPartialText;
      case DocumentStatus.overdue:
        return AppColors.statusOverdueText;
      case DocumentStatus.accepted:
        return AppColors.statusAcceptedText;
      case DocumentStatus.cancelled:
        return AppColors.textMuted;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case DocumentStatus.paid:
        return AppColors.statusPaidBg;
      case DocumentStatus.sent:
        return AppColors.statusSentBg;
      case DocumentStatus.partial:
        return AppColors.statusPartialBg;
      case DocumentStatus.overdue:
        return AppColors.statusOverdueBg;
      case DocumentStatus.accepted:
        return AppColors.statusAcceptedBg;
      case DocumentStatus.cancelled:
        return AppColors.surfaceVariant;
    }
  }

  Color get borderColor {
    switch (this) {
      case DocumentStatus.paid:
        return AppColors.statusPaidBorder;
      case DocumentStatus.sent:
        return AppColors.statusSentBorder;
      case DocumentStatus.partial:
        return AppColors.statusPartialBorder;
      case DocumentStatus.overdue:
        return AppColors.statusOverdueBorder;
      case DocumentStatus.accepted:
        return AppColors.statusAcceptedBorder;
      case DocumentStatus.cancelled:
        return AppColors.border;
    }
  }
}

class StatusBadge extends StatelessWidget {
  final DocumentStatus status;
  final bool isCompact;

  const StatusBadge({super.key, required this.status, this.isCompact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? AppDimensions.sm : AppDimensions.md,
        vertical: isCompact ? 3.0 : 4.5,
      ),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        borderRadius: AppDimensions.roundedSm,
        border: Border.all(color: status.borderColor, width: 1),
      ),
      child: Text(
        status.displayName,
        style: AppTypography.stamp.copyWith(
          color: status.textColor,
          fontSize: isCompact ? 9.5 : 10.5,
        ),
      ),
    );
  }
}
