with open('d:/real_invoice/lib/features/documents/presentation/pdf_preview_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

old_check = """                          if (t.isPremium) {
                            final subState = context.read<SubscriptionBloc>().state;
                            if (subState.plan?.isFree ?? true) {"""
                            
new_check = """                          if (t.isPremium) {
                            final subState = context.read<SubscriptionBloc>().state;
                            if (!(subState.plan?.hasPremiumTemplates ?? false)) {"""

content = content.replace(old_check, new_check)

with open('d:/real_invoice/lib/features/documents/presentation/pdf_preview_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("pdf_preview_screen patched with backend property check")