with open('d:/real_invoice/lib/features/subscription/presentation/checkout_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

old_success = """  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
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
    await repo.saveOrUpgradePlan(newPlan);"""

new_success = """  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    double baseTotal = widget.monthlyPrice * _selectedDuration;
    double invozPerc = _getInvozDiscountPercentage(_selectedDuration);
    double invozDiscount = baseTotal * invozPerc;
    double welcomeDiscount = 0.0;
    if (widget.hasWelcomeOffer) {
      if (_selectedDuration == 12) welcomeDiscount = baseTotal * 0.50;
      else if (_selectedDuration == 1) welcomeDiscount = baseTotal;
    }
    double subtotal = baseTotal - invozDiscount - welcomeDiscount;
    if (subtotal < 0) subtotal = 0;
    double gstAmount = subtotal * _gstRate;
    double totalPayable = subtotal + gstAmount;

    final repo = SubscriptionRepository();
    final newPlan = SubscriptionPlanModel(
       id: widget.planName.toLowerCase() + '_' + DateTime.now().millisecondsSinceEpoch.toString(), 
       planName: widget.planName,
       price: baseTotal,
       durationMonths: _selectedDuration,
       discountPercentage: (invozDiscount + welcomeDiscount) / baseTotal,
       discountAmount: invozDiscount + welcomeDiscount,
       gstAmount: gstAmount,
       finalAmount: totalPayable,
       status: 'Active',
       transactionId: response.paymentId ?? DateTime.now().millisecondsSinceEpoch.toString(),
       paymentMethod: 'Razorpay',
       startDate: DateTime.now(),
       expiryDate: DateTime.now().add(Duration(days: 30 * _selectedDuration)),
       autoRenew: true,
       createdAt: DateTime.now(),
    );
    await repo.saveOrUpgradePlan(newPlan);"""

content = content.replace(old_success, new_success)

with open('d:/real_invoice/lib/features/subscription/presentation/checkout_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("checkout_screen success handler fixed")