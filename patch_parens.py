import re

with open('d:/real_invoice/lib/features/documents/presentation/document_list_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Replace ending block for the bottom sheets
pattern = r'            \],\n          \),\n        \);\n      \},\n    \);'
replacement = r'''            ],
          ),
          ),
        );
      },
    );'''
text = re.sub(pattern, replacement, text)

with open('d:/real_invoice/lib/features/documents/presentation/document_list_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)
print("document_list_screen.dart fixed parens")