import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'dart:typed_data';
import '../../../core/constants/app_colors.dart';
import '../../business_profile/domain/business_profile_model.dart';
import '../../customers/domain/customer_model.dart';
import '../../pdf_engine/document_pdf_generator.dart';
import '../../pdf_engine/template_registry.dart';
import '../domain/document_item_model.dart';
import '../domain/document_model.dart';

class TemplatePreviewScreen extends StatelessWidget {
  final TemplateInfo template;
  final DocumentType documentType;
  final BusinessProfile profile;
  final bool isDefault;
  final VoidCallback onSetDefault;

  const TemplatePreviewScreen({
    super.key,
    required this.template,
    required this.documentType,
    required this.profile,
    required this.isDefault,
    required this.onSetDefault,
  });

  static Future<void> show({
    required BuildContext context,
    required TemplateInfo template,
    required DocumentType documentType,
    required BusinessProfile profile,
    required bool isDefault,
    required VoidCallback onSetDefault,
    bool showPaymentDetails = true,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => TemplatePreviewScreen(
          template: template,
          documentType: documentType,
          profile: profile,
          isDefault: isDefault,
          onSetDefault: onSetDefault,
        ),
      ),
    );
  }

  DocumentModel _createSampleDocument() {
    final now = DateTime.now();
    return DocumentModel(
      id: 'sample-preview',
      docType: documentType,
      docNumber: '${documentType.prefix}001',
      issueDate: now,
      dueDate: now.add(const Duration(days: 15)),
      createdAt: now,
      updatedAt: now,
      customerSnapshot: Customer(
        id: 'sample-cust',
        name: 'Acme Technologies Pvt Ltd',
        billingAddress:
            '42 Silicon Valley Road, Indiranagar, Bengaluru, KA 560038',
        gstin: '29ABCDE1234F1Z5',
        email: 'billing@acmetech.com',
        phone: '+91 98765 43210',
        createdAt: now,
      ),
      items: const [
        DocumentItem(
          id: '1',
          documentId: 'sample-preview',
          title: 'Design System & Branding',
          description:
              'High-fidelity mobile app UI/UX mockups and design token library',
          quantity: 1.0,
          unitPrice: 28000.0,
          taxPercent: 18.0,
          hsnSacCode: '998314',
        ),
        DocumentItem(
          id: '2',
          documentId: 'sample-preview',
          title: 'Mobile Application Sprint',
          description:
              'Frontend and backend API integration for cross-platform app',
          quantity: 2.0,
          unitPrice: 32000.0,
          taxPercent: 18.0,
          hsnSacCode: '998313',
        ),
      ],
      templateId: template.id,

      notes: 'Thank you for choosing our services!',
      terms:
          '1. Payment due within 15 days from the date of issuance.\n2. In case of late payment, interest @ 1.5% per month will be charged.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final sampleDoc = _createSampleDocument();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Column(
          children: [
            Text(
              template.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '${documentType.displayName} Template Preview',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Close',
        ),
      ),
      body: Column(
        children: [
          // Native Interactive PDF Viewer with zoom/pan
          Expanded(
            child: FutureBuilder<Uint8List?>(
              future: _generatePdfImage(sampleDoc),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return const Center(child: Text('Failed to load preview'));
                }
                return Container(
                  color: AppColors.canvas,
                  child: InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 4.0,
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
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
                        child: Image.memory(snapshot.data!),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Action Bar with "Close" and "Set Default"
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              MediaQuery.of(context).padding.bottom > 0
                  ? MediaQuery.of(context).padding.bottom + 4
                  : 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
              border: const Border(
                top: BorderSide(
                  color: AppColors.border,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // Close Button
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(
                          color: AppColors.borderStrong,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Set Default Button
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        onSetDefault();
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Set Default',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<Uint8List?> _generatePdfImage(DocumentModel sampleDoc) async {
    try {
      final bytes = await DocumentPdfGenerator.generate(
        document: sampleDoc,
        profile: profile,
        templateId: template.id,
      );

      await for (final page in Printing.raster(bytes, pages: [0], dpi: 200)) {
        return await page.toPng();
      }
    } catch (e) {
      debugPrint('Error rasterizing pdf: ');
    }
    return null;
  }
}
