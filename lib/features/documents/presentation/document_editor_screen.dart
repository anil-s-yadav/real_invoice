import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/status_badge.dart';
import '../../business_profile/bloc/business_profile_bloc.dart';
import '../../business_profile/bloc/business_profile_state.dart';
import '../../business_profile/domain/business_profile_model.dart';
import '../../business_profile/presentation/manage_company_list_screen.dart';
import '../../customers/domain/customer_model.dart';
import '../../home/bloc/home_bloc.dart';
import '../../home/bloc/home_event.dart';
import '../bloc/document_bloc.dart';
import '../bloc/document_event.dart';
import '../data/document_repository.dart';
import '../domain/document_item_model.dart';
import '../domain/document_model.dart';
import '../../settings/presentation/payment_details_list_screen.dart';
import 'pdf_preview_screen.dart';
import 'widgets/customer_select_sheet.dart';
import 'widgets/item_entry_sheet.dart';

class DocumentEditorScreen extends StatefulWidget {
  final DocumentModel? initialDocument;
  final DocumentType initialType;

  const DocumentEditorScreen({
    super.key,
    this.initialDocument,
    this.initialType = DocumentType.invoice,
  });

  @override
  State<DocumentEditorScreen> createState() => _DocumentEditorScreenState();
}

class _DocumentEditorScreenState extends State<DocumentEditorScreen> {
  late String _documentId;
  late DocumentType _docType;
  late TextEditingController _docNumberController;
  late TextEditingController _poNumberController;
  late TextEditingController _subjectController;
  late TextEditingController _shippingController;
  late DateTime _issueDate;
  late DateTime _dueDate;
  Customer? _selectedCustomer;
  List<DocumentItem> _items = [];
  double _overallDiscountValue = 0.0;
  DiscountType _overallDiscountType = DiscountType.percentage;
  late TextEditingController _notesController;
  late TextEditingController _termsController;
  late String _templateId;
  bool _isSaving = false;
  bool _isInitialized = false;
  bool _includePaymentDetails = false;
  String? _selectedBankDetailId;
  String? _selectedUpiDetailId;

