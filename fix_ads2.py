import re
files = {
  'd:/real_invoice/lib/features/onboarding/presentation/onboarding_screen.dart': [
    (r'(if \(mounted\) \{\s+if \(widget\.isAddingNewCompany\))', r'if (mounted) {\n          InterstitialAdManager.showAd(context);\n          if (widget.isAddingNewCompany')
  ],
  'd:/real_invoice/lib/features/customers/presentation/customer_editor_sheet.dart': [
    (r'(if \(mounted\) \{\s+Navigator\.of\(context\)\.pop\(customer\);\s+\})', r'if (mounted) {\n      InterstitialAdManager.showAd(context);\n      Navigator.of(context).pop(customer);\n    }')
  ],
  'd:/real_invoice/lib/features/products/presentation/product_editor_sheet.dart': [
    (r'(if \(mounted\) \{\s+Navigator\.of\(context\)\.pop\(product\);\s+\})', r'if (mounted) {\n      InterstitialAdManager.showAd(context);\n      Navigator.of(context).pop(product);\n    }')
  ],
  'd:/real_invoice/lib/features/settings/presentation/payment_details_list_screen.dart': [
    (r'(if \(_formKey\.currentState!\.validate\(\)\) \{)', r'if (_formKey.currentState!.validate()) {\n        InterstitialAdManager.showAd(context);')
  ],
  'd:/real_invoice/lib/features/settings/presentation/tax_discount_settings_screen.dart': [
    (r'(if \(mounted\) \{\s+setState\(\(\) => _isSaving = false\);)', r'if (mounted) {\n        InterstitialAdManager.showAd(context);\n        setState(() => _isSaving = false);')
  ]
}

for file, replacements in files.items():
    with open(file, 'r', encoding='utf-8') as f:
        text = f.read()
    
    for old, new in replacements:
        text = re.sub(old, new, text)
        
    with open(file, 'w', encoding='utf-8') as f:
        f.write(text)
print("All files patched again")