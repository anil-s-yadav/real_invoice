with open('lib/features/business_profile/presentation/company_detail_screen.dart', 'r', encoding='utf-8') as f:
    lines = f.readlines()
start = -1
for i, line in enumerate(lines):
    if "Widget _buildImagePicker(" in line:
        start = i
        break
if start != -1:
    for i in range(start, start + 50):
        if i < len(lines):
            print(lines[i], end='')
