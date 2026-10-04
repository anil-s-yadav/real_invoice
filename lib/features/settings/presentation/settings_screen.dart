import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:invoz/features/ads/ad_banner_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/theme/theme_cubit.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/settings_tile.dart';
import '../../business_profile/presentation/manage_company_list_screen.dart';
import '../../subscription/presentation/plan_info_screen.dart';
import '../../subscriptions/bloc/subscription_bloc.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor = isDark
        ? AppColors.darkBorder
        : AppColors.border.withValues(alpha: 0.5);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
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
                Divider(height: 1, color: dividerColor, indent: 56),
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
                Divider(height: 1, color: dividerColor, indent: 56),
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
                Divider(height: 1, color: dividerColor, indent: 56),
                BlocBuilder<SubscriptionBloc, SubscriptionState>(
                  builder: (context, subState) {
                    final plan = subState.plan;
                    final planName = plan?.planName ?? 'Free Plan';
                    final isPremium = subState is PremiumTierState;
                    final subtitle = isPremium
                        ? '$planName (Active)'
                        : 'Free Plan • Tap to view';

                    return SettingsTile(
                      title: 'Subscription',
                      subtitle: subtitle,
                      icon: isPremium
                          ? Icons.workspace_premium_rounded
                          : Icons.workspace_premium_outlined,
                      color: AppColors.premiumGold,
                      isLast: true,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const PlanInfoScreen(),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: AdBannerWidget(),
          ),

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
                Divider(height: 1, color: dividerColor, indent: 56),
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
                Divider(height: 1, color: dividerColor, indent: 56),
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
                Divider(height: 1, color: dividerColor, indent: 56),
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
                        dropdownColor: Theme.of(context).colorScheme.surface,
                        icon: Icon(
                          Icons.expand_more,
                          size: 20,
                          color: isDark
                              ? AppColors.darkTextMuted
                              : AppColors.textMuted,
                        ),
                        alignment: Alignment.centerRight,
                        items: [
                          DropdownMenuItem(
                            value: ThemeMode.system,
                            child: Text(
                              'System',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.light,
                            child: Text(
                              'Light',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: ThemeMode.dark,
                            child: Text(
                              'Dark',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                              ),
                            ),
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
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: AdBannerWidget(),
          ),
          _buildSectionHeader('SUPPORT & ABOUT'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SettingsTile(
                  title: 'Rate the App',
                  subtitle: 'Love Invoz? Leave a review!',
                  icon: Icons.star_rate_rounded,
                  color: Colors.amber,
                  isFirst: true,
                  onTap: () async {
                    final InAppReview inAppReview = InAppReview.instance;
                    if (await inAppReview.isAvailable()) {
                      inAppReview.requestReview();
                    }
                  },
                ),
                Divider(height: 1, color: dividerColor, indent: 56),
                SettingsTile(
                  title: 'Privacy Policy',
                  isFirst: false,

                  icon: Icons.security,
                  color: Colors.green,
                  isLast: false,
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: AppColors.textMuted,
                    ),
                  onTap: () async {
                      final Uri url = Uri.parse('https://invoice-c1603.web.app/privacy');
                      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                        debugPrint('Could not launch $url');
                      }
                    },
                ),
                Divider(height: 1, color: dividerColor, indent: 56),
                SettingsTile(
                  title: 'Terms & Conditions',
                  icon: Icons.gavel,
                  color: Colors.deepPurple,
                  isFirst: false,
                  isLast: false,
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                  onTap: () async {
                    final Uri url = Uri.parse('https://invoice-c1603.web.app/terms');
                    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                      debugPrint('Could not launch $url');
                    }
                  },
                ),
                Divider(height: 1, color: dividerColor, indent: 56),
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
                Divider(height: 1, color: dividerColor, indent: 56),
                SettingsTile(
                  title: 'Rate Us',
                  subtitle: 'Share your feedback',
                  icon: Icons.star_outline,
                  color: Colors.amber,
                  onTap: () => _showComingSoon(context, 'Rate Us'),
                ),
                Divider(height: 1, color: dividerColor, indent: 56),
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
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: AdBannerWidget(),
          ),
          const SizedBox(height: 36),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
            ),
          ),
        );
      },
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





