import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:invoz/core/constants/app_colors.dart';
import 'package:invoz/features/reports/domain/analytics_data_models.dart';

class PremiumGraphs {
  static Widget buildYoYGrowthChart(
    BuildContext context,
    bool isDark,
    AnalyticsData data,
  ) {
    final spotsCurrent = <FlSpot>[];
    final spotsLast = <FlSpot>[];
    double maxVal = 10.0;

    for (int i = 0; i < 12; i++) {
      final current = data.cashFlowSpots[i].billedAmount;
      final last = data.lastYearBilledSpots[i];
      spotsCurrent.add(FlSpot(i.toDouble(), current));
      spotsLast.add(FlSpot(i.toDouble(), last));
      if (current > maxVal) maxVal = current;
      if (last > maxVal) maxVal = last;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Year-Over-Year Growth',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            Row(
              children: [
                _indicator('This Year', AppColors.primary),
                const SizedBox(width: 8),
                _indicator('Last Year', Colors.grey.withValues(alpha: 0.6)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 220,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
          ),
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    getTitlesWidget: (val, meta) {
                      final idx = val.toInt();
                      if (idx >= 0 && idx < data.cashFlowSpots.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            data.cashFlowSpots[idx].label,
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minY: 0,
              maxY: maxVal * 1.2,
              lineBarsData: [
                LineChartBarData(
                  spots: spotsLast,
                  isCurved: true,
                  color: Colors.grey.withValues(alpha: 0.5),
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  dashArray: [5, 5],
                ),
                LineChartBarData(
                  spots: spotsCurrent,
                  isCurved: true,
                  color: AppColors.primary,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static Widget _indicator(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  static Widget buildDebtAgingDonutChart(
    BuildContext context,
    bool isDark,
    AnalyticsData data,
  ) {
    if (data.totalOutstanding <= 0) return const SizedBox.shrink();

    double bucket15 = 0;
    double bucket30 = 0;
    double bucket60 = 0;
    double bucket90 = 0;
    double bucketOlder = 0;

    for (final bucket in data.agingBuckets) {
      if (bucket.label == '0-15 Days')
        bucket15 = bucket.totalAmount;
      else if (bucket.label == '16-30 Days')
        bucket30 = bucket.totalAmount;
      else if (bucket.label == '31-60 Days')
        bucket60 = bucket.totalAmount;
      else if (bucket.label == '61-90 Days')
        bucket90 = bucket.totalAmount;
      else
        bucketOlder = bucket.totalAmount;
    }

    final sections = <PieChartSectionData>[];
    if (bucket15 > 0)
      sections.add(
        PieChartSectionData(
          color: Colors.green,
          value: bucket15,
          title: '15d',
          radius: 40,
          titleStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    if (bucket30 > 0)
      sections.add(
        PieChartSectionData(
          color: Colors.yellow.shade700,
          value: bucket30,
          title: '30d',
          radius: 45,
          titleStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    if (bucket60 > 0)
      sections.add(
        PieChartSectionData(
          color: Colors.orange,
          value: bucket60,
          title: '60d',
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    if (bucket90 > 0)
      sections.add(
        PieChartSectionData(
          color: Colors.deepOrange,
          value: bucket90,
          title: '90d',
          radius: 55,
          titleStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    if (bucketOlder > 0)
      sections.add(
        PieChartSectionData(
          color: Colors.red,
          value: bucketOlder,
          title: '90d+',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Debt Aging Risk',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 30,
                    sections: sections,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (bucket15 > 0) ...[
                    _indicator('1-15 Days', Colors.green),
                    const SizedBox(height: 4),
                  ],
                  if (bucket30 > 0) ...[
                    _indicator('16-30 Days', Colors.yellow.shade700),
                    const SizedBox(height: 4),
                  ],
                  if (bucket60 > 0) ...[
                    _indicator('31-60 Days', Colors.orange),
                    const SizedBox(height: 4),
                  ],
                  if (bucket90 > 0) ...[
                    _indicator('61-90 Days', Colors.deepOrange),
                    const SizedBox(height: 4),
                  ],
                  if (bucketOlder > 0) ...[
                    _indicator('90+ Days', Colors.red),
                    const SizedBox(height: 4),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget buildNewVsReturningChart(
    BuildContext context,
    bool isDark,
    AnalyticsData data,
  ) {
    double maxVal = 10.0;
    final groups = <BarChartGroupData>[];

    for (int i = 0; i < 12; i++) {
      final newRev = data.newClientRevenueSpots[i];
      final retRev = data.returningClientRevenueSpots[i];
      if ((newRev + retRev) > maxVal) maxVal = newRev + retRev;

      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: newRev + retRev,
              rodStackItems: [
                BarChartRodStackItem(0, retRev, Colors.blueGrey),
                BarChartRodStackItem(
                  retRev,
                  newRev + retRev,
                  AppColors.primary,
                ),
              ],
              width: 12,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'New vs Returning Clients',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
            ),
            Row(
              children: [
                _indicator('New', AppColors.primary),
                const SizedBox(width: 8),
                _indicator('Returning', Colors.blueGrey),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 220,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
          ),
          child: BarChart(
            BarChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    getTitlesWidget: (val, meta) {
                      final idx = val.toInt();
                      if (idx >= 0 && idx < data.cashFlowSpots.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            data.cashFlowSpots[idx].label,
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              maxY: maxVal * 1.2,
              barGroups: groups,
            ),
          ),
        ),
      ],
    );
  }

  static Widget buildTaxMonthlyTrend(
    BuildContext context,
    bool isDark,
    AnalyticsData data,
  ) {
    double maxVal = 10.0;
    final groups = <BarChartGroupData>[];

    for (int i = 0; i < 12; i++) {
      final tax = data.taxMonthlySpots[i];
      if (tax > maxVal) maxVal = tax;

      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: tax,
              color: const Color(0xFFEF4444),
              width: 12,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tax Collection Trend',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 220,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
          ),
          child: BarChart(
            BarChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    getTitlesWidget: (val, meta) {
                      final idx = val.toInt();
                      if (idx >= 0 && idx < data.cashFlowSpots.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            data.cashFlowSpots[idx].label,
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              maxY: maxVal * 1.2,
              barGroups: groups,
            ),
          ),
        ),
      ],
    );
  }

  static Widget buildQuotationFunnelGraphic(
    BuildContext context,
    bool isDark,
    AnalyticsData data,
  ) {
    final funnel = data.quotationFunnel;
    final total = funnel.totalQuotations.toDouble();
    if (total == 0) return const SizedBox.shrink();

    Widget buildLayer(
      String label,
      int count,
      double widthFactor,
      Color color,
    ) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          children: [
            FractionallySizedBox(
              widthFactor: widthFactor,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: const BorderRadius.all(
                    Radius.elliptical(200, 20),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  "$label: $count",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quotation Conversion Funnel',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
          ),
          child: Column(
            children: [
              buildLayer('Created', funnel.totalQuotations, 1.0, Colors.blue),
              buildLayer('Pending', funnel.pendingCount, 0.75, Colors.orange),
              buildLayer('Accepted', funnel.acceptedCount, 0.5, Colors.green),
              if (funnel.lostCount > 0)
                buildLayer('Rejected', funnel.lostCount, 0.25, Colors.red),
            ],
          ),
        ),
      ],
    );
  }
}
