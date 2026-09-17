import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../bloc/customer_state.dart';
import '../domain/customer_model.dart';
import 'customer_editor_sheet.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: BlocBuilder<CustomerBloc, CustomerState>(
        builder: (context, state) {
          if (state is CustomerLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (state is CustomerLoaded) {
            final allCustomers = state.customers;
            final filtered = allCustomers.where((c) {
              if (_searchQuery.isEmpty) return true;
              final q = _searchQuery.toLowerCase();
              return c.name.toLowerCase().contains(q) ||
                  (c.phone?.toLowerCase().contains(q) ?? false) ||
                  (c.email?.toLowerCase().contains(q) ?? false) ||
                  (c.gstin?.toLowerCase().contains(q) ?? false);
            }).toList();

            if (allCustomers.isEmpty) {
              return EmptyStateView(
                icon: Icons.people_outline,
                title: 'No clients yet',
                description: 'Save your clients once and add them to invoices in seconds.',
                actionLabel: 'Add Client',
                onAction: () => CustomerEditorSheet.show(context),
              );
            }

            return Column(
              children: [
                Container(
                  color: AppColors.canvas,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: SizedBox(
                    height: 44,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val.trim()),
                      decoration: InputDecoration(
                        hintText: 'Search by name, phone, or GSTIN...',
                        hintStyle: const TextStyle(color: AppColors.textMuted),
                        prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textMuted),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.5))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Text(
                            'No clients match "$_searchQuery"',
                            style: AppTypography.bodyMedium,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final customer = filtered[index];
                            return _CustomerItemCard(customer: customer);
                          },
                        ),
                ),
              ],
            );
          }

          if (state is CustomerError) {
            return Center(
              child: Text(
                'Unable to load clients: ${state.message}',
                style: AppTypography.bodyMedium.copyWith(color: AppColors.statusOverdueText),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'customer_fab',
        onPressed: () => CustomerEditorSheet.show(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CustomerItemCard extends StatelessWidget {
  final Customer customer;

  const _CustomerItemCard({required this.customer});

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, parts.first.length.clamp(1, 2)).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        onTap: () => CustomerEditorSheet.show(context, customer: customer),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                _getInitials(customer.name),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (customer.phone != null && customer.phone!.isNotEmpty)
                    Text(customer.phone!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))
                  else if (customer.email != null && customer.email!.isNotEmpty)
                    Text(customer.email!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))
                  else
                    const Text(
                      'No contact info provided',
                      style: TextStyle(color: AppColors.textMuted, fontStyle: FontStyle.italic, fontSize: 13),
                    ),
                  if (customer.gstin != null && customer.gstin!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        'GSTIN: ${customer.gstin}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textMuted),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (val) async {
                if (val == 'edit') {
                  CustomerEditorSheet.show(context, customer: customer);
                } else if (val == 'delete') {
                  final confirmed = await ConfirmDialog.show(
                    context,
                    title: 'Delete Client?',
                    message: 'Are you sure you want to delete "${customer.name}"? Past documents created for this client will retain their details.',
                    confirmLabel: 'Delete',
                    isDestructive: true,
                  );
                  if (confirmed && context.mounted) {
                    context.read<CustomerBloc>().add(DeleteCustomerEvent(customer.id));
                  }
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 12), Text('Edit')]),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [Icon(Icons.delete_outline, size: 18, color: AppColors.statusOverdueText), SizedBox(width: 12), Text('Delete', style: TextStyle(color: AppColors.statusOverdueText))]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
