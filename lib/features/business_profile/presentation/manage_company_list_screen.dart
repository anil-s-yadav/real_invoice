import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../subscription/presentation/subscription_screen.dart';
import '../../subscriptions/bloc/subscription_bloc.dart';
import '../data/business_profile_repository.dart';
import '../domain/business_profile_model.dart';
import '../bloc/business_profile_bloc.dart';
import '../bloc/business_profile_event.dart';
import '../../onboarding/presentation/onboarding_screen.dart';
import 'company_detail_screen.dart';

class ManageCompanyListScreen extends StatefulWidget {
  const ManageCompanyListScreen({super.key});

  @override
  State<ManageCompanyListScreen> createState() =>
      _ManageCompanyListScreenState();
}

class _ManageCompanyListScreenState extends State<ManageCompanyListScreen> {
  late final BusinessProfileRepository _repository;
  List<BusinessProfile> _profiles = [];
  bool _isLoading = true;
  String _activeId = '';

  @override
  void initState() {
    super.initState();
    _repository = context.read<BusinessProfileRepository>();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final profiles = await _repository.getAllProfiles();
    final activeId = await _repository.getActiveProfileId();
    setState(() {
      _profiles = profiles;
      _activeId = activeId;
      _isLoading = false;
    });
  }

  Future<void> _setActive(String id) async {
    await _repository.setActiveProfileId(id);
    _loadData();
    if (mounted) {
      context.read<BusinessProfileBloc>().add(const LoadBusinessProfileEvent());
    }
  }



  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Manage Companies',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Compact Buy Premium Tab (Visible only on Free plan)
                        _buildPremiumBanner(context),

                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Your Businesses',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_profiles.length} Total',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Grid
                SliverPadding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 100,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.80,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final profile = _profiles[index];
                      final isActive = profile.id == _activeId;
                      return _buildCompanyCard(profile, isActive);
                    }, childCount: _profiles.length),
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const OnboardingScreen(isAddingNewCompany: true),
            ),
          );
          _loadData();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Company'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildCompanyCard(BusinessProfile profile, bool isActive) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => CompanyDetailScreen(
              profile: profile,
              isActive: isActive,
            ),
          ),
        );
        if (result == true) _loadData();
      },
      child: Builder(
        builder: (context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isActive
                    ? AppColors.primary
                    : (isDark
                        ? AppColors.darkBorder
                        : Colors.grey.withValues(alpha: 0.2)),
                width: isActive ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Logo
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: isDark
                            ? AppColors.darkSurfaceVariant
                            : AppColors.canvas,
                        backgroundImage:
                            profile.logoPath != null && profile.logoPath!.isNotEmpty
                                ? (profile.logoPath!.startsWith('http')
                                    ? CachedNetworkImageProvider(profile.logoPath!)
                                        as ImageProvider
                                    : FileImage(File(profile.logoPath!)))
                                : null,
                        child:
                            profile.logoPath == null || profile.logoPath!.isEmpty
                                ? const Icon(
                                    Icons.business,
                                    size: 22,
                                    color: AppColors.textSecondary,
                                  )
                                : null,
                      ),
                      const SizedBox(height: 10),

                      // Name
                      Text(
                        profile.businessName.isEmpty
                            ? 'Unnamed Company'
                            : profile.businessName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Extra Info
                      if (profile.gstin != null && profile.gstin!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            'GST: ${profile.gstin}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      if (profile.email != null && profile.email!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            '${profile.email}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      if (profile.phone != null &&
                          profile.phone!.isNotEmpty &&
                          (profile.gstin == null || profile.gstin!.isEmpty))
                        Text(
                          '${profile.phone}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                      const Spacer(),

                      // Active status / button
                      SizedBox(
                        width: double.infinity,
                        child: isActive
                            ? Container(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: 14,
                                      color: AppColors.primary,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Active',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : TextButton(
                                onPressed: () => _setActive(profile.id),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  backgroundColor: isDark
                                      ? AppColors.darkSurfaceVariant
                                      : Colors.grey.withValues(
                                          alpha: 0.05,
                                        ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'Set Active',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),

            if (isActive)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                    ),
                  ),
                  child: const Icon(Icons.star, size: 12, color: Colors.white),
                ),
              ),
          ],
        ),
      );
    },
  ),
);
  }

  Widget _buildPremiumBanner(BuildContext context) {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, subscriptionState) {
        final isFree = subscriptionState is! PremiumTierState;
        if (!isFree) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF1E1B4B), // Deep Midnight Indigo
                      Color(0xFF312E81), // Rich Indigo
                      Color(0xFF0F172A), // Midnight Navy
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF312E81).withValues(alpha: 0.3),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Badge & Discount Chip
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.workspace_premium_rounded,
                                size: 15,
                                color: Color(0xFFFBBF24),
                              ),
                              SizedBox(width: 5),
                              Text(
                                'INVOZ PRO',
                                style: TextStyle(
                                  color: Color(0xFFFBBF24),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.green.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: const Text(
                            'SPECIAL OFFER',
                            style: TextStyle(
                              color: Color(0xFF4ADE80),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Main Headline & Subtitle
                    const Text(
                      'Manage Multiple Companies with Ease',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Run multiple businesses from one app. Create separate invoice series, manage unique GSTINs, and customize branding for each enterprise.',
                      style: TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Feature highlights list
                    _buildFeatureItem(
                      Icons.domain_add_rounded,
                      'Add unlimited companies & switch profiles in 1 tap',
                    ),
                    const SizedBox(height: 8),
                    _buildFeatureItem(
                      Icons.auto_awesome_rounded,
                      'Unlock all premium invoice & quotation templates',
                    ),
                    const SizedBox(height: 8),
                    _buildFeatureItem(
                      Icons.draw_rounded,
                      'Custom signatures, stamps, & distinct business logos',
                    ),
                    const SizedBox(height: 8),
                    _buildFeatureItem(
                      Icons.cloud_sync_rounded,
                      'Real-time cloud sync & multi-device backup',
                    ),
                    const SizedBox(height: 16),

                    // Upgrade Button
                    Container(
                      width: double.infinity,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFF59E0B), // Amber 500
                            Color(0xFFD97706), // Amber 600
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bolt_rounded,
                            color: Colors.black,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Upgrade to Pro — View Plans',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.black,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        'Instant activation • Cancel anytime • 100% money-back guarantee',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 14,
            color: const Color(0xFFFBBF24),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFFF1F5F9),
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}


