import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/app_button.dart';
import '../../home/bloc/home_bloc.dart';
import '../../home/bloc/home_event.dart';
import '../bloc/business_profile_bloc.dart';
import '../bloc/business_profile_event.dart';
import '../bloc/business_profile_state.dart';
import '../data/business_profile_repository.dart';
import '../domain/business_profile_model.dart';
import '../../onboarding/bloc/onboarding_cubit.dart';
import '../../navigation/main_nav_scaffold.dart';

class BusinessProfileScreen extends StatefulWidget {
  final bool isOnboarding;
  final String? profileId;
  const BusinessProfileScreen({
    super.key,
    this.isOnboarding = false,
    this.profileId,
  });

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _websiteController;
  late final TextEditingController _addressController;
  late final TextEditingController _gstinController;
  late final TextEditingController _panController;
  late final TextEditingController _bankNameController;
  late final TextEditingController _accountNumberController;
  late final TextEditingController _ifscController;
  late final TextEditingController _upiIdController;
  late final TextEditingController _termsController;
  late final TextEditingController _notesController;

  String _currencyCode = 'INR';
  String _currencySymbol = '₹';
  bool _isSaving = false;
  bool _isInitialized = false;
  bool _isLoading = true;
  BusinessProfile _currentProfile = const BusinessProfile(id: '');

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _websiteController = TextEditingController();
    _addressController = TextEditingController();
    _gstinController = TextEditingController();
    _panController = TextEditingController();
    _bankNameController = TextEditingController();
    _accountNumberController = TextEditingController();
    _ifscController = TextEditingController();
    _upiIdController = TextEditingController();
    _termsController = TextEditingController();
    _notesController = TextEditingController();
    _loadInitialProfile();
  }

  Future<void> _loadInitialProfile() async {
    if (widget.profileId == null) {
      final state = context.read<BusinessProfileBloc>().state;
      if (state is BusinessProfileLoaded) {
        _currentProfile = state.profile;
      }
    } else if (widget.profileId!.isEmpty) {
      _currentProfile = const BusinessProfile(id: '');
    } else {
      final repo = context.read<BusinessProfileRepository>();
      try {
        _currentProfile = await repo.getProfile(widget.profileId);
      } catch (_) {}
    }

    _populateFromProfile(_currentProfile);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _populateFromProfile(BusinessProfile profile) {
    if (_isInitialized) return;
    _nameController.text = profile.businessName;
    _phoneController.text = profile.phone ?? '';
    _emailController.text = profile.email ?? '';
    _websiteController.text = profile.website ?? '';
    _addressController.text = profile.address ?? '';
    _gstinController.text = profile.gstin ?? '';
    _panController.text = profile.pan ?? '';
    _bankNameController.text = profile.bankName ?? '';
    _accountNumberController.text = profile.accountNumber ?? '';
    _ifscController.text = profile.ifscCode ?? '';
    _upiIdController.text = profile.upiId ?? '';
    _termsController.text = profile.defaultTerms;
    _notesController.text = profile.defaultNotes;
    _currencyCode = profile.currencyCode;
    _currencySymbol = profile.currencySymbol;
    _isInitialized = true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _addressController.dispose();
    _gstinController.dispose();
    _panController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _upiIdController.dispose();
    _termsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your business or freelancer name'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    final updated = _currentProfile.copyWith(
      businessName: name,
      phone: _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : null,
      email: _emailController.text.trim().isNotEmpty
          ? _emailController.text.trim()
          : null,
      website: _websiteController.text.trim().isNotEmpty
          ? _websiteController.text.trim()
          : null,
      address: _addressController.text.trim().isNotEmpty
          ? _addressController.text.trim()
          : null,
      gstin: _gstinController.text.trim().isNotEmpty
          ? _gstinController.text.trim().toUpperCase()
          : null,
      pan: _panController.text.trim().isNotEmpty
          ? _panController.text.trim().toUpperCase()
          : null,
      bankName: _bankNameController.text.trim().isNotEmpty
          ? _bankNameController.text.trim()
          : null,
      accountNumber: _accountNumberController.text.trim().isNotEmpty
          ? _accountNumberController.text.trim()
          : null,
      ifscCode: _ifscController.text.trim().isNotEmpty
          ? _ifscController.text.trim().toUpperCase()
          : null,
      upiId: _upiIdController.text.trim().isNotEmpty
          ? _upiIdController.text.trim()
          : null,
      defaultTerms: _termsController.text.trim(),
      defaultNotes: _notesController.text.trim(),
      currencyCode: _currencyCode,
      currencySymbol: _currencySymbol,
    );

    final repo = context.read<BusinessProfileRepository>();
    final activeId = await repo.getActiveProfileId();
    final savedProfile = await repo.saveProfile(updated);

    if (widget.isOnboarding ||
        activeId == savedProfile.id ||
        activeId.isEmpty) {
      if (activeId.isEmpty) {
        await repo.setActiveProfileId(savedProfile.id);
      }
      if (mounted) {
        context.read<BusinessProfileBloc>().add(
          UpdateBusinessProfileEvent(savedProfile),
        );
      }
    }

    if (mounted) {
      context.read<HomeBloc>().add(const LoadHomeDataEvent());
      setState(() => _isSaving = false);

      if (widget.isOnboarding) {
        context.read<OnboardingCubit>().completeOnboarding();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainNavScaffold()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Business profile saved! All new documents will use these details.',
            ),
            backgroundColor: AppColors.statusPaidText,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text(
          widget.isOnboarding ? 'Business Setup' : 'Business Profile',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.canvas,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        automaticallyImplyLeading: !widget.isOnboarding,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _handleSave,
            child: Text(
              widget.isOnboarding ? 'Finish' : 'Save',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.md,
                vertical: AppDimensions.md,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionHeader('Basic Details'),
                    _buildSection([
                      _buildFieldRow(
                        label: 'Name *',
                        controller: _nameController,
                        hint: 'Business or Freelancer Name',
                        textCapitalization: TextCapitalization.words,
                      ),
                      _buildFieldRow(
                        label: 'Phone',
                        controller: _phoneController,
                        hint: '+91 98765 43210',
                        keyboardType: TextInputType.phone,
                      ),
                      _buildFieldRow(
                        label: 'Email',
                        controller: _emailController,
                        hint: 'billing@example.com',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      _buildFieldRow(
                        label: 'Website',
                        controller: _websiteController,
                        hint: 'https://example.com',
                        keyboardType: TextInputType.url,
                      ),
                      _buildFieldRow(
                        label: 'Address',
                        controller: _addressController,
                        hint: 'Street, City, State, PIN',
                        maxLines: 2,
                        showDivider: false,
                      ),
                    ]),

                    _buildSectionHeader('Tax & Registration'),
                    _buildSection([
                      _buildFieldRow(
                        label: 'GSTIN',
                        controller: _gstinController,
                        hint: '29AAAAA0000A1Z5',
                        textCapitalization: TextCapitalization.characters,
                      ),
                      _buildFieldRow(
                        label: 'PAN',
                        controller: _panController,
                        hint: 'ABCDE1234F',
                        textCapitalization: TextCapitalization.characters,
                        showDivider: false,
                      ),
                    ]),

                    _buildSectionHeader('Bank & Payment'),
                    _buildSection([
                      _buildFieldRow(
                        label: 'Bank Name',
                        controller: _bankNameController,
                        hint: 'HDFC Bank',
                        textCapitalization: TextCapitalization.words,
                      ),
                      _buildFieldRow(
                        label: 'Account No',
                        controller: _accountNumberController,
                        hint: '501002000000',
                        keyboardType: TextInputType.number,
                      ),
                      _buildFieldRow(
                        label: 'IFSC Code',
                        controller: _ifscController,
                        hint: 'HDFC0001234',
                        textCapitalization: TextCapitalization.characters,
                      ),
                      _buildFieldRow(
                        label: 'UPI ID',
                        controller: _upiIdController,
                        hint: 'name@upi',
                        showDivider: false,
                      ),
                    ]),

                    _buildSectionHeader('Default Terms & Notes'),
                    _buildSection([
                      _buildFieldRow(
                        label: 'Terms',
                        controller: _termsController,
                        hint: 'Terms and Conditions...',
                        maxLines: 3,
                      ),
                      _buildFieldRow(
                        label: 'Notes',
                        controller: _notesController,
                        hint: 'Thank you for your business!',
                        maxLines: 2,
                        showDivider: false,
                      ),
                    ]),

                    const SizedBox(height: AppDimensions.xxl),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.sm,
                      ),
                      child: AppButton(
                        label: 'Save Profile',
                        onPressed: _handleSave,
                        isLoading: _isSaving,
                        icon: Icons.check,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.xxxl),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8, top: 24),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSection(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildFieldRow({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int maxLines = 1,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: maxLines > 1
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 100,
                child: Padding(
                  padding: EdgeInsets.only(top: maxLines > 1 ? 2.0 : 0),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  textCapitalization: textCapitalization,
                  maxLines: maxLines,
                  minLines: maxLines > 1 ? 1 : null,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textMuted,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, indent: 16, color: Color(0xFFEEEEEE)),
      ],
    );
  }
}
