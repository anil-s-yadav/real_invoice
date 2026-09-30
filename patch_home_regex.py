import re

with open('d:/real_invoice/lib/features/home/presentation/home_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

content = re.sub(
    r'(child: Column\(\s*crossAxisAlignment: CrossAxisAlignment\.stretch,\s*children: \[)',
    r'\1\n                    const Padding(\n                      padding: EdgeInsets.only(bottom: 12),\n                      child: AdBannerWidget(),\n                    ),',
    content,
    count=1
)

with open('d:/real_invoice/lib/features/home/presentation/home_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("home_screen.dart regex patched")