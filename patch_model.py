with open('d:/real_invoice/lib/features/subscription/domain/subscription_plan_model.dart', 'r', encoding='utf-8') as f:
    content = f.read()

getter = """  bool get isFree => planName.trim().toLowerCase() == 'free';

  int get maxCompaniesAllowed {
    if (isFree) return 1;
    if (planName.toLowerCase().contains('pro')) return 5;
    return 50;
  }"""

content = content.replace("  bool get isFree => planName.trim().toLowerCase() == 'free';", getter)

with open('d:/real_invoice/lib/features/subscription/domain/subscription_plan_model.dart', 'w', encoding='utf-8') as f:
    f.write(content)