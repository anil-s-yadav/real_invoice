import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/settings_tile.dart';
import '../../business_profile/bloc/business_profile_bloc.dart';
import '../../business_profile/bloc/business_profile_state.dart';
import '../../business_profile/domain/business_profile_model.dart';
import '../../business_profile/presentation/business_profile_screen.dart';
import 'default_templates_screen.dart';
import 'payment_details_list_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BusinessProfileBloc, BusinessProfileState>(
      builder: (context, profileState) {
        final profile = profileState is BusinessProfileLoaded
            ? profileState.profile
            : const BusinessProfile();

        return Scaffold(
          backgroundColor: AppColors.canvas,
          appBar: AppBar(
            title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
            centerTitle: true,
            backgroundColor: AppColors.canvas,
            elevation: 0,
            foregroundColor: AppColors.textPrimary,
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg, vertical: AppDimensions.md),
            children: [
              // Business Profile Header Card
              AppCard(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const BusinessProfileScreen()),
                  );
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppColors.primaryLight,
                      child: Text(
                        profile.businessName.isNotEmpty
                            ? profile.businessName.substring(0, profile.businessName.length.clamp(1, 2)).toUpperCase()
                            : 'BIZ',
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.businessName.isNotEmpty ? profile.businessName : 'Setup Business Profile',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            profile.businessName.isNotEmpty
                                ? [profile.phone, profile.gstin != null ? "GST: ${profile.gstin}" : null]
                                    .whereType<String>()
                                    .join(' • ')
                                : 'Add name, logo, phone, address & GSTIN',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.textMuted),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.xl),

              // Settings Group
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  'PREFERENCES',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: AppColors.textSecondary),
                ),
              ),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    // Theme Switcher
                    BlocBuilder<ThemeCubit, ThemeMode>(
                      builder: (context, themeMode) {
                        return SettingsTile(
                          title: 'Appearance',
                          subtitle: 'System, Light, or Dark',
                          icon: Icons.palette_outlined,
                          color: Colors.blue,
                          isFirst: true,
                          trailing: DropdownButton<ThemeMode>(
                            value: themeMode,
                            underline: const SizedBox(),
                            icon: const Icon(Icons.expand_more, size: 20, color: AppColors.textMuted),
                            alignment: Alignment.centerRight,
                            items: const [
                              DropdownMenuItem(value: ThemeMode.system, child: Text('System', style: TextStyle(fontSize: 14))),
                              DropdownMenuItem(value: ThemeMode.light, child: Text('Light', style: TextStyle(fontSize: 14))),
                              DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark', style: TextStyle(fontSize: 14))),
                            ],
                            onChanged: (mode) {
                              if (mode != null) {
                                context.read<ThemeCubit>().setThemeMode(mode);
                              }
                            },
                          ),
                          onTap: () {},
                        );
                      },
                    ),
                    Divider(height: 1, color: AppColors.border.withValues(alpha: 0.5), indent: 56),
                    
                    SettingsTile(
                      title: 'Document Templates',
                      subtitle: 'Manage invoice & quotation styles',
                      icon: Icons.dashboard_customize_outlined,
                      color: Colors.indigo,
                      onTap: () => _showTemplatesSheet(context),
                    ),
                    Divider(height: 1, color: AppColors.border.withValues(alpha: 0.5), indent: 56),

                    SettingsTile(
                      title: 'Bank & UPI Details',
                      subtitle: 'Set up default payment methods',
                      icon: Icons.account_balance_outlined,
                      color: Colors.teal,
                      isLast: true,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const PaymentDetailsListScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.xl),

              // App Info
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 12),
                child: Text(
                  'ABOUT & SECURITY',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: AppColors.textSecondary),
                ),
              ),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    SettingsTile(
                      title: 'Privacy & Security',
                      subtitle: '100% Offline-First (Local Storage)',
                      icon: Icons.security,
                      color: Colors.green,
                      isFirst: true,
                      trailing: const Icon(Icons.info_outline, size: 20, color: AppColors.textMuted),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('All data is securely stored on your device only.')),
                        );
                      },
                    ),
                    Divider(height: 1, color: AppColors.border.withValues(alpha: 0.5), indent: 56),
                    SettingsTile(
                      title: 'Version',
                      subtitle: '1.0.0 (Build 1)',
                      icon: Icons.info_outline,
                      color: Colors.grey,
                      isLast: true,
                      trailing: const SizedBox.shrink(),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.xxxl),
            ],
          ),
        );
      },
    );
  }

  void _showTemplatesSheet(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DefaultTemplatesScreen()),
    );
  }
}
