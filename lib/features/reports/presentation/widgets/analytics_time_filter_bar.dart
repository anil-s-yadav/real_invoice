import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/analytics_data_models.dart';

class AnalyticsTimeFilterBar extends StatelessWidget {
  final TimeFilterPreset selectedPreset;
  final Function(TimeFilterPreset preset) onPresetSelected;
  final VoidCallback onSelectCustomRange;
  final DateTime startDate;
  final DateTime endDate;

  const AnalyticsTimeFilterBar({
    super.key,
    required this.selectedPreset,
    required this.onPresetSelected,
    required this.onSelectCustomRange,
    required this.startDate,
    required this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 48,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          ...TimeFilterPreset.values.where((p) => p != TimeFilterPreset.custom).map((preset) {
            final isSelected = selectedPreset == preset;
            return Padding(
              padding: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
              child: FilterChip(
                label: Text(preset.label),
                selected: isSelected,
                showCheckmark: false,
                labelStyle: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? AppColors.darkTextSecondary : AppColors.textPrimary),
                ),
                backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
                selectedColor: AppColors.primary,
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? AppColors.darkBorder : AppColors.border),
                  width: 1,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                onSelected: (_) => onPresetSelected(preset),
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
            child: ActionChip(
              avatar: Icon(
                Icons.date_range_rounded,
                size: 16,
                color: selectedPreset == TimeFilterPreset.custom
                    ? Colors.white
                    : AppColors.primary,
              ),
              label: Text(
                selectedPreset == TimeFilterPreset.custom
                    ? '${startDate.day}/${startDate.month} - ${endDate.day}/${endDate.month}'
                    : 'Custom Range',
              ),
              labelStyle: TextStyle(
                fontSize: 12.5,
                fontWeight: selectedPreset == TimeFilterPreset.custom
                    ? FontWeight.w700
                    : FontWeight.w500,
                color: selectedPreset == TimeFilterPreset.custom
                    ? Colors.white
                    : (isDark ? AppColors.darkTextSecondary : AppColors.textPrimary),
              ),
              backgroundColor: selectedPreset == TimeFilterPreset.custom
                  ? AppColors.primary
                  : (isDark ? AppColors.darkSurface : Colors.white),
              side: BorderSide(
                color: selectedPreset == TimeFilterPreset.custom
                    ? AppColors.primary
                    : (isDark ? AppColors.darkBorder : AppColors.border),
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              onPressed: onSelectCustomRange,
            ),
          ),
        ],
      ),
    );
  }
}
