import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../business_profile/bloc/business_profile_bloc.dart';
import '../../business_profile/bloc/business_profile_event.dart';
import '../../business_profile/bloc/business_profile_state.dart';
import '../../business_profile/domain/business_profile_model.dart';
import '../../documents/domain/document_model.dart';
import '../../documents/presentation/template_preview_screen.dart';
import '../../documents/presentation/widgets/template_thumbnail_card.dart';
import '../../pdf_engine/template_registry.dart';

class DefaultTemplatesScreen extends StatefulWidget {
  final int initialIndex;

  const DefaultTemplatesScreen({super.key, this.initialIndex = 0});

  @override
  State<DefaultTemplatesScreen> createState() => _DefaultTemplatesScreenState();
}

class _DefaultTemplatesScreenState extends State<DefaultTemplatesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<DocumentType> _types = [
    DocumentType.invoice,
    DocumentType.quotation,
    DocumentType.receipt,
    DocumentType.proforma,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _types.length,
      vsync: this,
      initialIndex: widget.initialIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getDocumentColor(DocumentType type) {
    switch (type) {
      case DocumentType.invoice:
        return AppColors.primary;
      case DocumentType.quotation:
        return const Color(0xFFF26522);
      case DocumentType.receipt:
        return const Color(0xFF10B981);
      case DocumentType.proforma:
        return const Color(0xFF0284C7);
    }
  }

  IconData _getDocumentIcon(DocumentType type) {
    switch (type) {
      case DocumentType.invoice:
        return Icons.receipt_long_rounded;
      case DocumentType.quotation:
        return Icons.request_quote_rounded;
      case DocumentType.receipt:
        return Icons.task_alt_rounded;
      case DocumentType.proforma:
        return Icons.description_rounded;
    }
  }

  String _getDefaultTemplateId(DocumentType type, BusinessProfile profile) {
    switch (type) {
      case DocumentType.invoice:
        return profile.defaultInvoiceTemplateId;
      case DocumentType.quotation:
        return profile.defaultQuotationTemplateId;
      case DocumentType.receipt:
        return profile.defaultReceiptTemplateId;
      case DocumentType.proforma:
        return profile.defaultProformaTemplateId;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkCanvas : AppColors.canvas,
      appBar: AppBar(
        title: Text(
          'Default Templates',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDark ? AppColors.darkCanvas : AppColors.canvas,
        foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(54),
          child: Container(
            height: 42,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
                width: 0.8,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : Colors.white,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                  color: isDark
                      ? AppColors.darkBorder
                      : AppColors.border.withValues(alpha: 0.4),
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
              labelColor: isDark ? AppColors.primaryDark : AppColors.primary,
              unselectedLabelColor:
                  isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              labelStyle: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
              tabs: const [
                Tab(text: 'Invoice'),
                Tab(text: 'Quotation'),
                Tab(text: 'Receipt'),
                Tab(text: 'Proforma'),
              ],
            ),
          ),
        ),
      ),
      body: BlocBuilder<BusinessProfileBloc, BusinessProfileState>(
        builder: (context, state) {
          if (state is BusinessProfileError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is! BusinessProfileLoaded) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final profile = state.profile;

          return TabBarView(
            controller: _tabController,
            children: _types.map((type) {
              final templates = TemplateRegistry.getTemplatesFor(type);
              final currentDefaultId = _getDefaultTemplateId(type, profile);
              final currentTemplate = TemplateRegistry.getById(
                currentDefaultId,
              );
              final color = _getDocumentColor(type);
              final icon = _getDocumentIcon(type);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Active default banner
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : Colors.grey.withValues(alpha: 0.15),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(icon, color: color, size: 16),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                text: 'Active Default: ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary,
                                ),
                                children: [
                                  TextSpan(
                                    text: currentTemplate.name,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: color,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        ' • Tap any design to preview & set default',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? AppColors.darkTextMuted
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 5 Curated Templates in 2-column Grid
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.72,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 20,
                          ),
                      itemCount: templates.length,
                      itemBuilder: (context, index) {
                        final t = templates[index];
                        final isSelected = t.id == currentDefaultId;

                        return TemplateThumbnailCard(
                          template: t,
                          isSelected: isSelected,
                          documentType: type,

                          onTap: () {
                            TemplatePreviewScreen.show(
                              context: context,
                              template: t,
                              documentType: type,
                              profile: profile,
                              isDefault: isSelected,

                              onSetDefault: () {
                                final updatedProfile = profile.copyWith(
                                  defaultInvoiceTemplateId:
                                      type == DocumentType.invoice
                                      ? t.id
                                      : profile.defaultInvoiceTemplateId,
                                  defaultQuotationTemplateId:
                                      type == DocumentType.quotation
                                      ? t.id
                                      : profile.defaultQuotationTemplateId,
                                  defaultReceiptTemplateId:
                                      type == DocumentType.receipt
                                      ? t.id
                                      : profile.defaultReceiptTemplateId,
                                  defaultProformaTemplateId:
                                      type == DocumentType.proforma
                                      ? t.id
                                      : profile.defaultProformaTemplateId,
                                );
                                context.read<BusinessProfileBloc>().add(
                                  UpdateBusinessProfileEvent(updatedProfile),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${t.name} set as default for ${type.displayName}',
                                    ),
                                    duration: const Duration(seconds: 2),
                                    backgroundColor: AppColors.statusPaidText,
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
