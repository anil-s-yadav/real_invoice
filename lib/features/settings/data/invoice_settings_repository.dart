import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../documents/domain/document_model.dart';

class InvoiceSettingsRepository {
  static const String _keyInvoicePrefix = 'invoicePrefix';
  static const String _keyQuotationPrefix = 'quotationPrefix';
  static const String _keyReceiptPrefix = 'receiptPrefix';
  static const String _keyProformaPrefix = 'proformaPrefix';
  static const String _keyIncludeYear = 'includeYear';
  static const String _keyPaddingDigits = 'paddingDigits';

  static const String _keyDefaultTaxRate = 'defaultTaxRate';
  static const String _keyDefaultDiscountRate = 'defaultDiscountRate';
  static const String _keyDefaultTaxLabel = 'defaultTaxLabel';
  static const String _keyDefaultTaxEnabled = 'defaultTaxEnabled';

  DocumentReference<Map<String, dynamic>>? get _settingsRef {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('settings')
        .doc('invoice_settings');
  }

  Future<Map<String, dynamic>> _getSettingsMap() async {
    final ref = _settingsRef;
    if (ref == null) return {};
    
    try {
      final doc = await ref.get();
      if (doc.exists) {
        return doc.data() ?? {};
      }
    } catch (e) {
      print('Error fetching settings: $e');
    }
    return {};
  }

  Future<void> _updateSetting(String key, dynamic value) async {
    final ref = _settingsRef;
    if (ref == null) return;
    
    try {
      await ref.set({key: value}, SetOptions(merge: true));
    } catch (e) {
      print('Error saving setting $key: $e');
    }
  }

  // Numbering preferences
  Future<String> getPrefixForType(DocumentType type) async {
    final data = await _getSettingsMap();
    switch (type) {
      case DocumentType.invoice:
        return data[_keyInvoicePrefix] as String? ?? 'INV-';
      case DocumentType.quotation:
        return data[_keyQuotationPrefix] as String? ?? 'EST-';
      case DocumentType.receipt:
        return data[_keyReceiptPrefix] as String? ?? 'REC-';
      case DocumentType.proforma:
        return data[_keyProformaPrefix] as String? ?? 'PRO-';
    }
  }

  Future<void> setPrefixForType(DocumentType type, String prefix) async {
    switch (type) {
      case DocumentType.invoice:
        await _updateSetting(_keyInvoicePrefix, prefix);
        break;
      case DocumentType.quotation:
        await _updateSetting(_keyQuotationPrefix, prefix);
        break;
      case DocumentType.receipt:
        await _updateSetting(_keyReceiptPrefix, prefix);
        break;
      case DocumentType.proforma:
        await _updateSetting(_keyProformaPrefix, prefix);
        break;
    }
  }

  Future<bool> getIncludeYear() async {
    final data = await _getSettingsMap();
    return data[_keyIncludeYear] as bool? ?? true;
  }

  Future<void> setIncludeYear(bool value) async {
    await _updateSetting(_keyIncludeYear, value);
  }

  Future<int> getPaddingDigits() async {
    final data = await _getSettingsMap();
    return data[_keyPaddingDigits] as int? ?? 4;
  }

  Future<void> setPaddingDigits(int value) async {
    await _updateSetting(_keyPaddingDigits, value);
  }

  // Tax & Discount preferences
  Future<double> getDefaultTaxRate() async {
    final data = await _getSettingsMap();
    final value = data[_keyDefaultTaxRate];
    if (value is num) return value.toDouble();
    return 18.0;
  }

  Future<void> setDefaultTaxRate(double rate) async {
    await _updateSetting(_keyDefaultTaxRate, rate);
  }

  Future<double> getDefaultDiscountRate() async {
    final data = await _getSettingsMap();
    final value = data[_keyDefaultDiscountRate];
    if (value is num) return value.toDouble();
    return 0.0;
  }

  Future<void> setDefaultDiscountRate(double rate) async {
    await _updateSetting(_keyDefaultDiscountRate, rate);
  }

  Future<String> getDefaultTaxLabel() async {
    final data = await _getSettingsMap();
    return data[_keyDefaultTaxLabel] as String? ?? 'GST';
  }

  Future<void> setDefaultTaxLabel(String label) async {
    await _updateSetting(_keyDefaultTaxLabel, label);
  }

  Future<bool> getDefaultTaxEnabled() async {
    final data = await _getSettingsMap();
    return data[_keyDefaultTaxEnabled] as bool? ?? true;
  }

  Future<void> setDefaultTaxEnabled(bool enabled) async {
    await _updateSetting(_keyDefaultTaxEnabled, enabled);
  }
}
