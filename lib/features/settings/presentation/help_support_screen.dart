import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/settings_tile.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const String _supportPhone = '+91 98765 43210';
  static const String _supportEmail = 'support@invoz.app';
  static const String _whatsappNumber = '919876543210';

  static const List<Map<String, String>> _faqs = [
    {
      'question': 'How do I create an invoice or quotation?',
      'answer':
          'From the Home screen, tap any document card under "Create New" (Invoice, Quotation, Receipt, or Proforma). Select or add a customer, add line items with prices and tax, then tap "Preview PDF" or "Save".',
    },
    {
      'question': 'How do I show my UPI QR code and bank details on PDFs?',
      'answer':
          '1. Go to Settings > Payment Profiles and add your Bank Account or UPI ID.\n2. In the Document Editor, scroll down to the "Additional Info" section.\n3. Turn ON the "Show Payment Details & QR Code" toggle before saving or exporting your PDF.',
    },
    {
      'question': 'Is my financial and business data secure?',
      'answer':
          'Yes, absolutely. invoz is 100% offline-first. All your customer information, invoices, items, and company profiles are stored locally on your device in an encrypted SQLite database. No data is shared or uploaded to external servers without your permission.',
    },
    {
      'question': 'How do I print or share an invoice PDF?',
      'answer':
          'Open any document from the Documents tab and tap "Preview PDF". You can tap the "Share" button to send via WhatsApp, Email, or other apps, or tap "Print" to send directly to any connected printer.',
    },
    {
      'question': 'Can I manage multiple businesses or company profiles?',
      'answer':
          'Yes! You can manage up to 10 distinct company profiles. Go to Settings > Company Profiles or tap "Company Profiles" under Manage Business on the Home screen to create, customize logos, or switch the active business profile.',
    },
    {
      'question': 'Can I convert a Quotation or Proforma into an Invoice?',
      'answer':
          'Yes. Open any Quotation or Proforma document from your list, tap the options menu, and choose "Convert to Invoice". All customer details, items, taxes, and terms will be seamlessly preserved.',
    },
    {
      'question': 'How do I add shipping charges or a PO number?',
      'answer':
          'In the Document Editor, expand the "Details (Optional)" section. You can enter a PO Number, Subject title, and Shipping Charges. Shipping charges are automatically calculated into the grand total.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Help & Support',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.lg,
            vertical: AppDimensions.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Above: FAQs Section
              _buildSectionHeader('FREQUENTLY ASKED QUESTIONS'),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (int i = 0; i < _faqs.length; i++) ...[
                      _buildFaqItem(
                        context,
                        _faqs[i]['question']!,
                        _faqs[i]['answer']!,
                      ),
                      if (i < _faqs.length - 1)
                        Divider(
                          height: 1,
                          color: AppColors.border.withValues(alpha: 0.5),
                          indent: 16,
                          endIndent: 16,
                        ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.xxxl),

              // Bottom: Contact & Email Section
              _buildSectionHeader('CONTACT & SUPPORT'),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    SettingsTile(
                      title: 'Contact Phone',
                      subtitle: _supportPhone,
                      icon: Icons.phone_outlined,
                      color: AppColors.primary,
                      isFirst: true,
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      onTap: () => _handleCallPhone(context),
                    ),
                    Divider(
                      height: 1,
                      color: AppColors.border.withValues(alpha: 0.5),
                      indent: 56,
                    ),
                    SettingsTile(
                      title: 'Email Support',
                      subtitle: _supportEmail,
                      icon: Icons.mail_outline_rounded,
                      color: Colors.deepOrange,
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      onTap: () => _handleSendEmail(context),
                    ),
                    Divider(
                      height: 1,
                      color: AppColors.border.withValues(alpha: 0.5),
                      indent: 56,
                    ),
                    SettingsTile(
                      title: 'WhatsApp Chat',
                      subtitle: 'Quick support & assistance',
                      icon: Icons.chat_outlined,
                      color: Colors.green,
                      isLast: true,
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      onTap: () => _handleOpenWhatsApp(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildFaqItem(BuildContext context, String question, String answer) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        iconColor: AppColors.primary,
        collapsedIconColor: AppColors.textMuted,
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        children: [
          Text(
            answer,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCallPhone(BuildContext context) async {
    final uri = Uri(scheme: 'tel', path: _supportPhone.replaceAll(' ', ''));
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          _copyToClipboard(
            context,
            _supportPhone,
            'Phone number copied to clipboard',
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        _copyToClipboard(
          context,
          _supportPhone,
          'Phone number copied to clipboard',
        );
      }
    }
  }

  Future<void> _handleSendEmail(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      queryParameters: {'subject': 'invoz Support Request'},
    );
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          _copyToClipboard(
            context,
            _supportEmail,
            'Support email copied to clipboard',
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        _copyToClipboard(
          context,
          _supportEmail,
          'Support email copied to clipboard',
        );
      }
    }
  }

  Future<void> _handleOpenWhatsApp(BuildContext context) async {
    final uri = Uri.parse(
      'https://wa.me/$_whatsappNumber?text=Hello%20invoz%20Support',
    );
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          _copyToClipboard(
            context,
            _supportPhone,
            'Contact number copied to clipboard',
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        _copyToClipboard(
          context,
          _supportPhone,
          'Contact number copied to clipboard',
        );
      }
    }
  }

  void _copyToClipboard(BuildContext context, String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
