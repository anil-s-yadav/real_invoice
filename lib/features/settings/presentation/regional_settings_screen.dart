import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../business_profile/bloc/business_profile_bloc.dart';
import '../../business_profile/bloc/business_profile_event.dart';
import '../../business_profile/bloc/business_profile_state.dart';

class RegionalSettingsScreen extends StatefulWidget {
  const RegionalSettingsScreen({super.key});

  @override
  State<RegionalSettingsScreen> createState() => _RegionalSettingsScreenState();
}

class _RegionalSettingsScreenState extends State<RegionalSettingsScreen> {
  String _selectedLanguage = 'English';
  String _selectedCountry = 'India';
  String _selectedCurrencyCode = 'INR';
  String _selectedCurrencySymbol = '?';
  bool _isLoading = true;

  final List<String> _languages = ['English', 'Hindi', 'Spanish', 'French'];
  final List<Map<String, String>> _countries = [
    {'name': 'India', 'currency': 'INR', 'symbol': '?'},
    {'name': 'United States', 'currency': 'USD', 'symbol': '\$'},
    {'name': 'United Kingdom', 'currency': 'GBP', 'symbol': '£'},
    {'name': 'Australia', 'currency': 'AUD', 'symbol': 'A\$'},
    {'name': 'Canada', 'currency': 'CAD', 'symbol': 'C\$'},
    {'name': 'Eurozone', 'currency': 'EUR', 'symbol': '€'},
    {'name': 'UAE', 'currency': 'AED', 'symbol': 'AED'},
    {'name': 'Singapore', 'currency': 'SGD', 'symbol': 'S\$'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final state = context.read<BusinessProfileBloc>().state;
    
    if (state is BusinessProfileLoaded) {
      _selectedCurrencyCode = state.profile.currencyCode;
      _selectedCurrencySymbol = state.profile.currencySymbol;
    }

    setState(() {
      _selectedLanguage = prefs.getString('app_language') ?? 'English';
      _selectedCountry = prefs.getString('app_country') ?? 'India';
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', _selectedLanguage);
    await prefs.setString('app_country', _selectedCountry);

    final state = context.read<BusinessProfileBloc>().state;
    if (state is BusinessProfileLoaded) {
      final updatedProfile = state.profile.copyWith(
        currencyCode: _selectedCurrencyCode,
        currencySymbol: _selectedCurrencySymbol,
      );
      context.read<BusinessProfileBloc>().add(UpdateBusinessProfileEvent(updatedProfile));
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Regional settings updated')),
      );
      Navigator.of(context).pop();
    }
  }

  Widget _buildSearchableDropdown({
    required String value,
    required List<String> items,
    required Function(String) onChanged,
    required IconData icon,
  }) {
    return InkWell(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) {
            String searchQuery = '';
            return StatefulBuilder(
              builder: (context, setStateDialog) {
                final filteredItems = items.where((i) => i.toLowerCase().contains(searchQuery.toLowerCase())).toList();
                return Dialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('Select Option', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0),
                          ),
                          onChanged: (val) {
                            setStateDialog(() {
                              searchQuery = val;
                            });
                          },
                        ),
                      ),
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(filteredItems[index]),
                              onTap: () {
                                onChanged(filteredItems[index]);
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
            const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Regional Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.canvas,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.public, size: 48, color: AppColors.primary),
                    const SizedBox(height: 16),
                    const Text('Regional Settings', style: AppTypography.displayMedium),
                    const SizedBox(height: 8),
                    const Text('Choose your preferred language, operating country, and default currency.', style: AppTypography.bodyMedium),
                    const SizedBox(height: 32),

                    // Language
                    const Text('App Language', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    _buildSearchableDropdown(
                      value: _selectedLanguage,
                      items: _languages,
                      onChanged: (val) => setState(() => _selectedLanguage = val),
                      icon: Icons.language,
                    ),
                    const SizedBox(height: 24),

                    // Country & Currency
                    const Text('Operating Country & Currency', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
                          const Icon(Icons.payments_outlined, color: AppColors.textSecondary, size: 20),
                          const SizedBox(width: 12),
                          const Expanded(child: Text('Default Currency', style: TextStyle(color: AppColors.textSecondary))),
                          Text('\ (\)', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Bottom Controls
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: 'Save Settings',
                  onPressed: _saveSettings,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

