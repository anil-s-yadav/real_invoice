import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/utils/currency_formatter.dart';
import '../../../domain/analytics_data_models.dart';

class OverviewCashflowTab extends StatefulWidget {
  final AnalyticsData data;

  const OverviewCashflowTab({super.key, required this.data});

  @override
  State<OverviewCashflowTab> createState() => _OverviewCashflowTabState();
}

class _OverviewCashflowTabState extends State<OverviewCashflowTab> {
  int _touchedPieIndex = -1;

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Calculate max chart ceiling
    double maxMonthVal = 1000.0;
    for (final spot in data.cashFlowSpots) {
      if (spot.billedAmount > maxMonthVal) maxMonthVal = spot.billedAmount;
      if (spot.collectedAmount > maxMonthVal) maxMonthVal = spot.collectedAmount;
    }

    final billedSpots = data.cashFlowSpots.map((s) => FlSpot(s.monthIndex.toDouble(), s.billedAmount)).toList();
    final collectedSpots = data.cashFlowSpots.map((s) => FlSpot(s.monthIndex.toDouble(), s.collectedAmount)).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. KPI 2x2 Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  context,
                  title: 'Invoiced Revenue',
                  value: CurrencyFormatter.formatCompact(data.totalInvoiced),
                  subtitle: '${data.totalInvoiceCount} documents billed',
                  icon: Icons.receipt_long_rounded,
                  iconColor: AppColors.primary,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  context,
                  title: 'Cash Collected',
                  value: CurrencyFormatter.formatCompact(data.totalCollected),
                  subtitle: 'Actual payments received',
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: AppColors.statusPaidText,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  context,
                  title: 'Outstanding Due',
                  value: CurrencyFormatter.formatCompact(data.totalOutstanding),
                  subtitle: data.totalOverdue > 0
                      ? '${CurrencyFormatter.formatCompact(data.totalOverdue)} overdue'
                      : 'All within due date',
                  icon: Icons.pending_actions_rounded,
                  iconColor: data.totalOverdue > 0 ? const Color(0xFFEF4444) : const Color(0xFFF59E0B),
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  context,
                  title: 'Avg. Invoice Value',
                  value: CurrencyFormatter.formatCompact(data.averageInvoiceValue),
                  subtitle: 'Across current period',
                  icon: Icons.bar_chart_rounded,
                  iconColor: const Color(0xFF8B5CF6),
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2. DSO (Days Sales Outstanding) Banner
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.speed_rounded,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Days to Collect (DSO)',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: data.averageCollectionDays <= 15
                                  ? AppColors.statusPaidBg
                                  : AppColors.statusSentBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              data.averageCollectionDays <= 15 ? 'Healthy' : 'Moderate',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: data.averageCollectionDays <= 15
                                    ? AppColors.statusPaidText
                                    : AppColors.statusSentText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Clients take an average of ${data.averageCollectionDays} days from billing to clear payments.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 3. Billed vs Collected Trend Chart
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Billed vs Collected Trend',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
              Row(
                children: [
                  _buildLegendIndicator('Billed', AppColors.primary),
                  const SizedBox(width: 12),
                  _buildLegendIndicator('Collected', AppColors.statusPaidText),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.fromLTRB(12, 20, 16, 12),
            child: SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxMonthVal / 4 > 0 ? maxMonthVal / 4 : 1,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                      strokeWidth: 0.8,
                      dashArray: [4, 4],
                    ),
                  ),
                  titlesData: FlTitlesData(
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          const months = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
                          final idx = value.toInt();
                          if (idx >= 0 && idx < 12) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                months[idx],
                                style: TextStyle(
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 42,
                        interval: maxMonthVal / 4 > 0 ? maxMonthVal / 4 : 1,
                        getTitlesWidget: (value, meta) {
                          if (value == 0) return const Text('');
                          return Text(
                            CurrencyFormatter.formatCompact(value),
                            style: TextStyle(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 11,
                  minY: 0,
                  maxY: maxMonthVal * 1.25,
                  lineBarsData: [
                    // Billed Line
                    LineChartBarData(
                      spots: billedSpots,
                      isCurved: true,
                      curveSmoothness: 0.25,
                      color: AppColors.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                      ),
                    ),
                    // Collected Line
                    LineChartBarData(
                      spots: collectedSpots,
                      isCurved: true,
                      curveSmoothness: 0.25,
                      color: AppColors.statusPaidText,
                      barWidth: 2.5,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 4. Payment Methods Breakdown
          Text(
            'Payment Methods Mix',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildPaymentMethodsDonut(context, isDark),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isDark,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildLegendIndicator(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodsDonut(BuildContext context, bool isDark) {
    final methods = widget.data.paymentMethodsBreakdown;
    final total = methods.values.fold(0.0, (a, b) => a + b);

    if (methods.isEmpty || total == 0) {
      return AppCard(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 36,
                color: isDark ? AppColors.darkTextMuted : AppColors.textMuted,
              ),
              const SizedBox(height: 8),
              Text(
                'No payments recorded in this period',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final colors = [
      AppColors.primary,
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFF8B5CF6),
      const Color(0xFF06B6D4),
    ];

    final entries = methods.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final pieSections = <PieChartSectionData>[];
    final legendWidgets = <Widget>[];

    for (int i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final color = colors[i % colors.length];
      final pct = (entry.value / total * 100);

      pieSections.add(
        PieChartSectionData(
          color: color,
          value: entry.value,
          title: pct > 8 ? '${pct.toStringAsFixed(0)}%' : '',
          radius: _touchedPieIndex == i ? 52 : 44,
          titleStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );

      legendWidgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.key,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                CurrencyFormatter.formatCompact(entry.value),
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      );
    }

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          SizedBox(
            height: 140,
            width: 140,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (event, pieResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieResponse == null ||
                          pieResponse.touchedSection == null) {
                        _touchedPieIndex = -1;
                        return;
                      }
                      _touchedPieIndex = pieResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 2,
                centerSpaceRadius: 36,
                sections: pieSections,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: legendWidgets,
            ),
          ),
        ],
      ),
    );
  }
}
