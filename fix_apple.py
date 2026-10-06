with open('d:/real_invoice/lib/features/auth/presentation/sign_in_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

import re

# Match the Apple button block up to its closing parenthesis
# We can search for `                                  _SocialSignInButton(\n` ... `Continue with Apple` ... `const SignInWithAppleRequestedEvent(),\n                                      );\n                                    },\n                                  ),`

pattern = r"(                                  _SocialSignInButton\(\s*icon: const Icon\(\s*Icons\.apple,[\s\S]*?const SignInWithAppleRequestedEvent\(\),\s*\);\s*\},\s*\),)"
replacement = """                                  if (kDebugMode) ...[
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

text = re.sub(pattern, replacement, text)

with open('d:/real_invoice/lib/features/auth/presentation/sign_in_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)
print("Regex replace done")