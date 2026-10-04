import re

# 1. FIX CUSTOMER SELECT SHEET
with open('lib/features/documents/presentation/widgets/customer_select_sheet.dart', 'r', encoding='utf-8') as f:
    cust_content = f.read()

cust_pattern = r"return ListView\.separated\([\s\S]*?itemBuilder: \(context, index\) \{[\s\S]*?final customer = filtered\[index\];\s*final isSelected =[\s\S]*?widget\.selectedCustomer\?\.id == customer\.id;\s*final isDark =[\s\S]*?Theme\.of\(context\)\.brightness == Brightness\.dark;\s*(return AppCard\([\s\S]*?\)\]\,\s*\)\,\s*\)\;)\s*\}\,\s*\)\;"

cust_replacement = r"""return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1, 
                      indent: 16, 
                      endIndent: 16, 
                      color: AppColors.border.withValues(alpha: 0.3)
                    ),
                    itemBuilder: (context, index) {
                      final customer = filtered[index];
                      final isSelected = widget.selectedCustomer?.id == customer.id;
                      final isDark = Theme.of(context).brightness == Brightness.dark;

                      return InkWell(
                        onTap: () => Navigator.of(context).pop(customer),
                        child: Container(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08)
                              : Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      customer.name,
                                      style: AppTypography.titleMedium.copyWith(
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                      ),
                                    ),
                                    if (customer.phone != null && customer.phone!.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        customer.phone!,
                                        style: AppTypography.bodySmall.copyWith(
                                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                            ],
                          ),
                        ),
                      );
                    },
                  );"""

cust_content = re.sub(cust_pattern, cust_replacement, cust_content)

with open('lib/features/documents/presentation/widgets/customer_select_sheet.dart', 'w', encoding='utf-8') as f:
    f.write(cust_content)


# 2. FIX PRODUCT SELECT SHEET
with open('lib/features/documents/presentation/widgets/product_select_sheet.dart', 'r', encoding='utf-8') as f:
    prod_content = f.read()

prod_content = prod_content.replace("'Select Item'", "'Select Product/Service'")

prod_pattern = r"return ListView\.separated\([\s\S]*?itemBuilder: \(context, index\) \{[\s\S]*?final product = filtered\[index\];\s*final isSelected =[\s\S]*?widget\.selectedProduct\?\.id == product\.id;\s*final isDark =[\s\S]*?Theme\.of\(context\)\.brightness == Brightness\.dark;\s*(return AppCard\([\s\S]*?\)\]\,\s*\)\,\s*\)\,\s*\)\,\s*\)\;)\s*\}\,\s*\)\;"

prod_replacement = r"""return ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => Divider(
                      height: 1, 
                      indent: 16, 
                      endIndent: 16, 
                      color: AppColors.border.withValues(alpha: 0.3)
                    ),
                    itemBuilder: (context, index) {
                      final product = filtered[index];
                      final isSelected = widget.selectedProduct?.id == product.id;
                      final isDark = Theme.of(context).brightness == Brightness.dark;

                      return InkWell(
                        onTap: () => Navigator.of(context).pop(product),
                        child: Container(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08)
                              : Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary.withValues(alpha: 0.1)
                                      : (isDark ? AppColors.darkSurface : AppColors.surfaceVariant),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.inventory_2_outlined,
                                  color: isSelected
                                      ? AppColors.primary
                                      : (isDark ? AppColors.darkTextSecondary : AppColors.textMuted),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.title,
                                      style: AppTypography.titleSmall.copyWith(
                                        color: isSelected
                                            ? AppColors.primary
                                            : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      ' / ',
                                      style: TextStyle(
                                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
                            ],
                          ),
                        ),
                      );
                    },
                  );"""

prod_content = re.sub(prod_pattern, prod_replacement, prod_content)

with open('lib/features/documents/presentation/widgets/product_select_sheet.dart', 'w', encoding='utf-8') as f:
    f.write(prod_content)
