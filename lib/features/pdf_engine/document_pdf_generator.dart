import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/status_badge.dart';
import '../business_profile/domain/business_profile_model.dart';
import '../documents/domain/document_model.dart';
import 'template_registry.dart';

class DocumentPdfGenerator {
  DocumentPdfGenerator._();

  static Future<Uint8List> generate({
    required DocumentModel document,
    required BusinessProfile profile,
    String? templateId,
  }) async {
    // Load fonts: prefer local assets (works offline/debug), fallback to network
    pw.Font font;
    pw.Font boldFont;
    pw.Font fallback;
    try {
      final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
      final boldData = await rootBundle.load('assets/fonts/Roboto-Medium.ttf');
      final fallbackData = await rootBundle.load('assets/fonts/NotoSansDevanagari-Regular.ttf');
      font = pw.Font.ttf(fontData);
      boldFont = pw.Font.ttf(boldData);
      fallback = pw.Font.ttf(fallbackData);
    } catch (_) {
      // Fallback to network fonts if local assets are missing
      font = await PdfGoogleFonts.robotoRegular();
      boldFont = await PdfGoogleFonts.robotoMedium();
      fallback = await PdfGoogleFonts.notoSansDevanagariRegular();
    }

    final pdf = pw.Document(
      title: '${document.docType.displayName} ${document.docNumber}',
      author: profile.businessName.isNotEmpty
          ? profile.businessName
          : 'RedInvoice',
      theme: pw.ThemeData.withFont(
        base: font,
        bold: boldFont,
        fontFallback: [fallback],
      ),
    );

    final selectedTemplate = templateId ?? document.templateId;

    Uint8List? logoBytes;
    if (profile.logoPath != null && profile.logoPath!.isNotEmpty) {
      try {
        final file = File(profile.logoPath!);
        if (await file.exists()) {
          logoBytes = await file.readAsBytes();
        }
      } catch (_) {}
    }

    Uint8List? signatureBytes;
    if (profile.signaturePath != null && profile.signaturePath!.isNotEmpty) {
      try {
        final file = File(profile.signaturePath!);
        if (await file.exists()) {
          signatureBytes = await file.readAsBytes();
        }
      } catch (_) {}
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: _getMargins(selectedTemplate),
        footer: (context) => pw.Container(
          margin: const pw.EdgeInsets.only(top: 16),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'This is a computer generated Document.',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
              ),
              pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
              ),
            ],
          ),
        ),
        build: (context) => _buildTemplateContent(
          context,
          document,
          profile,
          selectedTemplate,
          logoBytes: logoBytes,
          signatureBytes: signatureBytes,
        ),
      ),
    );

    return pdf.save();
  }

  static pw.EdgeInsets _getMargins(String templateId) {
    if (templateId == TemplateRegistry.compact) {
      return const pw.EdgeInsets.all(24);
    }
    return const pw.EdgeInsets.all(32);
  }

  static List<pw.Widget> _buildTemplateContent(
    pw.Context context,
    DocumentModel doc,
    BusinessProfile profile,
    String templateId, {
    Uint8List? logoBytes,
    Uint8List? signatureBytes,
  }) {
    switch (templateId) {
      case TemplateRegistry.sunsetOrange:
        return _buildSunsetOrange(
          context,
          doc,
          profile,
          logoBytes: logoBytes,
          signatureBytes: signatureBytes,
        );
      case TemplateRegistry.minimal:
        return _buildMinimal(context, doc, profile);
      case TemplateRegistry.corporate:
        return _buildCorporate(context, doc, profile);
      case TemplateRegistry.elegant:
        return _buildElegant(context, doc, profile);
      case TemplateRegistry.compact:
        return _buildCompact(context, doc, profile);
      case TemplateRegistry.bold:
        return _buildBold(context, doc, profile);
      case TemplateRegistry.modernCrimson:
      default:
        return _buildModernCrimson(context, doc, profile);
    }
  }

  static String _fmt(double amount, BusinessProfile profile) {
    final sym = profile.currencySymbol.isEmpty
        ? '\u20B9'
        : profile.currencySymbol;
    return CurrencyFormatter.format(amount, symbol: sym);
  }

  // 1. MODERN CRIMSON (Signature RedInvoice style)
  static List<pw.Widget> _buildModernCrimson(
    pw.Context context,
    DocumentModel doc,
    BusinessProfile profile,
  ) {
    final primaryColor = PdfColor.fromHex('C92A2A');
    final darkColor = PdfColor.fromHex('1E2022');
    final grayColor = PdfColor.fromHex('5A6065');
    final lightBg = PdfColor.fromHex('FFF1F2');
    final borderColor = PdfColor.fromHex('E8E2D9');

    return [
      // Top Header
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                profile.businessName.isNotEmpty
                    ? profile.businessName
                    : 'Your Business Name',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              if (profile.address != null && profile.address!.isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 3),
                  child: pw.Text(
                    profile.address!,
                    style: pw.TextStyle(fontSize: 9, color: grayColor),
                  ),
                ),
              if (profile.phone != null || profile.email != null)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 2),
                  child: pw.Text(
                    [
                      profile.phone,
                      profile.email,
                    ].whereType<String>().join('  |  '),
                    style: pw.TextStyle(fontSize: 9, color: grayColor),
                  ),
                ),
              if (profile.gstin != null && profile.gstin!.isNotEmpty)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(top: 2),
                  child: pw.Text(
                    'GSTIN: ${profile.gstin}',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: pw.BoxDecoration(
                  color: lightBg,
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(4),
                  ),
                ),
                child: pw.Text(
                  doc.docType.displayName.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                doc.docNumber,
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Date: ${DateFormatter.format(doc.issueDate)}',
                style: pw.TextStyle(fontSize: 9, color: grayColor),
              ),
              pw.Text(
                'Due Date: ${DateFormatter.format(doc.dueDate)}',
                style: pw.TextStyle(fontSize: 9, color: grayColor),
              ),
              if (doc.status == DocumentStatus.paid) ...[
                pw.SizedBox(height: 4),
                _buildStatusStamp('PAID', PdfColor.fromHex('047857')),
              ],
            ],
          ),
        ],
      ),
      pw.SizedBox(height: 20),

      // Customer Section
      pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: borderColor, width: 1),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        ),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'BILLED TO',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    doc.customerSnapshot?.name ?? 'Walk-in Customer',
                    style: pw.TextStyle(
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                      color: darkColor,
                    ),
                  ),
                  if (doc.customerSnapshot?.billingAddress != null)
                    pw.Text(
                      doc.customerSnapshot!.billingAddress!,
                      style: pw.TextStyle(fontSize: 9, color: grayColor),
                    ),
                  if (doc.customerSnapshot?.phone != null)
                    pw.Text(
                      'Phone: ${doc.customerSnapshot!.phone}',
                      style: pw.TextStyle(fontSize: 9, color: grayColor),
                    ),
                  if (doc.customerSnapshot?.gstin != null)
                    pw.Text(
                      'GSTIN: ${doc.customerSnapshot!.gstin}',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      pw.SizedBox(height: 16),

      // Items Table
      _buildStandardItemsTable(doc, profile, primaryColor, lightBg),
      pw.SizedBox(height: 16),

      // Bottom Section: Payment / UPI + Totals
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 6,
            child: _buildBankAndUpiBlock(profile, doc, primaryColor),
          ),
          pw.SizedBox(width: 20),
          pw.Expanded(
            flex: 5,
            child: _buildTotalsBlock(doc, profile, primaryColor),
          ),
        ],
      ),
      pw.SizedBox(height: 16),

      // Notes & Terms
      if (doc.terms != null || doc.notes != null) _buildTermsAndNotes(doc),
    ];
  }

  // 2. CLASSIC MINIMAL (Swiss minimalist design)
  static List<pw.Widget> _buildMinimal(
    pw.Context context,
    DocumentModel doc,
    BusinessProfile profile,
  ) {
    final blackColor = PdfColors.black;
    final grayColor = PdfColor.fromHex('666666');

    return [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                profile.businessName.isNotEmpty
                    ? profile.businessName
                    : 'Business Name',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (profile.address != null)
                pw.Text(
                  profile.address!,
                  style: pw.TextStyle(fontSize: 9, color: grayColor),
                ),
              if (profile.phone != null)
                pw.Text(
                  profile.phone!,
                  style: pw.TextStyle(fontSize: 9, color: grayColor),
                ),
              if (profile.gstin != null)
                pw.Text(
                  'GSTIN: ${profile.gstin}',
                  style: pw.TextStyle(fontSize: 9),
                ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                doc.docType.displayName.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                doc.docNumber,
                style: pw.TextStyle(fontSize: 11, color: grayColor),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'Date: ${DateFormatter.format(doc.issueDate)}',
                style: pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                'Due: ${DateFormatter.format(doc.dueDate)}',
                style: pw.TextStyle(fontSize: 9),
              ),
            ],
          ),
        ],
      ),
      pw.Divider(thickness: 0.8, color: PdfColors.black),
      pw.SizedBox(height: 12),

      // Client info
      pw.Text(
        'CLIENT',
        style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
      ),
      pw.Text(
        doc.customerSnapshot?.name ?? 'Client',
        style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
      ),
      if (doc.customerSnapshot?.billingAddress != null)
        pw.Text(
          doc.customerSnapshot!.billingAddress!,
          style: pw.TextStyle(fontSize: 9, color: grayColor),
        ),
      pw.SizedBox(height: 16),

      // Table with simple dividers
      _buildStandardItemsTable(
        doc,
        profile,
        blackColor,
        PdfColors.white,
        showHeaderBg: false,
      ),
      pw.SizedBox(height: 16),

      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 5,
            child: _buildBankAndUpiBlock(profile, doc, blackColor),
          ),
          pw.SizedBox(width: 20),
          pw.Expanded(
            flex: 5,
            child: _buildTotalsBlock(doc, profile, blackColor),
          ),
        ],
      ),
      pw.SizedBox(height: 16),
      if (doc.terms != null || doc.notes != null) _buildTermsAndNotes(doc),
    ];
  }

  // 3. CORPORATE PROFESSIONAL (Formal grid with GST columns)
  static List<pw.Widget> _buildCorporate(
    pw.Context context,
    DocumentModel doc,
    BusinessProfile profile,
  ) {
    final navyColor = PdfColor.fromHex('1E3A8A');
    final grayColor = PdfColor.fromHex('475569');
    final lightNavy = PdfColor.fromHex('EFF6FF');

    return [
      pw.Container(
        padding: const pw.EdgeInsets.all(12),
        color: lightNavy,
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  profile.businessName.isNotEmpty
                      ? profile.businessName
                      : 'Enterprise Business',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: navyColor,
                  ),
                ),
                if (profile.gstin != null)
                  pw.Text(
                    'GSTIN / UIN: ${profile.gstin}',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                if (profile.pan != null)
                  pw.Text(
                    'PAN: ${profile.pan}',
                    style: pw.TextStyle(fontSize: 9),
                  ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'TAX ${doc.docType.displayName.toUpperCase()}',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: navyColor,
                  ),
                ),
                pw.Text(
                  'Doc No: ${doc.docNumber}',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Date: ${DateFormatter.format(doc.issueDate)}',
                  style: pw.TextStyle(fontSize: 9),
                ),
              ],
            ),
          ],
        ),
      ),
      pw.SizedBox(height: 12),

      pw.Row(
        children: [
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Buyer (Bill To):',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: navyColor,
                    ),
                  ),
                  pw.Text(
                    doc.customerSnapshot?.name ?? 'Valued Client',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  if (doc.customerSnapshot?.billingAddress != null)
                    pw.Text(
                      doc.customerSnapshot!.billingAddress!,
                      style: pw.TextStyle(fontSize: 8, color: grayColor),
                    ),
                  if (doc.customerSnapshot?.gstin != null)
                    pw.Text(
                      'GSTIN: ${doc.customerSnapshot!.gstin}',
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Supplier / Consignor:',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: navyColor,
                    ),
                  ),
                  pw.Text(
                    profile.businessName,
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  if (profile.address != null)
                    pw.Text(
                      profile.address!,
                      style: pw.TextStyle(fontSize: 8, color: grayColor),
                    ),
                  if (profile.phone != null)
                    pw.Text(
                      'Tel: ${profile.phone}',
                      style: pw.TextStyle(fontSize: 8, color: grayColor),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 12),

      _buildStandardItemsTable(doc, profile, navyColor, lightNavy),
      pw.SizedBox(height: 16),

      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 6,
            child: _buildBankAndUpiBlock(profile, doc, navyColor),
          ),
          pw.SizedBox(width: 20),
          pw.Expanded(
            flex: 5,
            child: _buildTotalsBlock(doc, profile, navyColor),
          ),
        ],
      ),
      pw.SizedBox(height: 16),
      if (doc.terms != null || doc.notes != null) _buildTermsAndNotes(doc),
    ];
  }

  // 4. ARTISAN ELEGANT (Editorial Serif style)
  static List<pw.Widget> _buildElegant(
    pw.Context context,
    DocumentModel doc,
    BusinessProfile profile,
  ) {
    final warmBrown = PdfColor.fromHex('78350F');
    final warmBg = PdfColor.fromHex('FEF3C7');
    final grayColor = PdfColor.fromHex('713F12');

    return [
      pw.Center(
        child: pw.Column(
          children: [
            pw.Text(
              profile.businessName.isNotEmpty
                  ? profile.businessName.toUpperCase()
                  : 'STUDIO ATELIER',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: warmBrown,
                letterSpacing: 2,
              ),
            ),
            if (profile.address != null)
              pw.Text(
                profile.address!,
                style: pw.TextStyle(fontSize: 8, color: grayColor),
              ),
            if (profile.phone != null || profile.email != null)
              pw.Text(
                [
                  profile.phone,
                  profile.email,
                ].whereType<String>().join('  |  '),
                style: pw.TextStyle(fontSize: 8, color: grayColor),
              ),
            pw.SizedBox(height: 8),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 3,
              ),
              decoration: pw.BoxDecoration(
                color: warmBg,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
              ),
              child: pw.Text(
                '${doc.docType.displayName.toUpperCase()}  |  ${doc.docNumber}',
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: warmBrown,
                ),
              ),
            ),
          ],
        ),
      ),
      pw.SizedBox(height: 16),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'PREPARED FOR:',
                style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                  color: warmBrown,
                ),
              ),
              pw.Text(
                doc.customerSnapshot?.name ?? 'Client',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (doc.customerSnapshot?.phone != null)
                pw.Text(
                  doc.customerSnapshot!.phone!,
                  style: pw.TextStyle(fontSize: 8),
                ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'ISSUE DATE: ${DateFormatter.format(doc.issueDate)}',
                style: const pw.TextStyle(fontSize: 8),
              ),
              pw.Text(
                'DUE DATE: ${DateFormatter.format(doc.dueDate)}',
                style: const pw.TextStyle(fontSize: 8),
              ),
            ],
          ),
        ],
      ),
      pw.SizedBox(height: 12),
      _buildStandardItemsTable(doc, profile, warmBrown, warmBg),
      pw.SizedBox(height: 16),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 5,
            child: _buildBankAndUpiBlock(profile, doc, warmBrown),
          ),
          pw.SizedBox(width: 20),
          pw.Expanded(
            flex: 5,
            child: _buildTotalsBlock(doc, profile, warmBrown),
          ),
        ],
      ),
      pw.SizedBox(height: 16),
      if (doc.terms != null || doc.notes != null) _buildTermsAndNotes(doc),
    ];
  }

  // 5. COMPACT SLIP (Single page dense layout)
  static List<pw.Widget> _buildCompact(
    pw.Context context,
    DocumentModel doc,
    BusinessProfile profile,
  ) {
    final charcoal = PdfColor.fromHex('374151');
    final grayColor = PdfColor.fromHex('6B7280');

    return [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            profile.businessName,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: charcoal,
            ),
          ),
          pw.Text(
            '${doc.docType.displayName.toUpperCase()} #${doc.docNumber}',
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
      pw.Text(
        'Date: ${DateFormatter.format(doc.issueDate)}  |  Customer: ${doc.customerSnapshot?.name ?? "General Client"}',
        style: pw.TextStyle(fontSize: 8, color: grayColor),
      ),
      pw.Divider(thickness: 0.5),
      _buildStandardItemsTable(
        doc,
        profile,
        charcoal,
        PdfColors.grey100,
        isCompact: true,
      ),
      pw.SizedBox(height: 8),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 5,
            child: _buildBankAndUpiBlock(
              profile,
              doc,
              charcoal,
              isCompact: true,
            ),
          ),
          pw.SizedBox(width: 12),
          pw.Expanded(
            flex: 5,
            child: _buildTotalsBlock(doc, profile, charcoal),
          ),
        ],
      ),
      if (doc.terms != null) ...[
        pw.SizedBox(height: 8),
        pw.Text('Terms: ${doc.terms}', style: const pw.TextStyle(fontSize: 7)),
      ],
    ];
  }

  // 6. BOLD EDITORIAL (Dark header bar with punchy totals)
  static List<pw.Widget> _buildBold(
    pw.Context context,
    DocumentModel doc,
    BusinessProfile profile,
  ) {
    final darkHeader = PdfColor.fromHex('0F172A');
    final crimson = PdfColor.fromHex('C92A2A');

    return [
      pw.Container(
        padding: const pw.EdgeInsets.all(16),
        decoration: pw.BoxDecoration(
          color: darkHeader,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  profile.businessName.isNotEmpty
                      ? profile.businessName
                      : 'Enterprise',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
                if (profile.phone != null || profile.email != null)
                  pw.Text(
                    [
                      profile.phone,
                      profile.email,
                    ].whereType<String>().join(' | '),
                    style: const pw.TextStyle(
                      fontSize: 8,
                      color: PdfColors.grey400,
                    ),
                  ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  doc.docType.displayName.toUpperCase(),
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: crimson,
                  ),
                ),
                pw.Text(
                  doc.docNumber,
                  style: const pw.TextStyle(
                    fontSize: 11,
                    color: PdfColors.white,
                  ),
                ),
                pw.Text(
                  DateFormatter.format(doc.issueDate),
                  style: const pw.TextStyle(
                    fontSize: 8,
                    color: PdfColors.grey400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      pw.SizedBox(height: 16),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'INVOICE TO:',
                style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                  color: darkHeader,
                ),
              ),
              pw.Text(
                doc.customerSnapshot?.name ?? 'Client',
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              if (doc.customerSnapshot?.billingAddress != null)
                pw.Text(
                  doc.customerSnapshot!.billingAddress!,
                  style: const pw.TextStyle(fontSize: 8),
                ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'AMOUNT DUE',
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey700,
                ),
              ),
              pw.Text(
                _fmt(doc.balanceDue, profile),
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: crimson,
                ),
              ),
            ],
          ),
        ],
      ),
      pw.SizedBox(height: 16),
      _buildStandardItemsTable(doc, profile, darkHeader, PdfColors.grey200),
      pw.SizedBox(height: 16),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 5,
            child: _buildBankAndUpiBlock(profile, doc, darkHeader),
          ),
          pw.SizedBox(width: 20),
          pw.Expanded(
            flex: 5,
            child: _buildTotalsBlock(doc, profile, darkHeader),
          ),
        ],
      ),
      pw.SizedBox(height: 16),
      if (doc.terms != null || doc.notes != null) _buildTermsAndNotes(doc),
    ];
  }

  // --- REUSABLE SUB-BUILDERS ---

  static pw.Widget _buildStandardItemsTable(
    DocumentModel doc,
    BusinessProfile profile,
    PdfColor primaryColor,
    PdfColor headerBg, {
    bool showHeaderBg = true,
    bool isCompact = false,
  }) {
    return pw.TableHelper.fromTextArray(
      border: const pw.TableBorder(
        bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
        horizontalInside: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
      ),
      headerStyle: pw.TextStyle(
        fontSize: isCompact ? 8 : 9,
        fontWeight: pw.FontWeight.bold,
        color: showHeaderBg ? primaryColor : PdfColors.black,
      ),
      headerDecoration: showHeaderBg ? pw.BoxDecoration(color: headerBg) : null,
      cellStyle: pw.TextStyle(fontSize: isCompact ? 7.5 : 8.5),
      cellPadding: pw.EdgeInsets.symmetric(
        horizontal: 6,
        vertical: isCompact ? 4 : 6,
      ),
      columnWidths: {
        0: const pw.FixedColumnWidth(24),
        1: const pw.FlexColumnWidth(4),
        2: const pw.FixedColumnWidth(36),
        3: const pw.FixedColumnWidth(48),
        4: const pw.FixedColumnWidth(40),
        5: const pw.FixedColumnWidth(56),
      },
      headers: ['#', 'Description', 'Qty', 'Rate', 'Tax', 'Amount'],
      data: doc.items.asMap().entries.map((entry) {
        final idx = entry.key + 1;
        final item = entry.value;
        return [
          '$idx',
          '${item.title}${item.description != null && item.description!.isNotEmpty ? "\n${item.description!}" : ""}',
          '${item.quantity % 1 == 0 ? item.quantity.toInt() : item.quantity} ${item.unit}',
          _fmt(item.unitPrice, profile),
          item.taxPercent > 0 ? '${item.taxPercent.toStringAsFixed(0)}%' : '-',
          _fmt(item.lineTotal, profile),
        ];
      }).toList(),
    );
  }

  static pw.Widget _buildTotalsBlock(
    DocumentModel doc,
    BusinessProfile profile,
    PdfColor accentColor,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        _buildRow('Subtotal:', _fmt(doc.subtotal, profile)),
        if (doc.overallDiscountAmount > 0)
          _buildRow(
            'Discount:',
            '- ${_fmt(doc.overallDiscountAmount, profile)}',
          ),
        if (doc.totalTaxAmount > 0)
          _buildRow('Total Tax:', '+ ${_fmt(doc.totalTaxAmount, profile)}'),
        if (doc.roundOff.abs() > 0.001)
          _buildRow(
            'Round Off:',
            doc.roundOff > 0
                ? '+ ${_fmt(doc.roundOff, profile)}'
                : '- ${_fmt(doc.roundOff.abs(), profile)}',
          ),
        pw.Divider(thickness: 1, color: accentColor),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'Total Amount:',
              style: pw.TextStyle(
                fontSize: 11,
                fontWeight: pw.FontWeight.bold,
                color: accentColor,
              ),
            ),
            pw.Text(
              _fmt(doc.totalAmount, profile),
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: accentColor,
              ),
            ),
          ],
        ),
        if (doc.totalPaid > 0) ...[
          pw.SizedBox(height: 3),
          _buildRow('Amount Paid:', _fmt(doc.totalPaid, profile)),
          _buildRow(
            'Balance Due:',
            _fmt(doc.balanceDue, profile),
            isBold: true,
          ),
        ],
        pw.SizedBox(height: 6),
        pw.Text(
          '(${CurrencyFormatter.toWords(doc.totalAmount)})',
          style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700),
          textAlign: pw.TextAlign.right,
        ),
      ],
    );
  }

  static pw.Widget _buildRow(
    String label,
    String value, {
    bool isBold = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 8.5,
              color: isBold ? PdfColors.black : PdfColors.grey700,
              fontWeight: isBold ? pw.FontWeight.bold : null,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 8.5,
              fontWeight: isBold ? pw.FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildBankAndUpiBlock(
    BusinessProfile profile,
    DocumentModel doc,
    PdfColor accentColor, {
    bool isCompact = false,
  }) {
    if (!doc.includePaymentDetails) return pw.Container();

    // Get all Bank details
    var bankDetails = profile.paymentDetails
        .where((p) => p.type == 'Bank')
        .toList();
    // If a specific bank detail is selected, filter it
    if (doc.selectedBankDetailId == 'none') {
      bankDetails = [];
    } else if (doc.selectedBankDetailId != null &&
        doc.selectedBankDetailId!.isNotEmpty) {
      bankDetails = bankDetails
          .where((p) => p.id == doc.selectedBankDetailId)
          .toList();
    } else if (bankDetails.isNotEmpty) {
      // If none selected but we have multiple, default to the first one (since we only show 1 per invoice)
      bankDetails = [bankDetails.first];
    }

    // Legacy fallback if no Bank details exist but old fields are present
    if (bankDetails.isEmpty &&
        doc.selectedBankDetailId != 'none' &&
        profile.bankName != null &&
        profile.bankName!.isNotEmpty) {
      bankDetails.add(
        PaymentDetail(
          id: 'legacy',
          type: 'Bank',
          title: 'Bank Account',
          details: '${profile.accountNumber}',
          extra: profile.ifscCode,
        ),
      );
    }

    // Get all UPI details
    var upiDetails = profile.paymentDetails
        .where((p) => p.type == 'UPI')
        .toList();
    // If a specific UPI detail is selected, filter it
    if (doc.selectedUpiDetailId == 'none') {
      upiDetails = [];
    } else if (doc.selectedUpiDetailId != null &&
        doc.selectedUpiDetailId!.isNotEmpty) {
      upiDetails = upiDetails
          .where((p) => p.id == doc.selectedUpiDetailId)
          .toList();
    } else if (upiDetails.isNotEmpty) {
      // Default to the first one
      upiDetails = [upiDetails.first];
    }

    // Legacy fallback for UPI
    if (upiDetails.isEmpty &&
        doc.selectedUpiDetailId != 'none' &&
        profile.upiId != null &&
        profile.upiId!.isNotEmpty) {
      upiDetails.add(
        PaymentDetail(
          id: 'legacy_upi',
          type: 'UPI',
          title: 'UPI',
          details: profile.upiId!,
        ),
      );
    }

    final hasBank = bankDetails.isNotEmpty;
    final hasUpi = upiDetails.isNotEmpty;

    if (!hasBank && !hasUpi) {
      return pw.Container();
    }

    // Generate UPI QR for the first UPI ID found
    String? upiUri;
    if (hasUpi) {
      final upiId = upiDetails.first.details;
      final name = profile.businessName.isNotEmpty
          ? profile.businessName
          : 'Merchant';
      upiUri =
          'upi://pay?pa=$upiId&pn=${Uri.encodeComponent(name)}&am=${doc.balanceDue.toStringAsFixed(2)}&cu=INR&tn=${Uri.encodeComponent(doc.docNumber)}';
    }

    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          if (hasUpi && upiUri != null) ...[
            pw.Column(
              children: [
                pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: upiUri,
                  width: isCompact ? 50 : 64,
                  height: isCompact ? 50 : 64,
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  'Scan to Pay (UPI)',
                  style: const pw.TextStyle(
                    fontSize: 6.5,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
            ),
            pw.SizedBox(width: 8),
          ],
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'PAYMENT DETAILS',
                  style: pw.TextStyle(
                    fontSize: 7.5,
                    fontWeight: pw.FontWeight.bold,
                    color: accentColor,
                  ),
                ),
                if (hasUpi)
                  ...upiDetails.map(
                    (u) => pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 2),
                      child: pw.Text(
                        'UPI (${u.title}): ${u.details}',
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (hasBank)
                  ...bankDetails.map(
                    (b) => pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 4),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Bank: ${b.title}',
                            style: const pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            'A/C No: ${b.details}',
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                          if (b.extra != null && b.extra!.isNotEmpty)
                            pw.Text(
                              'IFSC: ${b.extra}',
                              style: const pw.TextStyle(fontSize: 8),
                            ),
                        ],
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

  static pw.Widget _buildTermsAndNotes(DocumentModel doc) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (doc.terms != null && doc.terms!.isNotEmpty) ...[
          pw.Text(
            'Terms & Conditions:',
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            doc.terms!,
            style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 6),
        ],
        if (doc.notes != null && doc.notes!.isNotEmpty) ...[
          pw.Text(
            'Note:',
            style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            doc.notes!,
            style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey700),
          ),
        ],
      ],
    );
  }

  static pw.Widget _buildStatusStamp(String text, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: color, width: 1.2),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  // 7. SUNSET ORANGE (Quotation template with peach party cards & bold orange banner)
  static List<pw.Widget> _buildSunsetOrange(
    pw.Context context,
    DocumentModel doc,
    BusinessProfile profile, {
    Uint8List? logoBytes,
    Uint8List? signatureBytes,
  }) {
    final orangeColor = PdfColor.fromHex('F26522');
    final lightPeachBg = PdfColor.fromHex('FFF3EC');
    final darkColor = PdfColor.fromHex('1F2937');
    final grayColor = PdfColor.fromHex('5A6065');
    final greenColor = PdfColor.fromHex('16A34A');
    final borderColor = PdfColor.fromHex('FED7AA');

    // Determine place of supply
    String placeOfSupply = 'Karnataka';
    if (doc.customerSnapshot?.billingAddress != null &&
        doc.customerSnapshot!.billingAddress!.isNotEmpty) {
      final parts = doc.customerSnapshot!.billingAddress!.split(',');
      if (parts.isNotEmpty) {
        placeOfSupply = parts.last.trim();
      }
    } else if (profile.address != null && profile.address!.isNotEmpty) {
      final parts = profile.address!.split(',');
      if (parts.isNotEmpty) {
        placeOfSupply = parts.last.trim();
      }
    }

    return [
      // Centered Top Title (e.g. Quotation)
      pw.Center(
        child: pw.Text(
          doc.docType.displayName,
          style: pw.TextStyle(
            fontSize: 22,
            fontWeight: pw.FontWeight.bold,
            color: orangeColor,
          ),
        ),
      ),
      pw.SizedBox(height: 12),

      // Brand Logo / Name (Left) and Meta Data (Right)
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          // Left: Brand Logo & Name
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              if (logoBytes != null) ...[
                pw.Container(
                  width: 44,
                  height: 44,
                  child: pw.Image(
                    pw.MemoryImage(logoBytes),
                    fit: pw.BoxFit.contain,
                  ),
                ),
                pw.SizedBox(width: 10),
              ],
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    profile.businessName.isNotEmpty
                        ? profile.businessName.toUpperCase()
                        : 'YOUR BUSINESS',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: darkColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (profile.website != null && profile.website!.isNotEmpty)
                    pw.Text(
                      profile.website!,
                      style: pw.TextStyle(fontSize: 8.5, color: grayColor),
                    ),
                ],
              ),
            ],
          ),
          // Right: Document meta
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Row(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text(
                    '${doc.docType.displayName}#',
                    style: pw.TextStyle(fontSize: 9, color: grayColor),
                  ),
                  pw.SizedBox(width: 14),
                  pw.Text(
                    doc.docNumber,
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: darkColor,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 3),
              pw.Row(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text(
                    '${doc.docType.displayName} Date',
                    style: pw.TextStyle(fontSize: 9, color: grayColor),
                  ),
                  pw.SizedBox(width: 14),
                  pw.Text(
                    DateFormatter.format(doc.issueDate).toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: darkColor,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 3),
              pw.Row(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text(
                    'Due Date',
                    style: pw.TextStyle(fontSize: 9, color: grayColor),
                  ),
                  pw.SizedBox(width: 14),
                  pw.Text(
                    DateFormatter.format(doc.dueDate).toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: darkColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      pw.SizedBox(height: 16),

      // Two Peach Tinted Party Cards
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Left: Quotation by
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: lightPeachBg,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                border: pw.Border.all(color: borderColor, width: 0.5),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '${doc.docType.displayName} by',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: orangeColor,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    profile.businessName.isNotEmpty
                        ? profile.businessName
                        : 'Your Business Name',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: darkColor,
                    ),
                  ),
                  if (profile.address != null &&
                      profile.address!.isNotEmpty) ...[
                    pw.SizedBox(height: 2),
                    pw.Text(
                      profile.address!,
                      style: pw.TextStyle(fontSize: 8, color: grayColor),
                    ),
                  ],
                  if (profile.phone != null || profile.email != null) ...[
                    pw.SizedBox(height: 2),
                    pw.Text(
                      [
                        profile.phone,
                        profile.email,
                      ].whereType<String>().join('  |  '),
                      style: pw.TextStyle(fontSize: 8, color: grayColor),
                    ),
                  ],
                  if (profile.gstin != null && profile.gstin!.isNotEmpty) ...[
                    pw.SizedBox(height: 4),
                    pw.Row(
                      children: [
                        pw.SizedBox(
                          width: 36,
                          child: pw.Text(
                            'GSTIN',
                            style: pw.TextStyle(
                              fontSize: 7.5,
                              fontWeight: pw.FontWeight.bold,
                              color: darkColor,
                            ),
                          ),
                        ),
                        pw.Text(
                          profile.gstin!,
                          style: pw.TextStyle(fontSize: 7.5, color: darkColor),
                        ),
                      ],
                    ),
                  ],
                  if (profile.pan != null && profile.pan!.isNotEmpty) ...[
                    pw.SizedBox(height: 2),
                    pw.Row(
                      children: [
                        pw.SizedBox(
                          width: 36,
                          child: pw.Text(
                            'PAN',
                            style: pw.TextStyle(
                              fontSize: 7.5,
                              fontWeight: pw.FontWeight.bold,
                              color: darkColor,
                            ),
                          ),
                        ),
                        pw.Text(
                          profile.pan!,
                          style: pw.TextStyle(fontSize: 7.5, color: darkColor),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          pw.SizedBox(width: 12),
          // Right: Quotation to
          pw.Expanded(
            child: pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: lightPeachBg,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                border: pw.Border.all(color: borderColor, width: 0.5),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '${doc.docType.displayName} to',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: orangeColor,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    doc.customerSnapshot?.name ?? 'Valued Customer',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: darkColor,
                    ),
                  ),
                  if (doc.customerSnapshot?.billingAddress != null &&
                      doc.customerSnapshot!.billingAddress!.isNotEmpty) ...[
                    pw.SizedBox(height: 2),
                    pw.Text(
                      doc.customerSnapshot!.billingAddress!,
                      style: pw.TextStyle(fontSize: 8, color: grayColor),
                    ),
                  ],
                  if (doc.customerSnapshot?.phone != null) ...[
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Phone: ${doc.customerSnapshot!.phone!}',
                      style: pw.TextStyle(fontSize: 8, color: grayColor),
                    ),
                  ],
                  if (doc.customerSnapshot?.gstin != null &&
                      doc.customerSnapshot!.gstin!.isNotEmpty) ...[
                    pw.SizedBox(height: 4),
                    pw.Row(
                      children: [
                        pw.SizedBox(
                          width: 36,
                          child: pw.Text(
                            'GSTIN',
                            style: pw.TextStyle(
                              fontSize: 7.5,
                              fontWeight: pw.FontWeight.bold,
                              color: darkColor,
                            ),
                          ),
                        ),
                        pw.Text(
                          doc.customerSnapshot!.gstin!,
                          style: pw.TextStyle(fontSize: 7.5, color: darkColor),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 6),

      // Place of Supply & Country of Supply Row
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(
            children: [
              pw.Text(
                'Place of Supply   ',
                style: pw.TextStyle(fontSize: 8, color: grayColor),
              ),
              pw.Text(
                placeOfSupply,
                style: pw.TextStyle(
                  fontSize: 8.5,
                  fontWeight: pw.FontWeight.bold,
                  color: darkColor,
                ),
              ),
            ],
          ),
          pw.Row(
            children: [
              pw.Text(
                'Country of Supply   ',
                style: pw.TextStyle(fontSize: 8, color: grayColor),
              ),
              pw.Text(
                'India',
                style: pw.TextStyle(
                  fontSize: 8.5,
                  fontWeight: pw.FontWeight.bold,
                  color: darkColor,
                ),
              ),
            ],
          ),
        ],
      ),
      pw.SizedBox(height: 12),

      // Items Table with alternating rows
      pw.Table(
        columnWidths: {
          0: const pw.FlexColumnWidth(5),
          1: const pw.FixedColumnWidth(40),
          2: const pw.FixedColumnWidth(65),
          3: const pw.FixedColumnWidth(75),
        },
        children: [
          // Table Header
          pw.TableRow(
            decoration: pw.BoxDecoration(color: orangeColor),
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                child: pw.Text(
                  'Item # / Item description',
                  style: pw.TextStyle(
                    fontSize: 8.5,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 6,
                ),
                child: pw.Text(
                  'Qty.',
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    fontSize: 8.5,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 6,
                ),
                child: pw.Text(
                  'Rate',
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    fontSize: 8.5,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                child: pw.Text(
                  'Amount',
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                    fontSize: 8.5,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ),
            ],
          ),
          // Table Rows
          ...doc.items.asMap().entries.map((entry) {
            final idx = entry.key + 1;
            final item = entry.value;
            final isPeachRow = entry.key % 2 == 1;
            return pw.TableRow(
              decoration: pw.BoxDecoration(
                color: isPeachRow ? lightPeachBg : PdfColors.white,
              ),
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        '$idx. ${item.title}',
                        style: pw.TextStyle(
                          fontSize: 8.5,
                          fontWeight: pw.FontWeight.bold,
                          color: darkColor,
                        ),
                      ),
                      if (item.description != null &&
                          item.description!.isNotEmpty)
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(top: 1),
                          child: pw.Text(
                            item.description!,
                            style: pw.TextStyle(
                              fontSize: 7.5,
                              color: grayColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 6,
                  ),
                  child: pw.Text(
                    '${item.quantity % 1 == 0 ? item.quantity.toInt() : item.quantity}',
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(fontSize: 8.5, color: darkColor),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 6,
                  ),
                  child: pw.Text(
                    _fmt(item.unitPrice, profile),
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(fontSize: 8.5, color: darkColor),
                  ),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: pw.Text(
                    _fmt(item.lineTotal, profile),
                    textAlign: pw.TextAlign.right,
                    style: pw.TextStyle(fontSize: 8.5, color: darkColor),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
      pw.SizedBox(height: 16),

      // Bottom Area: Left (Terms, Notes, Enquiry, Bank/UPI) | Right (Totals, In Words, Signature)
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Left Column
          pw.Expanded(
            flex: 5,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (doc.terms != null && doc.terms!.isNotEmpty) ...[
                  pw.Text(
                    'Terms and Conditions',
                    style: pw.TextStyle(
                      fontSize: 9.5,
                      fontWeight: pw.FontWeight.bold,
                      color: orangeColor,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    doc.terms!,
                    style: pw.TextStyle(
                      fontSize: 7.5,
                      color: darkColor,
                      lineSpacing: 1.4,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                ],
                if (doc.notes != null && doc.notes!.isNotEmpty) ...[
                  pw.Text(
                    'Additional Notes',
                    style: pw.TextStyle(
                      fontSize: 9.5,
                      fontWeight: pw.FontWeight.bold,
                      color: orangeColor,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    doc.notes!,
                    style: pw.TextStyle(
                      fontSize: 7.5,
                      color: darkColor,
                      lineSpacing: 1.4,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                ],
                if (doc.includePaymentDetails) ...[
                  _buildBankAndUpiBlock(
                    profile,
                    doc,
                    orangeColor,
                    isCompact: true,
                  ),
                  pw.SizedBox(height: 10),
                ],
                if (profile.email != null || profile.phone != null) ...[
                  pw.SizedBox(height: 4),
                  pw.RichText(
                    text: pw.TextSpan(
                      style: pw.TextStyle(fontSize: 7.5, color: darkColor),
                      children: [
                        const pw.TextSpan(
                          text: 'For any enquiries, email us on ',
                        ),
                        if (profile.email != null)
                          pw.TextSpan(
                            text: profile.email!,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        if (profile.email != null && profile.phone != null)
                          const pw.TextSpan(text: ' or call us on '),
                        if (profile.phone != null)
                          pw.TextSpan(
                            text: profile.phone!,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          pw.SizedBox(width: 24),
          // Right Column
          pw.Expanded(
            flex: 4,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // Sub Total
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Sub Total',
                      style: pw.TextStyle(fontSize: 9, color: darkColor),
                    ),
                    pw.Text(
                      _fmt(doc.subtotal, profile),
                      style: pw.TextStyle(
                        fontSize: 9.5,
                        fontWeight: pw.FontWeight.bold,
                        color: darkColor,
                      ),
                    ),
                  ],
                ),
                if (doc.overallDiscountAmount > 0) ...[
                  pw.SizedBox(height: 4),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Discount(${doc.overallDiscountValue % 1 == 0 ? doc.overallDiscountValue.toInt() : doc.overallDiscountValue}%)',
                        style: pw.TextStyle(
                          fontSize: 8.5,
                          color: greenColor,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        '- ${_fmt(doc.overallDiscountAmount, profile)}',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: greenColor,
                        ),
                      ),
                    ],
                  ),
                ],
                if (doc.totalTaxAmount > 0) ...[
                  pw.SizedBox(height: 4),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Tax Amount',
                        style: pw.TextStyle(fontSize: 8.5, color: darkColor),
                      ),
                      pw.Text(
                        '+ ${_fmt(doc.totalTaxAmount, profile)}',
                        style: pw.TextStyle(fontSize: 9, color: darkColor),
                      ),
                    ],
                  ),
                ],
                if (doc.shippingCharges > 0) ...[
                  pw.SizedBox(height: 4),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Shipping Charges',
                        style: pw.TextStyle(fontSize: 8.5, color: darkColor),
                      ),
                      pw.Text(
                        '+ ${_fmt(doc.shippingCharges, profile)}',
                        style: pw.TextStyle(fontSize: 9, color: darkColor),
                      ),
                    ],
                  ),
                ],
                if (doc.roundOff.abs() > 0.001) ...[
                  pw.SizedBox(height: 4),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Round Off',
                        style: pw.TextStyle(fontSize: 8.5, color: grayColor),
                      ),
                      pw.Text(
                        doc.roundOff > 0
                            ? '+ ${_fmt(doc.roundOff, profile)}'
                            : '- ${_fmt(doc.roundOff.abs(), profile)}',
                        style: pw.TextStyle(fontSize: 8.5, color: grayColor),
                      ),
                    ],
                  ),
                ],
                pw.SizedBox(height: 8),
                pw.Divider(thickness: 0.8, color: PdfColors.grey300),
                pw.SizedBox(height: 4),
                // Total
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Total',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        color: darkColor,
                      ),
                    ),
                    pw.Text(
                      _fmt(doc.totalAmount, profile),
                      style: pw.TextStyle(
                        fontSize: 15,
                        fontWeight: pw.FontWeight.bold,
                        color: darkColor,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 6),
                // In words
                pw.Text(
                  'Invoice Total (In words)',
                  style: pw.TextStyle(fontSize: 7, color: grayColor),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  CurrencyFormatter.toWords(doc.totalAmount),
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    color: darkColor,
                  ),
                ),

                if (doc.totalPaid > 0) ...[
                  pw.SizedBox(height: 6),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Amount Paid:',
                        style: pw.TextStyle(fontSize: 8, color: grayColor),
                      ),
                      pw.Text(
                        _fmt(doc.totalPaid, profile),
                        style: pw.TextStyle(
                          fontSize: 8.5,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Balance Due:',
                        style: pw.TextStyle(
                          fontSize: 8.5,
                          fontWeight: pw.FontWeight.bold,
                          color: orangeColor,
                        ),
                      ),
                      pw.Text(
                        _fmt(doc.balanceDue, profile),
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: orangeColor,
                        ),
                      ),
                    ],
                  ),
                ],

                // Signature block
                pw.SizedBox(height: 20),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      if (signatureBytes != null)
                        pw.Container(
                          height: 38,
                          child: pw.Image(
                            pw.MemoryImage(signatureBytes),
                            fit: pw.BoxFit.contain,
                          ),
                        )
                      else
                        pw.Container(
                          height: 28,
                          width: 80,
                          alignment: pw.Alignment.bottomCenter,
                          child: pw.Divider(thickness: 0.5, color: darkColor),
                        ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        'Authorized Signature',
                        style: pw.TextStyle(
                          fontSize: 8,
                          fontWeight: pw.FontWeight.bold,
                          color: darkColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ];
  }
}
