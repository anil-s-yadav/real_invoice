import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/settings_tile.dart';
import '../../business_profile/presentation/manage_company_list_screen.dart';
import '../../subscription/presentation/subscription_screen.dart';
import 'default_templates_screen.dart';
import 'help_support_screen.dart';
import 'payment_details_list_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.canvas,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.lg,
          vertical: AppDimensions.md,
        ),
        children: [
          _buildSectionHeader('ACCOUNT & BUSINESS'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SettingsTile(
                  title: 'Manage Company',
                  subtitle: 'Update business details, logo & GSTIN',
                  icon: Icons.storefront_outlined,
                  color: AppColors.primary,
                  isFirst: true,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ManageCompanyListScreen(),
                      ),
                    );
                  },
                ),
                Divider(
                  height: 1,
                  color: AppColors.border.withValues(alpha: 0.5),
                  indent: 56,
                ),
                SettingsTile(
                  title: 'Manage Subscription',
                  subtitle: 'Current Plan: Free Plan',
                  icon: Icons.workspace_premium_outlined,
                  color: AppColors.premiumGold,
                  isLast: true,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SubscriptionScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('INVOICING & TAXES'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SettingsTile(
                  title: 'Default Templates',
                  subtitle: 'Manage invoice & quotation styles',
                  icon: Icons.dashboard_customize_outlined,
                  color: Colors.indigo,
                  isFirst: true,
                  onTap: () => _showTemplatesSheet(context),
                ),
                Divider(
                  height: 1,
                  color: AppColors.border.withValues(alpha: 0.5),
                  indent: 56,
                ),
                SettingsTile(
                  title: 'Invoice Numbering',
                  subtitle: 'Customize prefixes (e.g. INV-)',
                  icon: Icons.numbers_rounded,
                  color: Colors.orange,
                  onTap: () => _showComingSoon(context, 'Invoice Numbering'),
                ),
                Divider(
                  height: 1,
                  color: AppColors.border.withValues(alpha: 0.5),
                  indent: 56,
                ),
                SettingsTile(
                  title: 'Tax & Discount Defaults',
                  subtitle: 'Set default GST or discount rates',
                  icon: Icons.receipt_long_outlined,
                  color: Colors.purple,
                  isLast: true,
                  onTap: () => _showComingSoon(context, 'Tax Defaults'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('PAYMENTS'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SettingsTile(
                  title: 'Payment Profiles',
                  subtitle: 'Manage Banking Details',
                  icon: Icons.account_balance_outlined,
                  color: Colors.teal,
                  isFirst: true,
                  isLast: true,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PaymentDetailsListScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('DATA & PRIVACY'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SettingsTile(
                  title: 'Privacy & Security',
                  icon: Icons.security,
                  color: Colors.green,
                  isFirst: true,
                  isLast: true,
                  trailing: const Icon(
                    Icons.info_outline,
                    size: 20,
                    color: AppColors.textMuted,
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'All data is securely stored on your device only.',
                        ),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('APP PREFERENCES'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                BlocBuilder<ThemeCubit, ThemeMode>(
                  builder: (context, themeMode) {
                    return SettingsTile(
                      title: 'Appearance',

                      icon: Icons.palette_outlined,
                      color: Colors.pinkAccent,
                      isFirst: true,
                      isLast: true,
                      trailing: DropdownButton<ThemeMode>(
                        value: themeMode,
                        underline: const SizedBox(),
                        icon: const Icon(
                          Icons.expand_more,
                          size: 20,
                          color: AppColors.textMuted,
                        ),
                        alignment: Alignment.centerRight,
                        items: const [
                          DropdownMenuItem(
                            value: ThemeMode.system,
                            child: Text(
                              'System',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.light,
                            child: Text(
                              'Light',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.dark,
                            child: Text('Dark', style: TextStyle(fontSize: 14)),
                          ),
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
              ],
            ),
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('ABOUT'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SettingsTile(
                  title: 'Help & Support',
                  subtitle: 'FAQs, contact, and email support',
                  icon: Icons.help_outline,
                  color: Colors.blueGrey,
                  isFirst: true,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const HelpSupportScreen(),
                      ),
                    );
                  },
                ),
                Divider(
                  height: 1,
                  color: AppColors.border.withValues(alpha: 0.5),
                  indent: 56,
                ),
                SettingsTile(
                  title: 'Rate Us',
                  subtitle: 'Love the app? Leave a review!',
                  icon: Icons.star_outline,
                  color: Colors.amber,
                  onTap: () => _showComingSoon(context, 'Rate Us'),
                ),
                Divider(
                  height: 1,
                  color: AppColors.border.withValues(alpha: 0.5),
                  indent: 56,
                ),
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
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  void _showTemplatesSheet(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const DefaultTemplatesScreen()));
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature is coming soon!'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
