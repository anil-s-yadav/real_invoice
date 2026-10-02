import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../data/subscription_repository.dart';
import '../domain/subscription_plan_model.dart';

class CheckoutScreen extends StatefulWidget {
  final String planName;
  final double monthlyPrice;
  final bool hasWelcomeOffer;

  const CheckoutScreen({
    super.key,
    required this.planName,
    required this.monthlyPrice,
    this.hasWelcomeOffer = false,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final List<int> _durations = [1, 6, 12];
  late int _selectedDuration;
  final double _gstRate = 0.18; // 18% GST
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _selectedDuration = 12; // Default to 1 Year plan for maximum value
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final double baseTotal = widget.monthlyPrice * _selectedDuration;
    final double invozPerc = _getInvozDiscountPercentage(_selectedDuration);
    final double invozDiscount = baseTotal * invozPerc;
    double welcomeDiscount = 0.0;
    if (widget.hasWelcomeOffer) {
      if (_selectedDuration == 12) {
        welcomeDiscount = baseTotal * 0.50;
      } else if (_selectedDuration == 1) {
        welcomeDiscount = baseTotal;
      }
    }
    double subtotal = baseTotal - invozDiscount - welcomeDiscount;
    if (subtotal < 0) subtotal = 0;
    final double gstAmount = subtotal * _gstRate;
    final double totalPayable = subtotal + gstAmount;

    int maxCompanies = 1;
    int maxClients = 3;
    int maxDocs = 5;
    int maxDevices = 1;
    bool isAdFree = false;
    bool hasPremium = false;
    bool hasAnalytics = false;

    final String pName = widget.planName.toLowerCase();
    if (pName == 'single') {
      maxCompanies = 1;
      maxClients = 10;
      maxDocs = -1; // unlimited
      maxDevices = 2;
      hasPremium = true;
      isAdFree = true;
    } else if (pName.contains('pro')) {
      maxCompanies = 3;
      maxClients = -1;
      maxDocs = -1;
      maxDevices = 3;
      isAdFree = true;
      hasPremium = true;
      hasAnalytics = true;
    } else if (pName == 'gold') {
      maxCompanies = 10;
      maxClients = -1;
      maxDocs = -1;
      maxDevices = -1;
      isAdFree = true;
      hasPremium = true;
      hasAnalytics = true;
    }

    final repo = SubscriptionRepository();
    final newPlan = SubscriptionPlanModel(
      id: '${widget.planName.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}',
      planName: widget.planName,
      price: baseTotal,
      durationMonths: _selectedDuration,
      discountPercentage: (invozDiscount + welcomeDiscount) / baseTotal,
      discountAmount: invozDiscount + welcomeDiscount,
      gstAmount: gstAmount,
      finalAmount: totalPayable,
      status: 'Active',
      transactionId:
          response.paymentId ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      orderId: response.orderId,
      paymentSignature: response.signature,
      paymentMethod: 'Razorpay',
      startDate: DateTime.now(),
      expiryDate: DateTime.now().add(Duration(days: 30 * _selectedDuration)),
      autoRenew: true,
      createdAt: DateTime.now(),
      maxCompaniesAllowed: maxCompanies,
      maxClientsAllowed: maxClients,
      maxItemsAllowed: maxClients,
      maxDocumentsPerDay: maxDocs,
      maxDevicesAllowed: maxDevices,
      isAdFree: isAdFree,
      hasPremiumTemplates: hasPremium,
      hasAnalytics: hasAnalytics,
    );
    await repo.saveOrUpgradePlan(newPlan);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Subscription upgraded successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.of(context).pop();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External Wallet Selected: ${response.walletName}'),
      ),
    );
  }

  double _getInvozDiscountPercentage(int months) {
    if (widget.hasWelcomeOffer && months == 12) {
      return 0.10;
    }
    if (months == 6) return 0.05;
    if (months == 12) return 0.20;
    return 0.0;
  }

  Future<void> _openTermsUrl() async {
    final url = Uri.parse('https://invoz.app/terms');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _showTermsDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.verified_outlined,
              color: AppColors.primary,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              'Terms & Conditions',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'By completing your purchase, you agree to the following terms:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              _buildTermBullet(
                isDark,
                'Subscription & Renewal',
                'Subscriptions renew automatically at the end of each billing duration unless cancelled prior.',
              ),
              const SizedBox(height: 10),
              _buildTermBullet(
                isDark,
                'Promotions & Discounts',
                'Promotional welcome discounts apply to eligible first-time purchases for the chosen initial duration.',
              ),
              const SizedBox(height: 10),
              _buildTermBullet(
                isDark,
                'Taxes & GST',
                'An 18% Goods & Services Tax (GST) is calculated and levied as mandated under applicable tax regulations.',
              ),
              const SizedBox(height: 10),
              _buildTermBullet(
                isDark,
                'Cancellation & Refunds',
                'You can cancel your subscription anytime. Documents created previously remain accessible forever.',
              ),
              const SizedBox(height: 10),
              _buildTermBullet(
                isDark,
                'Data Security',
                'Your business records, clients, and invoice files remain encrypted and strictly confidential.',
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _openTermsUrl,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.open_in_new_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Read full Terms & Conditions online',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Got it',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermBullet(bool isDark, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Icon(Icons.circle, size: 6, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: description,
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _triggerPayment(double totalPayable) {
    final options = {
      'key': 'rzp_test_ThkLyPi706leO9',
      'amount': (totalPayable * 100).toInt(),
      'name': 'Invoz App',
      'description': '${widget.planName} - $_selectedDuration Months Plan',
      'timeout': 120,
      'prefill': {'contact': '', 'email': ''},
      'theme': {'color': '#4F46E5'},
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final double baseTotal = widget.monthlyPrice * _selectedDuration;
    final double invozPerc = _getInvozDiscountPercentage(_selectedDuration);
    final double invozDiscount = baseTotal * invozPerc;

    double welcomeDiscount = 0.0;
    if (widget.hasWelcomeOffer) {
      if (_selectedDuration == 12) {
        welcomeDiscount = baseTotal * 0.50;
      } else if (_selectedDuration == 1) {
        welcomeDiscount = baseTotal;
      }
    }

    final double totalDiscount = invozDiscount + welcomeDiscount;
    double subtotal = baseTotal - totalDiscount;
    if (subtotal < 0) subtotal = 0;
    final double gstAmount = subtotal * _gstRate;
    final double totalPayable = subtotal + gstAmount;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkCanvas : const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Text(
              'Secure Checkout',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.lock_rounded, size: 16, color: Colors.green),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => _showTermsDialog(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14),
            ),
            child: Text(
              'Terms',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: isDark ? AppColors.primaryLight : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HERO PLAN CARD
            _buildHeroPlanCard(isDark),
            const SizedBox(height: 24),

            // 2. DURATION SELECTOR TITLE & OPTIONS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Choose Billing Cycle',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : const Color(0xFF0F172A),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Cancel Anytime',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Dynamic Duration Cards
            ..._durations.map(
              (duration) => _buildDurationOptionCard(duration, isDark),
            ),

            // Welcome Offer banner notification if applied
            if (widget.hasWelcomeOffer &&
                (_selectedDuration == 12 || _selectedDuration == 1)) ...[
              const SizedBox(height: 4),
              _buildWelcomeOfferBanner(),
            ],

            const SizedBox(height: 24),

            // 3. PAYMENT & ORDER BREAKDOWN
            Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),
            _buildOrderSummaryCard(
              isDark: isDark,
              baseTotal: baseTotal,
              invozDiscount: invozDiscount,
              welcomeDiscount: welcomeDiscount,
              totalDiscount: totalDiscount,
              subtotal: subtotal,
              gstAmount: gstAmount,
              totalPayable: totalPayable,
            ),

            const SizedBox(height: 24),

            // 4. MAIN ACTION BUTTON
            _buildCheckoutCTAButton(totalPayable),

            const SizedBox(height: 24),

            // 5. PAYMENT METHODS SUPPORTED (UPI, Cards, NetBanking)
            _buildPaymentMethodsRow(isDark),

            const SizedBox(height: 20),

            // 6. TRUST & SAFETY BADGES
            _buildModernTrustBadges(isDark),
          ],
        ),
      ),
    );
  }

  // --- COMPONENT: HERO PLAN CARD ---
  Widget _buildHeroPlanCard(bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4F46E5), // Indigo
            Color(0xFF3730A3), // Deep Indigo
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background decorative glow circle
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        color: Colors.amberAccent,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.planName} Plan',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'All Premium Features Unlocked',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '₹${widget.monthlyPrice.toStringAsFixed(0)}/mo',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- COMPONENT: DURATION OPTION CARD ---
  Widget _buildDurationOptionCard(int duration, bool isDark) {
    final isSelected = _selectedDuration == duration;
    String title;
    String subtitle;
    String? badgeText;
    Color badgeColor = Colors.green;

    if (duration == 1) {
      title = '1 Month';
      subtitle = 'Billed monthly';
      if (widget.hasWelcomeOffer) {
        badgeText = '100% FREE';
        badgeColor = const Color(0xFF10B981);
      }
    } else if (duration == 6) {
      title = '6 Months';
      subtitle =
          '₹${(widget.monthlyPrice * 0.95).toStringAsFixed(0)}/mo • Billed bi-annually';
      badgeText = 'SAVE 5%';
      badgeColor = const Color(0xFF059669);
    } else {
      title = '1 Year';
      subtitle =
          '₹${(widget.monthlyPrice * (widget.hasWelcomeOffer ? 0.40 : 0.80)).toStringAsFixed(0)}/mo • Best Value';
      badgeText = widget.hasWelcomeOffer ? 'SAVE 60%' : 'SAVE 20%';
      badgeColor = const Color(0xFFD97706); // Amber/Gold badge
    }

    final double rawPrice = widget.monthlyPrice * duration;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedDuration = duration;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.06)
                : (isDark ? AppColors.darkSurface : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0)),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              // Custom Animated Checkbox Circle
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark
                              ? Colors.grey[600]!
                              : const Color(0xFFCBD5E1)),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),

              // Title, Subtitle, and Badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        if (badgeText != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: badgeColor,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badgeText,
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),

              // Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${rawPrice.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : const Color(0xFF0F172A),
                    ),
                  ),
                  if (isSelected && duration == 12)
                    const Text(
                      'Billed Annually',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- COMPONENT: WELCOME OFFER APPLIED BANNER ---
  Widget _buildWelcomeOfferBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5), // Light mint green
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFA7F3D0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.celebration_rounded,
              color: Colors.white,
              size: 14,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _selectedDuration == 12
                  ? 'Welcome Coupon Applied: Extra 50% discount on 1-Year Plan!'
                  : 'Welcome Coupon Applied: 100% FREE on 1-Month Plan!',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF065F46),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- COMPONENT: ORDER SUMMARY CARD ---
  Widget _buildOrderSummaryCard({
    required bool isDark,
    required double baseTotal,
    required double invozDiscount,
    required double welcomeDiscount,
    required double totalDiscount,
    required double subtotal,
    required double gstAmount,
    required double totalPayable,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
        ),
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
          _buildSummaryRow(
            'Base Amount ($_selectedDuration Months)',
            '₹${baseTotal.toStringAsFixed(2)}',
            isDark: isDark,
          ),
          if (invozDiscount > 0)
            _buildSummaryRow(
              'Plan Discount',
              '- ₹${invozDiscount.toStringAsFixed(2)}',
              color: Colors.green,
              isDark: isDark,
            ),
          if (welcomeDiscount > 0)
            _buildSummaryRow(
              'Welcome Promotional Offer',
              '- ₹${welcomeDiscount.toStringAsFixed(2)}',
              color: Colors.green,
              isDark: isDark,
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          _buildSummaryRow(
            'Subtotal',
            '₹${subtotal.toStringAsFixed(2)}',
            isBold: true,
            isDark: isDark,
          ),
          _buildSummaryRow(
            'GST (18% Mandated)',
            '+ ₹${gstAmount.toStringAsFixed(2)}',
            color: isDark
                ? AppColors.darkTextSecondary
                : const Color(0xFF64748B),
            isDark: isDark,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Payable',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Includes all taxes',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
              Text(
                '₹${totalPayable.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          if (totalDiscount > 0) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.stars_rounded,
                    size: 16,
                    color: Color(0xFF059669),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Total savings on this order: ₹${totalDiscount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF059669),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    Color? color,
    bool isBold = false,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isBold
                  ? (isDark
                        ? AppColors.darkTextPrimary
                        : const Color(0xFF0F172A))
                  : (isDark
                        ? AppColors.darkTextSecondary
                        : const Color(0xFF64748B)),
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color:
                  color ??
                  (isBold
                      ? (isDark
                            ? AppColors.darkTextPrimary
                            : const Color(0xFF0F172A))
                      : (isDark
                            ? AppColors.darkTextSecondary
                            : const Color(0xFF334155))),
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // --- COMPONENT: CHECKOUT PRIMARY CTA BUTTON ---
  Widget _buildCheckoutCTAButton(double totalPayable) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => _triggerPayment(totalPayable),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_rounded, size: 20),
            const SizedBox(width: 10),
            Text(
              'Pay ₹${totalPayable.toStringAsFixed(0)} & Activate',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- COMPONENT: PAYMENT METHODS LOGOS/BADGES ---
  Widget _buildPaymentMethodsRow(bool isDark) {
    final methods = ['UPI', 'GPay', 'PhonePe', 'Cards', 'NetBanking'];
    return Column(
      children: [
        Text(
          'POWERED BY RAZORPAY • 100% SECURE',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: isDark ? Colors.grey[500] : const Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: methods.map((m) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDark
                      ? AppColors.darkBorder
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Text(
                m,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : const Color(0xFF475569),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- COMPONENT: MODERN TRUST & MOTIVATION BADGES ---
  Widget _buildModernTrustBadges(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          _buildTrustBadgeTile(
            icon: Icons.shield_rounded,
            iconColor: Colors.blueAccent,
            title: '256-Bit Bank-Grade Encryption',
            subtitle:
                'Your transactions and account data are encrypted end-to-end.',
            isDark: isDark,
          ),
          const SizedBox(height: 14),
          _buildTrustBadgeTile(
            icon: Icons.published_with_changes_rounded,
            iconColor: Colors.green,
            title: '7-Day Money-Back Guarantee',
            subtitle:
                'Try risk-free. If not completely satisfied, get a full 100% refund.',
            isDark: isDark,
          ),
          const SizedBox(height: 14),
          _buildTrustBadgeTile(
            icon: Icons.bolt_rounded,
            iconColor: Colors.amber,
            title: 'Instant Plan Activation',
            subtitle:
                'Your plan limits and premium tools are unlocked immediately upon payment.',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildTrustBadgeTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.14),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : const Color(0xFF64748B),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
