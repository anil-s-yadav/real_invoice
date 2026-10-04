import re

with open('lib/features/settings/presentation/help_support_screen.dart', 'r') as f:
    content = f.read()

# Update numbers
content = content.replace("static const String _supportPhone = '+91 98765 43210';", "static const String _supportPhone = '+91 9892986314';")
content = content.replace("static const String _whatsappNumber = '919876543210';", "static const String _whatsappNumber = '919892986314';")

# Add imports
if "import 'package:flutter_bloc/flutter_bloc.dart';" not in content:
    content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:flutter_bloc/flutter_bloc.dart';\nimport '../../subscriptions/bloc/subscription_bloc.dart';\nimport '../../subscriptions/bloc/subscription_state.dart';")

# Find the build block
pattern = r"(Widget build\(BuildContext context\) \{)(\s*final isDark)"
replacement = r"\1\n    final subState = context.watch<SubscriptionBloc>().state;\n    final isPremium = subState is PremiumTierState;\2"
content = re.sub(pattern, replacement, content)

# Wrap the Phone tile
phone_tile = r"(SettingsTile\(\s*title: 'Contact Phone'[\s\S]*?onTap: \(\) => _handleCallPhone\(context\),\s*\),\s*Divider\(\s*height: 1,\s*color: AppColors.border\.withValues\(alpha: 0\.5\),\s*indent: 56,\s*\),)"
content = re.sub(phone_tile, r"if (isPremium) \1", content)

with open('lib/features/settings/presentation/help_support_screen.dart', 'w') as f:
    f.write(content)
