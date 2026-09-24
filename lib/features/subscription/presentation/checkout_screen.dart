import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CheckoutScreen extends StatefulWidget {
  final String planName;
  final double monthlyPrice;

  const CheckoutScreen({
    super.key,
    required this.planName,
    required this.monthlyPrice,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Available durations in months
  final List<int> _durations = [1, 6, 12, 24, 36, 60];
  int _selectedDuration = 12; // Default to 1 year
  
  // Exact data from excel
  final double _platformFee = 9.0; // Fixed fee for 1 month plan
  final double _gstRate = 0.18; // 18% GST

  double _getInvozDiscountPercentage(int months) {
    if (months < 12) return 0.0;
    return widget.planName == 'Single' ? 0.15 : 0.16;
  }

  double _getYearlyDiscountPercentage(int months) {
    if (months == 24) return 0.10;
    if (months == 36) return 0.12;
    if (months == 60) return 0.14;
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    // Calculations based on the user rules
    double baseTotal = widget.monthlyPrice * _selectedDuration;
    
    double invozPerc = _getInvozDiscountPercentage(_selectedDuration);
    double yearlyPerc = _getYearlyDiscountPercentage(_selectedDuration);
    
    double invozDiscount = baseTotal * invozPerc;
    double yearlyDiscount = baseTotal * yearlyPerc;
    
    double platformFeeApplied = _selectedDuration == 1 ? _platformFee : 0.0;

    double subtotal = baseTotal - invozDiscount - yearlyDiscount + platformFeeApplied;
    double gstAmount = subtotal * _gstRate;
    double totalPayable = subtotal + gstAmount;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan summary
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.planName} Plan',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Base price: ₹${widget.monthlyPrice.toStringAsFixed(0)} / month',
                    style: TextStyle(fontSize: 16, color: Colors.white.withValues(alpha: 0.8)),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            Text(
              'Select Duration',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            // Duration selector
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _durations.map((duration) {
                final isSelected = _selectedDuration == duration;
                String label;
                if (duration == 1) {
                  label = '1 Month';
                } else if (duration == 6) {
                  label = '6 Months';
                } else if (duration == 12) {
                  label = '1 Year';
                } else {
                  label = '${duration ~/ 12} Years';
                }

                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedDuration = duration;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: (MediaQuery.of(context).size.width - 52) / 2, // 2 columns
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.1)
                          : (isDark ? AppColors.darkSurface : Colors.white),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : (isDark ? AppColors.darkBorder : AppColors.border),
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? (isDark ? AppColors.primaryLight : AppColors.primary)
                              : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            if (_selectedDuration == 1)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.orange.shade900.withValues(alpha: 0.25) : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isDark ? Colors.orange.shade800 : Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: isDark ? Colors.orange.shade300 : Colors.orange.shade800, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'A platform fee of ₹${_platformFee.toStringAsFixed(0)} is applied on 1-month plans. Select a longer plan to avoid this fee and unlock huge discounts!',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.orange.shade200 : Colors.orange.shade900,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 32),
            Text(
              'Payment Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
              ),
              child: Column(
                children: [
                  _SummaryRow('Base Amount (${_selectedDuration}m)', '₹${baseTotal.toStringAsFixed(2)}'),
                  
                  if (invozDiscount > 0)
                    _SummaryRow('invoz Discount (${(invozPerc * 100).toStringAsFixed(0)}%)', '- ₹${invozDiscount.toStringAsFixed(2)}', color: Colors.green),
                    
                  if (yearlyDiscount > 0)
                    _SummaryRow('Yearly Discount (${(yearlyPerc * 100).toStringAsFixed(0)}%)', '- ₹${yearlyDiscount.toStringAsFixed(2)}', color: Colors.green),
                    
                  if (platformFeeApplied > 0)
                    _SummaryRow('Platform Fee', '+ ₹${platformFeeApplied.toStringAsFixed(2)}', color: Colors.orange),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1),
                  ),
                  _SummaryRow('Subtotal', '₹${subtotal.toStringAsFixed(2)}', isBold: true),
                  _SummaryRow('GST (18%)', '+ ₹${gstAmount.toStringAsFixed(2)}', color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
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
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '₹${totalPayable.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppColors.primaryLight : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
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
                    const SnackBar(content: Text('Payment Gateway Integration Pending')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: const Text(
                  'Proceed to Pay',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              color: color ?? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
