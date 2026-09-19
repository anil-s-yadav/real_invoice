import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/status_badge.dart';
import '../../business_profile/bloc/business_profile_bloc.dart';
import '../../business_profile/bloc/business_profile_state.dart';
import '../../business_profile/domain/business_profile_model.dart';
import '../../home/bloc/home_bloc.dart';
import '../../home/bloc/home_event.dart';
import '../../pdf_engine/document_pdf_generator.dart';
import '../../pdf_engine/template_registry.dart';
import '../bloc/document_bloc.dart';
import '../bloc/document_event.dart';
import '../bloc/document_state.dart';
import '../data/document_repository.dart';
import '../domain/document_model.dart';
import 'document_editor_screen.dart';
import 'widgets/payment_entry_sheet.dart';
import 'widgets/template_thumbnail_card.dart';

class PdfPreviewScreen extends StatefulWidget {
  final DocumentModel document;

  const PdfPreviewScreen({super.key, required this.document});

  @override
  State<PdfPreviewScreen> createState() => _PdfPreviewScreenState();
}

class _PdfPreviewScreenState extends State<PdfPreviewScreen> {
  late DocumentModel _document;
  late String _currentTemplateId;

  @override
  void initState() {
    super.initState();
    _document = widget.document;
    _currentTemplateId = widget.document.templateId;
  }

