with open('d:/real_invoice/lib/features/subscription/presentation/checkout_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace("    bool hasPremium = false;\n", "    bool hasPremium = false;\n    bool hasAnalytics = false;\n")
text = text.replace("      isAdFree = true;\n        hasPremium = true;\n      } else if (pName == 'gold')", "      isAdFree = true;\n        hasPremium = true;\n        hasAnalytics = true;\n      } else if (pName == 'gold')")
text = text.replace("      isAdFree = true;\n        hasPremium = true;\n      }", "      isAdFree = true;\n        hasPremium = true;\n        hasAnalytics = true;\n      }")
text = text.replace("        hasPremiumTemplates: hasPremium,\n", "        hasPremiumTemplates: hasPremium,\n        hasAnalytics: hasAnalytics,\n")

with open('d:/real_invoice/lib/features/subscription/presentation/checkout_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)
print("checkout_screen.dart updated with hasAnalytics")