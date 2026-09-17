import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/status_badge.dart';
import '../../business_profile/bloc/business_profile_bloc.dart';
import '../../business_profile/bloc/business_profile_state.dart';
import '../../customers/domain/customer_model.dart';
import '../../home/bloc/home_bloc.dart';
import '../../home/bloc/home_event.dart';
import '../bloc/document_bloc.dart';
import '../bloc/document_event.dart';
import '../data/document_repository.dart';
import '../domain/document_item_model.dart';
import '../domain/document_model.dart';
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

  @override
  void initState() {
    super.initState();
    final doc = widget.initialDocument;
    _documentId = doc?.id ?? const Uuid().v4();
    _docType = doc?.docType ?? widget.initialType;
    _docNumberController = TextEditingController(text: doc?.docNumber ?? '');
    _issueDate = doc?.issueDate ?? DateTime.now();
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

    // If new document, prefill document number and default notes/terms from profile
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
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one line item to this document.'),
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
      Navigator.of(context).push(
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
      appBar: AppBar(
        title: Text(
          widget.initialDocument != null
              ? 'Edit ${_docType.displayName}'
              : 'New ${_docType.displayName}',
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _handleSaveDraft,
            child: const Text(
              'Save Draft',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.lg,
            AppDimensions.sm,
            AppDimensions.lg,
            100, // Room for bottom sticky bar
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Document Type Switcher Pills
              _buildDocTypePills(),
              const SizedBox(height: AppDimensions.lg),

              // 2. Document Meta Card (Number + Dates)
              _buildMetaCard(),
              const SizedBox(height: AppDimensions.lg),

              // 3. Customer Section
              _buildCustomerSection(),
              const SizedBox(height: AppDimensions.lg),

              // 4. Line Items Section
              _buildItemsSection(),
              const SizedBox(height: AppDimensions.lg),

              // 5. Totals & Tax Summary Card
              if (_items.isNotEmpty) ...[
                _buildSummaryCard(),
                const SizedBox(height: AppDimensions.lg),
              ],

              // 6. Notes & Terms Accordion
              _buildNotesTermsSection(),
            ],
          ),
        ),
      ),
      bottomSheet: _buildBottomStickyBar(),
    );
  }

  Widget _buildDocTypePills() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: DocumentType.values.map((type) {
          final isSelected = _docType == type;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(type.displayName),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 13,
              ),
              side: BorderSide(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: 1.2,
              ),
              onSelected: (selected) async {
                if (selected && _docType != type) {
                  setState(() => _docType = type);
                  final nextNum = await context
                      .read<DocumentRepository>()
                      .getNextDocumentNumber(type);
                  if (mounted) {
                    setState(() => _docNumberController.text = nextNum);
                  }
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMetaCard() {
    return AppCard(
      child: Column(
        children: [
          AppTextField(
            controller: _docNumberController,
            label: '${_docType.displayName} Number',
            hint: 'e.g. INV-2026-0001',
            textCapitalization: TextCapitalization.characters,
            prefix: const Icon(Icons.tag, size: 18, color: AppColors.textMuted),
          ),
          const SizedBox(height: AppDimensions.md),
          Row(
            children: [
              Expanded(
                child: _buildDateTile(
                  label: '${_docType.displayName} Date',
                  dateStr: DateFormatter.format(_issueDate),
                  onTap: _selectIssueDate,
                  icon: Icons.calendar_today_outlined,
                ),
              ),
              const SizedBox(width: AppDimensions.md),
              Expanded(
                child: _buildDateTile(
                  label: _docType == DocumentType.quotation
                      ? 'Valid Until'
                      : 'Due Date',
                  dateStr: DateFormatter.format(_dueDate),
                  onTap: _selectDueDate,
                  icon: Icons.event_available_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateTile({
    required String label,
    required String dateStr,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppDimensions.roundedMd,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: AppDimensions.roundedMd,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTypography.bodySmall.copyWith(fontSize: 11)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(icon, size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    dateStr,
                    style: AppTypography.titleSmall.copyWith(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Billed To (Customer)',
                style: AppTypography.titleSmall.copyWith(fontSize: 13),
              ),
              if (_selectedCustomer != null)
                TextButton(
                  onPressed: () async {
                    final customer = await CustomerSelectSheet.show(
                      context,
                      current: _selectedCustomer,
                    );
                    if (customer != null) {
                      setState(() => _selectedCustomer = customer);
                    }
                  },
                  child: const Text('Change', style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
          const SizedBox(height: 6),
          if (_selectedCustomer == null)
            AppButton(
              label: 'Select or Add Customer',
              variant: AppButtonVariant.outline,
              icon: Icons.person_add_outlined,
              onPressed: () async {
                final customer = await CustomerSelectSheet.show(context);
                if (customer != null) {
                  setState(() => _selectedCustomer = customer);
                }
              },
            )
          else
            Container(
              padding: const EdgeInsets.all(AppDimensions.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: AppDimensions.roundedMd,
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(
                      Icons.person,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedCustomer!.name,
                          style: AppTypography.titleMedium,
                        ),
                        if (_selectedCustomer!.phone != null)
                          Text(
                            _selectedCustomer!.phone!,
                            style: AppTypography.bodySmall,
                          ),
                        if (_selectedCustomer!.gstin != null)
                          Text(
                            'GSTIN: ${_selectedCustomer!.gstin}',
                            style: AppTypography.bodySmall,
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      size: 18,
                      color: AppColors.textMuted,
                    ),
                    onPressed: () => setState(() => _selectedCustomer = null),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildItemsSection() {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Items & Services (${_items.length})',
                style: AppTypography.titleSmall.copyWith(fontSize: 13),
              ),
              Text(
                'Subtotal: ${CurrencyFormatter.format(_subtotal)}',
                style: AppTypography.tabularNumbers.copyWith(
                  fontSize: 13,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.md),
          if (_items.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 36,
                    color: AppColors.borderStrong,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No items added yet',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 180,
                    child: AppButton(
                      label: 'Add First Item',
                      icon: Icons.add,
                      variant: AppButtonVariant.primary,
                      height: 38,
                      onPressed: () async {
                        final item = await ItemEntrySheet.show(
                          context,
                          documentId: _documentId,
                        );
                        if (item != null) setState(() => _items.add(item));
                      },
                    ),
                  ),
                ],
              ),
            )
          else ...[
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _items.length,
              separatorBuilder: (context, index) => const Divider(height: 16),
              itemBuilder: (context, index) {
                final item = _items[index];
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final updated = await ItemEntrySheet.show(
                            context,
                            documentId: _documentId,
                            item: item,
                          );
                          if (updated != null) {
                            setState(() => _items[index] = updated);
                          }
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: AppTypography.titleMedium.copyWith(
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${item.quantity % 1 == 0 ? item.quantity.toInt() : item.quantity} ${item.unit} × ${CurrencyFormatter.format(item.unitPrice)}'
                              '${item.taxPercent > 0 ? " + GST ${item.taxPercent.toStringAsFixed(0)}%" : ""}'
                              '${item.discountPercent > 0 ? " (${item.discountPercent.toStringAsFixed(0)}% off)" : ""}',
                              style: AppTypography.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      CurrencyFormatter.format(item.lineTotal),
                      style: AppTypography.moneyMedium,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: AppColors.statusOverdueText,
                      ),
                      padding: const EdgeInsets.only(left: 8),
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        setState(() => _items.removeAt(index));
                      },
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: AppDimensions.md),
            AppButton(
              label: 'Add Another Item',
              icon: Icons.add,
              variant: AppButtonVariant.outline,
              height: 40,
              onPressed: () async {
                final item = await ItemEntrySheet.show(
                  context,
                  documentId: _documentId,
                );
                if (item != null) setState(() => _items.add(item));
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return AppCard(
      backgroundColor: AppColors.surfaceVariant,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal', style: AppTypography.bodyMedium),
              Text(
                CurrencyFormatter.format(_subtotal),
                style: AppTypography.tabularNumbers,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Overall Discount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('Discount', style: AppTypography.bodyMedium),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _showDiscountDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        _overallDiscountValue > 0
                            ? (_overallDiscountType == DiscountType.percentage
                                  ? '${_overallDiscountValue.toStringAsFixed(0)}% (Tap to edit)'
                                  : '₹${_overallDiscountValue.toStringAsFixed(0)} (Tap to edit)')
                            : '+ Add',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (_overallDiscountAmount > 0)
                Text(
                  '- ${CurrencyFormatter.format(_overallDiscountAmount)}',
                  style: AppTypography.tabularNumbers.copyWith(
                    color: AppColors.statusOverdueText,
                  ),
                )
              else
                const Text('₹ 0.00', style: AppTypography.tabularNumbers),
            ],
          ),
          if (_taxTotal > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total GST (Taxes)',
                  style: AppTypography.bodyMedium,
                ),
                Text(
                  '+ ${CurrencyFormatter.format(_taxTotal)}',
                  style: AppTypography.tabularNumbers.copyWith(
                    color: AppColors.accentNavy,
                  ),
                ),
              ],
            ),
          ],
          if (_roundOff.abs() > 0.001) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Round Off', style: AppTypography.bodySmall),
                Text(
                  _roundOff > 0
                      ? '+ ₹${_roundOff.toStringAsFixed(2)}'
                      : '- ₹${_roundOff.abs().toStringAsFixed(2)}',
                  style: AppTypography.tabularNumbers.copyWith(fontSize: 12),
                ),
              ],
            ),
          ],
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                CurrencyFormatter.format(_finalTotal),
                style: AppTypography.moneyHero.copyWith(
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDiscountDialog() {
    final controller = TextEditingController(
      text: _overallDiscountValue > 0 ? _overallDiscountValue.toString() : '',
    );
    DiscountType tempType = _overallDiscountType;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Overall Document Discount'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Percentage (%)'),
                      selected: tempType == DiscountType.percentage,
                      onSelected: (s) {
                        if (s) {
                          setDialogState(
                            () => tempType = DiscountType.percentage,
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Flat Amount (₹)'),
                      selected: tempType == DiscountType.fixed,
                      onSelected: (s) {
                        if (s) {
                          setDialogState(() => tempType = DiscountType.fixed);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                autofocus: true,
                decoration: InputDecoration(
                  labelText: tempType == DiscountType.percentage
                      ? 'Discount %'
                      : 'Discount Amount (₹)',
                  hintText: '0',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _overallDiscountValue = 0.0;
                });
                Navigator.of(ctx).pop();
              },
              child: const Text('Remove Discount'),
            ),
            ElevatedButton(
              onPressed: () {
                final val = double.tryParse(controller.text.trim()) ?? 0.0;
                setState(() {
                  _overallDiscountValue = val;
                  _overallDiscountType = tempType;
                });
                Navigator.of(ctx).pop();
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesTermsSection() {
    return AppCard(
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(
          'Payment Terms & Notes',
          style: AppTypography.titleSmall.copyWith(fontSize: 14),
        ),
        subtitle: const Text(
          'Add bank details, payment instructions or thanks',
          style: AppTypography.bodySmall,
        ),
        children: [
          const SizedBox(height: AppDimensions.sm),
          AppTextField(
            controller: _termsController,
            label: 'Terms & Conditions',
            hint: 'e.g. Payment due in 15 days; Late fees apply',
            maxLines: 3,
          ),
          const SizedBox(height: AppDimensions.md),
          AppTextField(
            controller: _notesController,
            label: 'Notes / Remarks for Customer',
            hint: 'e.g. Thank you for your business!',
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomStickyBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, -2),
            blurRadius: 6,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.lg,
        vertical: AppDimensions.md,
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total Payable', style: AppTypography.bodySmall),
              Text(
                CurrencyFormatter.format(_finalTotal),
                style: AppTypography.moneyLarge.copyWith(
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(width: AppDimensions.lg),
          Expanded(
            child: AppButton(
              label: 'Preview & PDF',
              icon: Icons.picture_as_pdf_outlined,
              isLoading: _isSaving,
              onPressed: _items.isNotEmpty ? _handleSaveAndPreview : null,
            ),
          ),
        ],
      ),
    );
  }
}
