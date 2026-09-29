import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:printing/printing.dart';
import 'package:real_invoice/features/business_profile/domain/business_profile_model.dart';
import 'package:real_invoice/features/documents/domain/document_model.dart';
import 'package:real_invoice/features/pdf_engine/document_pdf_generator.dart';
import 'package:real_invoice/features/pdf_engine/template_registry.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Generate Template Thumbnails', (tester) async {
    // Create full dummy data
    final dummyProfile = BusinessProfile(
      id: 'dummy',
      businessName: 'Acme Corp Ltd.',
      email: 'contact@acmecorp.com',
      phone: '+91 98765 43210',
      address: '123 Tech Park, Innovation Hub\nBangalore, 560001',
      gstin: '29ABCDE1234F1Z5',
      pan: 'ABCDE1234F',
      bankName: 'HDFC Bank',
      accountNumber: '50100234567890',
      ifscCode: 'HDFC0001234',
      upiId: 'acme@okhdfcbank',
      defaultNotes: 'Thank you for your business!',
      defaultTerms: '1. Payment due in 15 days.\n2. Late fee of 1.5% per month applies.',
    );

    final dummyDoc = DocumentModel(
      id: 'dummy_doc',
      businessId: 'dummy',
      docType: DocumentType.invoice,
      docNumber: 'INV-2023-001',
      issueDate: DateTime.now(),
      dueDate: DateTime.now().add(const Duration(days: 15)),
      items: [
        DocumentItem(
          id: '1',
          description: 'Web Development Services',
          quantity: 1,
          unitPrice: 15000,
          taxPercent: 18,
        ),
        DocumentItem(
          id: '2',
          description: 'Server Hosting (1 Year)',
          quantity: 1,
          unitPrice: 5000,
          taxPercent: 18,
        ),
        DocumentItem(
          id: '3',
          description: 'Maintenance Support',
          quantity: 3,
          unitPrice: 2000,
          taxPercent: 18,
        ),
      ],
      subtotal: 26000,
      totalTaxAmount: 4680,
      overallDiscountAmount: 0,
      itemDiscountsTotal: 0,
      totalAmount: 30680,
      balanceDue: 30680,
      totalPaid: 0,
      notes: 'Please review the invoice and process the payment.',
      customerSnapshot: CustomerSnapshot(
        id: 'cust1',
        name: 'Tech Solutions Inc.',
        email: 'accounts@techsolutions.com',
        phone: '+91 99887 76655',
        address: '456 Business Avenue, IT Park\nMumbai, 400001',
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Future<void> generateAndSave(String templateId, String assetPath) async {
      print('Generating PDF for $templateId...');
      final pdfBytes = await DocumentPdfGenerator.generate(
        document: dummyDoc,
        profile: dummyProfile,
        templateId: templateId,
      );

      print('Rasterizing PDF for $templateId...');
      await for (final page in Printing.raster(pdfBytes, pages: [0], dpi: 200)) {
        final pngBytes = await page.toPng();
        final file = File(assetPath);
        await file.create(recursive: true);
        await file.writeAsBytes(pngBytes);
        print('Saved thumbnail to ${file.absolute.path}');
        break; // Only first page
      }
    }

    await generateAndSave(TemplateRegistry.freeClassic, 'assets/images/templates/free_template_thumb.png');
    await generateAndSave(TemplateRegistry.premiumModern, 'assets/images/templates/paid_template_thumb.png');
    
    print('Thumbnails generated successfully!');
  });
}
