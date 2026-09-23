import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../bloc/onboarding_cubit.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../business_profile/bloc/business_profile_bloc.dart';
import '../../business_profile/bloc/business_profile_event.dart';
import '../../business_profile/bloc/business_profile_state.dart';
import '../../navigation/main_nav_scaffold.dart';
import '../../business_profile/domain/business_profile_model.dart';

class OnboardingScreen extends StatefulWidget {
  final bool isAddingNewCompany;

  const OnboardingScreen({super.key, this.isAddingNewCompany = false});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  int get _totalPages => widget.isAddingNewCompany ? 4 : 5;

  final ImagePicker _picker = ImagePicker();

  // Step 1: Localization
  String _selectedLanguage = 'English';
  String _selectedCountry = 'India';
  String _selectedCurrencyCode = 'INR';
  String _selectedCurrencySymbol = '₹';

  // Step 2, 3, 4: Images
  String? _logoPath;
  String? _signaturePath;
  String? _stampPath;

  // Step 5: Business Info
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _gstinController = TextEditingController();
  final _panController = TextEditingController();
  final _websiteController = TextEditingController();

  final List<String> _languages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Hindi',
    'Arabic',
  ];
  final List<Map<String, String>> _countries = [
    {'name': 'India', 'currency': 'INR', 'symbol': '₹'},
    {'name': 'United States', 'currency': 'USD', 'symbol': '\$'},
    {'name': 'United Kingdom', 'currency': 'GBP', 'symbol': '£'},
    {'name': 'Australia', 'currency': 'AUD', 'symbol': 'A\$'},
    {'name': 'Canada', 'currency': 'CAD', 'symbol': 'C\$'},
    {'name': 'Eurozone', 'currency': 'EUR', 'symbol': '€'},
    {'name': 'UAE', 'currency': 'AED', 'symbol': 'AED'},
    {'name': 'Singapore', 'currency': 'SGD', 'symbol': 'S\$'},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _gstinController.dispose();
    _panController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      // Validate step 5 form if we're on it before submitting?
      // Actually we submit on step 5.
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    if (widget.isAddingNewCompany) {
      Navigator.of(context).pop();
      return;
    }
    _finishAndNavigate(const BusinessProfile(id: ''));
    // passing empty ID allows the bloc to create a new blank profile, or use existing
  }

  Future<void> _submitOnboarding() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Business Name is required')),
      );
      return;
    }

    final state = context.read<BusinessProfileBloc>().state;

    BusinessProfile profile;
    if (state is BusinessProfileLoaded) {
      profile = state.profile.copyWith(
        businessName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        gstin: _gstinController.text.trim(),
        pan: _panController.text.trim(),
        website: _websiteController.text.trim(),
        currencyCode: _selectedCurrencyCode,
        currencySymbol: _selectedCurrencySymbol,
        logoPath: _logoPath,
        signaturePath: _signaturePath,
        stampPath: _stampPath,
      );
    } else {
      profile = BusinessProfile(
        id: '',
        businessName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        gstin: _gstinController.text.trim(),
        pan: _panController.text.trim(),
        website: _websiteController.text.trim(),
        currencyCode: _selectedCurrencyCode,
        currencySymbol: _selectedCurrencySymbol,
        logoPath: _logoPath,
        signaturePath: _signaturePath,
        stampPath: _stampPath,
      );
    }
    _finishAndNavigate(profile);
  }

  Future<void> _finishAndNavigate(BusinessProfile profile) async {
    if (!widget.isAddingNewCompany) {
      if (mounted) {
        await context.read<OnboardingCubit>().completeOnboarding();
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('app_language', _selectedLanguage);
      await prefs.setString('app_country', _selectedCountry);
    }

    if (mounted) {
      if (profile.businessName.isNotEmpty) {
        context.read<BusinessProfileBloc>().add(
          UpdateBusinessProfileEvent(profile),
        );
      }

      if (widget.isAddingNewCompany) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavScaffold()),
        );
      }
    }
  }

  Future<void> _pickImage(int step) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bool isSignature = step == 2;
      final title = isSignature ? 'Crop Signature' : 'Crop Image';

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: isSignature 
            ? null // Free crop for signature
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
          if (step == 1) _logoPath = croppedFile.path;
          if (step == 2) _signaturePath = croppedFile.path;
          if (step == 3) _stampPath = croppedFile.path;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _skipOnboarding,
            child: const Text(
              'Skip',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
            return Column(
              children: [
                // Progress Indicator
                if (!isKeyboardOpen) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Row(
                      children: List.generate(_totalPages, (index) {
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            height: 4,
                            decoration: BoxDecoration(
                              color: index <= _currentPage
                                  ? AppColors.primary
                                  : AppColors.border,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

            // Page Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: widget.isAddingNewCompany
                    ? [
                        _buildStepImageUpload(
                          1,
                          'Upload Company Logo',
                          'A professional logo builds trust with your clients.',
                          _logoPath,
                        ),
                        _buildStepImageUpload(
                          2,
                          'Upload Signature',
                          'Digital signatures make your invoices authentic and legally compliant.',
                          _signaturePath,
                        ),
                        _buildStepImageUpload(
                          3,
                          'Upload Company Stamp',
                          'Optional. Add an official company stamp/seal.',
                          _stampPath,
                          isOptional: true,
                        ),
                        _buildStep5BusinessInfo(),
                      ]
                    : [
                        _buildStep1Localization(),
                        _buildStepImageUpload(
                          1,
                          'Upload Company Logo',
                          'A professional logo builds trust with your clients.',
                          _logoPath,
                        ),
                        _buildStepImageUpload(
                          2,
                          'Upload Signature',
                          'Digital signatures make your invoices authentic and legally compliant.',
                          _signaturePath,
                        ),
                        _buildStepImageUpload(
                          3,
                          'Upload Company Stamp',
                          'Optional. Add an official company stamp/seal.',
                          _stampPath,
                          isOptional: true,
                        ),
                        _buildStep5BusinessInfo(),
                      ],
              ),
            ),

            // Bottom Controls
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              child: Row(
                children: [
                  Visibility(
                    visible: _currentPage > 0,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: OutlinedButton(
                        onPressed: _previousPage,
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                            horizontal: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: AppButton(
                      key: const ValueKey('continue_button'),
                      label: _currentPage == _totalPages - 1
                          ? 'Complete Setup'
                          : 'Continue',
                      onPressed: _nextPage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    ),
  );
  }

  Widget _buildStep1Localization() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.public, size: 48, color: AppColors.primary),
          const SizedBox(height: 16),
          const Text('Regional Settings', style: AppTypography.displayMedium),
          const SizedBox(height: 8),
          const Text(
            'Choose your preferred language, operating country, and default currency.',
            style: AppTypography.bodyMedium,
          ),
          const SizedBox(height: 32),

          // Language
          const Text(
            'App Language',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _buildSearchableDropdown(
            value: _selectedLanguage,
            items: _languages,
            onChanged: (val) => setState(() => _selectedLanguage = val),
            icon: Icons.language,
          ),
          const SizedBox(height: 24),

          // Country & Currency
          const Text(
            'Operating Country & Currency',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _buildSearchableDropdown(
            value: _selectedCountry,
            items: _countries.map((c) => c['name']!).toList(),
            onChanged: (val) {
              setState(() {
                _selectedCountry = val;
                final country = _countries.firstWhere((c) => c['name'] == val);
                _selectedCurrencyCode = country['currency']!;
                _selectedCurrencySymbol = country['symbol']!;
              });
            },
            icon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.payments_outlined,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Default Currency',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                Text(
                  '$_selectedCurrencyCode ($_selectedCurrencySymbol)',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchableDropdown({
    required String value,
    required List<String> items,
    required Function(String) onChanged,
    required IconData icon,
  }) {
    return InkWell(
      onTap: () {
        _showSearchBottomSheet(
          title: 'Select Option',
          items: items,
          onSelected: onChanged,
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  void _showSearchBottomSheet({
    required String title,
    required List<String> items,
    required Function(String) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            String searchQuery = '';
            return StatefulBuilder(
              builder: (context, setModalState) {
                final filtered = items
                    .where(
                      (item) => item.toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      ),
                    )
                    .toList();
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: AppColors.surfaceVariant,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                        ),
                        onChanged: (val) =>
                            setModalState(() => searchQuery = val),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return ListTile(
                            title: Text(item),
                            onTap: () {
                              onSelected(item);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildStepImageUpload(
    int step,
    String title,
    String subtitle,
    String? imagePath, {
    bool isOptional = false,
  }) {
    final IconData icon = step == 1
        ? Icons.business
        : (step == 2 ? Icons.draw : Icons.verified);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 48, color: AppColors.primary),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Text(title, style: AppTypography.displayMedium)),
              if (isOptional)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Text(
                    '(Optional)',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: AppTypography.bodyMedium),
          const SizedBox(height: 48),

          Center(
            child: GestureDetector(
              onTap: () => _pickImage(step),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: imagePath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.file(File(imagePath), fit: BoxFit.contain),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            size: 48,
                            color: AppColors.primary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Tap to Upload',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
          if (imagePath != null)
            Center(
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    if (step == 1) _logoPath = null;
                    if (step == 2) _signaturePath = null;
                    if (step == 3) _stampPath = null;
                  });
                },
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text(
                  'Remove Image',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStep5BusinessInfo() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.storefront, size: 48, color: AppColors.primary),
            const SizedBox(height: 16),
            const Text(
              'Business Information',
              style: AppTypography.displayMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'Almost done! Enter your primary business details.',
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: 32),

            AppTextField(
              label: 'Business Name',
              controller: _nameController,
              prefix: const Icon(Icons.business),
              onChanged: (val) {
                if (val.isNotEmpty) setState(() {});
              },
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Email Address',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              prefix: const Icon(Icons.email_outlined),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Phone Number',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              prefix: const Icon(Icons.phone_outlined),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Tax ID (GSTIN)',
              controller: _gstinController,
              prefix: const Icon(Icons.receipt_long_outlined),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Company ID (PAN)',
              controller: _panController,
              textCapitalization: TextCapitalization.characters,
              prefix: const Icon(Icons.credit_card_outlined),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Website (Optional)',
              controller: _websiteController,
              keyboardType: TextInputType.url,
              prefix: const Icon(Icons.language_outlined),
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Address',
              controller: _addressController,
              prefix: const Icon(Icons.location_on_outlined),
              maxLines: 3,
            ),
            const SizedBox(height: 48), // Padding for keyboard
          ],
        ),
      ),
    );
  }
}
