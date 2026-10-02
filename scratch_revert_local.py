filepath = 'lib/features/settings/presentation/regional_settings_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

new_code = '''    if (state is BusinessProfileLoaded) {
      _selectedCurrencyCode = state.profile.currencyCode;
      
      // Fix for legacy corrupted symbols saved in the database
      try {
        final matchingCountry = AppConstants.countries.firstWhere(
            (c) => c['currency'] == _selectedCurrencyCode);
        _selectedCurrencySymbol = matchingCountry['symbol']!;
      } catch (e) {
        _selectedCurrencySymbol = state.profile.currencySymbol;
      }
    }'''

old_code = '''    if (state is BusinessProfileLoaded) {
      _selectedCurrencyCode = state.profile.currencyCode;
      _selectedCurrencySymbol = state.profile.currencySymbol;
    }'''

content = content.replace(new_code, old_code)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
print('Reverted local fix in regional settings')
