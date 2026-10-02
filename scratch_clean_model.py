import re

filepath = 'lib/features/business_profile/domain/business_profile_model.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    lines = f.readlines()

new_lines = []
for line in lines:
    if 'bankName' in line or 'accountNumber' in line or 'ifscCode' in line or 'upiId' in line:
        continue
    new_lines.append(line)

with open(filepath, 'w', encoding='utf-8') as f:
    f.writelines(new_lines)
print('Cleaned BusinessProfileModel')
