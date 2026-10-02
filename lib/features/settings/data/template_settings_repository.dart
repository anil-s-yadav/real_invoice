import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../documents/domain/document_model.dart';

class TemplateSettingsRepository {
  static const String _keyInvoice = 'defaultInvoiceTemplateId';
  static const String _keyQuotation = 'defaultQuotationTemplateId';
  static const String _keyReceipt = 'defaultReceiptTemplateId';
  static const String _keyProforma = 'defaultProformaTemplateId';

  DocumentReference<Map<String, dynamic>>? get _ref {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('settings')
        .doc('template_settings');
  }

  Future<void> syncSettings() async {
    final ref = _ref;
    if (ref == null) return;
    try {
      await ref.get(const GetOptions(source: Source.server));
    } catch (_) {}
  }

  Future<Map<String, dynamic>> _getMap() async {
    final ref = _ref;
    if (ref == null) return {};
    try {
      final doc = await ref.get();
      if (doc.exists) {
        return doc.data() ?? {};
      }
    } catch (e) {
      print('Error fetching template settings: $e');
    }
    return {};
  }

  Future<void> _update(String key, String value) async {
    final ref = _ref;
    if (ref == null) return;
    try {
      await ref.set({key: value}, SetOptions(merge: true));
    } catch (e) {
      print('Error saving template setting $key: $e');
    }
  }

  Future<String> getDefaultTemplate(DocumentType type) async {
    final data = await _getMap();
    switch (type) {
      case DocumentType.invoice:
        return data[_keyInvoice] as String? ?? 'modern_crimson';
      case DocumentType.quotation:
        return data[_keyQuotation] as String? ?? 'modern_crimson';
      case DocumentType.receipt:
        return data[_keyReceipt] as String? ?? 'modern_crimson';
      case DocumentType.proforma:
        return data[_keyProforma] as String? ?? 'modern_crimson';
    }
  }

  Future<void> setDefaultTemplate(DocumentType type, String templateId) async {
    switch (type) {
      case DocumentType.invoice:
        await _update(_keyInvoice, templateId);
        break;
      case DocumentType.quotation:
        await _update(_keyQuotation, templateId);
        break;
      case DocumentType.receipt:
        await _update(_keyReceipt, templateId);
        break;
      case DocumentType.proforma:
        await _update(_keyProforma, templateId);
        break;
    }
  }
}
