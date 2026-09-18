import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../products/bloc/product_bloc.dart';
import '../../../products/bloc/product_state.dart';
import '../../../products/domain/product_model.dart';
import '../../../products/presentation/product_editor_sheet.dart';

class ProductSelectSheet extends StatefulWidget {
  final ProductItem? selectedProduct;

  const ProductSelectSheet({super.key, this.selectedProduct});

  static Future<ProductItem?> show(
    BuildContext context, {
    ProductItem? current,
  }) {
    return AppBottomSheet.show<ProductItem>(
      context: context,
      title: 'Select Item',
      child: ProductSelectSheet(selectedProduct: current),
    );
  }

  @override
  State<ProductSelectSheet> createState() => _ProductSelectSheetState();
}

class _ProductSelectSheetState extends State<ProductSelectSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.lg,
              AppDimensions.sm,
              AppDimensions.lg,
              AppDimensions.xs,
            ),
            child: AppButton(
              label: 'Add New Item to Catalog',
              icon: Icons.add_box_outlined,
              variant: AppButtonVariant.outline,
              onPressed: () async {
                final newItem = await ProductEditorSheet.show(context);
                if (newItem != null && context.mounted) {
                  Navigator.of(context).pop(newItem);
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.lg,
              vertical: AppDimensions.sm,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              decoration: const InputDecoration(
                hintText: 'Search items by name...',
                prefixIcon: Icon(
                  Icons.search,
                  size: 20,
                  color: AppColors.textMuted,
                ),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductLoaded) {
                  final allProducts = state.products;
                  final filtered = allProducts.where((p) {
                    if (_searchQuery.isEmpty) return true;
                    final q = _searchQuery.toLowerCase();
                    return p.title.toLowerCase().contains(q) ||
                        (p.description?.toLowerCase().contains(q) ?? false);
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppDimensions.xl),
                        child: Text(
                          _searchQuery.isEmpty
                              ? 'No items found in catalog.'
                              : 'No items match your search.',
                          style: const TextStyle(color: AppColors.textMuted),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(AppDimensions.md),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final product = filtered[index];
                      final isSelected =
                          widget.selectedProduct?.id == product.id;

                      return AppCard(
                        padding: EdgeInsets.zero,
                        backgroundColor: isSelected
                            ? AppColors.primary.withValues(alpha: 0.05)
                            : AppColors.surface,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(product),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary.withValues(
                                            alpha: 0.1,
                                          )
                                        : AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.inventory_2_outlined,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.title,
                                        style: AppTypography.titleSmall
                                            .copyWith(
                                              color: isSelected
                                                  ? AppColors.primary
                                                  : AppColors.textPrimary,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${CurrencyFormatter.format(product.unitPrice)} / ${product.unit}',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }
}
