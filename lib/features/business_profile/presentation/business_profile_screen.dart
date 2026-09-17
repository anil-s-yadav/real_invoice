import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../home/bloc/home_bloc.dart';
import '../../home/bloc/home_event.dart';
import '../bloc/business_profile_bloc.dart';
import '../bloc/business_profile_event.dart';
import '../bloc/business_profile_state.dart';
import '../domain/business_profile_model.dart';
import '../../onboarding/bloc/onboarding_cubit.dart';
import '../../navigation/main_nav_scaffold.dart';

class BusinessProfileScreen extends StatefulWidget {
  final bool isOnboarding;
  const BusinessProfileScreen({super.key, this.isOnboarding = false});

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
        const SnackBar(content: Text('Please enter your business or freelancer name')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final profileState = context.read<BusinessProfileBloc>().state;
    final currentProfile = profileState is BusinessProfileLoaded ? profileState.profile : const BusinessProfile();
    final updated = currentProfile.copyWith(
      businessName: name,
      phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
      email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : null,
      website: _websiteController.text.trim().isNotEmpty ? _websiteController.text.trim() : null,
      address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
      gstin: _gstinController.text.trim().isNotEmpty
          ? _gstinController.text.trim().toUpperCase()
          : null,
      pan: _panController.text.trim().isNotEmpty
          ? _panController.text.trim().toUpperCase()
          : null,
      bankName: _bankNameController.text.trim().isNotEmpty ? _bankNameController.text.trim() : null,
      accountNumber: _accountNumberController.text.trim().isNotEmpty
          ? _accountNumberController.text.trim()
          : null,
      ifscCode: _ifscController.text.trim().isNotEmpty
          ? _ifscController.text.trim().toUpperCase()
          : null,
      upiId: _upiIdController.text.trim().isNotEmpty ? _upiIdController.text.trim() : null,
      defaultTerms: _termsController.text.trim(),
      defaultNotes: _notesController.text.trim(),
      currencyCode: _currencyCode,
      currencySymbol: _currencySymbol,
    );

    context.read<BusinessProfileBloc>().add(UpdateBusinessProfileEvent(updated));
    context.read<HomeBloc>().add(const LoadHomeDataEvent());

    if (mounted) {
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
            content: Text('Business profile saved! All new documents will use these details.'),
            backgroundColor: AppColors.statusPaidText,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text(widget.isOnboarding ? 'Business Setup' : 'Business Profile', style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.canvas,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        automaticallyImplyLeading: !widget.isOnboarding,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _handleSave,
            child: Text(widget.isOnboarding ? 'Finish' : 'Save', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
      body: BlocConsumer<BusinessProfileBloc, BusinessProfileState>(
        listener: (context, state) {
          if (state is BusinessProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.statusOverdueText),
            );
          }
        },
        builder: (context, state) {
          if (state is BusinessProfileLoaded) {
            _populateFromProfile(state.profile);
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.lg, vertical: AppDimensions.md),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header callout
                    AppCard(
                      backgroundColor: AppColors.primaryLight.withValues(alpha: 0.5),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                      padding: const EdgeInsets.all(AppDimensions.md),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.info_outline, color: AppColors.primary, size: 22),
                          ),
                          const SizedBox(width: AppDimensions.md),
                          Expanded(
                            child: Text(
                              'Configure once. These details automatically appear on your invoices and quotations.',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.xl),

                    // Basic Business Info
                    _buildSectionHeader('BASIC DETAILS'),
                    AppCard(
                      padding: const EdgeInsets.all(AppDimensions.md),
                      child: Column(
                        children: [
                          AppTextField(
                            controller: _nameController,
                            label: 'Business / Freelancer Name *',
                            hint: 'e.g. Apex Creative Studio',
                            textCapitalization: TextCapitalization.words,
                          ),
                          const SizedBox(height: AppDimensions.md),
                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  controller: _phoneController,
                                  label: 'Business Phone',
                                  hint: '+91 98765 43210',
                                  keyboardType: TextInputType.phone,
                                  prefix: const Icon(Icons.phone_outlined, size: 18, color: AppColors.textMuted),
                                ),
                              ),
                              const SizedBox(width: AppDimensions.md),
                              Expanded(
                                child: AppTextField(
                                  controller: _emailController,
                                  label: 'Business Email',
                                  hint: 'billing@apex.in',
                                  keyboardType: TextInputType.emailAddress,
                                  prefix: const Icon(Icons.mail_outline, size: 18, color: AppColors.textMuted),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.md),
                          AppTextField(
                            controller: _addressController,
                            label: 'Business Address',
                            hint: 'Flat/Shop No, Street, City, State, PIN',
                            maxLines: 2,
                          ),
                          const SizedBox(height: AppDimensions.md),
                          AppTextField(
                            controller: _websiteController,
                            label: 'Website (Optional)',
                            hint: 'https://apexstudio.in',
                            keyboardType: TextInputType.url,
                            prefix: const Icon(Icons.language_outlined, size: 18, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.xl),

                    // Tax & Registration (Indian GST / PAN)
                    _buildSectionHeader('TAX & REGISTRATION'),
                    AppCard(
                      padding: const EdgeInsets.all(AppDimensions.md),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  controller: _gstinController,
                                  label: 'GSTIN (GST Number)',
                                  hint: '29AAAAA0000A1Z5',
                                  textCapitalization: TextCapitalization.characters,
                                ),
                              ),
                              const SizedBox(width: AppDimensions.md),
                              Expanded(
                                child: AppTextField(
                                  controller: _panController,
                                  label: 'PAN (Permanent Account No.)',
                                  hint: 'ABCDE1234F',
                                  textCapitalization: TextCapitalization.characters,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.xl),

                    // Default Notes & Terms
                    _buildSectionHeader('DEFAULT TERMS & NOTES'),
                    AppCard(
                      padding: const EdgeInsets.all(AppDimensions.md),
                      child: Column(
                        children: [
                          AppTextField(
                            controller: _termsController,
                            label: 'Terms & Conditions',
                            hint: 'Terms printed at the bottom of documents...',
                            maxLines: 3,
                          ),
                          const SizedBox(height: AppDimensions.md),
                          AppTextField(
                            controller: _notesController,
                            label: 'Client Note / Thank You',
                            hint: 'e.g. Thank you for your business!',
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.xxl),

                    AppButton(
                      label: 'Save Profile',
                      onPressed: _handleSave,
                      isLoading: _isSaving,
                      icon: Icons.check,
                    ),
                    const SizedBox(height: AppDimensions.xxxl),
                  ],
                ),
              ),
            );
          }
          if (state is BusinessProfileLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          return const Center(child: Text('Unable to load profile'));
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
