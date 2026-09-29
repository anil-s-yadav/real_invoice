with open('d:/real_invoice/lib/features/documents/presentation/pdf_preview_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

import_statement = "import '../../subscription/presentation/subscription_screen.dart';"
if import_statement not in content:
    content = import_statement + "\n" + content

# We need to import SubscriptionBloc too
import_bloc = "import '../../subscriptions/bloc/subscription_bloc.dart';"
if import_bloc not in content:
    content = import_bloc + "\n" + content

tap_original = """                      return InkWell(
                        onTap: () {
                          if (!isSelected) {"""

tap_new = """                      return InkWell(
                        onTap: () {
                          if (t.isPremium) {
                            final subState = context.read<SubscriptionBloc>().state;
                            if (subState.plan?.isFree ?? true) {
                              Navigator.pop(bottomSheetContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('This is a Premium template. Please upgrade your plan.'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                              );
                              return;
                            }
                          }
                          
                          if (!isSelected) {"""

content = content.replace(tap_original, tap_new)

with open('d:/real_invoice/lib/features/documents/presentation/pdf_preview_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("pdf_preview_screen patched")