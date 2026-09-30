with open('d:/real_invoice/lib/features/documents/presentation/document_list_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Replace the builder start for BOTH bottom sheets if there are two (one for date, one for status)
import re

def replacer(match):
    return match.group(0).replace("child: Column(", "child: SingleChildScrollView(\n              child: Column(")

text = re.sub(r'builder: \(sheetContext\) \{\s*return SafeArea\(\s*child: Column\(', replacer, text)

# Now we need to add the closing parenthesis for SingleChildScrollView.
# The end of the SafeArea is:
#               ],
#             ),
#           );
#         },

text = text.replace("              ],\n            ),\n          );\n        },", "              ],\n            ),\n            ),\n          );\n        },")

# Remove duplicate AdBanner
text = text.replace("            Divider(),\n            const SizedBox(height: AppDimensions.xl),\n            Padding(\n              padding: const EdgeInsets.all(8.0),\n              child: Center(child: AdBannerWidget()),\n            ),\n            Padding(\n              padding: const EdgeInsets.all(8.0),\n              child: Center(child: AdBannerWidget()),\n            ),", "            const Divider(),\n            const SizedBox(height: 8),\n            const Padding(\n              padding: EdgeInsets.all(8.0),\n              child: Center(child: AdBannerWidget()),\n            ),")

with open('d:/real_invoice/lib/features/documents/presentation/document_list_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)
print("document_list_screen.dart updated")