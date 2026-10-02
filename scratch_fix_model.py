import re

filepath = 'lib/features/business_profile/domain/business_profile_model.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# Add import if missing
if 'app_constants.dart' not in content:
    content = content.replace(
        'class BusinessProfile {',
        "import '../../../core/constants/app_constants.dart';\n\nclass BusinessProfile {"
    )

old_code = '''      currencyCode: map['currencyCode'] as String? ?? 'INR',
      currencySymbol: map['currencySymbol'] as String? ?? '\\u20B9','''

new_code = '''      currencyCode: map['currencyCode'] as String? ?? 'INR',
      currencySymbol: _sanitizeCurrencySymbol(
        map['currencyCode'] as String? ?? 'INR',
        map['currencySymbol'] as String? ?? '\\u20B9',
      ),'''

if '_sanitizeCurrencySymbol' not in content:
    content = content.replace(old_code, new_code)
    
    sanitize_func = '''
  static String _sanitizeCurrencySymbol(String code, String fallback) {
    try {
      final matchingCountry = AppConstants.countries.firstWhere(
          (c) => c['currency'] == code);
      return matchingCountry['symbol']!;
    } catch (e) {
      return fallback;
    }
  }
}'''
    content = content.replace('\n}\n', sanitize_func)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
print('Fixed business profile model')
