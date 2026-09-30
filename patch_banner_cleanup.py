import re

with open('d:/real_invoice/lib/features/business_profile/presentation/manage_company_list_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

pattern = r"  Widget _buildFeatureItem\(IconData icon, String text\) \{.*?\}(?=\n\n  void _setActive)"
text = re.sub(pattern, "", text, flags=re.DOTALL)

with open('d:/real_invoice/lib/features/business_profile/presentation/manage_company_list_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)
print("Removed _buildFeatureItem")