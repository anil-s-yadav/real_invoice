import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import 'checkout_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int _selectedPlanIndex = 2; // Default to Professional
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _selectedPlanIndex,
      viewportFraction: 0.86,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _sendEmail(String emailAddress) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: emailAddress,
      query: 'subject=invoz Support Request',
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  final List<Map<String, dynamic>> _plans = [
    {
      'name': 'Free',
      'tagline': 'Ideal for early-stage invoicing',
      'price': 0.0,
      'badge': null,
      'accentColor': const Color(0xFF64748B),
      'badgeBg': const Color(0xFFF1F5F9),
      'badgeTextColor': const Color(0xFF475569),
      'features': [
        {'text': '1 Company Profile', 'highlight': true},
        {'text': 'Manage up to 3 Clients', 'highlight': false},
        {'text': 'Create up to 5 documents / day', 'highlight': false},
        {'text': 'Single device access', 'highlight': false},
        {'text': 'Standard invoice templates', 'highlight': false},
        {'text': 'Cloud backup & cross-device sync', 'highlight': false},
        {'text': 'Standard email support', 'highlight': false},
        {
          'text': 'Supported by unobtrusive ads',
          'highlight': false,
          'isLimitation': true,
        },
      ],
    },
    {
      'name': 'Single',
      'tagline': 'Perfect for solo entrepreneurs',
      'price': 49.0,
      'badge': 'STARTER PRO',
      'accentColor': const Color(0xFF2563EB),
      'badgeBg': const Color(0xFFEFF6FF),
      'badgeTextColor': const Color(0xFF1D4ED8),
      'features': [
        {'text': '1 Company Profile', 'highlight': true},
        {'text': 'Manage up to 10 Clients', 'highlight': false},
        {'text': 'Unlimited document creation', 'highlight': true},
        {'text': 'Dual device synchronization', 'highlight': false},
        {'text': 'Full access to Premium templates', 'highlight': true},
        {'text': 'Cloud backup & cross-device sync', 'highlight': false},
        {'text': 'Standard email support', 'highlight': false},
        {
          'text': 'Minimal ads (small banners only)',
          'highlight': false,
          'isLimitation': true,
        },
      ],
    },
    {
      'name': 'Professional',
      'tagline': 'Best for expanding businesses & teams',
      'price': 99.0,
      'badge': 'MOST POPULAR',
      'accentColor': const Color(0xFF4F46E5),
      'badgeBg': const Color(0xFFEEF2FF),
      'badgeTextColor': const Color(0xFF4338CA),
      'features': [
        {'text': '100% Ad-free experience', 'highlight': true},
        {'text': 'Up to 3 Company Profiles', 'highlight': true},
        {'text': 'Unlimited clients & contacts', 'highlight': true},
        {'text': 'Multi-device sync (up to 3 devices)', 'highlight': false},
        {'text': 'Unlimited document creation', 'highlight': true},
        {'text': 'All Premium templates & customizations', 'highlight': false},
        {'text': 'Comprehensive financial analytics', 'highlight': true},
        {'text': 'Priority WhatsApp & Email support', 'highlight': true},
        {'text': 'Automatic cloud backup & instant sync', 'highlight': false},
      ],
    },
    {
      'name': 'Gold',
      'tagline': 'Complete power for growing enterprises',
      'price': 149.0,
      'badge': 'BEST VALUE',
      'accentColor': const Color(0xFFD97706),
      'badgeBg': const Color(0xFFFFFBEB),
      'badgeTextColor': const Color(0xFFB45309),
      'features': [
        {'text': '100% Ad-free experience', 'highlight': true},
        {'text': 'Up to 10 Company Profiles', 'highlight': true},
        {'text': 'Unlimited clients & contacts', 'highlight': true},
        {'text': 'Unlimited multi-device synchronization', 'highlight': true},
        {'text': 'Unlimited document creation', 'highlight': true},
        {'text': 'All Premium templates & customizations', 'highlight': false},
        {'text': 'Comprehensive financial analytics', 'highlight': true},
        {'text': 'VIP Priority Call, WhatsApp & Email', 'highlight': true},
        {'text': 'Automatic cloud backup & instant sync', 'highlight': false},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final selectedPlan = _plans[_selectedPlanIndex];
    final isFreePlan = _selectedPlanIndex == 0;
    final accentColor = selectedPlan['accentColor'] as Color;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Choose Your Plan',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Text(
              'Scale Your Business With invoz',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),

            // const SizedBox(height: 6),
            // const Text(
            //   'Select a plan tailored to your volume. Upgrade or switch whenever you need.',
            //   textAlign: TextAlign.center,
            //   style: TextStyle(
            //     fontSize: 13,
            //     color: AppColors.textSecondary,
            //     height: 1.4,
            //   ),
            // ),
            //   ],
            // ),
            // ),
            const SizedBox(height: 20),

            // Plan Cards Carousel
            SizedBox(
              height: 480,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _plans.length,
                onPageChanged: (index) {
                  setState(() {
                    _selectedPlanIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  final plan = _plans[index];
                  final isSelected = _selectedPlanIndex == index;
                  final planAccent = plan['accentColor'] as Color;
                  final badge = plan['badge'] as String?;
                  final badgeBg = plan['badgeBg'] as Color;
                  final badgeTextColor = plan['badgeTextColor'] as Color;
                  final features =
                      plan['features'] as List<Map<String, dynamic>>;

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    margin: EdgeInsets.only(
                      right: 12,
                      left: index == 0 ? 4 : 4,
                      top: isSelected ? 4 : 18,
                      bottom: isSelected ? 4 : 18,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected
                            ? planAccent
                            : (isDark ? AppColors.darkBorder : AppColors.border),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? planAccent.withValues(alpha: 0.18)
                              : Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                          blurRadius: isSelected ? 22 : 10,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(22.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top row: Plan name + Badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                plan['name'] as String,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: planAccent,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              if (badge != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: badgeBg,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: badgeTextColor.withValues(
                                        alpha: 0.25,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    badge,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: badgeTextColor,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            plan['tagline'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Pricing display
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                (plan['price'] as double) == 0.0
                                    ? 'Free'
                                    : '₹${(plan['price'] as double).toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                  letterSpacing: -1,
                                ),
                              ),
                              if ((plan['price'] as double) > 0.0)
                                Text(
                                  ' / month',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Divider(
                            height: 1,
                            color: isDark ? AppColors.darkBorder : AppColors.border,
                          ),
                          const SizedBox(height: 14),

                          // Feature list
                          Expanded(
                            child: ListView.separated(
                              physics: const BouncingScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: features.length,
                              separatorBuilder: (context, _) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, fIdx) {
                                final feature = features[fIdx];
                                final isLimitation =
                                    feature['isLimitation'] == true;
                                final isHighlight =
                                    feature['highlight'] == true;

                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: isLimitation
                                            ? (isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade100)
                                            : planAccent.withValues(
                                                alpha: 0.12,
                                              ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        isLimitation
                                            ? Icons.remove
                                            : Icons.check,
                                        size: 13,
                                        color: isLimitation
                                            ? (isDark ? AppColors.darkTextMuted : Colors.grey.shade600)
                                            : planAccent,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        feature['text'] as String,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: isHighlight
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                          color: isLimitation
                                              ? (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary)
                                              : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                                          height: 1.25,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 14),

            // Carousel dots indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_plans.length, (dotIdx) {
                final isSelected = _selectedPlanIndex == dotIdx;
                final planColor = _plans[dotIdx]['accentColor'] as Color;

                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      dotIdx,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isSelected ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isSelected ? planColor : AppColors.borderStrong,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 20),

            // Action CTA Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: isFreePlan
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CheckoutScreen(
                                planName: selectedPlan['name'] as String,
                                monthlyPrice: selectedPlan['price'] as double,
                              ),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.surfaceVariant,
                    disabledForegroundColor: AppColors.textMuted,
                    elevation: isFreePlan ? 0 : 4,
                    shadowColor: accentColor.withValues(alpha: 0.35),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isFreePlan
                            ? 'Your Current Free Plan'
                            : 'Continue with ${selectedPlan['name']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (!isFreePlan) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Support & Assistance Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.support_agent_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Questions about our plans? We\'re here to help.',
                          style: TextStyle(
                            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _makePhoneCall('+918441061235'),
                            icon: const Icon(
                              Icons.phone_outlined,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            label: Text(
                              '+91 8441061235',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _sendEmail('support@invoz.app'),
                            icon: const Icon(
                              Icons.mail_outline_rounded,
                              size: 14,
                              color: Color(0xFF0D9488),
                            ),
                            label: Text(
                              'Email Support',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
            const Text(
              'Secure 256-bit encryption • Cancel anytime • Instant activation',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
