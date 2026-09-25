import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../subscriptions/bloc/subscription_bloc.dart';
import '../data/subscription_repository.dart';
import '../domain/subscription_plan_model.dart';
import 'subscription_screen.dart';

class PlanInfoScreen extends StatefulWidget {
  const PlanInfoScreen({super.key});

  @override
  State<PlanInfoScreen> createState() => _PlanInfoScreenState();
}

class _PlanInfoScreenState extends State<PlanInfoScreen> {
  final SubscriptionRepository _repository = SubscriptionRepository();
  bool _isLoading = false;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _textPrimary =>
      _isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
  Color get _textSecondary =>
      _isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
  Color get _surfaceColor => _isDark ? AppColors.darkSurface : Colors.white;
  Color get _borderColor =>
      _isDark ? AppColors.darkBorder : AppColors.border.withValues(alpha: 0.5);

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleToggleAutoRenew(SubscriptionPlanModel plan) async {
    setState(() => _isLoading = true);
    try {
      final newValue = !plan.autoRenew;
      await _repository.toggleAutoRenew(newValue);
      if (mounted) {
        context.read<SubscriptionBloc>().add(
          const CheckSubscriptionStatusEvent(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newValue ? 'Auto-Renewal enabled' : 'Auto-Renewal disabled',
            ),
            backgroundColor: newValue
                ? AppColors.statusPaidText
                : AppColors.textSecondary,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleCancelSubscription(SubscriptionPlanModel plan) async {
    final confirm = await ConfirmDialog.show(
      context,
      title: 'Cancel Subscription',
      message:
          'Are you sure you want to cancel your ${plan.planName} subscription? You will continue to have access until your validity expires.',
      confirmLabel: 'Cancel Plan',
      isDestructive: true,
    );

    if (confirm && mounted) {
      setState(() => _isLoading = true);
      try {
        await _repository.cancelPlan();
        if (mounted) {
          context.read<SubscriptionBloc>().add(
            const CheckSubscriptionStatusEvent(),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Subscription cancelled successfully'),
              backgroundColor: AppColors.statusOverdueText,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDark ? AppColors.darkCanvas : AppColors.canvas,
      appBar: AppBar(
        title: Text(
          'Plan Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: _isDark ? AppColors.darkSurface : Colors.white,
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
              );
            },
            icon: Icon(Icons.swap_horiz_rounded, size: 18),
            label: Text('All Plans'),
          ),
        ],
      ),
      body: StreamBuilder<SubscriptionPlanModel>(
        stream: _repository.currentPlanStream(),
        builder: (context, snapshot) {
          final plan = snapshot.data ?? SubscriptionPlanModel.defaultFree();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Hero Active Plan Card
                _buildActivePlanCard(plan),
                SizedBox(height: 16),

                // 2. Payment & Pricing Breakdown
                _buildPaymentBreakdownCard(plan),
                SizedBox(height: 16),

                // 3. Transaction & Reference Info
                _buildTransactionInfoCard(plan),
                SizedBox(height: 20),

                // 4. Upgrade / Downgrade Actions
                _buildActionButtons(plan),
                SizedBox(height: 24),

                // 5. Firestore Synced Plan History
                _buildPlanHistorySection(),
                SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActivePlanCard(SubscriptionPlanModel plan) {
    final isFree = plan.isFree;
    final isCancelled = plan.status.toLowerCase() == 'cancelled';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isFree
              ? [const Color(0xFF334155), const Color(0xFF1E293B)]
              : [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isFree ? Colors.black : AppColors.primary).withValues(
              alpha: 0.25,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFree
                          ? Icons.storefront_outlined
                          : Icons.workspace_premium_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    '${plan.planName} Plan',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isCancelled
                      ? Colors.orange.withValues(alpha: 0.9)
                      : (isFree
                            ? Colors.white.withValues(alpha: 0.2)
                            : AppColors.premiumGold),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isCancelled ? 'CANCELLED' : (isFree ? 'FREE TIER' : 'ACTIVE'),
                  style: TextStyle(
                    color: isFree || isCancelled ? Colors.white : Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Price & Duration
          Text(
            isFree
                ? '₹0 / Lifetime'
                : '₹${plan.finalAmount.toStringAsFixed(0)} / ${plan.durationMonths} ${plan.durationMonths == 1 ? 'Month' : 'Months'}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 4),

          // Validity Subtitle
          Text(
            isFree
                ? 'Standard offline invoicing features included forever.'
                : (plan.expiryDate != null
                      ? 'Valid until ${DateFormat('MMMM d, yyyy').format(plan.expiryDate!)} (${plan.daysRemaining} days remaining)'
                      : 'Active Subscription'),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
            ),
          ),
          SizedBox(height: 16),

          // Auto-renewal switch row
          if (!isFree)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        plan.autoRenew
                            ? Icons.autorenew_rounded
                            : Icons.pause_circle_outline_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Text(
                        plan.autoRenew
                            ? 'Auto-Renewal: Enabled'
                            : 'Auto-Renewal: Disabled',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: _isLoading
                        ? null
                        : () => _handleToggleAutoRenew(plan),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Text(
                        plan.autoRenew ? 'Disable' : 'Enable',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
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

  Widget _buildPaymentBreakdownCard(SubscriptionPlanModel plan) {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 20,
                color: context.primaryTextColor,
              ),
              SizedBox(width: 8),
              Text(
                'Payment Summary',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          _buildSummaryRow(
            'Plan Base Price',
            '₹${(plan.price * plan.durationMonths).toStringAsFixed(2)}',
          ),
          _buildSummaryRow(
            'Duration',
            '${plan.durationMonths} ${plan.durationMonths == 1 ? 'Month' : 'Months'}',
          ),
          if (plan.discountAmount > 0)
            _buildSummaryRow(
              'Discount Applied (${plan.discountPercentage.toInt()}%)',
              '-₹${plan.discountAmount.toStringAsFixed(2)}',
              valueColor: Colors.green,
            ),
          if (plan.gstAmount > 0)
            _buildSummaryRow(
              'Taxes & GST (18%)',
              '+₹${plan.gstAmount.toStringAsFixed(2)}',
            ),
          const Divider(height: 20),
          _buildSummaryRow(
            'Net Amount Paid',
            '₹${plan.finalAmount.toStringAsFixed(2)}',
            isBold: true,
          ),
          _buildSummaryRow('Payment Method', plan.paymentMethod),
        ],
      ),
    );
  }

  Widget _buildTransactionInfoCard(SubscriptionPlanModel plan) {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.verified_outlined,
                size: 20,
                color: context.primaryTextColor,
              ),
              SizedBox(width: 8),
              Text(
                'Transaction Details',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 14),

          // Transaction ID with Copy
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transaction ID',
                style: TextStyle(fontSize: 13, color: _textSecondary),
              ),
              Row(
                children: [
                  Text(
                    plan.transactionId,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _textPrimary,
                    ),
                  ),
                  SizedBox(width: 4),
                  InkWell(
                    onTap: () =>
                        _copyToClipboard(plan.transactionId, 'Transaction ID'),
                    child: Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.copy_rounded,
                        size: 15,
                        color: context.primaryTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10),

          // Activation Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Activation Date',
                style: TextStyle(fontSize: 13, color: _textSecondary),
              ),
              Text(
                DateFormat('MMM d, yyyy - h:mm a').format(plan.startDate),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),

          // Payment Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment Status',
                style: TextStyle(fontSize: 13, color: _textSecondary),
              ),
              Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 14,
                    color: Colors.green,
                  ),
                  SizedBox(width: 4),
                  Text(
                    plan.status,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(SubscriptionPlanModel plan) {
    return Column(
      children: [
        AppButton(
          label: plan.isFree ? 'Upgrade to Premium' : 'Change / Upgrade Plan',
          icon: Icons.workspace_premium_rounded,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
            );
          },
        ),
        if (!plan.isFree && plan.status.toLowerCase() != 'cancelled') ...[
          SizedBox(height: 10),
          AppButton(
            label: 'Cancel Subscription',
            variant: AppButtonVariant.danger,
            icon: Icons.cancel_outlined,
            isLoading: _isLoading,
            onPressed: () => _handleCancelSubscription(plan),
          ),
        ],
      ],
    );
  }

  Widget _buildPlanHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.history_rounded,
              size: 20,
              color: context.primaryTextColor,
            ),
            SizedBox(width: 8),
            Text(
              'Plan & Billing History',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Text(
          'Transactions stored and synced with your cloud account',
          style: TextStyle(fontSize: 12, color: _textSecondary),
        ),
        SizedBox(height: 12),

        StreamBuilder<List<SubscriptionPlanModel>>(
          stream: _repository.planHistoryStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }

            final history = snapshot.data ?? [];

            if (history.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _surfaceColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _borderColor),
                ),
                child: Center(
                  child: Text(
                    'No transaction history available yet.',
                    style: TextStyle(color: _textSecondary, fontSize: 13),
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: history.length,
              separatorBuilder: (_, _) => SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = history[index];
                return _buildHistoryItem(item);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildHistoryItem(SubscriptionPlanModel item) {
    final dateStr = DateFormat('MMM d, yyyy').format(item.createdAt);
    final isCancelled = item.status.toLowerCase() == 'cancelled';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${item.planName} Plan (${item.durationMonths} Mo)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: _textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isCancelled
                      ? Colors.red.withValues(alpha: 0.1)
                      : Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isCancelled ? Colors.red : Colors.green,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Date: $dateStr',
                style: TextStyle(fontSize: 12, color: _textSecondary),
              ),
              Text(
                '₹${item.finalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'TXN: ${item.transactionId}',
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'monospace',
                    color: _textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              InkWell(
                onTap: () =>
                    _copyToClipboard(item.transactionId, 'Transaction ID'),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Icon(
                    Icons.copy_rounded,
                    size: 13,
                    color: context.primaryTextColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? _textPrimary : _textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? _textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
