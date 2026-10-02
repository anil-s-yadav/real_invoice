import re

filepath = 'lib/features/onboarding/presentation/onboarding_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if "String _selectedCurrencySymbol = '\\u20B9';" in line and "setState" not in line and 'class' not in "".join(lines[max(0, i-5):i]):
        if 'country' in lines[i-1]:
            lines[i] = "                _selectedCurrencySymbol = country['symbol']!;\n"

with open(filepath, 'w', encoding='utf-8') as f:
    f.writelines(lines)


filepath = 'lib/features/settings/presentation/regional_settings_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if "String _selectedCurrencySymbol = '\\u20B9';" in line and "setState" not in line and 'class' not in "".join(lines[max(0, i-5):i]):
        if 'country' in lines[i-1]:
             lines[i] = "                _selectedCurrencySymbol = country['symbol']!;\n"

with open(filepath, 'w', encoding='utf-8') as f:
    f.writelines(lines)
