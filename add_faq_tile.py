import re

with open('lib/features/settings/presentation/help_support_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

faq_tile = """                    ],
                    Divider(
                      height: 1,
                      color: AppColors.border.withValues(alpha: 0.5),
                      indent: 16,
                      endIndent: 16,
                    ),
                    SettingsTile(
                      title: 'View Detailed Web FAQs',
                      subtitle: 'Read our comprehensive guides online',
                      icon: Icons.public,
                      color: Colors.blueAccent,
                      isLast: true,
                      onTap: () async {
                        final Uri url = Uri.parse('https://invoice-c1603.web.app/faq');
                        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                          debugPrint('Could not launch $url');
                        }
                      },
                    ),"""

pattern = r"""                    \],[\n\s]*\],[\n\s]*\),"""
match = re.search(pattern, content)
if match:
    replacement = faq_tile + "\n                  ],\n                ),"
    content = content[:match.start()] + replacement + content[match.end():]
    with open('lib/features/settings/presentation/help_support_screen.dart', 'w', encoding='utf-8') as f:
        f.write(content)
    print("Added Detailed Web FAQs tile.")
else:
    print("Could not find the FAQ section end.")
