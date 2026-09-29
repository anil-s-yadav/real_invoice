with open('d:/real_invoice/lib/features/documents/presentation/widgets/template_thumbnail_card.dart', 'r', encoding='utf-8') as f:
    content = f.read()

content = content.replace('template.accentColor', 'AppColors.primary')

with open('d:/real_invoice/lib/features/documents/presentation/widgets/template_thumbnail_card.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("Replaced template.accentColor with AppColors.primary")