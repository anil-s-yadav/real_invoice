import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String _currency = 'INR';

  final Map<String, List<Map<String, dynamic>>> _plans = {
    'INR': [
      {
        'name': 'Starter',
        'price': '₹299',
        'period': '/mo',
        'subtitle': 'Perfect for freelancers starting out.',
        'tag': null,
        'color': AppColors.textSecondary,
        'btnText': 'Start Basic',
        'features': ['Up to 20 Invoices/mo', '1 Business Profile', 'Standard Templates', 'Export to PDF'],
        'missing': ['No Cloud Sync', 'Contains Ads'],
      },
      {
        'name': 'Pro',
        'price': '₹1,999',
        'period': '/yr',
        'subtitle': 'Everything you need to grow your business.',
        'tag': 'MOST POPULAR',
        'color': AppColors.primary,
        'btnText': 'Get Pro Now',
        'features': ['Unlimited Invoices', 'Up to 5 Businesses', '50+ Premium Templates', 'Cloud Sync & Backup', 'No Ads'],
        'missing': ['Priority Support'],
      },
      {
        'name': 'Lifetime',
        'price': '₹5,999',
        'period': ' once',
        'subtitle': 'Pay once, enjoy RedInvoice forever.',
        'tag': 'BEST VALUE',
        'color': AppColors.premiumGold,
        'btnText': 'Go Lifetime',
        'features': ['Unlimited Everything', 'Unlimited Businesses', 'All Premium Templates', 'Cloud Sync & Backup', 'Zero Ads Forever', '24/7 Priority Support'],
        'missing': [],
      },
    ],
    'USD': [
      {
        'name': 'Starter',
        'price': '\$4.99',
        'period': '/mo',
        'subtitle': 'Perfect for freelancers starting out.',
        'tag': null,
        'color': AppColors.textSecondary,
        'btnText': 'Start Basic',
        'features': ['Up to 20 Invoices/mo', '1 Business Profile', 'Standard Templates', 'Export to PDF'],
        'missing': ['No Cloud Sync', 'Contains Ads'],
      },
      {
        'name': 'Pro',
        'price': '\$39.99',
        'period': '/yr',
        'subtitle': 'Everything you need to grow your business.',
        'tag': 'MOST POPULAR',
        'color': AppColors.primary,
        'btnText': 'Get Pro Now',
        'features': ['Unlimited Invoices', 'Up to 5 Businesses', '50+ Premium Templates', 'Cloud Sync & Backup', 'No Ads'],
        'missing': ['Priority Support'],
      },
      {
        'name': 'Lifetime',
        'price': '\$119.99',
        'period': ' once',
        'subtitle': 'Pay once, enjoy RedInvoice forever.',
        'tag': 'BEST VALUE',
        'color': AppColors.premiumGold,
        'btnText': 'Go Lifetime',
        'features': ['Unlimited Everything', 'Unlimited Businesses', 'All Premium Templates', 'Cloud Sync & Backup', 'Zero Ads Forever', '24/7 Priority Support'],
        'missing': [],
      },
    ],
    'EUR': [
      {
        'name': 'Starter',
        'price': '€4.99',
        'period': '/mo',
        'subtitle': 'Perfect for freelancers starting out.',
        'tag': null,
        'color': AppColors.textSecondary,
        'btnText': 'Start Basic',
        'features': ['Up to 20 Invoices/mo', '1 Business Profile', 'Standard Templates', 'Export to PDF'],
        'missing': ['No Cloud Sync', 'Contains Ads'],
      },
      {
        'name': 'Pro',
        'price': '€39.99',
        'period': '/yr',
        'subtitle': 'Everything you need to grow your business.',
        'tag': 'MOST POPULAR',
        'color': AppColors.primary,
        'btnText': 'Get Pro Now',
        'features': ['Unlimited Invoices', 'Up to 5 Businesses', '50+ Premium Templates', 'Cloud Sync & Backup', 'No Ads'],
        'missing': ['Priority Support'],
      },
      {
        'name': 'Lifetime',
        'price': '€119.99',
        'period': ' once',
        'subtitle': 'Pay once, enjoy RedInvoice forever.',
        'tag': 'BEST VALUE',
        'color': AppColors.premiumGold,
        'btnText': 'Go Lifetime',
        'features': ['Unlimited Everything', 'Unlimited Businesses', 'All Premium Templates', 'Cloud Sync & Backup', 'Zero Ads Forever', '24/7 Priority Support'],
        'missing': [],
      },
    ],
  };

  void _buyPlan(String planName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Activated $planName Plan successfully!"),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final currentPlans = _plans[_currency]!;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Upgrade to Premium',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.currency_exchange, color: AppColors.textPrimary),
            tooltip: 'Change Currency',
            color: Colors.white,
            onSelected: (val) => setState(() => _currency = val),
            itemBuilder: (context) => _plans.keys
                .map((c) => PopupMenuItem(
                      value: c,
                      child: Text(c, style: const TextStyle(color: AppColors.textPrimary)),
                    ))
                .toList(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          // Trust Badges / Header
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Join 10,000+ businesses growing with RedInvoice Pro.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Cards
          Expanded(
            child: PageView.builder(
              controller: PageController(viewportFraction: 0.85, initialPage: 1),
              itemCount: currentPlans.length,
              itemBuilder: (context, index) {
                final plan = currentPlans[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
                  child: _buildPlanCard(plan),
                );
              },
            ),
          ),
          
          // Bottom Trust Footer
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, color: AppColors.textMuted, size: 16),
                const SizedBox(width: 6),
                const Text(
                  'Bank-Level 256-bit Security',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
                const SizedBox(width: 16),
                Container(width: 1, height: 12, color: AppColors.border),
                const SizedBox(width: 16),
                const Icon(Icons.event_available, color: AppColors.textMuted, size: 16),
                const SizedBox(width: 6),
                const Text(
                  'Cancel Anytime',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    final String name = plan['name'];
    final String price = plan['price'];
    final String period = plan['period'];
    final String subtitle = plan['subtitle'];
    final String? tag = plan['tag'];
    final Color color = plan['color'];
    final String btnText = plan['btnText'];
    final List<String> features = List<String>.from(plan['features'] as List);
    final List<String> missing = List<String>.from(plan['missing'] as List);

    final bool isGold = name == 'Lifetime';
    final bool isPopular = tag != null;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isPopular ? color.withValues(alpha: 0.8) : AppColors.border,
              width: isPopular ? 2 : 1,
            ),
            boxShadow: [
              if (isPopular)
                BoxShadow(
                  color: color.withValues(alpha: 0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12), // Space for top badge
                  
                  // Plan Name
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: color,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Subtitle
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: -1,
                        ),
                      ),
                      Text(
                        period,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // CTA Button
                  ElevatedButton(
                    onPressed: () => _buyPlan(name),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: isGold ? Colors.black : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: isPopular ? 8 : 0,
                      shadowColor: color.withValues(alpha: 0.5),
                    ),
                    child: Text(
                      btnText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Features Header
                  const Text(
                    'WHAT\'S INCLUDED',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textMuted,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Feature Lists
                  ...features.map((f) => _buildCheckItem(f, true, color)),
                  ...missing.map((m) => _buildCheckItem(m, false, AppColors.borderStrong)),
                ],
              ),
            ),
          ),
        ),
        if (isPopular)
          Positioned(
            top: -12,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: isGold ? Colors.black : Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCheckItem(String text, bool included, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: included ? iconColor.withValues(alpha: 0.15) : AppColors.canvas,
              shape: BoxShape.circle,
            ),
            child: Icon(
              included ? Icons.check : Icons.close,
              color: included ? iconColor : AppColors.textMuted,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: included ? AppColors.textPrimary : AppColors.textMuted,
                height: 1.3,
                decoration: included ? TextDecoration.none : TextDecoration.lineThrough,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
