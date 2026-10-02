import 'dart:convert';



import '../../../core/constants/app_constants.dart';

class BusinessProfile {
  final String id;
  final String businessName;
  final String? logoPath;
  final String? phone;
  final String? email;
  final String? address;
  final String? website;
  final String? gstin;
  final String? pan;
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;
  final String? upiId;
  final String? signaturePath;
  final String? stampPath;
  final String defaultTerms;
  final String defaultNotes;
  final String currencyCode;
  final String currencySymbol;
  final String defaultInvoiceTemplateId;
  final String defaultQuotationTemplateId;
  final String defaultReceiptTemplateId;
  final String defaultProformaTemplateId;

  const BusinessProfile({
    this.id = 'default_profile',
    this.businessName = '',
    this.logoPath,
    this.phone,
    this.email,
    this.address,
    this.website,
    this.gstin,
    this.pan,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.upiId,
    this.signaturePath,
    this.stampPath,
    this.defaultTerms =
        '1. Payment is due within 15 days of invoice date.\n2. Please mention invoice number in bank transfer/UPI notes.',
    this.defaultNotes = 'Thank you for your business!',
    this.currencyCode = 'INR',
    this.currencySymbol = '\u20B9',
    this.defaultInvoiceTemplateId = 'modern_crimson',
    this.defaultQuotationTemplateId = 'modern_crimson',
    this.defaultReceiptTemplateId = 'modern_crimson',
    this.defaultProformaTemplateId = 'modern_crimson',
  });

  bool get isConfigured => businessName.trim().isNotEmpty;

  BusinessProfile copyWith({
    String? id,
    String? businessName,
    String? logoPath,
    String? phone,
    String? email,
    String? address,
    String? website,
    String? gstin,
    String? pan,
    String? bankName,
    String? accountNumber,
    String? ifscCode,
    String? upiId,
    String? signaturePath,
    String? stampPath,
    String? defaultTerms,
    String? defaultNotes,
    String? currencyCode,
    String? currencySymbol,
    String? defaultInvoiceTemplateId,
    String? defaultQuotationTemplateId,
    String? defaultReceiptTemplateId,
    String? defaultProformaTemplateId,
  }) {
    return BusinessProfile(
      id: id ?? this.id,
      businessName: businessName ?? this.businessName,
      logoPath: logoPath ?? this.logoPath,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      website: website ?? this.website,
      gstin: gstin ?? this.gstin,
      pan: pan ?? this.pan,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      upiId: upiId ?? this.upiId,
      signaturePath: signaturePath ?? this.signaturePath,
      stampPath: stampPath ?? this.stampPath,
      defaultTerms: defaultTerms ?? this.defaultTerms,
      defaultNotes: defaultNotes ?? this.defaultNotes,
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      defaultInvoiceTemplateId:
          defaultInvoiceTemplateId ?? this.defaultInvoiceTemplateId,
      defaultQuotationTemplateId:
          defaultQuotationTemplateId ?? this.defaultQuotationTemplateId,
      defaultReceiptTemplateId:
          defaultReceiptTemplateId ?? this.defaultReceiptTemplateId,
      defaultProformaTemplateId:
          defaultProformaTemplateId ?? this.defaultProformaTemplateId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'businessName': businessName,
      'logoPath': logoPath,
      'phone': phone,
      'email': email,
      'address': address,
      'website': website,
      'gstin': gstin,
      'pan': pan,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'ifscCode': ifscCode,
      'upiId': upiId,
      'signaturePath': signaturePath,
      'stampPath': stampPath,
      'defaultTerms': defaultTerms,
      'defaultNotes': defaultNotes,
      'currencyCode': currencyCode,
      'currencySymbol': currencySymbol,
      'defaultInvoiceTemplateId': defaultInvoiceTemplateId,
      'defaultQuotationTemplateId': defaultQuotationTemplateId,
      'defaultReceiptTemplateId': defaultReceiptTemplateId,
      'defaultProformaTemplateId': defaultProformaTemplateId,
    };
  }

  factory BusinessProfile.fromMap(Map<String, dynamic> map) {

    return BusinessProfile(
      id: map['id'] as String? ?? 'default_profile',
      businessName: map['businessName'] as String? ?? '',
      logoPath: map['logoPath'] as String?,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      address: map['address'] as String?,
      website: map['website'] as String?,
      gstin: map['gstin'] as String?,
      pan: map['pan'] as String?,
      bankName: map['bankName'] as String?,
      accountNumber: map['accountNumber'] as String?,
      ifscCode: map['ifscCode'] as String?,
      upiId: map['upiId'] as String?,
      signaturePath: map['signaturePath'] as String?,
      stampPath: map['stampPath'] as String?,
      defaultTerms:
          map['defaultTerms'] as String? ?? '1. Payment is due within 15 days.',
      defaultNotes:
          map['defaultNotes'] as String? ?? 'Thank you for your business!',
      currencyCode: map['currencyCode'] as String? ?? 'INR',
      currencySymbol: _sanitizeCurrencySymbol(
        map['currencyCode'] as String? ?? 'INR',
        map['currencySymbol'] as String? ?? '\u20B9',
      ),
      defaultInvoiceTemplateId:
          map['defaultInvoiceTemplateId'] as String? ?? 'modern_crimson',
      defaultQuotationTemplateId:
          map['defaultQuotationTemplateId'] as String? ?? 'modern_crimson',
      defaultReceiptTemplateId:
          map['defaultReceiptTemplateId'] as String? ?? 'modern_crimson',
      defaultProformaTemplateId:
          map['defaultProformaTemplateId'] as String? ?? 'modern_crimson',
    );
  }
  static String _sanitizeCurrencySymbol(String code, String fallback) {
    try {
      final matchingCountry = AppConstants.countries.firstWhere(
          (c) => c['currency'] == code);
      return matchingCountry['symbol']!;
    } catch (e) {
      return fallback;
    }
  }
}