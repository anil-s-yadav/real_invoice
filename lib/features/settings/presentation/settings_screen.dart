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
import 'invoice_numbering_screen.dart';
import 'payment_details_list_screen.dart';
import 'regional_settings_screen.dart';
import 'tax_discount_settings_screen.dart';

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
          // vertical: AppDimensions.md,
        ),
        children: [
          _buildSectionHeader('BUSINESS'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SettingsTile(
                  title: 'Change Language/Country/Currency',
                  subtitle: 'App language and default currency',
                  icon: Icons.public,
                  color: Colors.blueAccent,
                  isFirst: true,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => RegionalSettingsScreen(),
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
                  title: 'Company Profile',
                  subtitle: 'Business details, logo & GSTIN',
                  icon: Icons.storefront_outlined,
                  color: AppColors.primary,
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
                  title: 'Payment Profiles',
                  subtitle: 'Bank accounts & UPI details',
                  icon: Icons.account_balance_outlined,
                  color: Colors.teal,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PaymentDetailsListScreen(),
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
                  title: 'Subscription',
                  subtitle: 'Free Plan',
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
          const SizedBox(height: 20),

          _buildSectionHeader('PREFERENCES'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SettingsTile(
                  title: 'Default Templates',
                  subtitle: 'Invoice & quotation styles',
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
                  subtitle: 'Prefixes & sequence',
                  icon: Icons.numbers_rounded,
                  color: Colors.orange,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const InvoiceNumberingScreen(),
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
                  title: 'Tax & Discounts',
                  subtitle: 'Default GST & discount rates',
                  icon: Icons.receipt_long_outlined,
                  color: Colors.purple,
                  isLast: true,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const TaxDiscountSettingsScreen(),
                      ),
                    );
                  },
                ),
                Divider(
                  height: 1,
                  color: AppColors.border.withValues(alpha: 0.5),
                  indent: 56,
                ),
                BlocBuilder<ThemeCubit, ThemeMode>(
                  builder: (context, themeMode) {
                    return SettingsTile(
                      title: 'Appearance',
                      subtitle: 'Theme & visual mode',
                      icon: Icons.palette_outlined,
                      color: Colors.pinkAccent,
                      isFirst: true,
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

          const SizedBox(height: 20),

          _buildSectionHeader('SUPPORT & ABOUT'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SettingsTile(
                  title: 'Privacy Policy & Terms',

                  icon: Icons.security,
                  color: Colors.green,
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
                Divider(
                  height: 1,
                  color: AppColors.border.withValues(alpha: 0.5),
                  indent: 56,
                ),
                SettingsTile(
                  title: 'Help & Support',
                  subtitle: 'FAQs, contact & email',
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
                  subtitle: 'Share your feedback',
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
                  title: 'App Version',
                  icon: Icons.info_outline,
                  color: Colors.grey,
                  isLast: true,
                  trailing: const Text(
                    '1.0.0',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),
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
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
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
