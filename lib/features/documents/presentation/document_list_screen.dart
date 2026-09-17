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

class DocumentListScreen extends StatefulWidget {
  final DocumentType? initialFilterType;

  const DocumentListScreen({super.key, this.initialFilterType});

  @override
  State<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen> {
  final TextEditingController _searchController = TextEditingController();
  DocumentType? _selectedType;
  DocumentStatus? _selectedStatus;
  String _searchQuery = '';
  int? _selectedMonth;
  int? _selectedYear;

  static const _monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  List<DateTime> _getRecentMonths() {
    final now = DateTime.now();
    return List.generate(12, (index) {
      return DateTime(now.year, now.month - index, 1);
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialFilterType;
    if (widget.initialFilterType != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _applyFilter(type: widget.initialFilterType);
      });
    }
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
    int? month,
    int? year,
    bool clearType = false,
    bool clearStatus = false,
    bool clearMonth = false,
  }) {
    setState(() {
      if (clearType) {
        _selectedType = null;
      } else if (type != null) _selectedType = type;

      if (clearStatus) {
        _selectedStatus = null;
      } else if (status != null) _selectedStatus = status;

      if (clearMonth) {
        _selectedMonth = null;
        _selectedYear = null;
      } else if (month != null && year != null) {
        _selectedMonth = month;
        _selectedYear = year;
      }

      if (query != null) _searchQuery = query;
    });

    context.read<DocumentBloc>().add(LoadDocumentsEvent(
      type: _selectedType,
      status: _selectedStatus,
      searchQuery: _searchQuery,
      month: _selectedMonth,
      year: _selectedYear,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DocumentBloc, DocumentState>(
      listener: (context, state) {
        if (state is DocumentActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppColors.statusPaidText));
          if (state.resultingDocument != null && state.message.contains('Quotation converted')) {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => PdfPreviewScreen(document: state.resultingDocument!)));
          }
        } else if (state is DocumentError) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppColors.statusOverdueText));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        appBar: AppBar(
          title: const Text('Documents', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: AppColors.canvas,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
        body: Column(
          children: [
            // Filter Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              decoration: BoxDecoration(
                color: AppColors.canvas,
                border: Border(bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.5))),
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 44,
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => _applyFilter(query: val.trim()),
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search doc number or client...',
                        hintStyle: const TextStyle(color: AppColors.textMuted),
                        prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textMuted),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(icon: const Icon(Icons.clear, size: 16), onPressed: () { _searchController.clear(); _applyFilter(query: ''); })
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.5))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 32,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildCompactChip('All', isSelected: _selectedType == null, onSelected: () => _applyFilter(clearType: true)),
                        ...DocumentType.values.map((type) => _buildCompactChip(type.displayName, isSelected: _selectedType == type, onSelected: () => _applyFilter(type: type))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 32,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildCompactDropdown(
                          icon: Icons.calendar_today_outlined,
                          label: _selectedMonth != null ? '${_monthNames[_selectedMonth! - 1]} $_selectedYear' : 'Any Month',
                          items: [
                            const PopupMenuItem<String>(value: 'all', child: Text('Any Month')),
                            ..._getRecentMonths().map((d) => PopupMenuItem<String>(value: '${d.month}-${d.year}', child: Text('${_monthNames[d.month - 1]} ${d.year}'))),
                          ],
                          onSelected: (val) {
                            if (val == 'all') {
                              _applyFilter(clearMonth: true);
                            } else {
                              final parts = val.split('-');
                              _applyFilter(month: int.parse(parts[0]), year: int.parse(parts[1]));
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildCompactDropdown(
                          icon: Icons.filter_alt_outlined,
                          label: _selectedStatus != null ? _selectedStatus!.displayName : 'Any Status',
                          items: [
                            const PopupMenuItem<String>(value: 'all', child: Text('Any Status')),
                            ...[DocumentStatus.draft, DocumentStatus.sent, DocumentStatus.paid, DocumentStatus.partial, DocumentStatus.overdue].map(
                              (s) => PopupMenuItem<String>(value: s.name, child: Text(s.displayName)),
                            ),
                          ],
                          onSelected: (val) {
                            if (val == 'all') {
                              _applyFilter(clearStatus: true);
                            } else {
                              _applyFilter(status: DocumentStatus.values.firstWhere((e) => e.name == val));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Documents List
            Expanded(
              child: BlocBuilder<DocumentBloc, DocumentState>(
                builder: (context, state) {
                  if (state is DocumentLoaded) {
                    final documents = state.documents;
                    if (documents.isEmpty) {
                      final hasFilters = _selectedType != null || _selectedStatus != null || _searchQuery.isNotEmpty || _selectedMonth != null;
                      return EmptyStateView(
                        icon: Icons.description_outlined,
                        title: hasFilters ? 'No documents match' : 'No documents yet',
                        description: hasFilters ? 'Try adjusting filters.' : 'Create your first invoice or quotation.',
                        actionLabel: hasFilters ? null : 'Create Document',
                        onAction: hasFilters ? null : () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DocumentEditorScreen(initialType: DocumentType.invoice))),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      itemCount: documents.length,
                      itemBuilder: (context, index) => _DocumentListItemCard(document: documents[index]),
                    );
                  }
                  if (state is DocumentLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  return const Center(child: Text('Unable to load documents'));
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          heroTag: 'document_fab',
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DocumentEditorScreen(initialType: _selectedType ?? DocumentType.invoice))),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildCompactChip(String label, {required bool isSelected, required VoidCallback onSelected}) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Text(
          label,
          style: TextStyle(color: isSelected ? Colors.white : AppColors.textSecondary, fontSize: 13, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildCompactDropdown({required IconData icon, required String label, required List<PopupMenuEntry<String>> items, required Function(String) onSelected}) {
    return PopupMenuButton<String>(
      onSelected: onSelected,
      itemBuilder: (context) => items,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 16, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

class _DocumentListItemCard extends StatelessWidget {
  final DocumentModel document;
  const _DocumentListItemCard({required this.document});

  Color _getTypeColor(DocumentType type) {
    switch (type) {
      case DocumentType.invoice: return Colors.blueAccent;
      case DocumentType.quotation: return Colors.purpleAccent;
      case DocumentType.receipt: return Colors.greenAccent;
      case DocumentType.proforma: return Colors.orangeAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveStatus = document.calculatedStatus;
    final typeColor = _getTypeColor(document.docType);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: EdgeInsets.zero,
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => PdfPreviewScreen(document: document))),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Accent Line
              Container(width: 6, decoration: BoxDecoration(color: typeColor, borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)))),
              
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Main Info (Middle)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(document.docNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary)),
                                const SizedBox(width: 8),
                                Expanded(child: Text(document.customerSnapshot?.name ?? 'Walk-in Customer', style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textMuted),
                                const SizedBox(width: 4),
                                Text('${DateFormatter.formatShort(document.issueDate)} • ${document.docType.displayName}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      // Right Info (Amount + Status)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(CurrencyFormatter.format(document.totalAmount), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textPrimary)),
                          const SizedBox(height: 6),
                          StatusBadge(status: effectiveStatus, isCompact: true),
                        ],
                      ),
                      const SizedBox(width: 8),
                      // More Actions Menu
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, size: 20, color: AppColors.textMuted),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        onSelected: (val) async {
                          if (val == 'preview') {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => PdfPreviewScreen(document: document)));
                          } else if (val == 'edit') Navigator.of(context).push(MaterialPageRoute(builder: (_) => DocumentEditorScreen(initialDocument: document)));
                          else if (val == 'payment') await PaymentEntrySheet.show(context, document: document);
                          else if (val == 'convert') {
                            context.read<DocumentBloc>().add(ConvertQuotationEvent(document.id));
                            context.read<HomeBloc>().add(const LoadHomeDataEvent());
                          } else if (val == 'delete') {
                            final confirmed = await ConfirmDialog.show(context, title: 'Delete Document?', message: 'Are you sure you want to delete ${document.docType.displayName} "${document.docNumber}"?', confirmLabel: 'Delete', isDestructive: true);
                            if (confirmed && context.mounted) {
                              context.read<DocumentBloc>().add(DeleteDocumentEvent(document.id));
                              context.read<HomeBloc>().add(const LoadHomeDataEvent());
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'preview', child: Row(children: [Icon(Icons.picture_as_pdf_outlined, size: 18), SizedBox(width: 12), Text('View & Share')])),
                          const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit_outlined, size: 18), SizedBox(width: 12), Text('Edit')])),
                          if (document.docType == DocumentType.invoice && document.balanceDue > 0)
                            const PopupMenuItem(value: 'payment', child: Row(children: [Icon(Icons.payments_outlined, size: 18, color: AppColors.statusPaidText), SizedBox(width: 12), Text('Record Payment', style: TextStyle(color: AppColors.statusPaidText))])),
                          if (document.docType == DocumentType.quotation && document.status != DocumentStatus.accepted)
                            const PopupMenuItem(value: 'convert', child: Row(children: [Icon(Icons.transform_outlined, size: 18, color: AppColors.primary), SizedBox(width: 12), Text('Convert to Invoice', style: TextStyle(color: AppColors.primary))])),
                          const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete_outline, size: 18, color: AppColors.statusOverdueText), SizedBox(width: 12), Text('Delete', style: TextStyle(color: AppColors.statusOverdueText))])),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
