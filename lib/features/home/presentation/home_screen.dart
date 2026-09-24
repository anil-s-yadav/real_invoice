import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/settings_tile.dart';
import '../../../core/widgets/status_badge.dart';
import '../../business_profile/presentation/manage_company_list_screen.dart';
import '../../documents/data/document_repository.dart';
import '../../documents/domain/document_model.dart';
import '../../documents/presentation/document_editor_screen.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../../subscription/presentation/subscription_screen.dart';
import '../../settings/presentation/user_profile_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/domain/auth_user_model.dart';

class HomeScreen extends StatefulWidget {
  final void Function({DocumentType? type, DocumentStatus? status})
  onNavigateToDocuments;
  final VoidCallback onNavigateToCustomers;
  final VoidCallback onNavigateToProducts;
  final VoidCallback onNavigateToSettings;

  const HomeScreen({
    super.key,
    required this.onNavigateToDocuments,
    required this.onNavigateToCustomers,
    required this.onNavigateToProducts,
    required this.onNavigateToSettings,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showPromoBanner = false;

  @override
  void initState() {
    super.initState();
    _checkPromoBanner();
  }

  Future<void> _checkPromoBanner() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDismissedStr = prefs.getString('promo_banner_dismissed_date');
    if (lastDismissedStr != null) {
      final lastDismissed = DateTime.tryParse(lastDismissedStr);
      if (lastDismissed != null) {
        final now = DateTime.now();
        final difference = now.difference(lastDismissed).inDays;
        if (difference < 7) {
          // Less than 7 days since dismissal
          setState(() {
            _showPromoBanner = false;
          });
          return;
        }
      }
    }
    setState(() {
      _showPromoBanner = true;
    });
  }

  Future<void> _dismissPromoBanner() async {
    setState(() {
      _showPromoBanner = false;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'promo_banner_dismissed_date',
      DateTime.now().toIso8601String(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final profile = state is HomeLoaded ? state.profile : null;
        final businessName = profile?.businessName;
        final isProfileConfigured =
            businessName != null && businessName.trim().isNotEmpty;
        final isLoading = state is! HomeLoaded;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/icons/applogo.png',
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'invoz',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      isLoading
                          ? 'Loading...'
                          : (isProfileConfigured
                                ? businessName
                                : 'Tap to setup profile'),
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: 11,
                        color: (isProfileConfigured || isLoading)
                            ? (isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary)
                            : AppColors.primary,
                        fontWeight: (isProfileConfigured || isLoading)
                            ? FontWeight.normal
                            : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              // 1. Premium Status Icon
              IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.workspace_premium,
                      size: 28,
                      color: AppColors.premiumGold,
                    ),
                    // Red dot or Green tick based on premium status
                    // Hardcoded to false for now to show the red dot prompt
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                tooltip: 'Premium',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SubscriptionScreen(),
                    ),
                  );
                },
              ),
              // 2. Notifications Icon
              IconButton(
                icon: const Badge(
                  backgroundColor: Colors.redAccent,
                  label: Text(
                    '2',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Icon(
                    Icons.notifications_outlined,
                    size: 30,
                    color: AppColors.primary,
                  ),
                ),
                tooltip: 'Notifications',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No new notifications')),
                  );
                },
              ),
              SizedBox(width: 8),
              // 3. User Profile Avatar
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, authState) {
                  final AuthUser? user = authState is Authenticated
                      ? authState.user
                      : null;
                  final photoUrl = user?.photoUrl;
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const UserProfileScreen(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.1,
                        ),
                        child: photoUrl != null && photoUrl.isNotEmpty
                            ? ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: photoUrl,
                                  width: 32,
                                  height: 32,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Icon(
                                    Icons.person,
                                    size: 20,
                                    color: AppColors.primary,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(
                                        Icons.person,
                                        size: 20,
                                        color: AppColors.primary,
                                      ),
                                ),
                              )
                            : const Icon(
                                Icons.person,
                                size: 20,
                                color: AppColors.primary,
                              ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(width: 16),
            ],
          ),
          body: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              context.read<HomeBloc>().add(const LoadHomeDataEvent());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.lg,
                vertical: AppDimensions.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Premium Welcome Offer Banner
                  if (!isLoading && !isProfileConfigured)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.border,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const ManageCompanyListScreen(),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.info_outline_rounded,
                                    color: AppColors.primary,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Complete Profile',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: isDark
                                                ? AppColors.darkTextPrimary
                                                : AppColors.textPrimary,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Add your business details and logo to start creating professional invoices.',
                                          style: TextStyle(
                                            color: isDark
                                                ? AppColors.darkTextSecondary
                                                : AppColors.textSecondary,
                                            fontSize: 13,
                                            height: 1.3,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppColors.textMuted,
                                    size: 24,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  if (_showPromoBanner) ...[
                    _buildPremiumPromoBanner(context),
                    const SizedBox(height: AppDimensions.xl),
                  ],

                  // 1. Overview Dashboard
                  _buildOverviewDashboard(
                    state is HomeLoaded ? state.stats : null,
                  ),
                  const SizedBox(height: AppDimensions.xxxl),

                  // 2. Create Document (Quick Actions - BIG)
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 12),
                    child: Text(
                      'Create New',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildBigQuickAction(
                        context,
                        'Invoice',
                        'assets/icons/invoice.png',
                        DocumentType.invoice,
                        fit: BoxFit.contain,
                        imagePadding: 14.0,
                      ),
                      _buildBigQuickAction(
                        context,
                        'Quotation',
                        'assets/icons/quotation.png',
                        DocumentType.quotation,
                        fit: BoxFit.contain,
                        imagePadding: 14.0,
                      ),
                      _buildBigQuickAction(
                        context,
                        'Receipt',
                        'assets/icons/receipt.png',
                        DocumentType.receipt,
                      ),
                      _buildBigQuickAction(
                        context,
                        'Proforma',
                        'assets/icons/proforma.png',
                        DocumentType.proforma,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.xxxl),

                  // OVERDUE NOTIFICATION CARD (Native HomeScreen Theme)
                  if (state is HomeLoaded && state.stats.overdueCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppDimensions.xl),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.border,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => widget.onNavigateToDocuments(
                              status: DocumentStatus.overdue,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              child: Row(
                                children: [
                                  // Clean rounded alert icon
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF450A0A)
                                          : const Color(0xFFFEF2F2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.warning_amber_rounded,
                                      color: Color(0xFFDC2626),
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Overdue text
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${state.stats.overdueCount} Overdue Bill${state.stats.overdueCount > 1 ? 's' : ''}',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: isDark
                                                ? AppColors.darkTextPrimary
                                                : AppColors.textPrimary,
                                            letterSpacing: -0.2,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${state.stats.overdueCount > 1 ? 'Payments are' : 'Payment is'} past the due date',
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            color: isDark
                                                ? AppColors.darkTextSecondary
                                                : AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // View Action Button
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF2F2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: const Color(0xFFFECACA),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'View',
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFFDC2626),
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 13,
                                          color: Color(0xFFDC2626),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: AppDimensions.xl),

                  // 3. Management Directories
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 12),
                    child: Text(
                      'Manage Business',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        SettingsTile(
                          title: 'Customers',
                          subtitle: 'Clients & GSTINs',
                          icon: Icons.people_alt,
                          color: Colors.blue,
                          onTap: widget.onNavigateToCustomers,
                          isFirst: true,
                        ),
                        Divider(
                          height: 1,
                          color: AppColors.border.withValues(alpha: 0.5),
                          indent: 56,
                        ),
                        SettingsTile(
                          title: 'Items',
                          subtitle: 'Products & Services',
                          icon: Icons.inventory_2,
                          color: Colors.orange,
                          onTap: widget.onNavigateToProducts,
                        ),
                        Divider(
                          height: 1,
                          color: AppColors.border.withValues(alpha: 0.5),
                          indent: 56,
                        ),
                        SettingsTile(
                          title: 'Company Profiles',
                          subtitle: 'Switch or manage up to 10 companies',
                          icon: Icons.business,
                          color: Colors.purple,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ManageCompanyListScreen(),
                              ),
                            );
                          },
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.xxxl),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverviewDashboard(SummaryStats? stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryDark,
            AppColors.primaryDark.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Outstanding',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                Icons.account_balance_wallet_outlined,
                color: Colors.white.withValues(alpha: 0.4),
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            stats == null
                ? '-'
                : CurrencyFormatter.formatCompact(stats.unpaidTotal),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w300,
              letterSpacing: -1.0,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF6B6B),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Overdue',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stats == null
                            ? '-'
                            : CurrencyFormatter.formatCompact(
                                stats.overdueTotal,
                              ),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF6EE7B7),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Collected',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        stats == null
                            ? '-'
                            : CurrencyFormatter.formatCompact(stats.paidTotal),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBigQuickAction(
    BuildContext context,
    String label,
    String imagePath,
    DocumentType type, {
    BoxFit fit = BoxFit.cover,
    double imagePadding = 0.0,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DocumentEditorScreen(initialType: type),
            ),
          );
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.border.withValues(alpha: 0.5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.25 : 0.08,
                        ),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: EdgeInsets.all(imagePadding),
                      child: Image.asset(imagePath, fit: fit),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // The _buildSettingsTile method was removed since we are now using the globally shared SettingsTile.

  Widget _buildPremiumPromoBanner(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFF512F),
                  Color(0xFFDD2476),
                ], // Vibrant Orange to Deep Pink
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFDD2476).withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 1,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Welcome Offer!',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'LIMITED TIME OFFER',
                              style: TextStyle(
                                color: Color(0xFFDD2476),
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '1 Year Free Premium, Tap to claim!.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 20),
            padding: const EdgeInsets.all(12),
            onPressed: _dismissPromoBanner,
          ),
        ),
      ],
    );
  }
}
