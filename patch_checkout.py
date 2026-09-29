with open('d:/real_invoice/lib/features/subscription/presentation/checkout_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Add imports
imports = """import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../data/subscription_repository.dart';
import '../domain/subscription_plan_model.dart';"""

content = content.replace("import 'package:flutter/material.dart';\nimport 'package:url_launcher/url_launcher.dart';\nimport '../../../core/constants/app_colors.dart';", imports)

# Add razorpay init and dispose
init_original = """  @override
  void initState() {
    super.initState();
    _selectedDuration = 12; // 1 Year plan
  }"""

init_new = """  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _selectedDuration = 12; // 1 Year plan
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final repo = SubscriptionRepository();
    final newPlan = SubscriptionPlanModel(
       id: widget.planName.toLowerCase(), 
       name: widget.planName,
       tier: widget.planName.contains('Pro') ? SubscriptionTier.pro : SubscriptionTier.premium,
       price: widget.monthlyPrice * _selectedDuration,
       isActive: true,
       autoRenew: true,
       createdAt: DateTime.now(),
       expiresAt: DateTime.now().add(Duration(days: 30 * _selectedDuration)),
       transactionId: response.paymentId ?? DateTime.now().millisecondsSinceEpoch.toString(),
       maxCompaniesAllowed: widget.planName.contains('Pro') ? 5 : 50, 
    );
    await repo.saveOrUpgradePlan(newPlan);
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Subscription upgraded successfully!'), backgroundColor: Colors.green),
    );
    // Go back to previous screen
    Navigator.of(context).pop();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External Wallet Selected: ${response.walletName}')),
    );
  }"""

content = content.replace(init_original, init_new)

# Add razorpay open
button_original = """                onPressed: () {
                  // TODO: Implement payment gateway
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment Gateway Integration Pending'),
                    ),
                  );
                },"""

button_new = """                onPressed: () {
                  var options = {
                    'key': 'rzp_test_ThkLyPi706leO9',
                    'amount': (totalPayable * 100).toInt(), // in paise
                    'name': 'Invoz App',
                    'description': '${widget.planName} - $_selectedDuration Months',
                    'timeout': 120, 
                    'prefill': {
                      'contact': '', 
                      'email': ''
                    }
                  };
                  try {
                    _razorpay.open(options);
                  } catch (e) {
                    debugPrint(e.toString());
                  }
                },"""

content = content.replace(button_original, button_new)

with open('d:/real_invoice/lib/features/subscription/presentation/checkout_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("checkout_screen patched")