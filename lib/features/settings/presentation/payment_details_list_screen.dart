import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../business_profile/bloc/business_profile_bloc.dart';
import '../../business_profile/bloc/business_profile_event.dart';
import '../../business_profile/bloc/business_profile_state.dart';
import '../../business_profile/domain/business_profile_model.dart';

class PaymentDetailsListScreen extends StatefulWidget {
  const PaymentDetailsListScreen({super.key});

  @override
  State<PaymentDetailsListScreen> createState() =>
      _PaymentDetailsListScreenState();
}

class _PaymentDetailsListScreenState extends State<PaymentDetailsListScreen> {
  void _showAddPaymentSheet(BuildContext context, BusinessProfile profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _AddPaymentSheet(
        onSave: (detail) {
          final updated = profile.copyWith(
            paymentDetails: [...profile.paymentDetails, detail],
          );
          context.read<BusinessProfileBloc>().add(
            UpdateBusinessProfileEvent(updated),
          );
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _deletePayment(
    BuildContext context,
    BusinessProfile profile,
    String id,
  ) {
    final updatedList = profile.paymentDetails
        .where((e) => e.id != id)
        .toList();
    final updated = profile.copyWith(paymentDetails: updatedList);
    context.read<BusinessProfileBloc>().add(
      UpdateBusinessProfileEvent(updated),
    );
  }

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _textPrimary =>
      _isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

  Widget _buildSamplePreviewCard(
    BusinessProfile profile,
    List<PaymentDetail> details,
  ) {
    final hasDetails = details.isNotEmpty;
    final bankDetails = details.where((p) => p.type == 'Bank').toList();
    final upiDetails = details.where((p) => p.type == 'UPI').toList();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: _isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasDetails
              ? AppColors.primary.withValues(alpha: 0.3)
              : (_isDark ? AppColors.darkBorder : AppColors.border),
          width: hasDetails ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: hasDetails
                  ? AppColors.primary.withValues(alpha: _isDark ? 0.15 : 0.05)
                  : (_isDark
                      ? AppColors.darkSurfaceVariant
                      : AppColors.surfaceVariant.withValues(alpha: 0.6)),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              border: Border(
                bottom: BorderSide(
                  color: hasDetails
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : (_isDark ? AppColors.darkBorder : AppColors.border),
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      hasDetails
                          ? Icons.verified_rounded
                          : Icons.visibility_outlined,
                      size: 16,
                      color: hasDetails
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      hasDetails
                          ? 'Document Preview (Live)'
                          : 'Sample Preview (On Documents)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: hasDetails
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: hasDetails
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : (_isDark ? AppColors.darkSurfaceVariant : Colors.white),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: hasDetails
                          ? AppColors.primary.withValues(alpha: 0.2)
                          : (_isDark ? AppColors.darkBorder : AppColors.border),
                    ),
                  ),
                  child: Text(
                    hasDetails ? 'ACTIVE' : 'SAMPLE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: hasDetails
                          ? AppColors.primary
                          : AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Simulated document payment block
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // QR Box Mock
                Column(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: _isDark
                            ? AppColors.darkSurfaceVariant
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _isDark
                              ? AppColors.darkBorder
                              : AppColors.borderStrong,
                          width: 1,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.qr_code_2_rounded,
                        size: 56,
                        color: _textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Scan to Pay (UPI)',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),

                // Details column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PAYMENT DETAILS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (hasDetails) ...[
                        if (upiDetails.isNotEmpty)
                          ...upiDetails.map(
                            (u) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                'UPI (${u.title}): ${u.details}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _textPrimary,
                                ),
                              ),
                            ),
                          ),
                        if (bankDetails.isNotEmpty)
                          ...bankDetails.map(
                            (b) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bank: ${b.title}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  'A/C: ${b.details}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _textPrimary,
                                  ),
                                ),
                                if (b.extra != null && b.extra!.isNotEmpty)
                                  Text(
                                    'IFSC: ${b.extra}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                const SizedBox(height: 4),
                              ],
                            ),
                          ),
                      ] else ...[
                        Text(
                          'UPI (GPay / PhonePe): merchant@okaxis',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Bank: HDFC Bank',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: _textPrimary,
                          ),
                        ),
                        Text(
                          'A/C: 50200012345678',
                          style: TextStyle(
                            fontSize: 11,
                            color: _textPrimary,
                          ),
                        ),
                        const Text(
                          'IFSC: HDFC0001234',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Payment Profiles & QR Code',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocBuilder<BusinessProfileBloc, BusinessProfileState>(
        builder: (context, state) {
          if (state is BusinessProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          final profile = state is BusinessProfileLoaded
              ? state.profile
              : const BusinessProfile();
          final details = profile.paymentDetails;

          return CustomScrollView(
            slivers: [
              // 1. Informational header
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your banking information and instant UPI payment QR code are printed automatically at the bottom of your invoices, quotations, and receipts.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Sample Preview Card
              SliverToBoxAdapter(
                child: _buildSamplePreviewCard(profile, details),
              ),

              // 3. Section Title & Add Action
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ADDED METHODS (${details.length})',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (details.isNotEmpty)
                        TextButton.icon(
                          onPressed: () =>
                              _showAddPaymentSheet(context, profile),
                          icon: const Icon(Icons.add_circle_outline, size: 16),
                          label: const Text(
                            'Add New',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // 4. List of Added Methods or Empty State (properly wrapped in Slivers)
              if (details.isEmpty)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: _isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isDark ? AppColors.darkBorder : AppColors.border,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 40,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No Payment Profiles added yet',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: _textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Add your bank account or UPI ID to make it easy for your clients to pay you directly.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () =>
                              _showAddPaymentSheet(context, profile),
                          icon: const Icon(Icons.add_rounded, size: 20),
                          label: const Text(
                            'Add Bank Account or UPI',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final item = details[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _isDark ? AppColors.darkSurface : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _isDark
                                  ? AppColors.darkBorder
                                  : AppColors.border.withValues(alpha: 0.8),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            leading: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.08,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                item.type == 'Bank'
                                    ? Icons.account_balance_rounded
                                    : Icons.qr_code_rounded,
                                color: AppColors.primary,
                                size: 22,
                              ),
                            ),
                            title: Text(
                              item.title,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: _textPrimary,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text(
                                item.type == 'Bank'
                                    ? 'A/C: ${item.details}${item.extra != null && item.extra!.isNotEmpty ? '  •  IFSC: ${item.extra}' : ''}'
                                    : 'UPI: ${item.details}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.redAccent,
                                size: 22,
                              ),
                              onPressed: () =>
                                  _deletePayment(context, profile, item.id),
                            ),
                          ),
                        ),
                      );
                    }, childCount: details.length),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                    child: OutlinedButton.icon(
                      onPressed: () => _showAddPaymentSheet(context, profile),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text(
                        'Add Another Method',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _AddPaymentSheet extends StatefulWidget {
  final Function(PaymentDetail) onSave;

  const _AddPaymentSheet({required this.onSave});

  @override
  State<_AddPaymentSheet> createState() => _AddPaymentSheetState();
}

class _AddPaymentSheetState extends State<_AddPaymentSheet> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'Bank';
  final _titleCtrl = TextEditingController();
  final _detailsCtrl = TextEditingController();
  final _extraCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _detailsCtrl.dispose();
    _extraCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(
        PaymentDetail(
          id: const Uuid().v4(),
          type: _type,
          title: _titleCtrl.text.trim(),
          details: _detailsCtrl.text.trim(),
          extra: _type == 'Bank' ? _extraCtrl.text.trim() : null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Add Payment Profile',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Bank', label: Text('Bank Account')),
                ButtonSegment(value: 'UPI', label: Text('UPI ID')),
              ],
              selected: {_type},
              onSelectionChanged: (set) {
                setState(() => _type = set.first);
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Display Name (e.g. HDFC Bank)',
              ),
              validator: (v) => v!.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _detailsCtrl,
              decoration: InputDecoration(
                labelText: _type == 'Bank' ? 'Account Number' : 'UPI ID',
              ),
              validator: (v) => v!.trim().isEmpty ? 'Required' : null,
            ),
            if (_type == 'Bank') ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _extraCtrl,
                decoration: const InputDecoration(labelText: 'IFSC Code'),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save Payment Profile',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
