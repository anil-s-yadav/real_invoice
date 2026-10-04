import re

with open('lib/features/settings/presentation/settings_screen.dart', 'r') as f:
    content = f.read()

pattern = r"\s*Divider\(height: 1, color: dividerColor, indent: 56\),\s*SettingsTile\(\s*title: 'Rate Us',[\s\S]*?onTap: \(\) => _showComingSoon\(context, 'Rate Us'\),\s*\),"
content = re.sub(pattern, "", content)

with open('lib/features/settings/presentation/settings_screen.dart', 'w') as f:
    f.write(content)
