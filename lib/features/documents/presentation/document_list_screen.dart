import '../data/document_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/app_card.dart';
import '../../home/bloc/home_bloc.dart';
import '../../home/bloc/home_event.dart';
import '../bloc/document_bloc.dart';
import '../bloc/document_event.dart';
import '../bloc/document_state.dart';
import '../domain/document_model.dart';
import 'document_editor_screen.dart';
import 'pdf_preview_screen.dart';
import 'widgets/payment_entry_sheet.dart';
import 'package:printing/printing.dart';
import '../../pdf_engine/document_pdf_generator.dart';
import '../../business_profile/bloc/business_profile_bloc.dart';
import '../../business_profile/bloc/business_profile_state.dart';

enum DateFilterRange {
  allTime,
  last7Days,
  last30Days,
  last90Days,
  last1Year,
  custom,
}

extension DateFilterRangeExt on DateFilterRange {
  String get displayName {
    switch (this) {
      case DateFilterRange.allTime:
        return 'All Time';
      case DateFilterRange.last7Days:
        return 'Last 7 Days';
      case DateFilterRange.last30Days:
        return 'Last 30 Days';
      case DateFilterRange.last90Days:
        return 'Last 90 Days';
      case DateFilterRange.last1Year:
        return 'Last 1 Year';
      case DateFilterRange.custom:
        return 'Custom Range';
    }
  }
}

class DocumentListScreen extends StatefulWidget {
  final DocumentType? initialFilterType;
  final DocumentStatus? initialFilterStatus;

  const DocumentListScreen({
    super.key,
    this.initialFilterType,
    this.initialFilterStatus,
  });

  @override
  State<DocumentListScreen> createState() => DocumentListScreenState();
}

class DocumentListScreenState extends State<DocumentListScreen> {
  final TextEditingController _searchController = TextEditingController();
  DocumentType? _selectedType;
  DocumentStatus? _selectedStatus;
  String _searchQuery = '';

