with open('d:/real_invoice/lib/features/documents/presentation/template_preview_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

import_bloc = "import 'package:flutter_bloc/flutter_bloc.dart';\nimport '../../subscriptions/bloc/subscription_bloc.dart';\nimport '../../subscription/presentation/subscription_screen.dart';"
if "subscription_bloc" not in content:
    content = import_bloc + "\n" + content

# Add bottom bar to template_preview_screen
body_end = """            ),
          ),
        ],
      ),
    );"""

new_body_end = """            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 60 : 10),
                blurRadius: 10,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: isDefault ? null : () {
              if (template.isPremium) {
                final subState = context.read<SubscriptionBloc>().state;
                if (subState.plan?.isFree ?? true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Premium template. Please upgrade your plan.'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
                  );
                  return;
                }
              }
              onSetDefault();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDefault ? Colors.grey : AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              isDefault ? 'Already Default Template' : 'Set as Default',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );"""

content = content.replace(body_end, new_body_end)

with open('d:/real_invoice/lib/features/documents/presentation/template_preview_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("template_preview_screen patched")