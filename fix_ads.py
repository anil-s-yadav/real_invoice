files = {
  'd:/real_invoice/lib/features/onboarding/presentation/onboarding_screen.dart': [
    ("        if (mounted) {\n          if (widget.isAddingNewCompany) {", "        if (mounted) {\n          InterstitialAdManager.showAd(context);\n          if (widget.isAddingNewCompany) {")
  ],
  'd:/real_invoice/lib/features/customers/presentation/customer_editor_sheet.dart': [
    ("    if (mounted) {\n      Navigator.of(context).pop(customer);\n    }", "    if (mounted) {\n      InterstitialAdManager.showAd(context);\n      Navigator.of(context).pop(customer);\n    }")
  ],
  'd:/real_invoice/lib/features/products/presentation/product_editor_sheet.dart': [
    ("    if (mounted) {\n      Navigator.of(context).pop(product);\n    }", "    if (mounted) {\n      InterstitialAdManager.showAd(context);\n      Navigator.of(context).pop(product);\n    }")
  ],
  'd:/real_invoice/lib/features/settings/presentation/payment_details_list_screen.dart': [
    ("      if (_formKey.currentState!.validate()) {", "      if (_formKey.currentState!.validate()) {\n        InterstitialAdManager.showAd(context);")
  ],
  'd:/real_invoice/lib/features/settings/presentation/tax_discount_settings_screen.dart': [
    ("      if (mounted) {\n        setState(() => _isSaving = false);", "      if (mounted) {\n        InterstitialAdManager.showAd(context);\n        setState(() => _isSaving = false);")
  ]
}

for file, replacements in files.items():
    with open(file, 'r', encoding='utf-8') as f:
        text = f.read()
    
    for old, new in replacements:
        text = text.replace(old, new)
        
    with open(file, 'w', encoding='utf-8') as f:
        f.write(text)
print("All files patched")