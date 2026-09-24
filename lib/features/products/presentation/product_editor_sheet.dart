import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../domain/product_model.dart';

class ProductEditorSheet extends StatefulWidget {
  final ProductItem? initialProduct;

  const ProductEditorSheet({super.key, this.initialProduct});

  static Future<ProductItem?> show(
    BuildContext context, {
    ProductItem? product,
  }) {
    return AppBottomSheet.show<ProductItem>(
      context: context,
      title: product != null ? 'Edit Item / Service' : 'New Item / Service',
      child: ProductEditorSheet(initialProduct: product),
    );
  }

  @override
  State<ProductEditorSheet> createState() => _ProductEditorSheetState();
}

class _ProductEditorSheetState extends State<ProductEditorSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _hsnController;

  String _selectedUnit = 'pcs';
  double _selectedTaxPercent = 18.0;
  String? _titleError;
  String? _priceError;
  bool _isSaving = false;

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
    final p = widget.initialProduct;
    _titleController = TextEditingController(text: p?.title ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _priceController = TextEditingController(
      text: p != null && p.unitPrice > 0 ? p.unitPrice.toStringAsFixed(2) : '',
    );
    _hsnController = TextEditingController(text: p?.hsnSacCode ?? '');
    _selectedUnit = p?.unit ?? 'pcs';
    _selectedTaxPercent = p?.defaultTaxPercent ?? 18.0;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _hsnController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = 'Title is required');
      return;
    }

    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price < 0) {
      setState(() => _priceError = 'Enter a valid price');
      return;
    }

    setState(() {
      _titleError = null;
      _priceError = null;
      _isSaving = true;
    });

    final product = ProductItem(
      id: widget.initialProduct?.id ?? const Uuid().v4(),
      title: title,
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      unitPrice: price,
      unit: _selectedUnit,
      defaultTaxPercent: _selectedTaxPercent,
      hsnSacCode: _hsnController.text.trim().isNotEmpty
          ? _hsnController.text.trim()
          : null,
      createdAt: widget.initialProduct?.createdAt ?? DateTime.now(),
    );

    context.read<ProductBloc>().add(SaveProductEvent(product));

    if (mounted) {
      Navigator.of(context).pop(product);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.lg,
        AppDimensions.md,
        AppDimensions.lg,
        AppDimensions.xxl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _titleController,
            label: 'Item or Service Name *',
            hint: 'e.g. Website Design or Brass Fitting 1/2"',
            errorText: _titleError,
            autofocus: widget.initialProduct == null,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (val) {
              if (_titleError != null && val.trim().isNotEmpty) {
                setState(() => _titleError = null);
              }
            },
          ),
          const SizedBox(height: AppDimensions.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: AppTextField(
                  controller: _priceController,
                  label: 'Price per Unit *',
                  hint: '0.00',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  prefix: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Center(
                      widthFactor: 1.0,
                      child: Text(
                        '₹',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  errorText: _priceError,
                  onChanged: (val) {
                    if (_priceError != null) setState(() => _priceError = null);
                  },
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                flex: 2,
                child: AppTextField(
                  controller: _hsnController,
                  label: 'HSN/SAC Code',
                  hint: 'e.g. 998314',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          Text(
            'Unit of Measure',
            style: AppTypography.titleSmall.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _commonUnits.map((unit) {
                final isSelected = _selectedUnit == unit;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(unit),
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
                      if (selected) setState(() => _selectedUnit = unit);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          Text(
            'Default Tax Rate (GST %)',
            style: AppTypography.titleSmall.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: _taxRates.map((rate) {
              final isSelected = _selectedTaxPercent == rate;
              return ChoiceChip(
                label: Text(
                  rate == 0 ? 'Exempt (0%)' : '${rate.toStringAsFixed(0)}%',
                ),
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
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? AppColors.darkBorder : AppColors.border),
                ),
                onSelected: (selected) {
                  if (selected) setState(() => _selectedTaxPercent = rate);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: AppDimensions.md),
          AppTextField(
            controller: _descriptionController,
            label: 'Description (Optional)',
            hint: 'Detailed specifications, inclusions, or warranties...',
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: AppDimensions.xl),
          AppButton(
            label: widget.initialProduct != null
                ? 'Update Item'
                : 'Save to Catalog',
            onPressed: _handleSave,
            isLoading: _isSaving,
            icon: Icons.check,
          ),
        ],
      ),
    );
  }
}
