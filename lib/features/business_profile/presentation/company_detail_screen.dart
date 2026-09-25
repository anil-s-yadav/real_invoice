import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
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

  late TextEditingController _nameController;
  late TextEditingController _gstinController;
  late TextEditingController _panController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _websiteController;
  late TextEditingController _bankNameController;
  late TextEditingController _accountNumberController;
  late TextEditingController _ifscCodeController;
  late TextEditingController _upiIdController;
  late TextEditingController _termsController;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _profile = widget.profile;

    _nameController = TextEditingController(text: _profile.businessName);
    _gstinController = TextEditingController(text: _profile.gstin ?? '');
    _panController = TextEditingController(text: _profile.pan ?? '');
    _phoneController = TextEditingController(text: _profile.phone ?? '');
    _emailController = TextEditingController(text: _profile.email ?? '');
    _addressController = TextEditingController(text: _profile.address ?? '');
    _websiteController = TextEditingController(text: _profile.website ?? '');
    _bankNameController = TextEditingController(text: _profile.bankName ?? '');
    _accountNumberController =
        TextEditingController(text: _profile.accountNumber ?? '');
    _ifscCodeController = TextEditingController(text: _profile.ifscCode ?? '');
    _upiIdController = TextEditingController(text: _profile.upiId ?? '');
    _termsController = TextEditingController(text: _profile.defaultTerms);
    _notesController = TextEditingController(text: _profile.defaultNotes);

    void markChanged() {
      if (!_hasChanges && mounted) {
        setState(() => _hasChanges = true);
      }
    }

    _nameController.addListener(markChanged);
    _gstinController.addListener(markChanged);
    _panController.addListener(markChanged);
    _phoneController.addListener(markChanged);
    _emailController.addListener(markChanged);
    _addressController.addListener(markChanged);
    _websiteController.addListener(markChanged);
    _bankNameController.addListener(markChanged);
    _accountNumberController.addListener(markChanged);
    _ifscCodeController.addListener(markChanged);
    _upiIdController.addListener(markChanged);
    _termsController.addListener(markChanged);
    _notesController.addListener(markChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _gstinController.dispose();
    _panController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _websiteController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscCodeController.dispose();
    _upiIdController.dispose();
    _termsController.dispose();
    _notesController.dispose();
    super.dispose();
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
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Business Name cannot be empty'),
          backgroundColor: AppColors.statusOverdueText,
        ),
      );
      return;
    }

    final updated = _profile.copyWith(
      businessName: name,
      gstin: _gstinController.text.trim().isEmpty
          ? null
          : _gstinController.text.trim(),
      pan: _panController.text.trim().isEmpty
          ? null
          : _panController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      website: _websiteController.text.trim().isEmpty
          ? null
          : _websiteController.text.trim(),
      bankName: _bankNameController.text.trim().isEmpty
          ? null
          : _bankNameController.text.trim(),
      accountNumber: _accountNumberController.text.trim().isEmpty
          ? null
          : _accountNumberController.text.trim(),
      ifscCode: _ifscCodeController.text.trim().isEmpty
          ? null
          : _ifscCodeController.text.trim(),
      upiId: _upiIdController.text.trim().isEmpty
          ? null
          : _upiIdController.text.trim(),
      defaultTerms: _termsController.text.trim(),
      defaultNotes: _notesController.text.trim(),
    );

    final repo = context.read<BusinessProfileRepository>();
    await repo.saveProfile(updated);
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
          'Are you sure you want to delete "${_nameController.text.isNotEmpty ? _nameController.text : _profile.businessName}"? This action cannot be undone.',
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

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  Color get _textPrimary =>
      _isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDark ? AppColors.darkCanvas : AppColors.canvas,
      appBar: AppBar(
        backgroundColor: _isDark ? AppColors.darkCanvas : AppColors.canvas,
        foregroundColor: _textPrimary,
        elevation: 0,
        title: Text(
          _nameController.text.isEmpty
              ? (_profile.businessName.isEmpty
                  ? 'Company Details'
                  : _profile.businessName)
              : _nameController.text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: AppColors.statusOverdueText,
            ),
            tooltip: 'Delete Company',
            onPressed: _handleDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Company Assets (Logo, Signature, Stamp)
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

            // Business Information
            _buildSectionTitle('Business Information', Icons.business_outlined),
            const SizedBox(height: 12),
            AppTextField(
              controller: _nameController,
              label: 'Business Name *',
              hint: 'e.g. Acme Innovations Pvt Ltd',
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _gstinController,
              label: 'Tax ID / GSTIN',
              hint: 'e.g. 29ABCDE1234F1Z5',
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _panController,
              label: 'Company ID / PAN',
              hint: 'e.g. ABCDE1234F',
              textCapitalization: TextCapitalization.characters,
            ),

            const SizedBox(height: 24),

            // Contact Details
            _buildSectionTitle('Contact Details', Icons.contact_mail_outlined),
            const SizedBox(height: 12),
            AppTextField(
              controller: _phoneController,
              label: 'Phone Number',
              hint: '+91 98765 43210',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _emailController,
              label: 'Email Address',
              hint: 'billing@company.com',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _addressController,
              label: 'Full Address',
              hint: 'Street, City, State, PIN',
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _websiteController,
              label: 'Website',
              hint: 'https://example.com',
              keyboardType: TextInputType.url,
            ),

            const SizedBox(height: 24),

            // Bank & Payment Details
            _buildSectionTitle(
              'Bank & Payment Details',
              Icons.account_balance_outlined,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _bankNameController,
              label: 'Bank Name',
              hint: 'e.g. HDFC Bank',
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _accountNumberController,
              label: 'Account Number',
              hint: 'e.g. 50100234567890',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _ifscCodeController,
              label: 'IFSC Code',
              hint: 'e.g. HDFC0001234',
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _upiIdController,
              label: 'UPI ID / VPA',
              hint: 'e.g. company@okhdfcbank',
            ),

            const SizedBox(height: 24),

            // Invoice Defaults
            _buildSectionTitle(
              'Default Notes & Terms',
              Icons.description_outlined,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _termsController,
              label: 'Terms & Conditions',
              hint: '1. Payment due within 15 days...',
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: _notesController,
              label: 'Customer Notes',
              hint: 'Thank you for your business!',
              maxLines: 2,
            ),

            const SizedBox(height: 24),

            // Active Company Badge
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
              label: 'Update Company',
              onPressed: _hasChanges ? _handleUpdate : null,
              icon: Icons.save_outlined,
            ),
            const SizedBox(height: 12),

            // Delete Button (Available for all companies & plans)
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
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
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
          color: _isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isDark
                ? AppColors.darkBorder
                : AppColors.border.withValues(alpha: 0.4),
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
                            ? CachedNetworkImage(
                                imageUrl: imagePath,
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
              decoration: BoxDecoration(
                color: _isDark ? AppColors.darkSurfaceVariant : AppColors.canvas,
                borderRadius: const BorderRadius.vertical(
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
}
