import 'package:shared_preferences/shared_preferences.dart';
import '../../documents/domain/document_model.dart';

class InvoiceSettingsRepository {
  static const String _keyInvoicePrefix = 'numbering_invoice_prefix';
  static const String _keyQuotationPrefix = 'numbering_quotation_prefix';
  static const String _keyReceiptPrefix = 'numbering_receipt_prefix';
  static const String _keyProformaPrefix = 'numbering_proforma_prefix';
  static const String _keyIncludeYear = 'numbering_include_year';
  static const String _keyPaddingDigits = 'numbering_padding_digits';

  static const String _keyDefaultTaxRate = 'default_tax_rate';
  static const String _keyDefaultDiscountRate = 'default_discount_rate';
  static const String _keyDefaultTaxLabel = 'default_tax_label';
  static const String _keyDefaultTaxEnabled = 'default_tax_enabled';

  // Numbering preferences
  Future<String> getPrefixForType(DocumentType type) async {
    final prefs = await SharedPreferences.getInstance();
    switch (type) {
      case DocumentType.invoice:
        return prefs.getString(_keyInvoicePrefix) ?? 'INV-';
      case DocumentType.quotation:
        return prefs.getString(_keyQuotationPrefix) ?? 'EST-';
      case DocumentType.receipt:
        return prefs.getString(_keyReceiptPrefix) ?? 'REC-';
      case DocumentType.proforma:
        return prefs.getString(_keyProformaPrefix) ?? 'PRO-';
    }
  }

  Future<void> setPrefixForType(DocumentType type, String prefix) async {
    final prefs = await SharedPreferences.getInstance();
    switch (type) {
      case DocumentType.invoice:
        await prefs.setString(_keyInvoicePrefix, prefix);
        break;
      case DocumentType.quotation:
        await prefs.setString(_keyQuotationPrefix, prefix);
        break;
      case DocumentType.receipt:
        await prefs.setString(_keyReceiptPrefix, prefix);
        break;
      case DocumentType.proforma:
        await prefs.setString(_keyProformaPrefix, prefix);
        break;
    }
  }

  Future<bool> getIncludeYear() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIncludeYear) ?? true;
  }

  Future<void> setIncludeYear(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIncludeYear, value);
  }

  Future<int> getPaddingDigits() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyPaddingDigits) ?? 4;
  }

  Future<void> setPaddingDigits(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyPaddingDigits, value);
  }

  // Tax & Discount preferences
  Future<double> getDefaultTaxRate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyDefaultTaxRate) ?? 18.0;
  }

  Future<void> setDefaultTaxRate(double rate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyDefaultTaxRate, rate);
  }

  Future<double> getDefaultDiscountRate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyDefaultDiscountRate) ?? 0.0;
  }

  Future<void> setDefaultDiscountRate(double rate) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyDefaultDiscountRate, rate);
  }

  Future<String> getDefaultTaxLabel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDefaultTaxLabel) ?? 'GST';
  }

  Future<void> setDefaultTaxLabel(String label) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDefaultTaxLabel, label);
  }

  Future<bool> getDefaultTaxEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDefaultTaxEnabled) ?? true;
  }

  Future<void> setDefaultTaxEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDefaultTaxEnabled, enabled);
  }
}
