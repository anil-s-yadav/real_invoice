with open('d:/real_invoice/lib/features/subscription/presentation/checkout_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace("      } else if (pName == \\'gold\\') {", "      } else if (pName == 'gold') {")
text = text.replace("      isAdFree = true;\n      hasPremium = true;\n    }", "      isAdFree = true;\n      hasPremium = true;\n      hasAnalytics = true;\n    }")

with open('d:/real_invoice/lib/features/subscription/presentation/checkout_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)
print("checkout_screen.dart fixed syntax")