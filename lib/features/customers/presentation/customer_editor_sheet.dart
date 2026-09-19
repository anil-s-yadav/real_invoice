import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/app_bottom_sheet.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../domain/customer_model.dart';

class CustomerEditorSheet extends StatefulWidget {
  final Customer? initialCustomer;

  const CustomerEditorSheet({super.key, this.initialCustomer});

  static Future<Customer?> show(BuildContext context, {Customer? customer}) {
    return AppBottomSheet.show<Customer>(
      context: context,
      title: customer != null ? 'Edit Customer' : 'New Customer',
      child: CustomerEditorSheet(initialCustomer: customer),
    );
  }

  @override
  State<CustomerEditorSheet> createState() => _CustomerEditorSheetState();
}

class _CustomerEditorSheetState extends State<CustomerEditorSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _billingAddressController;
  late final TextEditingController _shippingAddressController;
  late final TextEditingController _gstinController;
  late final TextEditingController _notesController;

  String? _nameError;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final c = widget.initialCustomer;
    _nameController = TextEditingController(text: c?.name ?? '');
    _phoneController = TextEditingController(text: c?.phone ?? '');
    _emailController = TextEditingController(text: c?.email ?? '');
    _billingAddressController = TextEditingController(
      text: c?.billingAddress ?? '',
    );
    _shippingAddressController = TextEditingController(
      text: c?.shippingAddress ?? '',
    );
    _gstinController = TextEditingController(text: c?.gstin ?? '');
    _notesController = TextEditingController(text: c?.notes ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _billingAddressController.dispose();
    _shippingAddressController.dispose();
    _gstinController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Customer name is required');
      return;
    }

    setState(() {
      _nameError = null;
      _isSaving = true;
    });

    final customer = Customer(
      id: widget.initialCustomer?.id ?? const Uuid().v4(),
      name: name,
      phone: _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : null,
      email: _emailController.text.trim().isNotEmpty
          ? _emailController.text.trim()
          : null,
      billingAddress: _billingAddressController.text.trim().isNotEmpty
          ? _billingAddressController.text.trim()
          : null,
      shippingAddress: _shippingAddressController.text.trim().isNotEmpty
          ? _shippingAddressController.text.trim()
          : null,
      gstin: _gstinController.text.trim().isNotEmpty
          ? _gstinController.text.trim().toUpperCase()
          : null,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
      createdAt: widget.initialCustomer?.createdAt ?? DateTime.now(),
    );

    context.read<CustomerBloc>().add(SaveCustomerEvent(customer));

    if (mounted) {
      Navigator.of(context).pop(customer);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            controller: _nameController,
            label: 'Customer / Client Name *',
            hint: 'e.g. Acme Innovations or Rajesh Kumar',
            errorText: _nameError,
            autofocus: widget.initialCustomer == null,
            textCapitalization: TextCapitalization.words,
            onChanged: (val) {
              if (_nameError != null && val.trim().isNotEmpty) {
                setState(() => _nameError = null);
              }
            },
          ),
          const SizedBox(height: AppDimensions.md),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  hint: '+91 98765 43210',
                  keyboardType: TextInputType.phone,
                  prefix: const Icon(
                    Icons.phone_outlined,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: AppTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hint: 'contact@acme.com',
                  keyboardType: TextInputType.emailAddress,
                  prefix: const Icon(
                    Icons.mail_outline,
                    size: 18,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          AppTextField(
            controller: _gstinController,
            label: 'GSTIN (Tax ID)',
            hint: 'e.g. 29ABCDE1234F1Z5',
            textCapitalization: TextCapitalization.characters,
            prefix: const Icon(
              Icons.badge_outlined,
              size: 18,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: AppDimensions.md),
          AppTextField(
            controller: _billingAddressController,
            label: 'Billing Address',
            hint: 'Building, Street, City, State, PIN',
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: AppDimensions.md),
          AppTextField(
            controller: _notesController,
            label: 'Notes / Payment Terms',
            hint: 'e.g. Preferred delivery in morning; Net 15 days',
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: AppDimensions.xl),
          AppButton(
            label: widget.initialCustomer != null
                ? 'Update Customer'
                : 'Save Customer',
            onPressed: _handleSave,
            isLoading: _isSaving,
            icon: Icons.check,
          ),
        ],
      ),
    );
  }
}
