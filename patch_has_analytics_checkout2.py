with open('d:/real_invoice/lib/features/subscription/presentation/checkout_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

import re
# 1. Add hasAnalytics to initialization
text = re.sub(r'(hasPremiumTemplates: hasPremium,\s*)\);', r'\1      hasAnalytics: hasAnalytics,\n    );', text)

# 2. Add hasAnalytics = true to Pro
text = re.sub(r'(isAdFree = true;\s*hasPremium = true;\s*)\} else if \(pName == \'gold\'\)', r'\1hasAnalytics = true;\n      } else if (pName == \'gold\')', text)

# 3. Add hasAnalytics = true to Gold
text = re.sub(r'(\} else if \(pName == \'gold\'\) \{[^}]*?hasPremium = true;\s*)\}', r'\1  hasAnalytics = true;\n      }', text)

with open('d:/real_invoice/lib/features/subscription/presentation/checkout_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)
print("checkout_screen.dart patched correctly")