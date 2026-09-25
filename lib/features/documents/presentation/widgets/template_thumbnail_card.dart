import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../pdf_engine/template_registry.dart';
import '../../domain/document_model.dart';

class TemplateThumbnailCard extends StatelessWidget {
  final TemplateInfo template;
  final bool isSelected;
  final VoidCallback onTap;
  final DocumentType documentType;

  const TemplateThumbnailCard({
    super.key,
    required this.template,
    required this.isSelected,
    required this.onTap,
    this.documentType = DocumentType.invoice,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? template.accentColor
                      : (isDark ? AppColors.darkBorder : AppColors.borderStrong),
                  width: isSelected ? 3 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: _buildDummyDataThumbnail(
                      template.id,
                      template.accentColor,
                      documentType,
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: template.accentColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            template.name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected
                  ? template.accentColor
                  : (isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDummyDataThumbnail(
    String id,
    Color accentColor,
    DocumentType docType,
  ) {
    if (id == TemplateRegistry.sunsetOrange) {
      return _buildSunsetOrangeThumbnail(accentColor, docType);
    }
    return _buildStandardThumbnail(id, accentColor, docType);
  }

  Widget _buildSunsetOrangeThumbnail(Color accentColor, DocumentType docType) {
    const double headingSize = 4.0;
    final Color textColor = Colors.black87;
    final Color mutedColor = Colors.black54;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              docType.displayName.toUpperCase(),
              style: TextStyle(
                color: accentColor,
                fontSize: 6.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'YOUR BRAND',
                style: TextStyle(
                  color: textColor,
                  fontSize: headingSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '004 | 19 JUN',
                style: TextStyle(color: mutedColor, fontSize: 3),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3EC),
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      color: const Color(0xFFFED7AA),
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quotation by',
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 3.2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Your Company\nGSTIN / PAN',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 2.6,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3EC),
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      color: const Color(0xFFFED7AA),
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quotation to',
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 3.2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Studio Den\nGSTIN / PAN',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 2.6,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Orange Header
          Container(
            height: 9,
            color: accentColor,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Item description',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 3.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Qty',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 3.2,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Amount',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 3.2,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          _buildDummyRow(
            'Web Development',
            '1',
            '₹10,000',
            bgColor: Colors.white,
          ),
          _buildDummyRow(
            'Logo Design',
            '1',
            '₹1,000',
            bgColor: const Color(0xFFFFF3EC),
          ),
          _buildDummyRow(
            'Full Stack Dev',
            '1',
            '₹40,000',
            bgColor: Colors.white,
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 35,
                padding: const EdgeInsets.all(2.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3EC),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(
                    color: const Color(0xFFFED7AA),
                    width: 0.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PAYMENT',
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 2.2,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'UPI: user@upi',
                      style: TextStyle(color: Colors.black87, fontSize: 2.2),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Sub Total: ₹51,000',
                    style: TextStyle(color: mutedColor, fontSize: 2.8),
                  ),
                  const Text(
                    'Discount(5%): -₹2,550',
                    style: TextStyle(
                      color: Color(0xFF16A34A),
                      fontSize: 2.8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Total: ₹48,450',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 4.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Auth. Signature',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 2.6,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStandardThumbnail(
    String id,
    Color accentColor,
    DocumentType docType,
  ) {
    const double titleSize = 5.5;
    const double headingSize = 3.8;
    const double bodySize = 3.2;

    final Color textColor = Colors.black87;
    final Color mutedColor = Colors.black54;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header variation based on template
          if (id == TemplateRegistry.bold) ...[
            Container(
              height: 18,
              width: double.infinity,
              color: accentColor,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                docType.displayName.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 7.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 4),
          ] else if (id == TemplateRegistry.corporate) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'YOUR LOGO',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  docType.displayName.toUpperCase(),
                  style: const TextStyle(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Container(height: 1.5, color: accentColor),
            const SizedBox(height: 4),
          ] else ...[
            Row(
              mainAxisAlignment: id == TemplateRegistry.elegant
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'RealInvoice',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (id != TemplateRegistry.elegant)
                  Text(
                    docType.displayName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
          ],

          // Addresses & Meta
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Billed To:',
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: headingSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Acme Corp\n123 Business Rd.',
                    style: TextStyle(
                      color: textColor,
                      fontSize: bodySize,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${docType.prefix}2024-001',
                    style: TextStyle(
                      color: textColor,
                      fontSize: headingSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Date: Oct 1\nDue: Oct 15',
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: bodySize,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 5),

          // Table Header
          Container(
            height: 9,
            color: id == TemplateRegistry.minimal
                ? Colors.transparent
                : accentColor.withValues(alpha: 0.1),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Item',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: headingSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Qty',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: headingSize,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Total',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: headingSize,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          Container(height: 0.8, color: accentColor.withValues(alpha: 0.3)),

          // Table Rows
          _buildDummyRow('Web Design', '1', '₹15,000'),
          _buildDummyRow('Hosting', '12', '₹2,400'),
          _buildDummyRow('Maintenance', '1', '₹5,000'),

          const Spacer(),

          // Totals
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 35,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!, width: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PAYMENT',
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 2.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'UPI: user@upi',
                      style: TextStyle(color: Colors.black87, fontSize: 2.5),
                    ),
                    const Text(
                      'Bank: HDFC A/c..',
                      style: TextStyle(color: Colors.black87, fontSize: 2.5),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Subtotal: ₹22,400',
                    style: TextStyle(color: mutedColor, fontSize: bodySize),
                  ),
                  const SizedBox(height: 0.5),
                  Text(
                    'Tax (18%): ₹4,032',
                    style: TextStyle(color: mutedColor, fontSize: bodySize),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    'Total: ₹26,432',
                    style: TextStyle(
                      color: textColor,
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Footer
          if (id == TemplateRegistry.modernCrimson ||
              id == TemplateRegistry.bold)
            Container(height: 2.5, color: accentColor)
          else
            Container(
              height: 1.5,
              width: double.infinity,
              color: Colors.grey[300],
            ),
        ],
      ),
    );
  }

  Widget _buildDummyRow(
    String item,
    String qty,
    String total, {
    Color? bgColor,
  }) {
    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              item,
              style: const TextStyle(fontSize: 3.2, color: Colors.black87),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              qty,
              style: const TextStyle(fontSize: 3.2, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              total,
              style: const TextStyle(
                fontSize: 3.2,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
