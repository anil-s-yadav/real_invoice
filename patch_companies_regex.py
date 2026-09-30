import re

with open('d:/real_invoice/lib/features/business_profile/presentation/manage_company_list_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

content = re.sub(
    r'(children: \[)',
    r'\1\n                          const AdBannerWidget(),\n                          const SizedBox(height: 12),',
    content,
    count=1
)

with open('d:/real_invoice/lib/features/business_profile/presentation/manage_company_list_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("manage_company_list_screen.dart regex patched")