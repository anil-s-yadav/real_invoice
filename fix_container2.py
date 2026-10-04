import re

with open('lib/features/documents/presentation/pdf_preview_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

pattern = r"return Container\(\s*height: screenHeight \* 0\.9,\s*color: isDark \? AppColors\.darkSurface : Colors\.white,"
replacement = r"return Container(\n            height: screenHeight * 0.9,"

content = re.sub(pattern, replacement, content)

with open('lib/features/documents/presentation/pdf_preview_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
