import re

with open('lib/features/settings/presentation/payment_details_list_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace the specific corrupted string
pattern = r"A/C: \$\{item\.details\}\$\{item\.extra != null && item\.extra!\.isNotEmpty \? '  â€¢  IFSC: \$\{item\.extra\}' : ''\}"
replacement = r"A/C: ${item.details}${item.extra != null && item.extra!.isNotEmpty ? '\nIFSC: ${item.extra}' : ''}"

content = re.sub(pattern, replacement, content)

with open('lib/features/settings/presentation/payment_details_list_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
