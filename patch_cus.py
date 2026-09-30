import re
with open('d:/real_invoice/lib/features/customers/presentation/customer_editor_sheet.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Add import
text = re.sub(r'(import \'package:flutter/material\.dart\';)', r'\1\nimport \'../../ads/interstitial_ad_manager.dart\';', text)

# Insert showAd
pattern = r'(      if \(mounted\) \{\n        Navigator\.of\(context\)\.pop\(customer\);\n      \})'
replacement = r'      if (mounted) {\n        InterstitialAdManager.showAd(context);\n        Navigator.of(context).pop(customer);\n      }'
text = re.sub(pattern, replacement, text)

with open('d:/real_invoice/lib/features/customers/presentation/customer_editor_sheet.dart', 'w', encoding='utf-8') as f:
    f.write(text)
print("customer_editor_sheet patched")