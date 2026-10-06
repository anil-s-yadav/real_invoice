with open('d:/real_invoice/lib/features/auth/presentation/sign_in_screen.dart', 'r', encoding='utf-8') as f:
    text = f.read()

import re
# We just want to replace the `_SocialSignInButton` for Apple.
# I'll find the line `label: 'Continue with Apple',` and replace the whole button logic around it.
# Actually let's just insert the new button right after the Google button!
# `label: 'Continue with Google',`
pattern = r"(label: 'Continue with Google',[\s\S]*?\},[\s\S]*?\),)"
replacement = r"""\1
                                  const SizedBox(height: 16),
                                  _SocialSignInButton(
                                    icon: const Icon(
                                      Icons.email_outlined,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    label: 'Login with Password',
                                    backgroundColor: AppColors.primary,
                                    textColor: Colors.white,
                                    hasBorder: false,
                                    onPressed: () {
                                      _showReviewerLogin(context);
                                    },
                                  ),"""
text = re.sub(pattern, replacement, text, count=1)

# And replace Apple to be kDebugMode
apple_pattern = r"(                                  const SizedBox\(height: 16\),\s+_SocialSignInButton\(\s+icon: const Icon\(\s+Icons\.apple,[\s\S]*?label: 'Continue with Apple',[\s\S]*?\},[\s\S]*?\),)"
apple_replace = r"""                                  if (kDebugMode) ...[
\1
                                  ],"""
text = re.sub(apple_pattern, apple_replace, text)

with open('d:/real_invoice/lib/features/auth/presentation/sign_in_screen.dart', 'w', encoding='utf-8') as f:
    f.write(text)
print("Regex replace 3 done")