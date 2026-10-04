import re

with open('lib/features/customers/presentation/customer_list_screen.dart', 'r') as f:
    content = f.read()

# Add url_launcher import if not exists
if 'package:url_launcher/url_launcher.dart' not in content:
    content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:url_launcher/url_launcher.dart';")

# Find where phone is rendered
phone_pattern = r"(if\s*\(customer\.phone\s*!=\s*null\s*&&\s*customer\.phone!\.isNotEmpty\)[\s\S]*?\),)"
website_ui = """\\1
                  if (customer.contactPerson != null && customer.contactPerson!.isNotEmpty)
                    Text(
                      'Contact: ',
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (customer.cin != null && customer.cin!.isNotEmpty)
                    Text(
                      'CIN: ',
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (customer.website != null && customer.website!.isNotEmpty)
                    GestureDetector(
                      onTap: () async {
                        var urlStr = customer.website!;
                        if (!urlStr.startsWith('http')) urlStr = 'https://\';
                        final url = Uri.parse(urlStr);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(url, mode: LaunchMode.externalApplication);
                        }
                      },
                      child: Row(
                        children: [
                          Icon(Icons.language, size: 14, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              customer.website!,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),"""

content = re.sub(phone_pattern, website_ui, content)

with open('lib/features/customers/presentation/customer_list_screen.dart', 'w') as f:
    f.write(content)
