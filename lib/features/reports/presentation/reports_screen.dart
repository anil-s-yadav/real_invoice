import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../business_profile/bloc/business_profile_bloc.dart';
import '../../business_profile/bloc/business_profile_state.dart';
import '../bloc/reports_bloc.dart';
import '../domain/analytics_data_models.dart';
import 'widgets/analytics_time_filter_bar.dart';
import 'widgets/tabs/overview_cashflow_tab.dart';
import 'widgets/tabs/receivables_aging_tab.dart';
import 'widgets/tabs/items_and_clients_tab.dart';
import 'widgets/tabs/tax_and_gst_tab.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TimeFilterPreset _selectedPreset = TimeFilterPreset.thisYear;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    final profileState = context.read<BusinessProfileBloc>().state;
    final gstin = profileState is BusinessProfileLoaded ? profileState.profile.gstin : null;

    context.read<ReportsBloc>().add(
      LoadAnalyticsEvent(
        preset: _selectedPreset,
        customStartDate: _customStartDate,
        customEndDate: _customEndDate,
        businessGstin: gstin,
      ),
    );
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 2),
      initialDateRange: DateTimeRange(
        start: _customStartDate ?? DateTime(now.year, 1, 1),
        end: _customEndDate ?? now,
      ),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? ColorScheme.dark(
                    primary: AppColors.primary,
                    surface: AppColors.darkSurface,
                    onSurface: AppColors.darkTextPrimary,
                  )
                : const ColorScheme.light(
                    primary: AppColors.primary,
                    surface: Colors.white,
                    onSurface: AppColors.textPrimary,
                  ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedPreset = TimeFilterPreset.custom;
        _customStartDate = picked.start;
        _customEndDate = DateTime(
          picked.end.year,
          picked.end.month,
          picked.end.day,
          23,
          59,
          59,
        );
      });
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Analytics',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(104),
          child: Column(
            children: [
              // Time Filter Bar
              BlocBuilder<ReportsBloc, ReportsState>(
                builder: (context, state) {
                  DateTime start = DateTime.now();
                  DateTime end = DateTime.now();
                  if (state is ReportsLoaded) {
                    start = state.data.startDate;
                    end = state.data.endDate;
                  }
                  return AnalyticsTimeFilterBar(
                    selectedPreset: _selectedPreset,
                    startDate: start,
                    endDate: end,
                    onPresetSelected: (preset) {
                      setState(() {
                        _selectedPreset = preset;
                      });
                      _loadData();
                    },
                    onSelectCustomRange: _pickCustomRange,
                  );
                },
              ),

              // Segmented TabBar
              Container(
                height: 42,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
                    width: 0.8,
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.border.withValues(alpha: 0.4),
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
                        blurRadius: 4,
                        offset: const Offset(0, 1.5),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  labelColor: isDark ? AppColors.primaryLight : AppColors.primary,
                  unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  labelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Aging'),
                    Tab(text: 'Items & Clients'),
                    Tab(text: 'Tax & GST'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          if (state is ReportsLoading || state is ReportsInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          } else if (state is ReportsLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                OverviewCashflowTab(data: state.data),
                ReceivablesAgingTab(data: state.data),
                ItemsAndClientsTab(data: state.data),
                TaxAndGstTab(data: state.data),
              ],
            );
          } else if (state is ReportsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 42,
                    color: Color(0xFFEF4444),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Failed to calculate analytics',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    state.message,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
