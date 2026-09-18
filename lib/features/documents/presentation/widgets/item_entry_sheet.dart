import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../products/domain/product_model.dart';
import '../../../settings/data/invoice_settings_repository.dart';
import '../../domain/document_item_model.dart';
import 'product_select_sheet.dart';

class ItemEntrySheet extends StatefulWidget {
  final String documentId;
  final DocumentItem? initialItem;

  const ItemEntrySheet({super.key, required this.documentId, this.initialItem});

  static Future<DocumentItem?> show(
    BuildContext context, {
    required String documentId,
    DocumentItem? item,
  }) {
    return AppBottomSheet.show<DocumentItem>(
      context: context,
      title: item != null ? 'Edit Line Item' : 'Add Line Item',
      child: ItemEntrySheet(documentId: documentId, initialItem: item),
    );
  }

  @override
  State<ItemEntrySheet> createState() => _ItemEntrySheetState();
}

class _ItemEntrySheetState extends State<ItemEntrySheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _qtyController;
  late final TextEditingController _priceController;
  late final TextEditingController _discountController;
  late final TextEditingController _hsnController;

  String _selectedUnit = 'pcs';
  double _taxPercent = 18.0;
  String? _selectedProductId;
  String? _titleError;
  String? _priceError;

  final List<String> _commonUnits = [
    'pcs',
    'hrs',
    'service',
    'days',
    'kg',
    'month',
    'visit',
    'box',
  ];
  final List<double> _taxRates = [0.0, 5.0, 12.0, 18.0, 28.0];

  @override
  void initState() {
    super.initState();
    final item = widget.initialItem;
    _titleController = TextEditingController(text: item?.title ?? '');
    _descController = TextEditingController(text: item?.description ?? '');
    _qtyController = TextEditingController(
      text: item != null
          ? (item.quantity % 1 == 0
                ? item.quantity.toInt().toString()
                : item.quantity.toString())
          : '1',
    );
    _priceController = TextEditingController(
      text: item != null ? item.unitPrice.toStringAsFixed(2) : '',
    );
    _discountController = TextEditingController(
      text: item != null && item.discountPercent > 0
          ? item.discountPercent.toStringAsFixed(1)
          : '0',
    );
    _hsnController = TextEditingController(text: item?.hsnSacCode ?? '');
    _selectedUnit = item?.unit ?? 'pcs';
    _taxPercent = item?.taxPercent ?? 18.0;
    _selectedProductId = item?.productId;

    if (item == null) {
      _loadDefaults();
    }
  }

  Future<void> _loadDefaults() async {
    final settingsRepo = InvoiceSettingsRepository();
    final taxEnabled = await settingsRepo.getDefaultTaxEnabled();
    final defaultTax = taxEnabled
        ? await settingsRepo.getDefaultTaxRate()
        : 0.0;
    final defaultDiscount = await settingsRepo.getDefaultDiscountRate();

    if (mounted) {
      setState(() {
        _taxPercent = defaultTax;
        if (!_taxRates.contains(_taxPercent)) {
          _taxRates.add(_taxPercent);
          _taxRates.sort();
        }
        if (defaultDiscount > 0) {
          _discountController.text = defaultDiscount.toStringAsFixed(
            defaultDiscount.truncateToDouble() == defaultDiscount ? 0 : 1,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _hsnController.dispose();
    super.dispose();
  }

  double get _currentQty => double.tryParse(_qtyController.text) ?? 1.0;
  double get _currentPrice => double.tryParse(_priceController.text) ?? 0.0;
  double get _currentDiscount =>
      double.tryParse(_discountController.text) ?? 0.0;

  double get _grossAmount => _currentQty * _currentPrice;
  double get _discountAmount => _grossAmount * (_currentDiscount / 100.0);
  double get _taxableAmount => _grossAmount - _discountAmount;
  double get _taxAmount => _taxableAmount * (_taxPercent / 100.0);
  double get _lineTotal => _taxableAmount + _taxAmount;

  void _onSelectProductFromCatalog(ProductItem product) {
    setState(() {
      _selectedProductId = product.id;
      _titleController.text = product.title;
      if (product.description != null)
        _descController.text = product.description!;
      _priceController.text = product.unitPrice.toStringAsFixed(2);
      _selectedUnit = product.unit;
      _taxPercent = product.defaultTaxPercent;
      if (product.hsnSacCode != null) _hsnController.text = product.hsnSacCode!;
    });
  }

  void _handleSave() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = 'Item title is required');
      return;
    }

    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price < 0) {
      setState(() => _priceError = 'Enter a valid price');
      return;
    }

    final item = DocumentItem(
      id: widget.initialItem?.id ?? const Uuid().v4(),
      documentId: widget.documentId,
      productId: _selectedProductId,
      title: title,
      description: _descController.text.trim().isNotEmpty
          ? _descController.text.trim()
          : null,
      quantity: _currentQty,
      unit: _selectedUnit,
      unitPrice: price,
      discountPercent: _currentDiscount,
      taxPercent: _taxPercent,
      hsnSacCode: _hsnController.text.trim().isNotEmpty
          ? _hsnController.text.trim()
          : null,
    );

    Navigator.of(context).pop(item);
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          // Search Saved Items Action
          InkWell(
            onTap: () async {
              final product = await ProductSelectSheet.show(context);
              if (product != null) {
                _onSelectProductFromCatalog(product);
              }
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.primary, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Search saved items from catalog...',
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.xl),

          // Title
          AppTextField(
            controller: _titleController,
            label: 'Item / Service Name *',
            hint: 'e.g. Electrical Rewiring or Logo Design',
            errorText: _titleError,
            autofocus:
                widget.initialItem == null && _titleController.text.isEmpty,
            onChanged: (val) {
              if (_titleError != null) setState(() => _titleError = null);
            },
          ),
          const SizedBox(height: AppDimensions.md),

          // Quantity & Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: AppTextField(
                  controller: _qtyController,
                  label: 'Qty *',
                  hint: '1',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                flex: 3,
                child: AppTextField(
                  controller: _priceController,
                  label: 'Unit Price *',
                  hint: '0.00',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  prefix: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Center(
                      widthFactor: 1.0,
                      child: Text(
                        '₹',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  errorText: _priceError,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),

          // Unit & Tax Rate
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedUnit,
                  decoration: _dropdownDecoration('Unit'),
                  items: _commonUnits
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedUnit = val);
                  },
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: DropdownButtonFormField<double>(
                  initialValue: _taxPercent,
                  decoration: _dropdownDecoration('GST Tax'),
                  items: _taxRates
                      .map(
                        (r) => DropdownMenuItem(
                          value: r,
                          child: Text(r == 0 ? 'Exempt (0%)' : '%'),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _taxPercent = val);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),

          // Tax & Discount
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _discountController,
                  label: 'Discount (%)',
                  hint: '0',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  suffix: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Center(widthFactor: 1.0, child: Text('%')),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: AppTextField(
                  controller: _hsnController,
                  label: 'HSN/SAC Code',
                  hint: 'Optional',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),

          AppTextField(
            controller: _descController,
            label: 'Description / Inclusions (Optional)',
            hint: 'e.g. includes travel and spare parts warranty',
            maxLines: 2,
          ),
          const SizedBox(height: AppDimensions.lg),

          // Live Calculation Card
          AppCard(
            backgroundColor: AppColors.surfaceVariant,
            padding: const EdgeInsets.all(AppDimensions.md),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Taxable Amount',
                      style: AppTypography.bodySmall,
                    ),
                    Text(
                      CurrencyFormatter.format(_taxableAmount),
                      style: AppTypography.tabularNumbers.copyWith(
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                if (_taxAmount > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('GST (%)', style: AppTypography.bodySmall),
                      Text(
                        '+ ',
                        style: AppTypography.tabularNumbers.copyWith(
                          fontSize: 13,
                          color: AppColors.accentNavy,
                        ),
                      ),
                    ],
                  ),
                ],
                const Divider(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Line Total',
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(_lineTotal),
                      style: AppTypography.moneyMedium.copyWith(
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.xl),

          AppButton(
            label: widget.initialItem != null
                ? 'Update Item'
                : 'Add to Document',
            onPressed: _handleSave,
            icon: Icons.check,
          ),
        ],
      ),
    );
  }
}
