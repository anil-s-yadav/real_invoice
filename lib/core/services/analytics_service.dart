import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // Custom Events
  static Future<void> logSignup(String method) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  static Future<void> logBusinessCreated(String businessId) async {
    await _analytics.logEvent(
      name: 'business_created',
      parameters: {'business_id': businessId},
    );
  }

  static Future<void> logTemplateSelected(String templateId) async {
    await _analytics.logEvent(
      name: 'template_selected',
      parameters: {'template_id': templateId},
    );
  }

  static Future<void> logInvoiceCreated(double amount) async {
    await _analytics.logEvent(
      name: 'invoice_created',
      parameters: {'amount': amount},
    );
  }

  static Future<void> logQuotationCreated(double amount) async {
    await _analytics.logEvent(
      name: 'quotation_created',
      parameters: {'amount': amount},
    );
  }

  static Future<void> logReceiptCreated(double amount) async {
    await _analytics.logEvent(
      name: 'receipt_created',
      parameters: {'amount': amount},
    );
  }

  static Future<void> logInvoiceShared() async {
    await _analytics.logShare(
      contentType: 'invoice',
      itemId: 'pdf',
      method: 'share_plus',
    );
    await _analytics.logEvent(name: 'invoice_shared');
  }

  static Future<void> logFirstInvoiceCreated() async {
    await _analytics.logEvent(name: 'first_invoice_created');
  }

  static Future<void> logFirstInvoiceShared() async {
    await _analytics.logEvent(name: 'first_invoice_shared');
  }

  static Future<void> logPricingViewed() async {
    await _analytics.logEvent(name: 'pricing_viewed');
  }

  static Future<void> logPurchaseStarted(String planName) async {
    await _analytics.logBeginCheckout(
      value: 0,
      currency: 'INR',
      items: [
        AnalyticsEventItem(itemName: planName, itemCategory: 'subscription'),
      ],
    );
    await _analytics.logEvent(
      name: 'purchase_started',
      parameters: {'plan_name': planName},
    );
  }

  static Future<void> logPurchaseCompleted(
    String planName,
    double value,
  ) async {
    await _analytics.logPurchase(
      currency: 'INR',
      value: value,
      items: [
        AnalyticsEventItem(itemName: planName, itemCategory: 'subscription'),
      ],
    );
    await _analytics.logEvent(
      name: 'purchase_completed',
      parameters: {'plan_name': planName, 'value': value},
    );
  }

  // Optional: App Open is usually tracked automatically, but we can log a custom one
  static Future<void> logCustomAppOpen() async {
    await _analytics.logAppOpen();
  }
}
