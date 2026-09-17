import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../business_profile/bloc/business_profile_bloc.dart';
import '../../business_profile/bloc/business_profile_event.dart';
import '../../business_profile/bloc/business_profile_state.dart';
import '../../business_profile/domain/business_profile_model.dart';
import 'package:uuid/uuid.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text(
          'Payment Methods',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.canvas,
        foregroundColor: AppColors.textPrimary,
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

          if (details.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No payment methods added',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add a bank account or UPI ID to get paid faster.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () => _showAddPaymentSheet(context, profile),
                    icon: const Icon(Icons.add),
                    label: const Text(
                      'Add Payment Method',
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
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: details.length,
            itemBuilder: (context, index) {
              final item = details[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        item.type == 'Bank'
                            ? Icons.account_balance
                            : Icons.qr_code,
                        color: AppColors.primary,
                      ),
                    ),
                    title: Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        item.type == 'Bank'
                            ? 'A/C: ${item.details}${item.extra != null ? '\nIFSC: ${item.extra}' : ''}'
                            : 'UPI: ${item.details}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () =>
                          _deletePayment(context, profile, item.id),
                    ),
                    isThreeLine:
                        item.type == 'Bank' &&
                        item.extra != null &&
                        item.extra!.isNotEmpty,
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton:
          BlocBuilder<BusinessProfileBloc, BusinessProfileState>(
            builder: (context, state) {
              final profile = state is BusinessProfileLoaded
                  ? state.profile
                  : const BusinessProfile();
              if (profile.paymentDetails.isEmpty) {
                return const SizedBox.shrink();
              }
              return FloatingActionButton(
                onPressed: () => _showAddPaymentSheet(context, profile),
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.add, color: Colors.white),
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
              'Add Payment Method',
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
                'Save Payment Method',
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
