with open('d:/real_invoice/lib/features/subscription/presentation/checkout_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

old_success = """    double gstAmount = subtotal * _gstRate;
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
       orderId: response.orderId,
       paymentSignature: response.signature,
       paymentMethod: 'Razorpay',
       startDate: DateTime.now(),
       expiryDate: DateTime.now().add(Duration(days: 30 * _selectedDuration)),
       autoRenew: true,
       createdAt: DateTime.now(),
       maxCompaniesAllowed: widget.planName.toLowerCase().contains('pro') ? 3 : 10,
    );"""

new_success = """    double gstAmount = subtotal * _gstRate;
    double totalPayable = subtotal + gstAmount;

    int maxCompanies = 1;
    int maxClients = 3;
    int maxDocs = 5;
    int maxDevices = 1;
    bool isAdFree = false;
    bool hasPremium = false;

    String pName = widget.planName.toLowerCase();
    if (pName == 'single') {
       maxCompanies = 1;
       maxClients = 10;
       maxDocs = -1; // -1 means unlimited
       maxDevices = 2;
       hasPremium = true;
    } else if (pName.contains('pro')) {
       maxCompanies = 3;
       maxClients = -1;
       maxDocs = -1;
       maxDevices = 3;
       isAdFree = true;
       hasPremium = true;
    } else if (pName == 'gold') {
       maxCompanies = 10;
       maxClients = -1;
       maxDocs = -1;
       maxDevices = -1;
       isAdFree = true;
       hasPremium = true;
    }

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
       orderId: response.orderId,
       paymentSignature: response.signature,
       paymentMethod: 'Razorpay',
       startDate: DateTime.now(),
       expiryDate: DateTime.now().add(Duration(days: 30 * _selectedDuration)),
       autoRenew: true,
       createdAt: DateTime.now(),
       maxCompaniesAllowed: maxCompanies,
       maxClientsAllowed: maxClients,
       maxItemsAllowed: maxClients, // using same limit for simplicity
       maxDocumentsPerDay: maxDocs,
       maxDevicesAllowed: maxDevices,
       isAdFree: isAdFree,
       hasPremiumTemplates: hasPremium,
    );"""

content = content.replace(old_success, new_success)

with open('d:/real_invoice/lib/features/subscription/presentation/checkout_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("checkout_screen patched with all limits")