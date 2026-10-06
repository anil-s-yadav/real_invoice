with open('d:/real_invoice/lib/features/auth/presentation/sign_in_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

text = text.replace("import 'package:flutter/foundation.dart';\n", "")

with open('d:/real_invoice/lib/features/auth/presentation/sign_in_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)
print("sign_in_screen.dart import fixed")