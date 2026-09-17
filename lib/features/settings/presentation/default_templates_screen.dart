import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../business_profile/bloc/business_profile_bloc.dart';
import '../../business_profile/bloc/business_profile_event.dart';
import '../../business_profile/bloc/business_profile_state.dart';
import '../../documents/domain/document_model.dart';
import '../../documents/presentation/widgets/template_thumbnail_card.dart';
import '../../pdf_engine/template_registry.dart';

class DefaultTemplatesScreen extends StatefulWidget {
  const DefaultTemplatesScreen({super.key});

  @override
  State<DefaultTemplatesScreen> createState() => _DefaultTemplatesScreenState();
}

class _DefaultTemplatesScreenState extends State<DefaultTemplatesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<DocumentType> _types = [
    DocumentType.invoice,
    DocumentType.quotation,
    DocumentType.receipt,
    DocumentType.proforma,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _types.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Default Templates', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.canvas,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: _types.map((t) => Tab(text: t.displayName)).toList(),
        ),
      ),
      body: BlocBuilder<BusinessProfileBloc, BusinessProfileState>(
        builder: (context, state) {
          if (state is BusinessProfileError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is! BusinessProfileLoaded) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final profile = state.profile;

          return TabBarView(
            controller: _tabController,
            children: _types.map((type) {
              String currentDefaultId;
              switch (type) {
                case DocumentType.invoice:
                  currentDefaultId = profile.defaultInvoiceTemplateId;
                  break;
                case DocumentType.quotation:
                  currentDefaultId = profile.defaultQuotationTemplateId;
                  break;
                case DocumentType.receipt:
                  currentDefaultId = profile.defaultReceiptTemplateId;
                  break;
                case DocumentType.proforma:
                  currentDefaultId = profile.defaultProformaTemplateId;
                  break;
              }

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 24,
                ),
                itemCount: TemplateRegistry.allTemplates.length,
                itemBuilder: (context, index) {
                  final t = TemplateRegistry.allTemplates[index];
                  final isSelected = t.id == currentDefaultId;

                  return TemplateThumbnailCard(
                    template: t,
                    isSelected: isSelected,
                    onTap: () {
                      final updatedProfile = profile.copyWith(
                        defaultInvoiceTemplateId: type == DocumentType.invoice ? t.id : profile.defaultInvoiceTemplateId,
                        defaultQuotationTemplateId: type == DocumentType.quotation ? t.id : profile.defaultQuotationTemplateId,
                        defaultReceiptTemplateId: type == DocumentType.receipt ? t.id : profile.defaultReceiptTemplateId,
                        defaultProformaTemplateId: type == DocumentType.proforma ? t.id : profile.defaultProformaTemplateId,
                      );
                      context.read<BusinessProfileBloc>().add(UpdateBusinessProfileEvent(updatedProfile));
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${t.name} set as default for ${type.displayName}'),
                          duration: const Duration(seconds: 2),
                          backgroundColor: AppColors.statusPaidText,
                        ),
                      );
                    },
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
