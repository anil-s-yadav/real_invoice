with open('d:/real_invoice/lib/features/home/presentation/home_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Add import
import re
text = re.sub(r'(import \'package:flutter/material\.dart\';)', r'\1\nimport \'../../ads/interstitial_ad_manager.dart\';', text)

# Add to initState
pattern = r'(void initState\(\) \{[\s\S]*?super\.initState\(\);)'
replacement = r'\1\n    WidgetsBinding.instance.addPostFrameCallback((_) {\n      InterstitialAdManager.loadAd(context);\n    });'
text = re.sub(pattern, replacement, text)

with open('d:/real_invoice/lib/features/home/presentation/home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)
print("home_screen patched")