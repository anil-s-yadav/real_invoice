import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../home/bloc/home_bloc.dart';
import '../../../home/bloc/home_event.dart';
import '../../bloc/document_bloc.dart';
import '../../bloc/document_event.dart';
import '../../domain/document_model.dart';

class PaymentEntrySheet extends StatefulWidget {
  final DocumentModel document;

  const PaymentEntrySheet({super.key, required this.document});

  static Future<bool?> show(
    BuildContext context, {
    required DocumentModel document,
  }) {
    return AppBottomSheet.show<bool>(
      context: context,
      title: 'Record Payment',
      child: PaymentEntrySheet(document: document),
    );
  }

  @override
  State<PaymentEntrySheet> createState() => _PaymentEntrySheetState();
}

class _PaymentEntrySheetState extends State<PaymentEntrySheet> {
  late final TextEditingController _amountController;
  late final TextEditingController _refController;
  late final TextEditingController _notesController;

  String _selectedMethod = 'UPI';
  bool _generateReceipt = true;
  bool _isProcessing = false;
  String? _amountError;

  final List<String> _methods = [
    'UPI',
    'Cash',
    'Bank Transfer',
    'Cheque',
    'Card',
  ];

  @override
  void initState() {
    super.initState();
    final balance = widget.document.balanceDue;
    _amountController = TextEditingController(
      text: balance > 0 ? balance.toStringAsFixed(2) : '',
    );
    _refController = TextEditingController();
    _notesController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _refController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _amountError = 'Enter a valid payment amount');
      return;
    }

    setState(() {
      _amountError = null;
      _isProcessing = true;
    });

    final docBloc = context.read<DocumentBloc>();
    final homeBloc = context.read<HomeBloc>();

    docBloc.add(
      RecordPaymentEvent(
        documentId: widget.document.id,
        amount: amount,
        paymentMethod: _selectedMethod,
        referenceNumber: _refController.text.trim().isNotEmpty
            ? _refController.text.trim()
            : null,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
        generateReceipt: _generateReceipt,
      ),
    );
    homeBloc.add(const LoadHomeDataEvent());

    if (mounted) {
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _generateReceipt
                ? 'Payment recorded and Receipt generated!'
                : 'Payment recorded successfully!',
          ),
          backgroundColor: AppColors.statusPaidText,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.lg,
        AppDimensions.sm,
        AppDimensions.lg,
        AppDimensions.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Invoice Summary Card
          AppCard(
            backgroundColor:
                isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant,
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.document.docNumber,
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      widget.document.customerSnapshot?.name ?? 'Customer',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Balance Due', style: AppTypography.bodySmall),
                    Text(
                      CurrencyFormatter.format(widget.document.balanceDue),
                      style: AppTypography.moneyMedium.copyWith(
                        color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.lg),

          // Payment Amount
          AppTextField(
            controller: _amountController,
            label: 'Payment Amount Received *',
            hint: '0.00',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefix: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                widthFactor: 1.0,
                child: Text(
                  '₹',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            errorText: _amountError,
            autofocus: true,
            onChanged: (val) {
              if (_amountError != null) setState(() => _amountError = null);
            },
          ),
          const SizedBox(height: AppDimensions.md),

          // Payment Profile Chips
          Text(
            'Payment Profile',
            style: AppTypography.titleSmall.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _methods.map((method) {
                final isSelected = _selectedMethod == method;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(method),
                    selected: isSelected,
                    selectedColor: isDark
                        ? AppColors.primary.withValues(alpha: 0.25)
                        : AppColors.primaryLight,
                    backgroundColor:
                        isDark ? AppColors.darkSurface : AppColors.surface,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary),
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : (isDark ? AppColors.darkBorder : AppColors.border),
                    ),
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedMethod = method);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppDimensions.md),

          // Ref / UTR
          AppTextField(
            controller: _refController,
            label: 'Transaction ID / UTR / Cheque No.',
            hint: 'e.g. UPI Ref 3241567890 or Cheque #00452',
          ),
          const SizedBox(height: AppDimensions.md),

          // Notes
          AppTextField(
            controller: _notesController,
            label: 'Payment Notes (Optional)',
            hint: 'e.g. Received via GPay; Final settlement',
          ),
          const SizedBox(height: AppDimensions.md),

          // Receipt toggle
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: _generateReceipt,
            title: const Text(
              'Generate & Save Receipt',
              style: AppTypography.titleSmall,
            ),
            subtitle: const Text(
              'Creates a matching Receipt document linked to this invoice.',
              style: AppTypography.bodySmall,
            ),
            activeThumbColor: AppColors.primary,
            onChanged: (val) => setState(() => _generateReceipt = val),
          ),
          const SizedBox(height: AppDimensions.lg),

          AppButton(
            label: 'Confirm Payment',
            onPressed: _handleSave,
            isLoading: _isProcessing,
            icon: Icons.check_circle_outline,
          ),
        ],
      ),
    );
  }
}
