import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../products/bloc/product_bloc.dart';
import '../../../products/bloc/product_state.dart';
import '../../../products/domain/product_model.dart';
import '../../domain/document_item_model.dart';

class ItemEntrySheet extends StatefulWidget {
  final String documentId;
  final DocumentItem? initialItem;

  const ItemEntrySheet({
    super.key,
    required this.documentId,
    this.initialItem,
  });

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

  final List<String> _commonUnits = ['pcs', 'hrs', 'service', 'days', 'kg', 'month', 'visit', 'box'];
  final List<double> _taxRates = [0.0, 5.0, 12.0, 18.0, 28.0];

  @override
  void initState() {
    super.initState();
    final item = widget.initialItem;
    _titleController = TextEditingController(text: item?.title ?? '');
    _descController = TextEditingController(text: item?.description ?? '');
    _qtyController = TextEditingController(
      text: item != null ? (item.quantity % 1 == 0 ? item.quantity.toInt().toString() : item.quantity.toString()) : '1',
    );
    _priceController = TextEditingController(
      text: item != null ? item.unitPrice.toStringAsFixed(2) : '',
    );
    _discountController = TextEditingController(
      text: item != null && item.discountPercent > 0 ? item.discountPercent.toStringAsFixed(1) : '0',
    );
    _hsnController = TextEditingController(text: item?.hsnSacCode ?? '');
    _selectedUnit = item?.unit ?? 'pcs';
    _taxPercent = item?.taxPercent ?? 18.0;
    _selectedProductId = item?.productId;
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
  double get _currentDiscount => double.tryParse(_discountController.text) ?? 0.0;

  double get _grossAmount => _currentQty * _currentPrice;
  double get _discountAmount => _grossAmount * (_currentDiscount / 100.0);
  double get _taxableAmount => _grossAmount - _discountAmount;
  double get _taxAmount => _taxableAmount * (_taxPercent / 100.0);
  double get _lineTotal => _taxableAmount + _taxAmount;

  void _onSelectProductFromCatalog(ProductItem product) {
    setState(() {
      _selectedProductId = product.id;
      _titleController.text = product.title;
      if (product.description != null) _descController.text = product.description!;
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
      description: _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
      quantity: _currentQty,
      unit: _selectedUnit,
      unitPrice: price,
      discountPercent: _currentDiscount,
      taxPercent: _taxPercent,
      hsnSacCode: _hsnController.text.trim().isNotEmpty ? _hsnController.text.trim() : null,
    );

    Navigator.of(context).pop(item);
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
          // Quick catalog chips if available
          BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              if (state is ProductLoaded && state.products.isNotEmpty) {
                final products = state.products;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Pick from Catalog',
                      style: AppTypography.titleSmall.copyWith(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: products.map((p) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ActionChip(
                              avatar: const Icon(Icons.bolt, size: 14, color: AppColors.accentGold),
                              label: Text('${p.title} (${CurrencyFormatter.format(p.unitPrice, decimalDigits: 0)})'),
                              backgroundColor: AppColors.surfaceVariant,
                              side: const BorderSide(color: AppColors.border),
                              onPressed: () => _onSelectProductFromCatalog(p),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.md),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),

          // Title
          AppTextField(
            controller: _titleController,
            label: 'Item / Service Name *',
            hint: 'e.g. Electrical Rewiring or Logo Design',
            errorText: _titleError,
            autofocus: widget.initialItem == null && _titleController.text.isEmpty,
            onChanged: (val) {
              if (_titleError != null) setState(() => _titleError = null);
            },
          ),
          const SizedBox(height: AppDimensions.md),

          // Quantity & Price
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quantity with stepper
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quantity *', style: AppTypography.titleSmall.copyWith(fontSize: 13)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        IconButton.filledTonal(
                          icon: const Icon(Icons.remove, size: 16),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.surfaceVariant,
                            padding: const EdgeInsets.all(8),
                            minimumSize: const Size(36, 36),
                          ),
                          onPressed: () {
                            final current = _currentQty;
                            if (current > 1) {
                              setState(() {
                                _qtyController.text = (current - 1).toString();
                              });
                            }
                          },
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: TextField(
                            controller: _qtyController,
                            textAlign: TextAlign.center,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: (_) => setState(() {}),
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(vertical: 10),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton.filledTonal(
                          icon: const Icon(Icons.add, size: 16),
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.surfaceVariant,
                            padding: const EdgeInsets.all(8),
                            minimumSize: const Size(36, 36),
                          ),
                          onPressed: () {
                            final current = _currentQty;
                            setState(() {
                              _qtyController.text = (current + 1).toString();
                            });
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              // Unit price
              Expanded(
                flex: 5,
                child: AppTextField(
                  controller: _priceController,
                  label: 'Unit Price *',
                  hint: '0.00',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefix: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Center(
                      widthFactor: 1.0,
                      child: Text('₹', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  errorText: _priceError,
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),

          // Units
          Text('Unit', style: AppTypography.titleSmall.copyWith(fontSize: 13)),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _commonUnits.map((unit) {
                final isSelected = _selectedUnit == unit;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(unit),
                    selected: isSelected,
                    selectedColor: AppColors.primaryLight,
                    backgroundColor: AppColors.surface,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 12,
                    ),
                    side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedUnit = unit);
                    },
                  ),
                );
              }).toList(),
            ),
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
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
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

          // GST Tax Rate Chips
          Text('GST Tax Rate', style: AppTypography.titleSmall.copyWith(fontSize: 13)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            children: _taxRates.map((rate) {
              final isSelected = _taxPercent == rate;
              return ChoiceChip(
                label: Text(rate == 0 ? 'Exempt (0%)' : '${rate.toStringAsFixed(0)}%'),
                selected: isSelected,
                selectedColor: AppColors.primaryLight,
                backgroundColor: AppColors.surface,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 12,
                ),
                side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
                onSelected: (selected) {
                  if (selected) setState(() => _taxPercent = rate);
                },
              );
            }).toList(),
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
                    const Text('Taxable Amount', style: AppTypography.bodySmall),
                    Text(
                      CurrencyFormatter.format(_taxableAmount),
                      style: AppTypography.tabularNumbers.copyWith(fontSize: 13),
                    ),
                  ],
                ),
                if (_taxAmount > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('GST ($_taxPercent%)', style: AppTypography.bodySmall),
                      Text(
                        '+ ${CurrencyFormatter.format(_taxAmount)}',
                        style: AppTypography.tabularNumbers.copyWith(fontSize: 13, color: AppColors.accentNavy),
                      ),
                    ],
                  ),
                ],
                const Divider(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Line Total', style: AppTypography.titleSmall.copyWith(fontWeight: FontWeight.w700)),
                    Text(
                      CurrencyFormatter.format(_lineTotal),
                      style: AppTypography.moneyMedium.copyWith(color: AppColors.primaryDark),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppDimensions.xl),

          AppButton(
            label: widget.initialItem != null ? 'Update Item' : 'Add to Document',
            onPressed: _handleSave,
            icon: Icons.check,
          ),
        ],
      ),
    );
  }
}
