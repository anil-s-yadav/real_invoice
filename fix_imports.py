files = [
  'd:/real_invoice/lib/features/home/presentation/home_screen.dart',
  'd:/real_invoice/lib/features/onboarding/presentation/onboarding_screen.dart',
  'd:/real_invoice/lib/features/customers/presentation/customer_editor_sheet.dart',
  'd:/real_invoice/lib/features/products/presentation/product_editor_sheet.dart',
  'd:/real_invoice/lib/features/settings/presentation/payment_details_list_screen.dart',
  'd:/real_invoice/lib/features/settings/presentation/tax_discount_settings_screen.dart'
]

for file in files:
    with open(file, 'r', encoding='utf-8') as f:
        text = f.read()
    
    text = text.replace("import \\'../../ads/interstitial_ad_manager.dart\\';", "import '../../ads/interstitial_ad_manager.dart';")
    
    with open(file, 'w', encoding='utf-8') as f:
        f.write(text)
print("Fixed imports")