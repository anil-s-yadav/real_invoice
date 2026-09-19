import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../customers/bloc/customer_bloc.dart';
import '../../../customers/bloc/customer_state.dart';
import '../../../customers/domain/customer_model.dart';
import '../../../customers/presentation/customer_editor_sheet.dart';

class CustomerSelectSheet extends StatefulWidget {
  final Customer? selectedCustomer;

  const CustomerSelectSheet({super.key, this.selectedCustomer});

  static Future<Customer?> show(BuildContext context, {Customer? current}) {
    return AppBottomSheet.show<Customer>(
      context: context,
      title: 'Select Customer',
      child: CustomerSelectSheet(selectedCustomer: current),
    );
  }

  @override
  State<CustomerSelectSheet> createState() => _CustomerSelectSheetState();
}

class _CustomerSelectSheetState extends State<CustomerSelectSheet> {
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
          // Top action: Add new customer button
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.lg,
              AppDimensions.sm,
              AppDimensions.lg,
              AppDimensions.xs,
            ),
            child: AppButton(
              label: 'Add New Customer',
              icon: Icons.person_add_outlined,
              variant: AppButtonVariant.outline,
              onPressed: () async {
                final newCustomer = await CustomerEditorSheet.show(context);
                if (newCustomer != null && context.mounted) {
                  Navigator.of(context).pop(newCustomer);
                }
              },
            ),
          ),
          // Search box
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.lg,
              vertical: AppDimensions.sm,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              decoration: InputDecoration(
                hintText: 'Search customer name or phone...',
                prefixIcon: const Icon(
                  Icons.search,
                  size: 20,
                  color: AppColors.textMuted,
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          const Divider(height: 1),
          // Customers list
          Expanded(
            child: BlocBuilder<CustomerBloc, CustomerState>(
              builder: (context, state) {
                if (state is CustomerLoaded) {
                  final allCustomers = state.customers;
                  final filtered = allCustomers.where((c) {
                    if (_searchQuery.isEmpty) return true;
                    final q = _searchQuery.toLowerCase();
                    return c.name.toLowerCase().contains(q) ||
                        (c.phone?.toLowerCase().contains(q) ?? false);
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppDimensions.xl),
                        child: Text(
                          _searchQuery.isEmpty
                              ? 'No customers added yet. Tap "Add New Customer" above to create one.'
                              : 'No customer matches "$_searchQuery"',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMedium,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(AppDimensions.lg),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: AppDimensions.xs),
                    itemBuilder: (context, index) {
                      final customer = filtered[index];
                      final isSelected =
                          widget.selectedCustomer?.id == customer.id;

                      return AppCard(
                        backgroundColor: isSelected
                            ? AppColors.primaryLight
                            : AppColors.surface,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                          width: isSelected ? 1.5 : 1.0,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.md,
                          vertical: AppDimensions.sm,
                        ),
                        onTap: () => Navigator.of(context).pop(customer),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    customer.name,
                                    style: AppTypography.titleMedium.copyWith(
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w600,
                                    ),
                                  ),
                                  if (customer.phone != null &&
                                      customer.phone!.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      customer.phone!,
                                      style: AppTypography.bodySmall,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: AppColors.primary,
                                size: 20,
                              ),
                          ],
                        ),
                      );
                    },
                  );
                }
                if (state is CustomerLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                return const Center(child: Text('Error loading customers'));
              },
            ),
          ),
        ],
      ),
    );
  }
}
