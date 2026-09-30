with open('d:/real_invoice/lib/features/subscription/presentation/checkout_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

old_plan = """       autoRenew: true,
       createdAt: DateTime.now(),
       maxCompaniesAllowed: widget.planName.toLowerCase().contains('pro') ? 5 : 50,"""

new_plan = """       autoRenew: true,
       createdAt: DateTime.now(),
       maxCompaniesAllowed: widget.planName.toLowerCase().contains('pro') ? 3 : 10,"""

content = content.replace(old_plan, new_plan)

with open('d:/real_invoice/lib/features/subscription/presentation/checkout_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("checkout_screen patched limits")