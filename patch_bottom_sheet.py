import re

with open('d:/real_invoice/lib/features/documents/presentation/document_list_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Replace the Column with SingleChildScrollView(child: Column(...))
pattern1 = r'        builder: \(sheetContext\) \{\s*return SafeArea\(\s*child: Column\('
replacement1 = r'''        builder: (sheetContext) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Column('''
text = re.sub(pattern1, replacement1, text, count=1)

# Remove the duplicate AdBannerWidget
pattern2 = r'              Padding\(\s*padding: const EdgeInsets\.all\(8\.0\),\s*child: Center\(child: AdBannerWidget\(\)\),\s*\),\s*Padding\(\s*padding: const EdgeInsets\.all\(8\.0\),\s*child: Center\(child: AdBannerWidget\(\)\),\s*\),'
replacement2 = r'''              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(child: AdBannerWidget()),
              ),'''
text = re.sub(pattern2, replacement2, text)

# There might also be a `const SizedBox(height: AppDimensions.xl),` causing too much space. Let's reduce it.
pattern3 = r'              Divider\(\),\s*const SizedBox\(height: AppDimensions\.xl\),'
replacement3 = r'''              const Divider(),
              const SizedBox(height: 8),'''
text = re.sub(pattern3, replacement3, text)

with open('d:/real_invoice/lib/features/documents/presentation/document_list_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)
print("document_list_screen.dart patched for overflow")