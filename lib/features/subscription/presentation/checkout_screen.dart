import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';

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
  // Available durations in months
  final List<int> _durations = [1, 6, 12];
  late int _selectedDuration;

  final double _gstRate = 0.18; // 18% GST

  @override
  void initState() {
    super.initState();
    _selectedDuration = 12; // 1 Year plan
  }

  double _getInvozDiscountPercentage(int months) {
    if (widget.hasWelcomeOffer && months == 12) {
      return 0.10; // Keep invoz discount 10% on welcome offer 1 year
    }
    if (months == 6) return 0.05; // Small 5% discount on 6 months
    if (months == 12) return 0.20; // 20% discount on 1 year
    return 0.0;
  }

  Future<void> _openTermsUrl() async {
    final url = Uri.parse('https://invoz.app/terms');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildTermItem(bool isDark, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 5),
          child: Icon(Icons.circle, size: 6, color: AppColors.primary),
        ),
        const SizedBox(width: 8),
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

  void _showTermsDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.article_outlined,
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
              _buildTermItem(
                isDark,
                'Subscription & Renewal',
                'Subscriptions renew automatically at the end of each billing duration unless cancelled prior.',
              ),
              const SizedBox(height: 10),
              _buildTermItem(
                isDark,
                'Welcome Offer & Discounts',
                'Welcome promotional discounts apply to eligible first-time purchases for the chosen initial duration.',
              ),
              const SizedBox(height: 10),
              _buildTermItem(
                isDark,
                'Taxes & GST',
                'An 18% Goods & Services Tax (GST) is calculated and levied as mandated under applicable Indian tax regulations.',
              ),
              const SizedBox(height: 10),
              _buildTermItem(
                isDark,
                'Cancellation & Refunds',
                'You can cancel your subscription anytime. Previously created invoices and documents remain accessible.',
              ),
              const SizedBox(height: 10),
              _buildTermItem(
                isDark,
                'Data Privacy',
                'Your business records, customer details, and invoice data remain encrypted and completely confidential.',
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

  @override
  Widget build(BuildContext context) {
    // Calculations based on the user rules
    double baseTotal = widget.monthlyPrice * _selectedDuration;

    double invozPerc = _getInvozDiscountPercentage(_selectedDuration);

    double invozDiscount = baseTotal * invozPerc;
    double yearlyDiscount = 0.0;

    double welcomeDiscount = 0.0;
    if (widget.hasWelcomeOffer) {
      if (_selectedDuration == 12) {
        welcomeDiscount = baseTotal * 0.50; // 50% extra discount on 1 year plan
      } else if (_selectedDuration == 1) {
        welcomeDiscount = baseTotal; // 100% discount on 1 month plan
      }
    }

    double platformFeeApplied = 0.0;

    double subtotal =
        baseTotal - invozDiscount - yearlyDiscount - welcomeDiscount;
    if (subtotal < 0) subtotal = 0; // Ensure subtotal doesn't go below 0
    double gstAmount = subtotal * _gstRate;
    double totalPayable = subtotal + gstAmount;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _showTermsDialog(context),
            icon: const Icon(Icons.article_outlined, size: 16),
            label: const Text(
              'Terms & Conds',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            style: TextButton.styleFrom(
              foregroundColor: isDark
                  ? AppColors.primaryLight
                  : AppColors.primary,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan summary (Compact)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.planName} Plan',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'All premium invoicing tools unlocked',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '₹${widget.monthlyPrice.toStringAsFixed(0)}/mo',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),
            Text(
              'Select Duration',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),

            // Duration selector (Compact)
            Column(
              children: _durations.map((duration) {
                final isSelected = _selectedDuration == duration;
                String label;
                String subLabel = '';
                String tag = '';
                if (duration == 1) {
                  label = '1 Month';
                  subLabel = 'Billed monthly';
                  if (widget.hasWelcomeOffer) tag = '100% FREE';
                } else if (duration == 6) {
                  label = '6 Months';
                  subLabel = 'Billed every 6 months';
                  tag = 'SAVE 5%';
                } else if (duration == 12) {
                  label = '1 Year';
                  subLabel = 'Billed annually';
                  if (widget.hasWelcomeOffer) {
                    tag = 'BEST VALUE - TOTAL 60% OFF';
                  } else {
                    tag = 'BEST VALUE - SAVE 20%';
                  }
                } else {
                  label = '${duration ~/ 12} Years';
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedDuration = duration;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(
                                alpha: isDark ? 0.25 : 0.05,
                              )
                            : (isDark ? AppColors.darkSurface : Colors.white),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                    ? AppColors.darkBorder
                                    : AppColors.border),
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Radio<int>(
                            value: duration,
                            groupValue: _selectedDuration,
                            onChanged: (val) {
                              setState(() {
                                _selectedDuration = val!;
                              });
                            },
                            activeColor: AppColors.primary,
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      label,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w600,
                                        color: isDark
                                            ? AppColors.darkTextPrimary
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                    if (tag.isNotEmpty) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.primary
                                              : Colors.green,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          tag,
                                          style: const TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  subLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '₹${(widget.monthlyPrice * duration).toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),
            if (widget.hasWelcomeOffer &&
                (_selectedDuration == 12 || _selectedDuration == 1))
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedDuration == 12
                            ? 'Welcome Offer Applied: 50% extra off 1-Year Plan!'
                            : 'Welcome Offer Applied: 100% free 1-Month Plan!',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Text(
              'Payment Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
              ),
              child: Column(
                children: [
                  _SummaryRow(
                    'Base Amount (${_selectedDuration}m)',
                    '₹${baseTotal.toStringAsFixed(2)}',
                  ),

                  if (invozDiscount > 0)
                    _SummaryRow(
                      'invoz Discount (${(invozPerc * 100).toStringAsFixed(0)}%)',
                      '- ₹${invozDiscount.toStringAsFixed(2)}',
                      color: Colors.green,
                    ),

                  if (welcomeDiscount > 0)
                    _SummaryRow(
                      'Welcome Offer (${_selectedDuration == 12 ? "50%" : "100%"})',
                      '- ₹${welcomeDiscount.toStringAsFixed(2)}',
                      color: Colors.green,
                    ),

                  if (platformFeeApplied > 0)
                    _SummaryRow(
                      'Platform Fee',
                      '+ ₹${platformFeeApplied.toStringAsFixed(2)}',
                      color: Colors.orange,
                    ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1),
                  ),
                  _SummaryRow(
                    'Subtotal',
                    '₹${subtotal.toStringAsFixed(2)}',
                    isBold: true,
                  ),
                  _SummaryRow(
                    'GST (18%)',
                    '+ ₹${gstAmount.toStringAsFixed(2)}',
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Payable',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '₹${totalPayable.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: isDark
                              ? AppColors.primaryLight
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (invozDiscount + yearlyDiscount + welcomeDiscount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.celebration_rounded,
                        color: Colors.green,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Awesome! You are saving ₹${(invozDiscount + yearlyDiscount + welcomeDiscount).toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement payment gateway
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment Gateway Integration Pending'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.lock_outline_rounded, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Secure Checkout',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final bool isBold;

  const _SummaryRow(this.label, this.value, {this.color, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: isBold
                  ? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)
                  : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary),
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color:
                  color ??
                  (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
