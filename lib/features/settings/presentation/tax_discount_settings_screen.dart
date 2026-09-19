import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../data/invoice_settings_repository.dart';

class TaxDiscountSettingsScreen extends StatefulWidget {
  const TaxDiscountSettingsScreen({super.key});

  @override
  State<TaxDiscountSettingsScreen> createState() =>
      _TaxDiscountSettingsScreenState();
}

class _TaxDiscountSettingsScreenState extends State<TaxDiscountSettingsScreen> {
  final _settingsRepo = InvoiceSettingsRepository();
  bool _isLoading = true;
  bool _isSaving = false;

  late TextEditingController _taxLabelController;
  late TextEditingController _taxRateController;
  late TextEditingController _discountRateController;
  bool _autoApplyTax = true;

  final List<double> _presetTaxRates = [0.0, 5.0, 12.0, 18.0, 28.0];
  final List<double> _presetDiscountRates = [0.0, 5.0, 10.0, 15.0, 20.0];
  final List<String> _commonTaxLabels = ['GST', 'VAT', 'Sales Tax', 'TAX'];

  @override
  void initState() {
    super.initState();
    _taxLabelController = TextEditingController(text: 'GST');
    _taxRateController = TextEditingController(text: '18.0');
    _discountRateController = TextEditingController(text: '0.0');
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final taxRate = await _settingsRepo.getDefaultTaxRate();
    final discountRate = await _settingsRepo.getDefaultDiscountRate();
    final taxLabel = await _settingsRepo.getDefaultTaxLabel();
    final taxEnabled = await _settingsRepo.getDefaultTaxEnabled();

    if (mounted) {
      setState(() {
        _taxRateController.text = taxRate.toStringAsFixed(
          taxRate.truncateToDouble() == taxRate ? 0 : 1,
        );
        _discountRateController.text = discountRate.toStringAsFixed(
          discountRate.truncateToDouble() == discountRate ? 0 : 1,
        );
        _taxLabelController.text = taxLabel;
        _autoApplyTax = taxEnabled;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _taxLabelController.dispose();
    _taxRateController.dispose();
    _discountRateController.dispose();
    super.dispose();
  }

  double get _currentTaxRate => double.tryParse(_taxRateController.text) ?? 0.0;
  double get _currentDiscountRate =>
      double.tryParse(_discountRateController.text) ?? 0.0;

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    final tax = double.tryParse(_taxRateController.text) ?? 0.0;
    final discount = double.tryParse(_discountRateController.text) ?? 0.0;
    final label = _taxLabelController.text.trim().isEmpty
        ? 'GST'
        : _taxLabelController.text.trim();

    await _settingsRepo.setDefaultTaxRate(tax);
    await _settingsRepo.setDefaultDiscountRate(discount);
    await _settingsRepo.setDefaultTaxLabel(label);
    await _settingsRepo.setDefaultTaxEnabled(_autoApplyTax);

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tax & Discount defaults saved successfully!'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tax & Discounts')),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text(
          'Tax & Discounts',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.lg,
          vertical: AppDimensions.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Preview Card
            _buildSectionHeader('LIVE CALCULATION PREVIEW'),
            _buildLivePreviewCard(),
            const SizedBox(height: 20),

            // Section 1: Default Tax / GST
            _buildSectionHeader('DEFAULT TAX / GST'),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tax Label
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tax Label / Type',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _commonTaxLabels.map((label) {
                            final isSelected =
                                _taxLabelController.text.toUpperCase() == label;
                            return ChoiceChip(
                              label: Text(label),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(
                                    () => _taxLabelController.text = label,
                                  );
                                }
                              },
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.border,
                                ),
                              ),
                              showCheckmark: false,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  _buildDivider(),

                  // Default Tax Rate
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Default Tax Rate',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(
                              width: 80,
                              height: 38,
                              child: TextField(
                                controller: _taxRateController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                textAlign: TextAlign.center,
                                onChanged: (_) => setState(() {}),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  suffixText: '%',
                                  suffixStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 6,
                                  ),
                                  isDense: true,
                                  filled: true,
                                  fillColor: AppColors.surfaceVariant
                                      .withValues(alpha: 0.5),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: AppColors.border,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: AppColors.border,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: AppColors.primary,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _presetTaxRates.map((rate) {
                            final isSelected = _currentTaxRate == rate;
                            final text = rate.truncateToDouble() == rate
                                ? '${rate.toInt()}%'
                                : '$rate%';
                            return ChoiceChip(
                              label: Text(text),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _taxRateController.text = rate
                                        .toStringAsFixed(
                                          rate.truncateToDouble() == rate
                                              ? 0
                                              : 1,
                                        );
                                  });
                                }
                              },
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.border,
                                ),
                              ),
                              showCheckmark: false,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  _buildDivider(),

                  // Auto Apply Switch
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Auto-apply to new items',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Pre-fill this rate whenever a line item is added',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: _autoApplyTax,
                          activeTrackColor: AppColors.primary,
                          onChanged: (val) {
                            setState(() => _autoApplyTax = val);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Section 2: Default Discount
            _buildSectionHeader('DEFAULT DISCOUNT'),
            AppCard(
              padding: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Default Discount Rate',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          height: 38,
                          child: TextField(
                            controller: _discountRateController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textAlign: TextAlign.center,
                            onChanged: (_) => setState(() {}),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              suffixText: '%',
                              suffixStyle: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                              isDense: true,
                              filled: true,
                              fillColor: AppColors.surfaceVariant.withValues(
                                alpha: 0.5,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: AppColors.border,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: AppColors.border,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                  width: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _presetDiscountRates.map((rate) {
                        final isSelected = _currentDiscountRate == rate;
                        final text = rate.truncateToDouble() == rate
                            ? '${rate.toInt()}%'
                            : '$rate%';
                        return ChoiceChip(
                          label: Text(text),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _discountRateController.text = rate
                                    .toStringAsFixed(
                                      rate.truncateToDouble() == rate ? 0 : 1,
                                    );
                              });
                            }
                          },
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                          showCheckmark: false,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Save Action
            AppButton(
              label: 'Save Tax & Discount Defaults',
              isLoading: _isSaving,
              onPressed: _saveSettings,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLivePreviewCard() {
    const baseAmount = 1000.0;
    final discountPercent = _currentDiscountRate;
    final discountAmount = baseAmount * (discountPercent / 100.0);
    final taxableAmount = baseAmount - discountAmount;
    final taxPercent = _autoApplyTax ? _currentTaxRate : 0.0;
    final taxAmount = taxableAmount * (taxPercent / 100.0);
    final totalAmount = taxableAmount + taxAmount;
    final taxLabel = _taxLabelController.text.trim().isEmpty
        ? 'GST'
        : _taxLabelController.text.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'SAMPLE ITEM (\$1,000.00)',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              Text(
                'Total: ${CurrencyFormatter.format(totalAmount)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildSummaryRow('Base Amount', CurrencyFormatter.format(baseAmount)),
          if (discountAmount > 0) ...[
            const SizedBox(height: 6),
            _buildSummaryRow(
              'Discount (${discountPercent.toStringAsFixed(discountPercent.truncateToDouble() == discountPercent ? 0 : 1)}%)',
              '-${CurrencyFormatter.format(discountAmount)}',
              valueColor: Colors.deepOrange,
            ),
          ],
          const SizedBox(height: 6),
          _buildSummaryRow(
            'Taxable Subtotal',
            CurrencyFormatter.format(taxableAmount),
          ),
          if (_autoApplyTax && taxPercent > 0) ...[
            const SizedBox(height: 6),
            _buildSummaryRow(
              '$taxLabel (${taxPercent.toStringAsFixed(taxPercent.truncateToDouble() == taxPercent ? 0 : 1)}%)',
              '+${CurrencyFormatter.format(taxAmount)}',
              valueColor: AppColors.primary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: AppColors.border.withValues(alpha: 0.5),
      indent: 16,
      endIndent: 16,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
