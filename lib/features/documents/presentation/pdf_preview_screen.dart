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
import '../data/document_repository.dart';
import '../domain/document_model.dart';
import 'document_editor_screen.dart';
import 'template_selector_screen.dart';
import 'widgets/payment_entry_sheet.dart';

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

  Future<void> _showTemplateSelector() async {
    final selectedId = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) =>
            TemplateSelectorScreen(initialTemplateId: _currentTemplateId),
      ),
    );

    if (selectedId != null && selectedId != _currentTemplateId && mounted) {
      setState(() {
        _currentTemplateId = selectedId;
        _document = _document.copyWith(templateId: selectedId);
      });
      // Persist template choice to database
      context.read<DocumentBloc>().add(SaveDocumentEvent(_document));
      context.read<HomeBloc>().add(const LoadHomeDataEvent());
    }
  }

  Future<void> _handleConvertToInvoice() async {
    final repo = context.read<DocumentRepository>();
    final invoice = await repo.convertQuotationToInvoice(_document.id);

    if (mounted) {
      context.read<DocumentBloc>().add(const LoadDocumentsEvent());
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
              IconButton(
                icon: const Icon(Icons.palette_outlined),
                tooltip: 'Change Template',
                onPressed: _showTemplateSelector,
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit Document',
                onPressed: () async {
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
              ),
              TextButton(
                child: Text("Done"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Quick actions banner (Convert / Record Payment)
              if (_document.docType == DocumentType.quotation &&
                  _document.status != DocumentStatus.accepted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.lg,
                    vertical: 8,
                  ),
                  color: AppColors.primaryLight,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: AppColors.primaryDark,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Client accepted this quotation?',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: _handleConvertToInvoice,
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
                    vertical: 8,
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
                          'Balance Due: ₹${_document.balanceDue.toStringAsFixed(2)}',
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
                padding: const EdgeInsets.fromLTRB(
                  AppDimensions.lg,
                  8,
                  AppDimensions.lg,
                  4,
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
                        'Change Style (6 available) ▾',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Native Interactive PDF Viewer with local printing & sharing
              Expanded(
                child: PdfPreview(
                  build: (format) => DocumentPdfGenerator.generate(
                    document: _document,
                    profile: profile,
                    templateId: _currentTemplateId,
                  ),
                  canChangeOrientation: false,
                  canChangePageFormat: false,
                  canDebug: false,
                  pdfFileName: '${_document.docNumber}.pdf',
                  loadingWidget: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
