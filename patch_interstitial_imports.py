with open('d:/real_invoice/lib/features/documents/presentation/document_editor_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

import_sub = "import '../../subscriptions/bloc/subscription_bloc.dart';"
if "subscription_bloc" not in content:
    content = import_sub + "\n" + content

with open('d:/real_invoice/lib/features/documents/presentation/document_editor_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
print("SubscriptionBloc imported")