import re
with open('d:/real_invoice/lib/features/settings/presentation/payment_details_list_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Add import
text = re.sub(r'(import \'package:flutter/material\.dart\';)', r'\1\nimport \'../../ads/interstitial_ad_manager.dart\';', text)

# Insert showAd
pattern = r'(      if \(_formKey\.currentState!\.validate\(\)\) \{)'
replacement = r'      if (_formKey.currentState!.validate()) {\n        InterstitialAdManager.showAd(context);'
text = re.sub(pattern, replacement, text)

with open('d:/real_invoice/lib/features/settings/presentation/payment_details_list_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)
print("payment_details_list_screen patched")