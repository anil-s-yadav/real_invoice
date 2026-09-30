import re
with open('d:/real_invoice/lib/features/onboarding/presentation/onboarding_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Add import
text = re.sub(r'(import \'package:flutter/material\.dart\';)', r'\1\nimport \'../../ads/interstitial_ad_manager.dart\';', text)

# Insert showAd
pattern = r'(        if \(mounted\) \{\n          if \(widget\.isAddingNewCompany\) \{)'
replacement = r'        if (mounted) {\n          InterstitialAdManager.showAd(context);\n          if (widget.isAddingNewCompany) {'
text = re.sub(pattern, replacement, text)

with open('d:/real_invoice/lib/features/onboarding/presentation/onboarding_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)
print("onboarding_screen patched")