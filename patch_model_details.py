with open('d:/real_invoice/lib/features/subscription/domain/subscription_plan_model.dart', 'r', encoding='utf-8') as f:
    content = f.read()

fields_old = """  final String transactionId;
  final String paymentMethod;"""
fields_new = """  final String transactionId;
  final String? orderId;
  final String? paymentSignature;
  final String paymentMethod;"""
content = content.replace(fields_old, fields_new)

constructor_old = """    required this.transactionId,
    this.paymentMethod = 'UPI',"""
constructor_new = """    required this.transactionId,
    this.orderId,
    this.paymentSignature,
    this.paymentMethod = 'UPI',"""
content = content.replace(constructor_old, constructor_new)

tomap_old = """        'transactionId': transactionId,
        'paymentMethod': paymentMethod,"""
tomap_new = """        'transactionId': transactionId,
        'orderId': orderId,
        'paymentSignature': paymentSignature,
        'paymentMethod': paymentMethod,"""
content = content.replace(tomap_old, tomap_new)

frommap_old = """      transactionId: map['transactionId'] ?? '',
      paymentMethod: map['paymentMethod'] ?? 'Unknown',"""
frommap_new = """      transactionId: map['transactionId'] ?? '',
      orderId: map['orderId'] as String?,
      paymentSignature: map['paymentSignature'] as String?,
      paymentMethod: map['paymentMethod'] ?? 'Unknown',"""
content = content.replace(frommap_old, frommap_new)

with open('d:/real_invoice/lib/features/subscription/domain/subscription_plan_model.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("SubscriptionPlanModel updated with razorpay details")