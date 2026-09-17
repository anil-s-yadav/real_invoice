import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../pdf_engine/template_registry.dart';

class TemplateThumbnailCard extends StatelessWidget {
  final TemplateInfo template;
  final bool isSelected;
  final VoidCallback onTap;

  const TemplateThumbnailCard({
    super.key,
    required this.template,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
                  color: isSelected ? template.accentColor : AppColors.borderStrong,
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
                    child: _buildDummyDataThumbnail(template.id, template.accentColor),
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
                        child: const Icon(Icons.check, color: Colors.white, size: 16),
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
              color: isSelected ? template.accentColor : AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDummyDataThumbnail(String id, Color accentColor) {
    const double titleSize = 6.0;
    const double headingSize = 4.0;
    const double bodySize = 3.5;
    
    final Color textColor = Colors.black87;
    final Color mutedColor = Colors.black54;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header variation based on template
          if (id == TemplateRegistry.bold) ...[
            Container(
              height: 20, 
              width: double.infinity,
              color: accentColor,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: const Text('INVOICE', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
            const SizedBox(height: 6),
          ] else if (id == TemplateRegistry.corporate) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('YOUR LOGO', style: TextStyle(color: accentColor, fontSize: titleSize, fontWeight: FontWeight.bold)),
                const Text('INVOICE', style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
              ],
            ),
            const SizedBox(height: 4),
            Container(height: 1.5, color: accentColor),
            const SizedBox(height: 6),
          ] else ...[
            Row(
              mainAxisAlignment: id == TemplateRegistry.elegant ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
              children: [
                Text('RealInvoice', style: TextStyle(color: accentColor, fontSize: titleSize, fontWeight: FontWeight.bold)),
                if (id != TemplateRegistry.elegant) const Text('INVOICE', style: TextStyle(fontSize: titleSize, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ],
            ),
            const SizedBox(height: 6),
          ],

          // Addresses & Meta
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Billed To:', style: TextStyle(color: mutedColor, fontSize: headingSize, fontWeight: FontWeight.bold)),
                  Text('Acme Corp\n123 Business Rd.\nTech Park, 40001', style: TextStyle(color: textColor, fontSize: bodySize, height: 1.2)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('INV-2024-001', style: TextStyle(color: textColor, fontSize: headingSize, fontWeight: FontWeight.bold)),
                  Text('Date: Oct 1, 2024\nDue: Oct 15, 2024', style: TextStyle(color: mutedColor, fontSize: bodySize, height: 1.2)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Table Header
          Container(
            height: 10,
            color: id == TemplateRegistry.minimal ? Colors.transparent : accentColor.withValues(alpha: 0.1),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Expanded(flex: 3, child: Text('Item', style: TextStyle(color: accentColor, fontSize: headingSize, fontWeight: FontWeight.bold))),
                Expanded(flex: 1, child: Text('Qty', style: TextStyle(color: accentColor, fontSize: headingSize, fontWeight: FontWeight.bold), textAlign: TextAlign.center)),
                Expanded(flex: 2, child: Text('Total', style: TextStyle(color: accentColor, fontSize: headingSize, fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
              ],
            ),
          ),
          Container(height: 1, color: accentColor.withValues(alpha: 0.3)),
          
          // Table Rows
          _buildDummyRow('Web Design', '1', '₹15,000'),
          _buildDummyRow('Hosting', '12', '₹2,400'),
          _buildDummyRow('Maintenance', '1', '₹5,000'),
          
          const Spacer(),
          
          // Totals
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Subtotal: ₹22,400', style: TextStyle(color: mutedColor, fontSize: bodySize)),
                  const SizedBox(height: 1),
                  Text('Tax (18%): ₹4,032', style: TextStyle(color: mutedColor, fontSize: bodySize)),
                  const SizedBox(height: 2),
                  Text('Total: ₹26,432', style: TextStyle(color: textColor, fontSize: titleSize, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          
          // Footer
          if (id == TemplateRegistry.modernCrimson || id == TemplateRegistry.bold)
            Container(height: 3, color: accentColor)
          else
            Container(height: 2, width: double.infinity, color: Colors.grey[300]),
        ],
      ),
    );
  }

  Widget _buildDummyRow(String item, String qty, String total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(item, style: const TextStyle(fontSize: 3.5, color: Colors.black87))),
          Expanded(flex: 1, child: Text(qty, style: const TextStyle(fontSize: 3.5, color: Colors.black54), textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text(total, style: const TextStyle(fontSize: 3.5, color: Colors.black87, fontWeight: FontWeight.w500), textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}
