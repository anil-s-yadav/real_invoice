import re

filepath = 'lib/features/onboarding/presentation/onboarding_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if '_selectedCurrencySymbol =' in line:
        lines[i] = "  String _selectedCurrencySymbol = '\\u20B9';\n"
    elif "{'name': 'India'," in line:
        lines[i] = "    {'name': 'India', 'currency': 'INR', 'symbol': '\\u20B9'},\n"
    elif "{'name': 'Eurozone'," in line:
        lines[i] = "    {'name': 'Eurozone', 'currency': 'EUR', 'symbol': '\\u20AC'},\n"
    elif "{'name': 'United Kingdom'," in line:
        lines[i] = "    {'name': 'United Kingdom', 'currency': 'GBP', 'symbol': '\\u00A3'},\n"

with open(filepath, 'w', encoding='utf-8') as f:
    f.writelines(lines)
print('Fixed onboarding screen properly')

filepath = 'lib/features/settings/presentation/regional_settings_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if '_selectedCurrencySymbol =' in line and 'state.profile' not in line:
        lines[i] = "  String _selectedCurrencySymbol = '\\u20B9';\n"
    elif "{'name': 'India'," in line:
        lines[i] = "    {'name': 'India', 'currency': 'INR', 'symbol': '\\u20B9'},\n"
    elif "{'name': 'Eurozone'," in line:
        lines[i] = "    {'name': 'Eurozone', 'currency': 'EUR', 'symbol': '\\u20AC'},\n"
    elif "{'name': 'United Kingdom'," in line:
        lines[i] = "    {'name': 'United Kingdom', 'currency': 'GBP', 'symbol': '\\u00A3'},\n"

with open(filepath, 'w', encoding='utf-8') as f:
    f.writelines(lines)
print('Fixed regional settings screen properly')
