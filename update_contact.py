import re

with open('lib/features/settings/presentation/help_support_screen.dart', 'r') as f:
    content = f.read()

# Update phone numbers
content = content.replace("static const String _supportPhone = '+91 98765 43210';", "static const String _supportPhone = '+91 9892986314';")
content = content.replace("static const String _whatsappNumber = '919876543210';", "static const String _whatsappNumber = '919892986314';")

# Add BlocBuilder for Contact Phone
if "import 'package:flutter_bloc/flutter_bloc.dart';" not in content:
    content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:flutter_bloc/flutter_bloc.dart';\nimport '../../subscription/bloc/subscription_bloc.dart';\nimport '../../subscription/bloc/subscription_state.dart';")

contact_pattern = r"(_buildSectionHeader\('CONTACT & SUPPORT'\),\s*AppCard\(\s*padding: EdgeInsets.zero,\s*child: )(Column\([\s\S]*?children: \[)([\s\S]*?)(SettingsTile\(\s*title: 'Contact Phone'[\s\S]*?onTap: \(\) => _handleCallPhone\(context\),\s*\),\s*Divider\([\s\S]*?indent: 56,\s*\),)"
replacement = r"""\1BlocBuilder<SubscriptionBloc, SubscriptionState>(
                  builder: (context, subState) {
                    final isPremium = subState is PremiumTierState;
                    return \2\3
                      if (isPremium) ...[
                        \4
                      ],"""

content = re.sub(contact_pattern, replacement, content)

# Check if we missed the closing brace for BlocBuilder
# Wait, AppCard child is Column, which we wrapped in BlocBuilder
# So we need to add the closing brace for builder: (context, subState) { return Column(...); }
# Column ends with ] ) ), let's do a different approach

# Better to just use context.watch<SubscriptionBloc>().state
watch_pattern = r"(Widget build\(BuildContext context\) \{)(\s*final isDark)"
watch_replacement = r"\1\n    final subState = context.watch<SubscriptionBloc>().state;\n    final isPremium = subState is PremiumTierState;\2"
content = re.sub(watch_pattern, watch_replacement, content)

tile_pattern = r"(SettingsTile\(\s*title: 'Contact Phone'[\s\S]*?onTap: \(\) => _handleCallPhone\(context\),\s*\),\s*Divider\([\s\S]*?indent: 56,\s*\),)"
tile_replacement = r"if (isPremium) \1"
content = re.sub(tile_pattern, tile_replacement, content)

with open('lib/features/settings/presentation/help_support_screen.dart', 'w') as f:
    f.write(content)