  DateFilterRange _selectedDateRangeType = DateFilterRange.allTime;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialFilterType;
    _selectedStatus = widget.initialFilterStatus;
    if (widget.initialFilterType != null ||
        widget.initialFilterStatus != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _applyFilter(
          type: widget.initialFilterType,
          status: widget.initialFilterStatus,
        );
      });
    }
  }

  void setFilter({
    DocumentType? type,
    DocumentStatus? status,
    bool clearType = false,
    bool clearStatus = false,
    bool clearSearch = true,
  }) {
    if (clearSearch) {
      _searchController.clear();
      _searchQuery = '';
    }
    _applyFilter(
      type: type,
      status: status,
      clearType: clearType || type == null,
      clearStatus: clearStatus,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilter({
    DocumentType? type,
    DocumentStatus? status,
    String? query,
    DateFilterRange? dateRangeType,
    DateTime? customStartDate,
    DateTime? customEndDate,
    bool clearType = false,
    bool clearStatus = false,
  }) {
    setState(() {
      if (clearType) {
        _selectedType = null;
      } else if (type != null) {
        _selectedType = type;
      }

      if (clearStatus) {
        _selectedStatus = null;
      } else if (status != null) {
        _selectedStatus = status;
      }

      if (dateRangeType != null) {
        _selectedDateRangeType = dateRangeType;
        if (dateRangeType == DateFilterRange.custom) {
          _customStartDate = customStartDate;
          _customEndDate = customEndDate;
        } else {
          _customStartDate = null;
          _customEndDate = null;
        }
      }

      if (query != null) _searchQuery = query;
    });

    DateTime? startDate;
    DateTime? endDate;
    final now = DateTime.now();

    switch (_selectedDateRangeType) {
      case DateFilterRange.allTime:
        break;
      case DateFilterRange.last7Days:
        startDate = now.subtract(const Duration(days: 7));
        endDate = now;
        break;
      case DateFilterRange.last30Days:
        startDate = now.subtract(const Duration(days: 30));
        endDate = now;
        break;
      case DateFilterRange.last90Days:
        startDate = now.subtract(const Duration(days: 90));
        endDate = now;
        break;
      case DateFilterRange.last1Year:
        startDate = DateTime(now.year - 1, now.month, now.day);
        endDate = now;
        break;
      case DateFilterRange.custom:
        startDate = _customStartDate;
        endDate = _customEndDate;
        break;
    }

    context.read<DocumentBloc>().add(
      LoadDocumentsEvent(
        type: _selectedType,
        status: _selectedStatus,
        searchQuery: _searchQuery,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  Future<void> _showDateRangePicker() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Select Date Range',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
              ),
              ...DateFilterRange.values.map((range) {
                final isSelected = _selectedDateRangeType == range;
                return ListTile(
                  title: Text(
                    range.displayName,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check,
                          color: isDark ? AppColors.primaryDark : AppColors.primary,
                        )
                      : null,
                  onTap: () async {
                    if (range == DateFilterRange.custom) {
                      Navigator.pop(sheetContext);
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                        builder: (pickerContext, child) {
                          return Theme(
                            data: Theme.of(pickerContext).copyWith(
                              colorScheme: isDark
                                  ? const ColorScheme.dark(
                                      primary: AppColors.primary,
                                      onPrimary: Colors.white,
                                      surface: AppColors.darkSurface,
                                      onSurface: AppColors.darkTextPrimary,
                                    )
                                  : const ColorScheme.light(
                                      primary: AppColors.primary,
                                      onPrimary: Colors.white,
                                      surface: Colors.white,
                                      onSurface: AppColors.textPrimary,
                                    ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) {
                        _applyFilter(
                          dateRangeType: DateFilterRange.custom,
                          customStartDate: picked.start,
                          customEndDate: picked.end,
                        );
                      }
                    } else {
                      _applyFilter(dateRangeType: range);
                      Navigator.pop(sheetContext);
                    }
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showStatusPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Select Status',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  'All Statuses',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                trailing: _selectedStatus == null
                    ? Icon(
                        Icons.check,
                        color: isDark ? AppColors.primaryDark : AppColors.primary,
                      )
                    : null,
                onTap: () {
                  _applyFilter(clearStatus: true);
                  Navigator.pop(sheetContext);
                },
              ),
              Divider(
                height: 1,
                color: isDark ? AppColors.darkBorder : AppColors.border,
              ),
              ...DocumentStatus.values.map((status) {
                final isSelected = _selectedStatus == status;
                return ListTile(
                  title: Text(
                    status.name.toUpperCase(),
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check,
                          color: isDark ? AppColors.primaryDark : AppColors.primary,
                        )
                      : null,
                  onTap: () {
                    _applyFilter(status: status);
                    Navigator.pop(sheetContext);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DocumentBloc, DocumentState>(
      listener: (context, state) {
        if (state is DocumentActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.statusPaidText,
            ),
          );
          if (state.resultingDocument != null &&
              state.message.contains('Quotation converted')) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    PdfPreviewScreen(document: state.resultingDocument!),
              ),
            );
          }
        } else if (state is DocumentError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.statusOverdueText,
            ),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter Header
              Builder(
                builder: (context) {
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  return Container(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCanvas : AppColors.canvas,
                      border: Border(
                        bottom: BorderSide(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.border.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 44,
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (val) =>
                                      _applyFilter(query: val.trim()),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.textPrimary,
                                  ),
                                  decoration: InputDecoration(
                                    hintText:
                                        'Search doc number or client...',
                                    hintStyle: const TextStyle(
                                      color: AppColors.textMuted,
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.search,
                                      size: 20,
                                      color: AppColors.textMuted,
                                    ),
                                    suffixIcon: _searchQuery.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(
                                              Icons.clear,
                                              size: 16,
                                            ),
                                            onPressed: () {
                                              _searchController.clear();
                                              _applyFilter(query: '');
                                            },
                                          )
                                        : null,
                                    filled: true,
                                    fillColor: isDark
                                        ? AppColors.darkSurface
                                        : Colors.white,
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                          vertical: 0,
                                          horizontal: 16,
                                        ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: isDark
                                            ? AppColors.darkBorder
                                            : AppColors.border.withValues(
                                                alpha: 0.5,
                                              ),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(width: 8),
                        // Month Filter Button
                        InkWell(
                          onTap: _showDateRangePicker,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 44,
                            width: 44,
                            decoration: BoxDecoration(
                              color:
                                  _selectedDateRangeType !=
                                      DateFilterRange.allTime
                                  ? AppColors.primary
                                  : (isDark
                                      ? AppColors.darkSurface
                                      : Colors.white),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    _selectedDateRangeType !=
                                        DateFilterRange.allTime
                                    ? AppColors.primary
                                    : (isDark
                                        ? AppColors.darkBorder
                                        : AppColors.border.withValues(
                                            alpha: 0.5,
                                          )),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.calendar_month_outlined,
                              size: 22,
                              color:
                                  _selectedDateRangeType !=
                                      DateFilterRange.allTime
                                  ? Colors.white
                                  : (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textMuted),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Status Filter Button
                        InkWell(
                          onTap: _showStatusPicker,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            height: 44,
                            width: 44,
                            decoration: BoxDecoration(
                              color: _selectedStatus != null
                                  ? AppColors.primary
                                  : (isDark
                                      ? AppColors.darkSurface
                                      : Colors.white),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _selectedStatus != null
                                    ? AppColors.primary
                                    : (isDark
                                        ? AppColors.darkBorder
                                        : AppColors.border.withValues(
                                            alpha: 0.5,
                                          )),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.filter_list_outlined,
                              size: 22,
                              color: _selectedStatus != null
                                  ? Colors.white
                                  : (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textMuted),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 32,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildCompactChip(
                            'All',
                            isSelected: _selectedType == null,
                            onSelected: () => _applyFilter(clearType: true),
                          ),
                          ...DocumentType.values.map(
                            (type) => _buildCompactChip(
                              type.displayName,
                              isSelected: _selectedType == type,
                              onSelected: () => _applyFilter(type: type),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_selectedStatus != null ||
                        _selectedDateRangeType != DateFilterRange.allTime) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        runAlignment: WrapAlignment.start,
                        alignment: WrapAlignment.start,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (_selectedStatus != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _selectedStatus == DocumentStatus.overdue
                                    ? (isDark
                                        ? AppColors.statusOverdueText.withValues(alpha: 0.2)
                                        : AppColors.statusOverdueBg)
                                    : (isDark
                                        ? AppColors.primary.withValues(alpha: 0.2)
                                        : AppColors.primaryLight),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color:
                                      _selectedStatus == DocumentStatus.overdue
                                      ? AppColors.statusOverdueBorder
                                      : (isDark
                                          ? AppColors.primary.withValues(alpha: 0.4)
                                          : AppColors.primary.withValues(
                                              alpha: 0.3,
                                            )),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_selectedStatus ==
                                      DocumentStatus.overdue) ...[
                                    const Icon(
                                      Icons.warning_amber_rounded,
                                      size: 14,
                                      color: AppColors.statusOverdueText,
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                  InkWell(
                                    onTap: _showStatusPicker,
                                    child: Text(
                                      'Status: ${_selectedStatus!.displayName}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color:
                                            _selectedStatus ==
                                                DocumentStatus.overdue
                                            ? (isDark
                                                ? const Color(0xFFFCA5A5)
                                                : AppColors.statusOverdueText)
                                            : (isDark
                                                ? AppColors.primaryDark
                                                : AppColors.primary),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  InkWell(
                                    onTap: () =>
                                        _applyFilter(clearStatus: true),
                                    borderRadius: BorderRadius.circular(10),
                                    child: Icon(
                                      Icons.close,
                                      size: 15,
                                      color:
                                          _selectedStatus ==
                                              DocumentStatus.overdue
                                          ? (isDark
                                              ? const Color(0xFFFCA5A5)
                                              : AppColors.statusOverdueText)
                                          : (isDark
                                              ? AppColors.primaryDark
                                              : AppColors.primary),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (_selectedDateRangeType != DateFilterRange.allTime)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.primary.withValues(alpha: 0.2)
                                    : AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.primary.withValues(alpha: 0.4)
                                      : AppColors.primary.withValues(
                                          alpha: 0.3,
                                        ),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_month_outlined,
                                    size: 14,
                                    color: isDark
                                        ? AppColors.primaryDark
                                        : AppColors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  InkWell(
                                    onTap: _showDateRangePicker,
                                    child: Text(
                                      'Date: ${_getDateRangeChipText()}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? AppColors.primaryDark
                                            : AppColors.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  InkWell(
                                    onTap: () => _applyFilter(
                                      dateRangeType: DateFilterRange.allTime,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                    child: Icon(
                                      Icons.close,
                                      size: 15,
                                      color: isDark
                                          ? AppColors.primaryDark
                                          : AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              );
            },
          ),

              // Documents List
              Expanded(
                child: BlocBuilder<DocumentBloc, DocumentState>(
                  builder: (context, state) {
                    if (state is DocumentLoaded) {
                      final documents = state.documents;
                      if (documents.isEmpty) {
                        final hasFilters =
                            _selectedType != null ||
                            _selectedStatus != null ||
                            _searchQuery.isNotEmpty ||
                            _selectedDateRangeType != DateFilterRange.allTime;
                        return EmptyStateView(
                          icon: Icons.description_outlined,
                          title: hasFilters
                              ? 'No documents match'
                              : 'No documents yet',
                          description: hasFilters
                              ? 'Try adjusting filters.'
                              : 'Create your first invoice or quotation.',
                          actionLabel: hasFilters ? null : 'Create Document',
                          onAction: hasFilters
                              ? null
                              : () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => DocumentEditorScreen(
                                      initialType: DocumentType.invoice,
                                    ),
                                  ),
                                ),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        itemCount: documents.length,
                        itemBuilder: (context, index) =>
                            _DocumentListItemCard(document: documents[index]),
                      );
                    }
                    if (state is DocumentLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      );
                    }
                    return const Center(
                      child: Text('Unable to load documents'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        // floatingActionButton: FloatingActionButton(
        //   heroTag: 'document_fab',
        //   onPressed: () => Navigator.of(context).push(
        //     MaterialPageRoute(
        //       builder: (_) => DocumentEditorScreen(
        //         initialType: _selectedType ?? DocumentType.invoice,
        //       ),
        //     ),
        //   ),
        //   backgroundColor: AppColors.primary,
        //   foregroundColor: Colors.white,
        //   elevation: 4,
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(16),
        //   ),
        //   child: const Icon(Icons.add),
        // ),
      ),
    );
  }

  Widget _buildCompactChip(
    String label, {
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.darkSurface : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark
                    ? AppColors.darkBorder
                    : AppColors.border.withValues(alpha: 0.5)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  String _getDateRangeChipText() {
    if (_selectedDateRangeType == DateFilterRange.custom &&
        _customStartDate != null &&
        _customEndDate != null) {
      return '${DateFormatter.formatShort(_customStartDate!)} - ${DateFormatter.formatShort(_customEndDate!)}';
    }
    return _selectedDateRangeType.displayName;
  }
}

class _DocumentListItemCard extends StatelessWidget {
  final DocumentModel document;
  const _DocumentListItemCard({required this.document});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveStatus = document.calculatedStatus;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PdfPreviewScreen(document: document),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Doc Type & Number, Template Tag, Status, Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _buildTypeBadge(document.docType),
                      Text(
                        document.docNumber,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    StatusBadge(status: effectiveStatus, isCompact: true),
                    const SizedBox(width: 4),
                    _buildActionsMenu(context),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Middle Row: Client Name
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 16,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    document.customerSnapshot?.name ?? 'Walk-in Customer',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Bottom Row: Dates & Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 13,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Created: ${DateFormatter.formatShort(document.issueDate)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (document.docType != DocumentType.receipt) ...[
                        const SizedBox(height: 3),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.event_outlined,
                              size: 13,
                              color: effectiveStatus == DocumentStatus.overdue
                                  ? AppColors.statusOverdueText
                                  : AppColors.textMuted,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Due: ${DateFormatter.formatShort(document.dueDate)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: effectiveStatus == DocumentStatus.overdue
                                    ? AppColors.statusOverdueText
                                    : AppColors.textSecondary,
                                fontWeight:
                                    effectiveStatus == DocumentStatus.overdue
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  CurrencyFormatter.format(document.totalAmount),
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: isDark ? AppColors.primaryDark : AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsMenu(BuildContext context) {
    return SizedBox(
      height: 24,
      width: 24,
      child: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textMuted),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onSelected: (val) async {
          if (val == 'preview') {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PdfPreviewScreen(document: document),
              ),
            );
          } else if (val == 'edit') {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => DocumentEditorScreen(initialDocument: document),
              ),
            );
          } else if (val == 'print') {
            final profileState = context.read<BusinessProfileBloc>().state;
            if (profileState is BusinessProfileLoaded) {
              await Printing.layoutPdf(
                onLayout: (format) => DocumentPdfGenerator.generate(
                  document: document,
                  profile: profileState.profile,
                  templateId: document.templateId,
                ),
                name: '${document.docNumber}.pdf',
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Wait for profile to load')),
              );
            }
          } else if (val == 'payment') {
            await PaymentEntrySheet.show(context, document: document);
          } else if (val == 'convert') {
            if (document.docType == DocumentType.proforma) {
              final repo = context.read<DocumentRepository>();
              await repo.convertProformaToInvoice(document.id);
              if (!context.mounted) return;
              final currentLoaded =
                  context.read<DocumentBloc>().state as DocumentLoaded?;
              context.read<DocumentBloc>().add(
                LoadDocumentsEvent(
                  type: currentLoaded?.typeFilter,
                  status: currentLoaded?.statusFilter,
                  searchQuery: currentLoaded?.searchQuery ?? '',
                  startDate: currentLoaded?.startDateFilter,
                  endDate: currentLoaded?.endDateFilter,
                ),
              );
            } else {
              context.read<DocumentBloc>().add(
                ConvertQuotationEvent(document.id),
              );
            }
            context.read<HomeBloc>().add(const LoadHomeDataEvent());
          } else if (val == 'mark_accepted') {
            final repo = context.read<DocumentRepository>();
            await repo.updateDocumentStatus(
              document.id,
              DocumentStatus.accepted,
            );
            if (!context.mounted) return;
            final currentLoaded =
                context.read<DocumentBloc>().state as DocumentLoaded?;
            context.read<DocumentBloc>().add(
              LoadDocumentsEvent(
                type: currentLoaded?.typeFilter,
                status: currentLoaded?.statusFilter,
                searchQuery: currentLoaded?.searchQuery ?? '',
                startDate: currentLoaded?.startDateFilter,
                endDate: currentLoaded?.endDateFilter,
              ),
            );
          } else if (val == 'delete') {
            final confirmed = await ConfirmDialog.show(
              context,
              title: 'Delete Document?',
              message:
                  'Are you sure you want to delete ${document.docType.displayName} "${document.docNumber}"?',
              confirmLabel: 'Delete',
              isDestructive: true,
            );
            if (confirmed && context.mounted) {
              context.read<DocumentBloc>().add(
                DeleteDocumentEvent(document.id),
              );
              context.read<HomeBloc>().add(const LoadHomeDataEvent());
            }
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'preview',
            child: Row(
              children: [
                Icon(Icons.picture_as_pdf_outlined, size: 18),
                SizedBox(width: 12),
                Text('View & Share'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'print',
            child: Row(
              children: [
                Icon(Icons.print_outlined, size: 18),
                SizedBox(width: 12),
                Text('Print'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit_outlined, size: 18),
                SizedBox(width: 12),
                Text('Edit'),
              ],
            ),
          ),
          if (document.docType == DocumentType.invoice &&
              document.balanceDue > 0)
            const PopupMenuItem(
              value: 'payment',
              child: Row(
                children: [
                  Icon(
                    Icons.payments_outlined,
                    size: 18,
                    color: AppColors.statusPaidText,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Record Payment',
                    style: TextStyle(color: AppColors.statusPaidText),
                  ),
                ],
              ),
            ),
          if (document.docType == DocumentType.quotation &&
              document.status != DocumentStatus.accepted)
            const PopupMenuItem(
              value: 'mark_accepted',
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: Colors.green,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Mark as Accepted',
                    style: TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ),
          if (document.docType == DocumentType.proforma ||
              (document.docType == DocumentType.quotation &&
                  document.status == DocumentStatus.accepted))
            const PopupMenuItem(
              value: 'convert',
              child: Row(
                children: [
                  Icon(
                    Icons.transform_outlined,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Convert to Invoice',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ],
              ),
            ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: AppColors.statusOverdueText,
                ),
                SizedBox(width: 12),
                Text(
                  'Delete',
                  style: TextStyle(color: AppColors.statusOverdueText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge(DocumentType docType) {
    final Color bgColor;
    final Color textColor;

    switch (docType) {
      case DocumentType.invoice:
        bgColor = const Color(0xFFEEF2FF);
        textColor = const Color(0xFF4338CA);
        break;
      case DocumentType.quotation:
        bgColor = const Color(0xFFFFFBEB);
        textColor = const Color(0xFFB45309);
        break;
      case DocumentType.receipt:
        bgColor = const Color(0xFFECFDF5);
        textColor = const Color(0xFF047857);
        break;
      case DocumentType.proforma:
        bgColor = const Color(0xFFF0F9FF);
        textColor = const Color(0xFF0369A1);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        docType.displayName.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: textColor,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
