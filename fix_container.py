import re

with open('lib/features/documents/presentation/pdf_preview_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# Replace the specific Container color
pattern = r"return Container\(\s*color: isDark \? AppColors\.darkSurface : Colors\.white,\s*padding: const EdgeInsets\.all\(16\),"
replacement = r"return Container(\n                padding: const EdgeInsets.all(16),"

content = re.sub(pattern, replacement, content)

with open('lib/features/documents/presentation/pdf_preview_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
