import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../bloc/business_profile_bloc.dart';
import '../bloc/business_profile_event.dart';
import '../data/business_profile_repository.dart';
import '../domain/business_profile_model.dart';

class CompanyDetailScreen extends StatefulWidget {
  final BusinessProfile profile;
  final bool isActive;

  const CompanyDetailScreen({
    super.key,
    required this.profile,
    required this.isActive,
  });

  @override
  State<CompanyDetailScreen> createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen> {
  late BusinessProfile _profile;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;
  }

  Future<void> _pickImage(String field) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bool isSignature = field == 'signature';
      final title = isSignature ? 'Crop Signature' : 'Crop Image';

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: isSignature 
            ? null 
            : const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: title,
            toolbarColor: AppColors.primary,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: isSignature 
                ? CropAspectRatioPreset.original 
                : CropAspectRatioPreset.square,
            lockAspectRatio: !isSignature,
          ),
          IOSUiSettings(
            title: title,
            aspectRatioLockEnabled: !isSignature,
            resetAspectRatioEnabled: false,
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _hasChanges = true;
          if (field == 'logo') {
            _profile = _profile.copyWith(logoPath: croppedFile.path);
          } else if (field == 'signature') {
            _profile = _profile.copyWith(signaturePath: croppedFile.path);
          } else if (field == 'stamp') {
            _profile = _profile.copyWith(stampPath: croppedFile.path);
          }
        });
      }
    }
  }

  Future<void> _handleUpdate() async {
    final repo = context.read<BusinessProfileRepository>();
    await repo.saveProfile(_profile);
    if (mounted) {
      context.read<BusinessProfileBloc>().add(const LoadBusinessProfileEvent());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Company updated successfully'),
          backgroundColor: AppColors.statusPaidText,
        ),
      );
      Navigator.pop(context, true);
    }
  }

  Future<void> _handleDelete() async {
    final confirm = await ConfirmDialog.show(
      context,
      title: 'Delete Company',
      message:
          'Are you sure you want to delete "${_profile.businessName}"? This action cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (confirm && mounted) {
      final repo = context.read<BusinessProfileRepository>();
      await repo.deleteProfile(_profile.id);
      if (mounted) {
        context
            .read<BusinessProfileBloc>()
            .add(const LoadBusinessProfileEvent());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Company deleted'),
            backgroundColor: AppColors.statusOverdueText,
          ),
        );
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text(
          _profile.businessName.isEmpty
              ? 'Company Details'
              : _profile.businessName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.canvas,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Editable Images Section
            _buildSectionTitle('Company Assets', Icons.image_outlined),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildImagePicker(
                    label: 'Logo',
                    imagePath: _profile.logoPath,
                    onTap: () => _pickImage('logo'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildImagePicker(
                    label: 'Signature',
                    imagePath: _profile.signaturePath,
                    onTap: () => _pickImage('signature'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildImagePicker(
                    label: 'Stamp',
                    imagePath: _profile.stampPath,
                    onTap: () => _pickImage('stamp'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Read-only Business Info
            _buildSectionTitle('Business Information', Icons.business_outlined),
            const SizedBox(height: 12),
            _buildReadOnlyField('Business Name', _profile.businessName),
            if (_profile.gstin != null && _profile.gstin!.isNotEmpty)
              _buildReadOnlyField('Tax ID / GSTIN', _profile.gstin!),
            if (_profile.pan != null && _profile.pan!.isNotEmpty)
              _buildReadOnlyField('Company ID / PAN', _profile.pan!),

            const SizedBox(height: 20),

            // Contact Info
            _buildSectionTitle('Contact Details', Icons.contact_mail_outlined),
            const SizedBox(height: 12),
            if (_profile.phone != null && _profile.phone!.isNotEmpty)
              _buildReadOnlyField('Phone', _profile.phone!),
            if (_profile.email != null && _profile.email!.isNotEmpty)
              _buildReadOnlyField('Email', _profile.email!),
            if (_profile.address != null && _profile.address!.isNotEmpty)
              _buildReadOnlyField('Address', _profile.address!),
            if (_profile.website != null && _profile.website!.isNotEmpty)
              _buildReadOnlyField('Website', _profile.website!),

            // Show empty state if no contact info
            if ((_profile.phone == null || _profile.phone!.isEmpty) &&
                (_profile.email == null || _profile.email!.isEmpty) &&
                (_profile.address == null || _profile.address!.isEmpty))
              _buildEmptyField('No contact details added'),

            const SizedBox(height: 20),

            // Payment Details
            if (_profile.paymentDetails.isNotEmpty) ...[
              _buildSectionTitle(
                'Payment Details',
                Icons.account_balance_outlined,
              ),
              const SizedBox(height: 12),
              ..._profile.paymentDetails.map(
                (pd) => _buildReadOnlyField(
                  pd.title.isEmpty ? pd.type : pd.title,
                  pd.details +
                      (pd.extra != null && pd.extra!.isNotEmpty
                          ? '\nIFSC: ${pd.extra}'
                          : ''),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Status
            if (widget.isActive)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'This is your active company',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 28),

            // Update Button
            AppButton(
              label: 'Update',
              onPressed: _hasChanges ? _handleUpdate : null,
              icon: Icons.save_outlined,
            ),
            const SizedBox(height: 12),

            // Delete Button
            if (!widget.isActive)
              AppButton(
                label: 'Delete Company',
                onPressed: _handleDelete,
                variant: AppButtonVariant.danger,
                icon: Icons.delete_outline,
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildImagePicker({
    required String label,
    required String? imagePath,
    required VoidCallback onTap,
  }) {
    final hasImage = imagePath != null && imagePath.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.4),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: hasImage
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: imagePath.startsWith('http')
                            ? Image.network(
                                imagePath,
                                fit: BoxFit.contain,
                              )
                            : Image.file(
                                File(imagePath),
                                fit: BoxFit.contain,
                              ),
                      )
                    : Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 32,
                        color: AppColors.textMuted.withValues(alpha: 0.5),
                      ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: const BoxDecoration(
                color: AppColors.canvas,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(11),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    hasImage ? Icons.edit : Icons.add,
                    size: 12,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyField(String message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          message,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textMuted,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
