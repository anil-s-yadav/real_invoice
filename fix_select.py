import re

with open('lib/features/documents/presentation/widgets/product_select_sheet.dart', 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace("' / '", "'${CurrencyFormatter.format(product.unitPrice)} / ${product.unit}'")
content = content.replace("import '../../../../core/widgets/app_card.dart';", "")

with open('lib/features/documents/presentation/widgets/product_select_sheet.dart', 'w', encoding='utf-8') as f:
    f.write(content)

with open('lib/features/documents/presentation/widgets/customer_select_sheet.dart', 'r', encoding='utf-8') as f:
    cust = f.read()

cust = cust.replace("import '../../../../core/widgets/app_card.dart';", "")

with open('lib/features/documents/presentation/widgets/customer_select_sheet.dart', 'w', encoding='utf-8') as f:
    f.write(cust)
