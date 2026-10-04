import re

with open('lib/features/settings/presentation/settings_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

terms_tile = """
                Divider(height: 1, color: dividerColor, indent: 56),
                SettingsTile(
                  title: 'Terms & Conditions',
                  icon: Icons.gavel,
                  color: Colors.deepPurple,
                  isFirst: false,
                  isLast: false,
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                  onTap: () async {
                    final Uri url = Uri.parse('https://invoice-c1603.web.app/terms');
                    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                      debugPrint('Could not launch $url');
                    }
                  },
                ),"""

pattern = r"""                      if \(\!await launchUrl\(url, mode: LaunchMode\.externalApplication\)\) \{\s*debugPrint\('Could not launch \$url'\);\s*\}\s*\},[\s\n]*\),"""

match = re.search(pattern, content)
if match:
    replacement = match.group(0) + terms_tile
    content = content[:match.start()] + replacement + content[match.end():]
    with open('lib/features/settings/presentation/settings_screen.dart', 'w', encoding='utf-8') as f:
        f.write(content)
    print("Added Terms and Conditions tile.")
else:
    print("Could not find the Privacy Policy tile.")
