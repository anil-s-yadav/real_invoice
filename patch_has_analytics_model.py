with open('d:/real_invoice/lib/features/subscription/domain/subscription_plan_model.dart', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace("  final bool hasPremiumTemplates;\n", "  final bool hasPremiumTemplates;\n  final bool hasAnalytics;\n")
text = text.replace("    this.hasPremiumTemplates = false,\n  });", "    this.hasPremiumTemplates = false,\n    this.hasAnalytics = false,\n  });")
text = text.replace("        'hasPremiumTemplates': hasPremiumTemplates,\n      };", "        'hasPremiumTemplates': hasPremiumTemplates,\n        'hasAnalytics': hasAnalytics,\n      };")
text = text.replace("      hasPremiumTemplates: map['hasPremiumTemplates'] ?? false,\n    );", "      hasPremiumTemplates: map['hasPremiumTemplates'] ?? false,\n      hasAnalytics: map['hasAnalytics'] ?? false,\n    );")
text = text.replace("      hasPremiumTemplates: false,\n    );", "      hasPremiumTemplates: false,\n      hasAnalytics: false,\n    );")

with open('d:/real_invoice/lib/features/subscription/domain/subscription_plan_model.dart', 'w', encoding='utf-8') as f:
    f.write(text)
print("SubscriptionPlanModel updated with hasAnalytics")