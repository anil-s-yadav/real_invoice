import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../domain/analytics_data_models.dart';

class ReceivablesAgingTab extends StatelessWidget {
  final AnalyticsData data;

  const ReceivablesAgingTab({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalReceivables = data.totalOutstanding;

    final bucketColors = [
      AppColors.statusPaidText,
      const Color(0xFFF59E0B),
      const Color(0xFFF97316),
      const Color(0xFFEA580C),
      const Color(0xFFDC2626),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Receivables Summary Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [AppColors.darkSurface, const Color(0xFF1E1B4B)]
                    : [const Color(0xFF312E81), AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Receivables Due',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                    Icon(
                      Icons.schedule_rounded,
                      color: Colors.white70,
                      size: 18,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  CurrencyFormatter.format(totalReceivables),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Overdue: ${CurrencyFormatter.formatCompact(data.totalOverdue)}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFCA5A5),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Across all open invoices',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 2. Debt Aging Buckets
          Text(
            'Accounts Receivable Aging',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Top segmented horizontal bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    height: 10,
                    child: Row(
                      children: List.generate(data.agingBuckets.length, (index) {
                        final b = data.agingBuckets[index];
                        final flex = (b.percentage * 10).round();
                        if (flex <= 0) return const SizedBox.shrink();
                        return Expanded(
                          flex: flex,
                          child: Container(color: bucketColors[index]),
                        );
                      }),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Buckets list
                ...List.generate(data.agingBuckets.length, (index) {
                  final bucket = data.agingBuckets[index];
                  final color = bucketColors[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                bucket.label,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Text(
                              '${bucket.invoiceCount} inv • ',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                              ),
                            ),
                            Text(
                              CurrencyFormatter.format(bucket.totalAmount),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (bucket.percentage / 100.0).clamp(0.0, 1.0),
                            backgroundColor: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF1F5F9),
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                            minHeight: 5,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 3. Overdue Debtors Leaderboard
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Overdue Debtors',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              if (data.topDebtors.isNotEmpty)
                Text(
                  '${data.topDebtors.length} accounts late',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          if (data.topDebtors.isEmpty)
            AppCard(
              padding: const EdgeInsets.all(28),
              child: Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 40,
                      color: AppColors.statusPaidText,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'All Payments Clear!',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'No overdue balances pending from any customer.',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...data.topDebtors.map((debtor) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          color: Color(0xFFEF4444),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              debtor.customerName,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${debtor.overdueDays} days late',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFDC2626),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '• ${debtor.invoiceCount} invoices',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CurrencyFormatter.format(debtor.totalOverdue),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (debtor.phone != null && debtor.phone!.isNotEmpty)
                            InkWell(
                              onTap: () async {
                                final cleanPhone = debtor.phone!.replaceAll(RegExp(r'\D'), '');
                                final url = Uri.parse(
                                  'https://wa.me/$cleanPhone?text=Hi%20${Uri.encodeComponent(debtor.customerName)},%20gentle%20reminder%20regarding%20the%20outstanding%20balance%20of%20${debtor.totalOverdue}%20on%20your%20invoice.',
                                );
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url, mode: LaunchMode.externalApplication);
                                }
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline_rounded,
                                    size: 13,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Remind',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
