import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/utils/currency_formatter.dart';
import '../bloc/reports_bloc.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    // Dispatch GenerateReportEvent to load real data
    context.read<ReportsBloc>().add(GenerateReportEvent(
      startDate: DateTime(DateTime.now().year, 1, 1),
      endDate: DateTime.now(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Analytics',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoading || state is ReportsInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ReportsLoaded) {
            final stats = state.stats;
            final docs = state.documents;
            
            // Total Revenue is unpaidTotal + paidTotal + overdueTotal
            final totalRevenue = stats.unpaidTotal + stats.paidTotal + stats.overdueTotal;

            // Generate monthly spots
            final monthlyData = List.generate(12, (index) => 0.0);
            for (var doc in docs) {
              if (doc.issueDate.year == DateTime.now().year) {
                monthlyData[doc.issueDate.month - 1] += doc.totalAmount;
              }
            }

            final spots = <FlSpot>[];
            double maxMonthVal = 0.0;
            for (int i = 0; i < 12; i++) {
              if (monthlyData[i] > maxMonthVal) maxMonthVal = monthlyData[i];
              spots.add(FlSpot(i.toDouble(), monthlyData[i]));
            }
            if (maxMonthVal == 0) maxMonthVal = 1000.0; // fallback

            // Revenue by client
            final Map<String, double> clientRevenue = {};
            for (var doc in docs) {
              final name = doc.customerSnapshot?.name ?? 'Unknown';
              clientRevenue[name] = (clientRevenue[name] ?? 0) + doc.totalAmount;
            }
            final sortedClients = clientRevenue.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));
            
            final List<PieChartSectionData> pieSections = [];
            final List<Widget> legendWidgets = [];
            
            final colors = [
              AppColors.primary,
              AppColors.primaryDark,
              AppColors.statusPaidText,
              AppColors.statusSentText,
            ];

            double otherRevenue = 0.0;
            for (int i = 0; i < sortedClients.length; i++) {
              if (i < 3) {
                final perc = totalRevenue > 0 ? (sortedClients[i].value / totalRevenue * 100) : 0;
                pieSections.add(PieChartSectionData(
                  color: colors[i],
                  value: sortedClients[i].value,
                  title: perc > 5 ? '${perc.toStringAsFixed(0)}%' : '',
                  radius: _touchedIndex == i ? 60 : 50,
                  titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                ));
                legendWidgets.add(Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildLegend(sortedClients[i].key, colors[i]),
                ));
              } else {
                otherRevenue += sortedClients[i].value;
              }
            }
            if (otherRevenue > 0) {
              final perc = totalRevenue > 0 ? (otherRevenue / totalRevenue * 100) : 0;
              pieSections.add(PieChartSectionData(
                color: colors[3],
                value: otherRevenue,
                title: perc > 5 ? '${perc.toStringAsFixed(0)}%' : '',
                radius: _touchedIndex == 3 ? 60 : 50,
                titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
              ));
              legendWidgets.add(_buildLegend('Others', colors[3]));
            }

            final isDark = Theme.of(context).brightness == Brightness.dark;

            if (pieSections.isEmpty) {
              pieSections.add(PieChartSectionData(
                color: isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade300,
                value: 1,
                title: '',
                radius: 50,
              ));
              legendWidgets.add(_buildLegend('No Data', isDark ? AppColors.darkTextMuted : Colors.grey.shade600));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // KPI Cards Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildKpiCard(
                          'Total Revenue',
                          CurrencyFormatter.formatCompact(totalRevenue),
                          '${docs.length} invoices',
                          Icons.trending_up,
                          AppColors.statusPaidText,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildKpiCard(
                          'Outstanding',
                          CurrencyFormatter.formatCompact(stats.unpaidTotal + stats.overdueTotal),
                          '${stats.unpaidCount + stats.overdueCount} pending',
                          Icons.schedule,
                          AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Monthly Revenue Line Chart
                  Text(
                    'Revenue Overview (This Year)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    padding: const EdgeInsets.all(20),
                    child: SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: maxMonthVal / 4 > 0 ? maxMonthVal / 4 : 1,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: isDark ? AppColors.darkBorder : AppColors.border,
                              strokeWidth: 1,
                              dashArray: [5, 5],
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 22,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  const months = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
                                  if (value.toInt() >= 0 && value.toInt() < 12) {
                                    return Text(
                                      months[value.toInt()],
                                      style: TextStyle(
                                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                        fontSize: 12,
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
                                reservedSize: 40,
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
                          maxY: maxMonthVal * 1.2,
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              color: AppColors.primary,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: const FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Revenue by Category Pie Chart
                  Text(
                    'Revenue by Client',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  AppCard(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        SizedBox(
                          height: 160,
                          width: 160,
                          child: PieChart(
                            PieChartData(
                              pieTouchData: PieTouchData(
                                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                  setState(() {
                                    if (!event.isInterestedForInteractions ||
                                        pieTouchResponse == null ||
                                        pieTouchResponse.touchedSection == null) {
                                      _touchedIndex = -1;
                                      return;
                                    }
                                    _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                  });
                                },
                              ),
                              borderData: FlBorderData(show: false),
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              sections: pieSections,
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: legendWidgets,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          }
          return const Center(child: Text('Error loading reports'));
        },
      ),
    );
  }

  Widget _buildKpiCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
              Icon(icon, size: 20, color: color),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(String label, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