  Future<void> _handleConvertProformaToInvoice() async {
    final repo = context.read<DocumentRepository>();
    final invoice = await repo.convertProformaToInvoice(_document.id);

    if (mounted) {
      final currentLoaded =
          context.read<DocumentBloc>().state as DocumentLoaded?;
      context.read<DocumentBloc>().add(
        LoadDocumentsEvent(
          type: currentLoaded?.typeFilter,
          status: currentLoaded?.statusFilter,
          searchQuery: currentLoaded?.searchQuery ?? '',
          startDate: currentLoaded?.startDateFilter,
          endDate: currentLoaded?.endDateFilter,
        ),
      );
      context.read<HomeBloc>().add(const LoadHomeDataEvent());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Proforma converted to Invoice !'),
          backgroundColor: AppColors.statusPaidText,
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => PdfPreviewScreen(document: invoice)),
      );
    }
  }

  Future<void> _handleConvertToInvoice() async {
    final repo = context.read<DocumentRepository>();
    final invoice = await repo.convertQuotationToInvoice(_document.id);

    if (mounted) {
      final currentLoaded =
          context.read<DocumentBloc>().state as DocumentLoaded?;
      context.read<DocumentBloc>().add(
        LoadDocumentsEvent(
          type: currentLoaded?.typeFilter,
          status: currentLoaded?.statusFilter,
          searchQuery: currentLoaded?.searchQuery ?? '',
          startDate: currentLoaded?.startDateFilter,
          endDate: currentLoaded?.endDateFilter,
        ),
      );
      context.read<HomeBloc>().add(const LoadHomeDataEvent());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Quotation converted to Invoice ${invoice.docNumber}!'),
          backgroundColor: AppColors.statusPaidText,
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => PdfPreviewScreen(document: invoice)),
      );
    }
  }

  Future<void> _handleRecordPayment() async {
    final success = await PaymentEntrySheet.show(context, document: _document);
    if (success == true && mounted) {
      final repo = context.read<DocumentRepository>();
      final updated = await repo.getDocumentById(_document.id);
      if (updated != null && mounted) {
        setState(() => _document = updated);
      }
    }
  }

  void _showTemplateSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (bottomSheetContext) {
        final screenHeight = MediaQuery.of(bottomSheetContext).size.height;
        final templates = TemplateRegistry.getTemplatesFor(_document.docType);

        return Container(
          height: screenHeight * 0.9,
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Template',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: AppColors.textPrimary,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.pop(bottomSheetContext),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: templates.length,
                  itemBuilder: (context, index) {
                    final t = templates[index];
                    final isSelected = t.id == _currentTemplateId;
                    return InkWell(
                      onTap: () {
                        if (!isSelected) {
                          setState(() {
                            _currentTemplateId = t.id;
                            _document = _document.copyWith(templateId: t.id);
                          });
                          context.read<DocumentBloc>().add(
                            SaveDocumentEvent(_document),
                          );
                          Navigator.pop(bottomSheetContext);
                        }
                      },
                      child: IgnorePointer(
                        child: TemplateThumbnailCard(
                          template: t,
                          isSelected: isSelected,
                          documentType: _document.docType,

                          onTap: () {},
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  void _showDocumentSettings() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Document Settings',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Show Payment Details & QR Code'),
                    subtitle: const Text('Include bank and UPI info on PDF'),
                    value: _document.includePaymentDetails,
                    activeThumbColor: AppColors.primary,
                    onChanged: (val) {
                      setStateSheet(() {
                        _document = _document.copyWith(
                          includePaymentDetails: val,
                        );
                      });
                      setState(() {});
                      context.read<DocumentBloc>().add(
                        SaveDocumentEvent(_document),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BusinessProfileBloc, BusinessProfileState>(
      builder: (context, profileState) {
        final profile = profileState is BusinessProfileLoaded
            ? profileState.profile
            : const BusinessProfile();

        return Scaffold(
          appBar: AppBar(
            title: Text(
              '${_document.docType.displayName} ${_document.docNumber}',
            ),
            actions: [
              GestureDetector(
                onTap: _showDocumentSettings,
                child: Icon(Icons.settings_outlined),
              ),
              SizedBox(width: 10),
              GestureDetector(
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          DocumentEditorScreen(initialDocument: _document),
                    ),
                  );
                  if (context.mounted) {
                    final repo = context.read<DocumentRepository>();
                    final updated = await repo.getDocumentById(_document.id);
                    if (updated != null && mounted) {
                      setState(() => _document = updated);
                    }
                  }
                },
                child: Icon(Icons.edit_outlined),
              ),

              TextButton(
                child: const Text("Done"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Quick actions banner (Convert / Record Payment)
                if (_document.docType == DocumentType.quotation &&
                    _document.status != DocumentStatus.accepted &&
                    _document.status != DocumentStatus.cancelled)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.lg,
                    ),
                    color: AppColors.primaryLight,
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Accepted?',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            final updated = _document.copyWith(
                              status: DocumentStatus.accepted,
                            );
                            setState(() => _document = updated);
                            context.read<DocumentBloc>().add(
                              SaveDocumentEvent(updated),
                            );
                          },
                          child: const Text(
                            'Yes',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            final updated = _document.copyWith(
                              status: DocumentStatus.cancelled,
                            );
                            setState(() => _document = updated);
                            context.read<DocumentBloc>().add(
                              SaveDocumentEvent(updated),
                            );
                          },
                          child: const Text(
                            'No',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (_document.docType == DocumentType.quotation &&
                    _document.status == DocumentStatus.accepted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.lg,
                    ),
                    color: AppColors.statusAcceptedBg,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.statusAcceptedText,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Quotation Accepted',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.statusAcceptedText,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _handleConvertToInvoice,
                          child: const Text(
                            'Convert to Invoice',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.statusAcceptedText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (_document.docType == DocumentType.proforma)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.lg,
                    ),
                    color: AppColors.primaryLight,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.transform,
                          color: AppColors.primaryDark,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Finalize Document',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _handleConvertProformaToInvoice,
                          child: const Text(
                            'Convert to Invoice',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (_document.docType == DocumentType.invoice &&
                    _document.balanceDue > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.lg,
                    ),
                    color: AppColors.statusPaidBg,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.payments_outlined,
                          color: AppColors.statusPaidText,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Balance Due: ₹',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.statusPaidText,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _handleRecordPayment,
                          child: const Text(
                            'Record Payment',
                            style: TextStyle(
                              color: AppColors.statusPaidText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Template pill chip indicator
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Template: ',
                            style: AppTypography.bodySmall,
                          ),
                          Text(
                            TemplateRegistry.getById(_currentTemplateId).name,
                            style: AppTypography.titleSmall.copyWith(
                              fontSize: 12,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: _showTemplateSelector,
                        child: Text(
                          'Change Style \u25BE',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Clean styled Native Interactive PDF Viewer
                Expanded(
                  child: PdfPreview(
                    build: (format) => DocumentPdfGenerator.generate(
                      document: _document,
                      profile: profile,
                      templateId: _currentTemplateId,
                    ),
                    previewPageMargin: EdgeInsets.all(5),
                    useActions: true,
                    canChangeOrientation: false,
                    canChangePageFormat: true,
                    canDebug: false,
                    scrollViewDecoration: const BoxDecoration(
                      color: AppColors.canvas,
                    ),
                    pdfPreviewPageDecoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(15),
                          blurRadius: 8,
                          spreadRadius: 0,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    pdfFileName: '${_document.docNumber}.pdf',
                    loadingWidget: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),

                // Custom Bottom Bar for Print & Share
                //
              ],
            ),
          ),
        );
      },
    );
  }
}
