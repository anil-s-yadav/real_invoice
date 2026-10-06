import re

with open('d:/real_invoice/lib/features/auth/presentation/sign_in_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

# Make sure foundation is imported for kDebugMode
if "import 'package:flutter/foundation.dart';" not in text:
    text = text.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:flutter/foundation.dart';")

apple_pattern = r"(                                  const SizedBox\(height: 16\),\n                                  _SocialSignInButton\([\s\S]*?const SignInWithAppleRequestedEvent\(\),\n                                      \);\n                                    \},\n                                  \),)"

replacement = """                                  if (kDebugMode) ...[
                                    const SizedBox(height: 16),
                                    _SocialSignInButton(
                                      icon: const Icon(
                                        Icons.apple,
                                        color: Colors.white,
                                        size: 28,
                                      ),
                                      label: 'Continue with Apple',
                                      backgroundColor: const Color(0xFF111827),
                                      textColor: Colors.white,
                                      hasBorder: false,
                                      onPressed: () {
                                        context.read<AuthBloc>().add(
                                          const SignInWithAppleRequestedEvent(),
                                        );
                                      },
                                    ),
                                  ],
                                  const SizedBox(height: 16),
                                  _SocialSignInButton(
                                    icon: const Icon(
                                      Icons.email_outlined,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    label: 'Login with Password',
                                    backgroundColor: const Color(0xFF4B5563),
                                    textColor: Colors.white,
                                    hasBorder: false,
                                    onPressed: () {
                                      _showReviewerLogin(context);
                                    },
                                  ),"""

text = re.sub(apple_pattern, replacement, text)

# Append reviewer login sheet
reviewer_login = """
void _showReviewerLogin(BuildContext context) {
  final emailCtrl = TextEditingController(text: 'invoz.review@gmail.com');
  final passCtrl = TextEditingController(text: 'invoz@123Z');
  
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      final isDark = Theme.of(ctx).brightness == Brightness.dark;
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Reviewer Login',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  context.read<AuthBloc>().add(
                    SignInWithEmailRequestedEvent(
                      emailCtrl.text.trim(),
                      passCtrl.text.trim(),
                    ),
                  );
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
    },
  );
}
"""

text = text + reviewer_login

with open('d:/real_invoice/lib/features/auth/presentation/sign_in_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)
print("sign_in_screen.dart patched")