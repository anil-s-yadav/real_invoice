import re

with open('lib/features/settings/presentation/settings_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

if 'in_app_review' not in content:
    content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:in_app_review/in_app_review.dart';")

tile = """                SettingsTile(
                  title: 'Rate the App',
                  subtitle: 'Love Invoz? Leave a review!',
                  icon: Icons.star_rate_rounded,
                  color: Colors.amber,
                  isFirst: true,
                  onTap: () async {
                    final InAppReview inAppReview = InAppReview.instance;
                    if (await inAppReview.isAvailable()) {
                      inAppReview.requestReview();
                    }
                  },
                ),
                Divider(height: 1, color: dividerColor, indent: 56),
                SettingsTile(
                  title: 'Privacy Policy & Terms',
                  isFirst: false,"""

content = re.sub(r"                SettingsTile\(\s*title: 'Privacy Policy & Terms',", tile, content)

with open('lib/features/settings/presentation/settings_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)
