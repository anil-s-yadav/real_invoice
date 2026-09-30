with open('d:/real_invoice/lib/features/documents/presentation/template_preview_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

old_check = """            onPressed: isDefault ? null : () {
              if (template.isPremium) {
                final subState = context.read<SubscriptionBloc>().state;
                if (subState.plan?.isFree ?? true) {"""
                
new_check = """            onPressed: isDefault ? null : () {
              if (template.isPremium) {
                final subState = context.read<SubscriptionBloc>().state;
                if (!(subState.plan?.hasPremiumTemplates ?? false)) {"""

content = content.replace(old_check, new_check)

with open('d:/real_invoice/lib/features/documents/presentation/template_preview_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("template_preview_screen patched with backend property check")