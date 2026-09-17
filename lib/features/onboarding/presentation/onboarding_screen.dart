import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../business_profile/bloc/business_profile_bloc.dart';
import '../../business_profile/bloc/business_profile_event.dart';
import '../../business_profile/bloc/business_profile_state.dart';
import '../../business_profile/presentation/business_profile_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  String _selectedLanguage = 'English';
  String _selectedCountry = 'India';
  String _selectedCurrencyCode = 'INR';
  String _selectedCurrencySymbol = '₹';

  final List<String> _languages = ['English', 'Spanish', 'French', 'German'];
  final List<Map<String, String>> _countries = [
    {'name': 'India', 'currency': 'INR', 'symbol': '₹'},
    {'name': 'United States', 'currency': 'USD', 'symbol': '\$'},
    {'name': 'United Kingdom', 'currency': 'GBP', 'symbol': '£'},
    {'name': 'Australia', 'currency': 'AUD', 'symbol': 'A\$'},
    {'name': 'Canada', 'currency': 'CAD', 'symbol': 'C\$'},
    {'name': 'Eurozone', 'currency': 'EUR', 'symbol': '€'},
  ];

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    // Save to SharedPreferences for Language/Country if needed
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', _selectedLanguage);
    await prefs.setString('app_country', _selectedCountry);

    // Update Business Profile with currency
    if (mounted) {
      final state = context.read<BusinessProfileBloc>().state;
      if (state is BusinessProfileLoaded) {
        final profile = state.profile.copyWith(
          currencyCode: _selectedCurrencyCode,
          currencySymbol: _selectedCurrencySymbol,
        );
        context.read<BusinessProfileBloc>().add(UpdateBusinessProfileEvent(profile));
      }
      
      // Navigate to Business Setup (which will complete onboarding on save)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const BusinessProfileScreen(isOnboarding: true),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildLanguageSelection(),
                  _buildCountrySelection(),
                  _buildCurrencySelection(),
                ],
              ),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelection() {
    return _buildAnimatedPage(
      icon: Icons.language,
      title: 'Welcome to RedInvoice',
      subtitle: 'Choose your preferred language to get started.',
      child: ListView.builder(
        itemCount: _languages.length,
        itemBuilder: (context, index) {
          final lang = _languages[index];
          final isSelected = lang == _selectedLanguage;
          return _buildOptionCard(
            title: lang,
            isSelected: isSelected,
            onTap: () {
              setState(() {
                _selectedLanguage = lang;
              });
              Future.delayed(const Duration(milliseconds: 300), _nextPage);
            },
          );
        },
      ),
    );
  }

  Widget _buildCountrySelection() {
    return _buildAnimatedPage(
      icon: Icons.public,
      title: 'Where are you located?',
      subtitle: 'We use this to set up default settings for your business.',
      child: ListView.builder(
        itemCount: _countries.length,
        itemBuilder: (context, index) {
          final countryMap = _countries[index];
          final country = countryMap['name']!;
          final isSelected = country == _selectedCountry;
          return _buildOptionCard(
            title: country,
            subtitle: 'Currency: ${countryMap['currency']}',
            isSelected: isSelected,
            onTap: () {
              setState(() {
                _selectedCountry = country;
                _selectedCurrencyCode = countryMap['currency']!;
                _selectedCurrencySymbol = countryMap['symbol']!;
              });
              Future.delayed(const Duration(milliseconds: 300), _nextPage);
            },
          );
        },
      ),
    );
  }

  Widget _buildCurrencySelection() {
    final currencies = _countries.map((c) => {'code': c['currency']!, 'symbol': c['symbol']!}).toSet().toList();
    if (!currencies.any((c) => c['code'] == 'JPY')) currencies.add({'code': 'JPY', 'symbol': '¥'});
    if (!currencies.any((c) => c['code'] == 'CNY')) currencies.add({'code': 'CNY', 'symbol': '¥'});

    return _buildAnimatedPage(
      icon: Icons.payments,
      title: 'Confirm Currency',
      subtitle: 'You can always change this later in settings.',
      child: ListView.builder(
        itemCount: currencies.length,
        itemBuilder: (context, index) {
          final currency = currencies[index];
          final isSelected = currency['code'] == _selectedCurrencyCode;
          return _buildOptionCard(
            title: '${currency['code']} (${currency['symbol']})',
            isSelected: isSelected,
            onTap: () {
              setState(() {
                _selectedCurrencyCode = currency['code']!;
                _selectedCurrencySymbol = currency['symbol']!;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildAnimatedPage({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
        builder: (context, value, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Opacity(
                  opacity: value,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 48, color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryDark,
                          letterSpacing: -0.5,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 40 * (1 - value)),
                    child: child,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    String? subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                          color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: isSelected ? AppColors.primary : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                AnimatedScale(
                  scale: isSelected ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.check_circle, color: AppColors.primary, size: 28),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Progress Bar
            Expanded(
              child: Row(
                children: List.generate(
                  3,
                  (index) => Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 8),
                      height: 6,
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? AppColors.primary
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 24),
            
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: ElevatedButton(
                key: ValueKey<int>(_currentPage),
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(130, 52), // Override theme infinity width
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _currentPage == 2 ? 'Let\'s Go' : 'Continue',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _currentPage == 2 ? Icons.rocket_launch : Icons.arrow_forward_rounded, 
                      size: 20
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
