import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../domain/analytics_data_models.dart';

class ItemsAndClientsTab extends StatelessWidget {
  final AnalyticsData data;

  const ItemsAndClientsTab({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Client Concentration Risk Card
          _buildConcentrationRiskCard(context, isDark),
          const SizedBox(height: 24),

          // 2. Top Products & Services Leaderboard
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Top Products & Services',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
              Text(
                'By Revenue',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (data.topProducts.isEmpty)
            _buildEmptyCard('No products billed in this period', isDark)
          else
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: List.generate(data.topProducts.length, (index) {
                  final p = data.topProducts[index];
                  final isLast = index == data.topProducts.length - 1;

                  return Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: index == 0
                                    ? AppColors.primary
                                    : (isDark
                                          ? AppColors.darkSurfaceVariant
                                          : const Color(0xFFF1F5F9)),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: index == 0
                                        ? Colors.white
                                        : (isDark
                                              ? AppColors.darkTextSecondary
                                              : AppColors.textSecondary),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.title,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${p.totalQuantity.toStringAsFixed(p.totalQuantity.truncateToDouble() == p.totalQuantity ? 0 : 1)} ${p.unit} sold',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark
                                          ? AppColors.darkTextMuted
                                          : AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  CurrencyFormatter.format(p.totalRevenue),
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  '${p.percentage.toStringAsFixed(1)}% of total',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: (p.percentage / 100.0).clamp(0.0, 1.0),
                            backgroundColor: isDark
                                ? AppColors.darkSurfaceVariant
                                : const Color(0xFFF1F5F9),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              index == 0
                                  ? AppColors.primary
                                  : AppColors.primaryLight.withValues(
                                      alpha: 0.9,
                                    ),
                            ),
                            minHeight: 5,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          const SizedBox(height: 24),

          // 3. Top Clients by LTV & Performance
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Client Intelligence & LTV',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.textPrimary,
                ),
              ),
              Text(
                'Top 5 Clients',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (data.topClients.isEmpty)
            _buildEmptyCard(
              'No client transactions recorded in this period',
              isDark,
            )
          else
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: List.generate(data.topClients.length, (index) {
                  final c = data.topClients[index];
                  final isLast = index == data.topClients.length - 1;

                  Color reliabilityBg = AppColors.statusPaidBg;
                  Color reliabilityText = AppColors.statusPaidText;
                  if (c.reliability == 'Slow') {
                    reliabilityBg = const Color(0xFFFEE2E2);
                    reliabilityText = const Color(0xFFDC2626);
                  } else if (c.reliability == 'Average') {
                    reliabilityBg = const Color(0xFFFEF3C7);
                    reliabilityText = const Color(0xFFD97706);
                  }

                  return Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primary.withValues(
                            alpha: 0.1,
                          ),
                          child: Text(
                            c.name.isNotEmpty ? c.name[0].toUpperCase() : 'C',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.name,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Text(
                                    '${c.invoiceCount} invoices • ',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark
                                          ? AppColors.darkTextMuted
                                          : AppColors.textMuted,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 1,
                                    ),
                                    decoration: BoxDecoration(
                                      color: reliabilityBg,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      c.reliability,
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        color: reliabilityText,
                                      ),
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
                              CurrencyFormatter.format(c.totalRevenue),
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              c.balanceDue > 0
                                  ? '${CurrencyFormatter.formatCompact(c.balanceDue)} due'
                                  : 'Paid up',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: c.balanceDue > 0
                                    ? const Color(0xFFEF4444)
                                    : AppColors.statusPaidText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          const SizedBox(height: 24),

          // 4. Quotation Funnel & Conversion Rate
          Text(
            'Quotation Pipeline & Win Rate',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildQuotationFunnelCard(context, isDark),
        ],
      ),
    );
  }

  Widget _buildConcentrationRiskCard(BuildContext context, bool isDark) {
    final concentration = data.top3ClientConcentration;
    final isHighRisk = concentration >= 60.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighRisk
            ? (isDark ? const Color(0xFF451A03) : const Color(0xFFFFFBEB))
            : (isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighRisk
              ? (isDark ? const Color(0xFFB45309) : const Color(0xFFFDE68A))
              : (isDark ? const Color(0xFF047857) : const Color(0xFFA7F3D0)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isHighRisk
                ? Icons.warning_amber_rounded
                : Icons.verified_user_rounded,
            color: isHighRisk
                ? const Color(0xFFD97706)
                : AppColors.statusPaidText,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isHighRisk
                      ? 'Client Concentration Notice'
                      : 'Healthy Revenue Diversification',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isHighRisk
                        ? (isDark
                              ? Colors.amber.shade200
                              : const Color(0xFF92400E))
                        : (isDark
                              ? const Color(0xFFA7F3D0)
                              : const Color(0xFF065F46)),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isHighRisk
                      ? 'Top 3 clients account for ${concentration.toStringAsFixed(1)}% of your total revenue. Diversifying client acquisition will improve business resilience.'
                      : 'Your revenue is well distributed across multiple clients, keeping business risk low.',
                  style: TextStyle(
                    fontSize: 12,
                    color: isHighRisk
                        ? (isDark
                              ? Colors.amber.shade100
                              : const Color(0xFFB45309))
                        : (isDark
                              ? const Color(0xFF6EE7B7)
                              : const Color(0xFF047857)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuotationFunnelCard(BuildContext context, bool isDark) {
    final funnel = data.quotationFunnel;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Win Rate (Conversion)',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${funnel.winRate.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${funnel.acceptedCount} of ${funnel.totalQuotations} quotes accepted',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 50,
                width: 1,
                color: isDark ? AppColors.darkBorder : AppColors.border,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Active Pipeline Value',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.formatCompact(funnel.pipelineValue),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${funnel.pendingCount} quotes pending response',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.darkTextMuted
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Funnel stages bar
          Row(
            children: [
              _buildFunnelStagePill(
                'Accepted: ${funnel.acceptedCount}',
                AppColors.statusPaidBg,
                AppColors.statusPaidText,
              ),
              const SizedBox(width: 8),
              _buildFunnelStagePill(
                'Pending: ${funnel.pendingCount}',
                const Color(0xFFFEF3C7),
                const Color(0xFFD97706),
              ),
              const SizedBox(width: 8),
              _buildFunnelStagePill(
                'Lost: ${funnel.lostCount}',
                const Color(0xFFFEE2E2),
                const Color(0xFFDC2626),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFunnelStagePill(String text, Color bg, Color textCol) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textCol,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyCard(String msg, bool isDark) {
    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Text(
          msg,
          style: TextStyle(
            fontSize: 13,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
