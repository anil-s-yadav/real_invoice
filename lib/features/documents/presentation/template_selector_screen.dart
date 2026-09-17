import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../business_profile/bloc/business_profile_bloc.dart';
import '../../business_profile/bloc/business_profile_event.dart';
import '../../business_profile/bloc/business_profile_state.dart';
import '../../business_profile/domain/business_profile_model.dart';
import '../../pdf_engine/template_registry.dart';
import '../domain/document_model.dart';
import 'template_preview_screen.dart';
import 'widgets/template_thumbnail_card.dart';

class TemplateSelectorScreen extends StatelessWidget {
  final String initialTemplateId;

  const TemplateSelectorScreen({
    super.key,
    required this.initialTemplateId,
  });

  @override
  Widget build(BuildContext context) {
    final profileState = context.watch<BusinessProfileBloc>().state;
    final profile = profileState is BusinessProfileLoaded
        ? profileState.profile
        : const BusinessProfile(id: '');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Template Gallery'),
        elevation: 0,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75, // Standard A4 proportion
          crossAxisSpacing: 16,
          mainAxisSpacing: 24,
        ),
        itemCount: TemplateRegistry.allTemplates.length,
        itemBuilder: (context, index) {
          final t = TemplateRegistry.allTemplates[index];
          final isSelected = t.id == initialTemplateId;

          return TemplateThumbnailCard(
            template: t,
            isSelected: isSelected,
            onTap: () {
              TemplatePreviewScreen.show(
                context: context,
                template: t,
                documentType: DocumentType.invoice,
                profile: profile,
                isDefault: isSelected,
                onSetDefault: () {
                  final updatedProfile = profile.copyWith(
                    defaultInvoiceTemplateId: t.id,
                  );
                  context.read<BusinessProfileBloc>().add(UpdateBusinessProfileEvent(updatedProfile));
                  Navigator.of(context).pop(t.id);
                },
              );
            },
          );
        },
      ),
    );
  }
}
