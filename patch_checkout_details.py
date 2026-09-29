with open('d:/real_invoice/lib/features/subscription/presentation/checkout_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

old_plan = """       status: 'Active',
       transactionId: response.paymentId ?? DateTime.now().millisecondsSinceEpoch.toString(),
       paymentMethod: 'Razorpay',"""

new_plan = """       status: 'Active',
       transactionId: response.paymentId ?? DateTime.now().millisecondsSinceEpoch.toString(),
       orderId: response.orderId,
       paymentSignature: response.signature,
       paymentMethod: 'Razorpay',"""

content = content.replace(old_plan, new_plan)

with open('d:/real_invoice/lib/features/subscription/presentation/checkout_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("checkout_screen patched with razorpay details")