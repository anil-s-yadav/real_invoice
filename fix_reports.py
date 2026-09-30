with open('d:/real_invoice/lib/features/reports/presentation/reports_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace("import '../../subscription/bloc/subscription_bloc.dart';", "import '../../subscriptions/bloc/subscription_bloc.dart';")

# Find the ending brackets and fix them.
# I will just replace the whole file from the end.
end_part = """          return const SizedBox.shrink();
        },
      ),
    );
  }
}"""
# Wait, let's just make sure the parentheses are balanced by replacing it properly.

# Let's count brackets manually
#       body: BlocBuilder<SubscriptionBloc, SubscriptionState>(
#         builder: (context, subState) {
#           ...
#           return BlocBuilder<ReportsBloc, ReportsState>(
#             builder: (context, state) {
#               ...
#               return const SizedBox.shrink();
#             },
#           );
#         },
#       ),
#     );
#   }
# }

new_end = """          return const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }
}"""

import re
text = re.sub(r'          return const SizedBox\.shrink\(\);\n        \},\n      \);\n        \}\n      \),\n    \);\n  \}\n\}', new_end, text)

# Just in case my previous replace failed, I will also replace this:
text = re.sub(r'          return const SizedBox\.shrink\(\);\n        \},\n      \),\n    \);\n  \}\n\}', new_end, text)

with open('d:/real_invoice/lib/features/reports/presentation/reports_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)
print("reports_screen.dart fixed")