import re
with open('d:/real_invoice/lib/features/settings/presentation/tax_discount_settings_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Add import
text = re.sub(r'(import \'package:flutter/material\.dart\';)', r'\1\nimport \'../../ads/interstitial_ad_manager.dart\';', text)

# Insert showAd
pattern = r'(        Navigator\.of\(context\)\.pop\(\);\n      \})'
replacement = r'        InterstitialAdManager.showAd(context);\n        Navigator.of(context).pop();\n      }'
text = re.sub(pattern, replacement, text)

with open('d:/real_invoice/lib/features/settings/presentation/tax_discount_settings_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)
print("tax_discount_settings_screen patched")