  @override
  void initState() {
    super.initState();
    final doc = widget.initialDocument;
    _documentId = doc?.id ?? const Uuid().v4();
    _docType = doc?.docType ?? widget.initialType;
    _docNumberController = TextEditingController(text: doc?.docNumber ?? '');
    _poNumberController = TextEditingController(text: doc?.poNumber ?? '');
    _subjectController = TextEditingController(text: doc?.subject ?? '');
    _shippingController = TextEditingController(
      text: doc != null && doc.shippingCharges > 0
          ? doc.shippingCharges.toStringAsFixed(2)
          : '',
    );
    _issueDate = doc?.issueDate ?? DateTime.now();
    _includePaymentDetails = doc?.includePaymentDetails ?? false;
    _selectedBankDetailId = doc?.selectedBankDetailId;
    _selectedUpiDetailId = doc?.selectedUpiDetailId;
    _dueDate = doc?.dueDate ?? DateTime.now().add(const Duration(days: 15));
    _selectedCustomer = doc?.customerSnapshot;
    _items = doc?.items != null ? List.from(doc!.items) : [];
    _overallDiscountValue = doc?.overallDiscountValue ?? 0.0;
    _overallDiscountType = doc?.overallDiscountType ?? DiscountType.percentage;
    _templateId = doc?.templateId ?? 'modern_crimson';
    _notesController = TextEditingController(text: doc?.notes ?? '');
    _termsController = TextEditingController(text: doc?.terms ?? '');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDefaults();
    });
  }

  Future<void> _initializeDefaults() async {
    if (_isInitialized) return;

    if (widget.initialDocument == null) {
      final repo = context.read<DocumentRepository>();
      final nextNumber = await repo.getNextDocumentNumber(_docType);
      if (!mounted) return;

      setState(() {
        _docNumberController.text = nextNumber;
      });

      final profileState = context.read<BusinessProfileBloc>().state;
      if (profileState is BusinessProfileLoaded) {
        final profile = profileState.profile;
        if (_termsController.text.isEmpty) {
          _termsController.text = profile.defaultTerms;
        }
        if (_notesController.text.isEmpty) {
          _notesController.text = profile.defaultNotes;
        }

        setState(() {
          switch (_docType) {
            case DocumentType.invoice:
              _templateId = profile.defaultInvoiceTemplateId;
              break;
            case DocumentType.quotation:
              _templateId = profile.defaultQuotationTemplateId;
              break;
            case DocumentType.receipt:
              _templateId = profile.defaultReceiptTemplateId;
              break;
            case DocumentType.proforma:
              _templateId = profile.defaultProformaTemplateId;
              break;
          }
        });
      }
    }

    _isInitialized = true;
  }

  @override
  void dispose() {
    _docNumberController.dispose();
    _poNumberController.dispose();
    _subjectController.dispose();
    _shippingController.dispose();
    _notesController.dispose();
    _termsController.dispose();
    super.dispose();
  }

  // Calculations
  double get _subtotal =>
      _items.fold(0.0, (sum, item) => sum + item.taxableAmount);
  double get _taxTotal => _items.fold(0.0, (sum, item) => sum + item.taxAmount);
  double get _overallDiscountAmount {
    if (_overallDiscountType == DiscountType.percentage) {
      return _subtotal * (_overallDiscountValue / 100.0);
    } else {
      return _overallDiscountValue > _subtotal
          ? _subtotal
          : _overallDiscountValue;
    }
  }

  double get _rawTotal => (_subtotal - _overallDiscountAmount) + _taxTotal;
  double get _roundOff => (_rawTotal.roundToDouble() - _rawTotal);
  double get _finalTotal => _rawTotal + _roundOff;

  Future<void> _selectIssueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _issueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        _issueDate = picked;
        if (_dueDate.isBefore(_issueDate)) {
          _dueDate = _issueDate.add(const Duration(days: 15));
        }
      });
    }
  }

  Future<void> _selectDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: _issueDate,
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<DocumentModel?> _buildAndSaveDocument({
    DocumentStatus? forcedStatus,
  }) async {
    final profileState = context.read<BusinessProfileBloc>().state;
    if (profileState is BusinessProfileLoaded) {
      if (profileState.profile.businessName.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please select or set up your Business Profile before creating a document.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return null;
      }
    }

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one line item to this document.'),
          backgroundColor: AppColors.statusOverdueText,
        ),
      );
      return null;
    }

    final docNumber = _docNumberController.text.trim().isNotEmpty
        ? _docNumberController.text.trim()
        : '${_docType.prefix}0001';

    setState(() => _isSaving = true);

    final now = DateTime.now();
    final status =
        forcedStatus ?? widget.initialDocument?.status ?? DocumentStatus.draft;

    final document = DocumentModel(
      id: _documentId,
      docNumber: docNumber,
      docType: _docType,
      customerId: _selectedCustomer?.id,
      customerSnapshot: _selectedCustomer,
      issueDate: _issueDate,
      dueDate: _dueDate,
      status: status,
      items: _items,
      payments: widget.initialDocument?.payments ?? const [],
      overallDiscountValue: _overallDiscountValue,
      overallDiscountType: _overallDiscountType,
      templateId: _templateId,
      includePaymentDetails:
          _selectedBankDetailId != null ||
          _selectedUpiDetailId != null ||
          _includePaymentDetails,
      selectedBankDetailId: _selectedBankDetailId,
      selectedUpiDetailId: _selectedUpiDetailId,
      poNumber: _poNumberController.text.trim().isNotEmpty
          ? _poNumberController.text.trim()
          : null,
      subject: _subjectController.text.trim().isNotEmpty
          ? _subjectController.text.trim()
          : null,
      shippingCharges: double.tryParse(_shippingController.text) ?? 0.0,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
      terms: _termsController.text.trim().isNotEmpty
          ? _termsController.text.trim()
          : null,
      relatedDocId: widget.initialDocument?.relatedDocId,
      createdAt: widget.initialDocument?.createdAt ?? now,
      updatedAt: now,
    );

    if (mounted) {
      context.read<DocumentBloc>().add(SaveDocumentEvent(document));
      context.read<HomeBloc>().add(const LoadHomeDataEvent());
      setState(() => _isSaving = false);
    }

    return document;
  }

  Future<void> _handleSaveAndPreview() async {
    final doc = await _buildAndSaveDocument();
    if (doc != null && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => PdfPreviewScreen(document: doc)),
      );
    }
  }

  Future<void> _handleSaveDraft() async {
    final doc = await _buildAndSaveDocument(forcedStatus: DocumentStatus.draft);
    if (doc != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${doc.docType.displayName} ${doc.docNumber} saved as Draft!',
          ),
          backgroundColor: AppColors.statusPaidText,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text(
          widget.initialDocument != null
              ? 'Edit ${_docType.displayName}'
              : 'New ${_docType.displayName}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.canvas,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _handleSaveDraft,
            child: const Text(
              'Save Draft',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            16,
            8,
            16,
            120, // Room for bottom sticky bar
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Document Type Switcher Pills
              // _buildDocTypePills(),
              // const SizedBox(height: 16),

              // 1.5 Selected Company Selector
              _buildCompanySelector(),
              const SizedBox(height: 16),

              // 2. Document Meta Card (Number + Dates)
              _buildMetaCard(),
              const SizedBox(height: 24),

              // 3. Customer Section
              _buildSectionTitle('BILLED TO'),
              _buildCustomerSection(),
              const SizedBox(height: 24),

              // 4. Line Items Section
              _buildSectionTitle('LINE ITEMS'),
              _buildItemsSection(),
              const SizedBox(height: 24),

              _buildSectionTitle('DETAILS (OPTIONAL)'),
              _buildOptionalFields(),
              const SizedBox(height: 24),

              // 5. Totals & Tax Summary Card
              if (_items.isNotEmpty) ...[
                _buildSectionTitle('SUMMARY'),
                _buildSummaryCard(),
                const SizedBox(height: 24),
              ],

              // 6. Notes & Terms Accordion
              _buildSectionTitle('SHOW PAYMENTS INFO'),
              _buildNotesTermsSection(),
            ],
          ),
        ),
      ),
      bottomSheet: _buildBottomStickyBar(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  // Widget _buildDocTypePills() {
  //   return SingleChildScrollView(
  //     scrollDirection: Axis.horizontal,
  //     child: Row(
  //       children: DocumentType.values.map((type) {
  //         final isSelected = _docType == type;
  //         return Padding(
  //           padding: const EdgeInsets.only(right: 8),
  //           child: GestureDetector(
  //             onTap: () async {
  //               if (!isSelected) {
  //                 setState(() => _docType = type);
  //                 final nextNum = await context
  //                     .read<DocumentRepository>()
  //                     .getNextDocumentNumber(type);
  //                 if (mounted) {
  //                   setState(() => _docNumberController.text = nextNum);
  //                 }
  //               }
  //             },
  //             child: AnimatedContainer(
  //               duration: const Duration(milliseconds: 200),
  //               padding: const EdgeInsets.symmetric(
  //                 horizontal: 16,
  //                 vertical: 8,
  //               ),
  //               decoration: BoxDecoration(
  //                 color: isSelected ? AppColors.primary : Colors.white,
  //                 borderRadius: BorderRadius.circular(20),
  //                 border: Border.all(
  //                   color: isSelected ? AppColors.primary : AppColors.border,
  //                   width: 1,
  //                 ),
  //                 boxShadow: isSelected
  //                     ? [
  //                         BoxShadow(
  //                           color: AppColors.primary.withValues(alpha: 0.3),
  //                           blurRadius: 8,
  //                           offset: const Offset(0, 4),
  //                         ),
  //                       ]
  //                     : [],
  //               ),
  //               child: Text(
  //                 type.displayName,
  //                 style: TextStyle(
  //                   color: isSelected ? Colors.white : AppColors.textPrimary,
  //                   fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
  //                   fontSize: 13,
  //                 ),
  //               ),
  //             ),
  //           ),
  //         );
  //       }).toList(),
  //     ),
  //   );
  // }

  Widget _buildCompanySelector() {
    return BlocBuilder<BusinessProfileBloc, BusinessProfileState>(
      builder: (context, state) {
        if (state is! BusinessProfileLoaded) {
          return const SizedBox.shrink();
        }
        final profile = state.profile;

        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ManageCompanyListScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                if (profile.logoPath != null && profile.logoPath!.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.file(
                      File(profile.logoPath!),
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.business, color: AppColors.primary),
                    ),
                  )
                else
                  const Icon(Icons.business, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Creating document for',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        profile.businessName.isNotEmpty
                            ? profile.businessName
                            : 'Set up your company',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.swap_horiz,
                  color: AppColors.primary,
                  size: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetaCard() {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Document number â€” simple inline row
          Row(
            children: [
              Text(
                '${_docType.displayName} #',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _docNumberController,
                  textCapitalization: TextCapitalization.characters,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'INV-2026-0001',
                    hintStyle: TextStyle(
                      color: AppColors.textMuted.withValues(alpha: 0.5),
                      fontWeight: FontWeight.normal,
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 10,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Dates row
          Row(
            children: [
              Expanded(
                child: _buildDateChip(
                  label: '${_docType.displayName} Date',
                  dateStr: DateFormatter.format(_issueDate),
                  onTap: _selectIssueDate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateChip(
                  label: _docType == DocumentType.quotation
                      ? 'Valid Until'
                      : 'Due Date',
                  dateStr: DateFormatter.format(_dueDate),
                  onTap: _selectDueDate,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateChip({
    required String label,
    required String dateStr,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.canvas,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateStr,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.calendar_today_rounded,
              size: 14,
              color: AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionalFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextField(
          controller: _subjectController,
          label: 'Subject / Title (Optional)',
          hint: 'e.g. Website Redesign Project',
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: _poNumberController,
                label: 'PO Number (Optional)',
                hint: 'e.g. PO-1234',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                controller: _shippingController,
                label: 'Shipping Charges',
                hint: '0.00',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCustomerSection() {
    if (_selectedCustomer == null) {
      return GestureDetector(
        onTap: () async {
          final customer = await CustomerSelectSheet.show(context);
          if (customer != null) {
            setState(() => _selectedCustomer = customer);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
              style: BorderStyle.solid,
              width: 1.5,
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_add_alt_1_rounded,
                color: AppColors.primary,
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                'Add Customer / Client',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return AppCard(
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
              _selectedCustomer!.name
                  .substring(0, _selectedCustomer!.name.length.clamp(1, 2))
                  .toUpperCase(),
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
                  _selectedCustomer!.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (_selectedCustomer!.phone != null &&
                    _selectedCustomer!.phone!.isNotEmpty)
                  Text(
                    _selectedCustomer!.phone!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  )
                else if (_selectedCustomer!.email != null &&
                    _selectedCustomer!.email!.isNotEmpty)
                  Text(
                    _selectedCustomer!.email!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.swap_horiz_rounded,
              color: AppColors.primary,
            ),
            onPressed: () async {
              final customer = await CustomerSelectSheet.show(context);
              if (customer != null) {
                setState(() => _selectedCustomer = customer);
              }
            },
            tooltip: 'Change Customer',
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection() {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          if (_items.isNotEmpty)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _items.length,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1, color: AppColors.border),
              itemBuilder: (context, index) {
                final item = _items[index];
                return InkWell(
                  onTap: () async {
                    final updatedItem = await ItemEntrySheet.show(
                      context,
                      documentId: _documentId,
                      item: item,
                    );
                    if (updatedItem != null) {
                      setState(() => _items[index] = updatedItem);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.quantity} x ${CurrencyFormatter.format(item.unitPrice)}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              CurrencyFormatter.format(item.lineTotal),
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (item.taxPercent > 0) ...[
                              const SizedBox(height: 4),
                              Text(
                                '+ ${item.taxPercent.toStringAsFixed(0)}% Tax',
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => setState(() => _items.removeAt(index)),
                          child: const Icon(
                            Icons.remove_circle_outline,
                            color: AppColors.statusOverdueText,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

          // Add Item Button inside the card
          InkWell(
            onTap: () async {
              final newItem = await ItemEntrySheet.show(
                context,
                documentId: _documentId,
              );
              if (newItem != null) {
                setState(() => _items.add(newItem));
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: _items.isNotEmpty
                    ? const Border(top: BorderSide(color: AppColors.border))
                    : null,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Add Line Item',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSummaryRow('Subtotal', CurrencyFormatter.format(_subtotal)),

          if (_overallDiscountAmount > 0 || _items.isNotEmpty) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: _showDiscountDialog,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Discount',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.edit_outlined,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      if (_overallDiscountValue > 0)
                        Text(
                          _overallDiscountType == DiscountType.percentage
                              ? ' (${_overallDiscountValue.toStringAsFixed(1)}%)'
                              : ' (Flat)',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  Text(
                    '- ${CurrencyFormatter.format(_overallDiscountAmount)}',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (_taxTotal > 0) ...[
            const SizedBox(height: 12),
            _buildSummaryRow(
              'Tax',
              '+ ${CurrencyFormatter.format(_taxTotal)}',
              valueColor: AppColors.textSecondary,
            ),
          ],

          if (_roundOff != 0) ...[
            const SizedBox(height: 12),
            _buildSummaryRow(
              'Round Off',
              _roundOff > 0
                  ? '+ ${CurrencyFormatter.format(_roundOff)}'
                  : CurrencyFormatter.format(_roundOff),
            ),
          ],

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1, color: AppColors.border),
          ),

          // Grand Total
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.8),
                  AppColors.primary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Grand Total',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  CurrencyFormatter.format(_finalTotal),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
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
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  void _showDiscountDialog() {
    double tempValue = _overallDiscountValue;
    DiscountType tempType = _overallDiscountType;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateSB) {
          return AlertDialog(
            title: const Text(
              'Apply Discount',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<DiscountType>(
                        title: const Text(
                          '%',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        value: DiscountType.percentage,
                        groupValue: tempType,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) => setStateSB(() => tempType = val!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<DiscountType>(
                        title: const Text(
                          'Flat',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        value: DiscountType.fixed,
                        groupValue: tempType,
                        contentPadding: EdgeInsets.zero,
                        onChanged: (val) => setStateSB(() => tempType = val!),
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  initialValue: tempValue > 0 ? tempValue.toString() : '',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Discount Value',
                    prefixIcon: tempType == DiscountType.fixed
                        ? const Icon(Icons.currency_rupee, size: 16)
                        : const Icon(Icons.percent, size: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (val) {
                    tempValue = double.tryParse(val) ?? 0.0;
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _overallDiscountValue = tempValue;
                    _overallDiscountType = tempType;
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Apply'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNotesTermsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Payment Profile & QR Code Selection Card
        BlocBuilder<BusinessProfileBloc, BusinessProfileState>(
          builder: (context, state) {
            if (state is! BusinessProfileLoaded) return const SizedBox();
            final profile = state.profile;
            final banks = profile.paymentDetails
                .where((p) => p.type == 'Bank')
                .toList();
            final upis = profile.paymentDetails
                .where((p) => p.type == 'UPI')
                .toList();

            // Add legacy options if needed
            if (banks.isEmpty &&
                profile.bankName != null &&
                profile.bankName!.isNotEmpty) {
              banks.add(
                PaymentDetail(
                  id: 'legacy',
                  type: 'Bank',
                  title: 'Legacy Bank Profile',
                  details: profile.accountNumber ?? '',
                ),
              );
            }
            if (upis.isEmpty &&
                profile.upiId != null &&
                profile.upiId!.isNotEmpty) {
              upis.add(
                PaymentDetail(
                  id: 'legacy_upi',
                  type: 'UPI',
                  title: 'Legacy UPI',
                  details: profile.upiId!,
                ),
              );
            }

            final hasAny = banks.isNotEmpty || upis.isNotEmpty;

            return AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.qr_code_2_rounded,
                        size: 22,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Select Payment Profile & QR',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (!hasAny) ...[
                    const Text(
                      'No payment profiles available.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const PaymentDetailsListScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_circle_outline, size: 18),
                      label: const Text('Create New Payment Profile'),
                    ),
                  ] else ...[
                    // Bank Dropdown
                    if (banks.isNotEmpty)
                      InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Bank Account (Select 1)',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String?>(
                            isExpanded: true,
                            value:
                                banks.any((b) => b.id == _selectedBankDetailId)
                                ? _selectedBankDetailId
                                : (banks.isNotEmpty &&
                                          _selectedBankDetailId != 'none'
                                      ? banks.first.id
                                      : 'none'),
                            items: [
                              const DropdownMenuItem(
                                value: 'none',
                                child: Text('None'),
                              ),
                              ...banks.map(
                                (b) => DropdownMenuItem(
                                  value: b.id,
                                  child: Text(b.title),
                                ),
                              ),
                            ],
                            onChanged: (val) {
                              setState(() {
                                _selectedBankDetailId = val;
                              });
                            },
                          ),
                        ),
                      ),
                    if (banks.isNotEmpty && upis.isNotEmpty)
                      const SizedBox(height: 12),
                    // UPI Dropdown
                    if (upis.isNotEmpty)
                      InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'UPI / QR (Select 1)',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String?>(
                            isExpanded: true,
                            value: upis.any((u) => u.id == _selectedUpiDetailId)
                                ? _selectedUpiDetailId
                                : (upis.isNotEmpty &&
                                          _selectedUpiDetailId != 'none'
                                      ? upis.first.id
                                      : 'none'),
                            items: [
                              const DropdownMenuItem(
                                value: 'none',
                                child: Text('None'),
                              ),
                              ...upis.map(
                                (u) => DropdownMenuItem(
                                  value: u.id,
                                  child: Text(u.title),
                                ),
                              ),
                            ],
                            onChanged: (val) {
                              setState(() {
                                _selectedUpiDetailId = val;
                              });
                            },
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 14),

        // 2. Customer Notes & Terms Grouped Card
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notes Header & Field
              const Row(
                children: [
                  Icon(
                    Icons.sticky_note_2_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Notes to Customer',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                maxLines: 2,
                minLines: 1,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText:
                      'e.g. Thank you for your business! Please feel free to reach out with any questions.',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                  isDense: true,
                  filled: true,
                  fillColor: AppColors.surfaceVariant.withValues(alpha: 0.35),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              // const Padding(
              //   padding: EdgeInsets.symmetric(vertical: 14),
              //   child: Divider(height: 1, color: AppColors.border),
              // ),
              SizedBox(height: 10),
              // Terms & Conditions Header & Field
              const Row(
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Terms & Conditions',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _termsController,
                maxLines: 3,
                minLines: 1,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText:
                      'e.g. Payment is due within 15 days of invoice date. Late payments incur a 1.5% monthly fee.',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                  isDense: true,
                  filled: true,
                  fillColor: AppColors.surfaceVariant.withValues(alpha: 0.35),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomStickyBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _handleSaveAndPreview,
                icon: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.picture_as_pdf_rounded),
                label: Text(_isSaving ? 'Saving...' : 'Save & Preview'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  shadowColor: AppColors.primary.withValues(alpha: 0.5),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
