import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  String _currency = 'INR';
  int _selectedCompanyTier =
      0; // 0: 1 Company, 1: 3 Companies, 2: 5 Companies, 3: 10 Companies
  int _currentCardIndex = 1; // Default to 1 Year (index 1)
  late final PageController _pageController;

  final List<String> _companyTiers = [
    'Single Company',
    'Three Companies',
    'Five Companies',
    'Unlimited (10)',
  ];

  final Map<String, String> _currencySymbols = {
    'INR': '₹',
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'AED': 'AED ',
  };

  // Pricing structure: Currency -> CompanyTier (0, 1, 2, 3) -> List of 4 duration plans
  // Plans: 6 Months (Professional), 1 Year (Premier), 2 Years (Gold), 5 Years (Platinum)
  final Map<String, List<List<Map<String, dynamic>>>> _pricingMatrix = {
    'INR': [
      // 1 Company
      [
        {
          'id': '6mo',
          'name': 'Professional',
          'duration': '6 Months',
          'strikePrice': '₹799',
          'price': '₹349',
          'saveText': 'SAVE 56%',
          'monthlyBreakdown': '₹58 / month',
          'subtitle': 'Great for solo entrepreneurs starting out.',
          'tag': null,
          'color': AppColors.primary,
          'features': [
            '1 Company Profile',
            'Unlimited Invoices & Quotes',
            'Cloud Backup & Sync',
            'PDF Export & WhatsApp Share',
            '100% Ad-Free Experience',
            'Reports & Analytics',
          ],
          'missing': [
            'Multi-Device Access',
            'Custom Domain & Branding',
            'Priority 24/7 Phone Support',
          ],
        },
        {
          'id': '1yr',
          'name': 'Premier',
          'duration': '1 Year',
          'strikePrice': '₹1,399',
          'price': '₹599',
          'saveText': 'SAVE 57% • BESTSELLER',
          'monthlyBreakdown': '₹50 / month',
          'subtitle': 'Most popular choice for growing businesses.',
          'tag': 'MOST POPULAR',
          'color': AppColors.primary,
          'features': [
            '1 Company Profile',
            'Unlimited Invoices, Quotations & Receipts',
            'Cloud Backup & Realtime Sync',
            'Multi-Device Access (Up to 3 devices)',
            '50+ Premium Invoice Templates',
            'Payment QR Code on Invoices',
            'Advanced Tax & GST Reports',
            '100% Ad-Free Experience',
          ],
          'missing': ['Priority 24/7 Phone Support'],
        },
        {
          'id': '2yr',
          'name': 'Gold',
          'duration': '2 Years',
          'strikePrice': '₹2,199',
          'price': '₹999',
          'saveText': 'SAVE 55%',
          'monthlyBreakdown': '₹41 / month',
          'subtitle': 'Long-term reliability with extra savings.',
          'tag': 'EXTENDED VALUE',
          'color': Color(0xFFD97706), // Amber Gold
          'features': [
            '1 Company Profile',
            'Unlimited All Documents & Catalog',
            'Cloud Backup & Multi-Device Sync',
            'All 50+ Premium Templates Unlocked',
            'Payment QR Code & Custom Signatures',
            'Advanced Tax, P&L and GST Reports',
            'Client Statement & Ledger Share',
            '100% Ad-Free Experience',
            'VIP Priority Chat Support',
          ],
          'missing': [],
        },
        {
          'id': '5yr',
          'name': 'Platinum',
          'duration': '5 Years',
          'strikePrice': '₹3,999',
          'price': '₹1,699',
          'saveText': 'SAVE 58% • MAXIMUM SAVINGS',
          'monthlyBreakdown': '₹28 / month',
          'subtitle': 'Ultimate peace of mind for established ventures.',
          'tag': 'BEST VALUE',
          'color': Color(0xFF0D9488), // Teal Platinum
          'features': [
            '1 Company Profile (5-Year Lock-in)',
            'Unlimited Invoices, Proformas & Receipts',
            'Zero Subscription Stress for 5 Years',
            'VIP Priority Phone & WhatsApp Support',
            'Automatic Daily Cloud Backups',
            'Multi-Device Sync on all devices',
            'All Upcoming Features Included Free',
            'Free Template Customization Request',
          ],
          'missing': [],
        },
      ],
      // 3 Companies
      [
        {
          'id': '6mo',
          'name': 'Professional',
          'duration': '6 Months',
          'strikePrice': '₹999',
          'price': '₹449',
          'saveText': 'SAVE 55%',
          'monthlyBreakdown': '₹75 / month',
          'subtitle': 'Manage up to 3 separate business profiles.',
          'tag': null,
          'color': AppColors.primary,
          'features': [
            'Up to 3 Company Profiles',
            'Unlimited Invoices & Documents',
            'Individual Logo & Signatures per Company',
            'Cloud Backup & Sync',
            'PDF Export & WhatsApp Share',
            '100% Ad-Free Experience',
          ],
          'missing': ['Multi-Device Access', 'VIP Priority Phone Support'],
        },
        {
          'id': '1yr',
          'name': 'Premier',
          'duration': '1 Year',
          'strikePrice': '₹1,799',
          'price': '₹799',
          'saveText': 'SAVE 56% • BESTSELLER',
          'monthlyBreakdown': '₹66 / month',
          'subtitle': 'Full management for 3 companies.',
          'tag': 'MOST POPULAR',
          'color': AppColors.primary,
          'features': [
            'Up to 3 Company Profiles',
            'Unlimited Documents for all 3 Companies',
            'Multi-Device Sync (Phone + Tablet + Web)',
            'All 50+ Premium Templates Unlocked',
            'Custom Payment QR Code per Company',
            'Consolidated & Separate GST Reports',
            '100% Ad-Free Experience',
            'Fast Email & Chat Support',
          ],
          'missing': [],
        },
        {
          'id': '2yr',
          'name': 'Gold',
          'duration': '2 Years',
          'strikePrice': '₹2,999',
          'price': '₹1,299',
          'saveText': 'SAVE 57%',
          'monthlyBreakdown': '₹54 / month',
          'subtitle': '2 years uninterrupted multi-business billing.',
          'tag': 'EXTENDED VALUE',
          'color': Color(0xFFD97706),
          'features': [
            'Up to 3 Company Profiles',
            'Unlimited Everything across all 3 Companies',
            'Instant Cloud Sync between devices',
            'All Premium Templates & Custom Watermarks',
            'Client Ledgers & Statements',
            'Consolidated P&L & Tax Reports',
            '100% Ad-Free Experience',
            'Priority 24/7 Support',
          ],
          'missing': [],
        },
        {
          'id': '5yr',
          'name': 'Platinum',
          'duration': '5 Years',
          'strikePrice': '₹4,999',
          'price': '₹2,199',
          'saveText': 'SAVE 56% • UNBEATABLE',
          'monthlyBreakdown': '₹36 / month',
          'subtitle': 'Longest protection for 3 businesses.',
          'tag': 'BEST VALUE',
          'color': Color(0xFF0D9488),
          'features': [
            'Up to 3 Company Profiles for 5 Full Years',
            'Unlimited Invoices, Clients & Products',
            'Multi-Device Sync on all phones & tablets',
            'VIP Dedicated Support Manager',
            'All Future Premium Updates Included',
            'Free Template Customization',
            'No Price Hikes Guarantee',
          ],
          'missing': [],
        },
      ],
      // 5 Companies
      [
        {
          'id': '6mo',
          'name': 'Professional',
          'duration': '6 Months',
          'strikePrice': '₹1,299',
          'price': '₹599',
          'saveText': 'SAVE 54%',
          'monthlyBreakdown': '₹100 / month',
          'subtitle': 'Manage 5 businesses in one single app.',
          'tag': null,
          'color': AppColors.primary,
          'features': [
            'Up to 5 Company Profiles',
            'Unlimited Invoices & Quotations',
            'Separate Bank Accounts & UPI per company',
            'Cloud Backup & Secure Sync',
            'PDF Export & WhatsApp Share',
            '100% Ad-Free Experience',
          ],
          'missing': ['VIP Dedicated Support'],
        },
        {
          'id': '1yr',
          'name': 'Premier',
          'duration': '1 Year',
          'strikePrice': '₹2,499',
          'price': '₹1,099',
          'saveText': 'SAVE 56%',
          'monthlyBreakdown': '₹91 / month',
          'subtitle': 'Ideal for accountants & agency owners.',
          'tag': 'MOST POPULAR',
          'color': AppColors.primary,
          'features': [
            'Up to 5 Company Profiles',
            'Unlimited Billing across all 5 Companies',
            'Multi-Device Sync on all screens',
            'All 50+ Premium Professional Templates',
            'Custom GST & HSN Breakdown Reports',
            'Payment Reminders & Ledger Sharing',
            '100% Ad-Free Experience',
            'Priority Fast Support',
          ],
          'missing': [],
        },
        {
          'id': '2yr',
          'name': 'Gold',
          'duration': '2 Years',
          'strikePrice': '₹3,999',
          'price': '₹1,799',
          'saveText': 'SAVE 55%',
          'monthlyBreakdown': '₹75 / month',
          'subtitle': '2 years complete coverage for 5 firms.',
          'tag': 'EXTENDED VALUE',
          'color': Color(0xFFD97706),
          'features': [
            'Up to 5 Company Profiles',
            'Unlimited Everything for 5 firms',
            'Unlimited Devices & Team Access',
            'Automatic Daily Cloud Backups',
            'All Premium Templates & Custom Watermarks',
            'Consolidated P&L & GST Reports',
            'VIP Priority Phone & Chat Support',
          ],
          'missing': [],
        },
        {
          'id': '5yr',
          'name': 'Platinum',
          'duration': '5 Years',
          'strikePrice': '₹6,999',
          'price': '₹2,999',
          'saveText': 'SAVE 57% • TOP TIER',
          'monthlyBreakdown': '₹50 / month',
          'subtitle': '5 Years uninterrupted enterprise control.',
          'tag': 'BEST VALUE',
          'color': Color(0xFF0D9488),
          'features': [
            'Up to 5 Company Profiles for 5 Years',
            'Lowest price per company (Just ₹10/mo/co)',
            'Unlimited Everything with VIP SLA',
            'Multi-Device Sync for all team members',
            'Dedicated Priority Support on WhatsApp',
            'Zero Price Hike Protection',
          ],
          'missing': [],
        },
      ],
      // 10 Companies (Unlimited)
      [
        {
          'id': '6mo',
          'name': 'Professional',
          'duration': '6 Months',
          'strikePrice': '₹1,599',
          'price': '₹799',
          'saveText': 'SAVE 50%',
          'monthlyBreakdown': '₹133 / month',
          'subtitle': 'Up to 10 company profiles.',
          'tag': null,
          'color': AppColors.primary,
          'features': [
            'Up to 10 Company Profiles',
            'Unlimited Documents & Customers',
            'Individual Settings per profile',
            'Cloud Backup & Sync',
            '100% Ad-Free Experience',
          ],
          'missing': [],
        },
        {
          'id': '1yr',
          'name': 'Premier',
          'duration': '1 Year',
          'strikePrice': '₹2,999',
          'price': '₹1,499',
          'saveText': 'SAVE 50%',
          'monthlyBreakdown': '₹125 / month',
          'subtitle': 'Full multi-entity power suite.',
          'tag': 'MOST POPULAR',
          'color': AppColors.primary,
          'features': [
            'Up to 10 Company Profiles',
            'Unlimited Documents, Products & Clients',
            'Multi-Device Sync on all devices',
            'All 50+ Templates & Custom Branding',
            'Individual & Combined Accounting Reports',
            '100% Ad-Free Experience',
            'Priority Fast Support',
          ],
          'missing': [],
        },
        {
          'id': '2yr',
          'name': 'Gold',
          'duration': '2 Years',
          'strikePrice': '₹4,999',
          'price': '₹2,399',
          'saveText': 'SAVE 52%',
          'monthlyBreakdown': '₹100 / month',
          'subtitle': 'Enterprise stability for 2 years.',
          'tag': 'EXTENDED VALUE',
          'color': Color(0xFFD97706),
          'features': [
            'Up to 10 Company Profiles',
            'Unlimited Everything across all 10 profiles',
            'Multi-Device Sync on all tablets and phones',
            'Dedicated WhatsApp Account Manager',
            'Consolidated Multi-Company Financials',
            'Priority 24/7 Support',
          ],
          'missing': [],
        },
        {
          'id': '5yr',
          'name': 'Platinum',
          'duration': '5 Years',
          'strikePrice': '₹8,999',
          'price': '₹3,999',
          'saveText': 'SAVE 55% • ULTRA SAVINGS',
          'monthlyBreakdown': '₹66 / month',
          'subtitle': 'Lifetime-scale access for up to 10 companies.',
          'tag': 'BEST VALUE',
          'color': Color(0xFF0D9488),
          'features': [
            'Up to 10 Company Profiles for 5 Full Years',
            'Only ₹6.6/month per company!',
            'VIP Direct Support Hotline',
            'Multi-Device Sync with Instant Syncing',
            'All Future Pro Features Included',
            'Free Custom PDF Template Design',
          ],
          'missing': [],
        },
      ],
    ],
    // USD
    'USD': [
      // 1 Company
      [
        {
          'id': '6mo',
          'name': 'Professional',
          'duration': '6 Months',
          'strikePrice': '\$9.99',
          'price': '\$4.99',
          'saveText': 'SAVE 50%',
          'monthlyBreakdown': '\$0.83 / month',
          'subtitle': 'Great for solo entrepreneurs starting out.',
          'tag': null,
          'color': AppColors.primary,
          'features': [
            '1 Company Profile',
            'Unlimited Invoices & Quotes',
            'Cloud Backup & Sync',
            'PDF Export & Email Share',
            '100% Ad-Free Experience',
          ],
          'missing': ['Multi-Device Access', 'VIP Support'],
        },
        {
          'id': '1yr',
          'name': 'Premier',
          'duration': '1 Year',
          'strikePrice': '\$17.99',
          'price': '\$7.99',
          'saveText': 'SAVE 55% • BESTSELLER',
          'monthlyBreakdown': '\$0.66 / month',
          'subtitle': 'Most popular choice for small businesses.',
          'tag': 'MOST POPULAR',
          'color': AppColors.primary,
          'features': [
            '1 Company Profile',
            'Unlimited Invoices & Receipts',
            'Multi-Device Sync (Phone + Tablet + Web)',
            '50+ Premium Professional Templates',
            'Payment QR Code & Custom Signatures',
            '100% Ad-Free Experience',
          ],
          'missing': ['VIP Priority Phone Support'],
        },
        {
          'id': '2yr',
          'name': 'Gold',
          'duration': '2 Years',
          'strikePrice': '\$29.99',
          'price': '\$13.99',
          'saveText': 'SAVE 53%',
          'monthlyBreakdown': '\$0.58 / month',
          'subtitle': 'Long-term reliability with extra savings.',
          'tag': 'EXTENDED VALUE',
          'color': Color(0xFFD97706),
          'features': [
            '1 Company Profile',
            'Unlimited All Documents & Catalog',
            'Cloud Backup & Multi-Device Sync',
            'All Premium Templates Unlocked',
            'Client Ledgers & Statements',
            '100% Ad-Free Experience',
            'VIP Priority Chat Support',
          ],
          'missing': [],
        },
        {
          'id': '5yr',
          'name': 'Platinum',
          'duration': '5 Years',
          'strikePrice': '\$49.99',
          'price': '\$21.99',
          'saveText': 'SAVE 56% • BEST VALUE',
          'monthlyBreakdown': '\$0.36 / month',
          'subtitle': '5 years total peace of mind.',
          'tag': 'BEST VALUE',
          'color': Color(0xFF0D9488),
          'features': [
            '1 Company Profile (5-Year Lock-in)',
            'Unlimited Invoices, Proformas & Receipts',
            'VIP Priority Phone & Email Support',
            'Automatic Daily Cloud Backups',
            'All Upcoming Features Included Free',
          ],
          'missing': [],
        },
      ],
      // 3 Companies
      [
        {
          'id': '6mo',
          'name': 'Professional',
          'duration': '6 Months',
          'strikePrice': '\$14.99',
          'price': '\$6.99',
          'saveText': 'SAVE 53%',
          'monthlyBreakdown': '\$1.16 / month',
          'subtitle': 'Up to 3 company profiles.',
          'tag': null,
          'color': AppColors.primary,
          'features': [
            'Up to 3 Company Profiles',
            'Unlimited Invoices & Documents',
            'Cloud Backup & Secure Sync',
            '100% Ad-Free Experience',
          ],
          'missing': ['Multi-Device Access'],
        },
        {
          'id': '1yr',
          'name': 'Premier',
          'duration': '1 Year',
          'strikePrice': '\$24.99',
          'price': '\$11.99',
          'saveText': 'SAVE 52%',
          'monthlyBreakdown': '\$0.99 / month',
          'subtitle': 'Manage 3 businesses easily.',
          'tag': 'MOST POPULAR',
          'color': AppColors.primary,
          'features': [
            'Up to 3 Company Profiles',
            'Unlimited Documents for all 3 Companies',
            'Multi-Device Sync on all screens',
            'All 50+ Premium Templates Unlocked',
            '100% Ad-Free Experience',
          ],
          'missing': [],
        },
        {
          'id': '2yr',
          'name': 'Gold',
          'duration': '2 Years',
          'strikePrice': '\$39.99',
          'price': '\$18.99',
          'saveText': 'SAVE 52%',
          'monthlyBreakdown': '\$0.79 / month',
          'subtitle': '2 Years multi-company access.',
          'tag': 'EXTENDED VALUE',
          'color': Color(0xFFD97706),
          'features': [
            'Up to 3 Company Profiles',
            'Unlimited Everything across all 3 Companies',
            'Instant Cloud Sync between devices',
            'VIP Priority Support',
          ],
          'missing': [],
        },
        {
          'id': '5yr',
          'name': 'Platinum',
          'duration': '5 Years',
          'strikePrice': '\$69.99',
          'price': '\$29.99',
          'saveText': 'SAVE 57%',
          'monthlyBreakdown': '\$0.49 / month',
          'subtitle': '5 Years complete coverage.',
          'tag': 'BEST VALUE',
          'color': Color(0xFF0D9488),
          'features': [
            'Up to 3 Company Profiles for 5 Full Years',
            'Unlimited Invoices, Clients & Products',
            'Multi-Device Sync & VIP SLA',
          ],
          'missing': [],
        },
      ],
      // 5 Companies
      [
        {
          'id': '6mo',
          'name': 'Professional',
          'duration': '6 Months',
          'strikePrice': '\$18.99',
          'price': '\$8.99',
          'saveText': 'SAVE 52%',
          'monthlyBreakdown': '\$1.49 / month',
          'subtitle': 'Manage 5 companies.',
          'tag': null,
          'color': AppColors.primary,
          'features': [
            'Up to 5 Company Profiles',
            'Unlimited Documents',
            'Cloud Backup',
          ],
          'missing': ['Multi-Device Access'],
        },
        {
          'id': '1yr',
          'name': 'Premier',
          'duration': '1 Year',
          'strikePrice': '\$34.99',
          'price': '\$15.99',
          'saveText': 'SAVE 54%',
          'monthlyBreakdown': '\$1.33 / month',
          'subtitle': '5 companies full access.',
          'tag': 'MOST POPULAR',
          'color': AppColors.primary,
          'features': [
            'Up to 5 Company Profiles',
            'Multi-Device Sync',
            'All 50+ Templates',
            '100% Ad-Free',
          ],
          'missing': [],
        },
        {
          'id': '2yr',
          'name': 'Gold',
          'duration': '2 Years',
          'strikePrice': '\$54.99',
          'price': '\$24.99',
          'saveText': 'SAVE 54%',
          'monthlyBreakdown': '\$1.04 / month',
          'subtitle': '2 Years for 5 companies.',
          'tag': 'EXTENDED VALUE',
          'color': Color(0xFFD97706),
          'features': [
            'Up to 5 Company Profiles',
            'Unlimited Everything',
            'VIP Priority Support',
          ],
          'missing': [],
        },
        {
          'id': '5yr',
          'name': 'Platinum',
          'duration': '5 Years',
          'strikePrice': '\$89.99',
          'price': '\$39.99',
          'saveText': 'SAVE 55%',
          'monthlyBreakdown': '\$0.66 / month',
          'subtitle': '5 Years enterprise access.',
          'tag': 'BEST VALUE',
          'color': Color(0xFF0D9488),
          'features': [
            'Up to 5 Company Profiles for 5 Years',
            'Unlimited Everything with VIP SLA',
          ],
          'missing': [],
        },
      ],
      // 10 Companies
      [
        {
          'id': '6mo',
          'name': 'Professional',
          'duration': '6 Months',
          'strikePrice': '\$22.99',
          'price': '\$10.99',
          'saveText': 'SAVE 52%',
          'monthlyBreakdown': '\$1.83 / month',
          'subtitle': 'Up to 10 company profiles.',
          'tag': null,
          'color': AppColors.primary,
          'features': [
            'Up to 10 Company Profiles',
            'Unlimited Documents',
            'Cloud Backup',
          ],
          'missing': [],
        },
        {
          'id': '1yr',
          'name': 'Premier',
          'duration': '1 Year',
          'strikePrice': '\$44.99',
          'price': '\$19.99',
          'saveText': 'SAVE 55%',
          'monthlyBreakdown': '\$1.66 / month',
          'subtitle': 'Enterprise multi-entity suite.',
          'tag': 'MOST POPULAR',
          'color': AppColors.primary,
          'features': [
            'Up to 10 Company Profiles',
            'Multi-Device Sync',
            'All 50+ Templates',
            '100% Ad-Free',
          ],
          'missing': [],
        },
        {
          'id': '2yr',
          'name': 'Gold',
          'duration': '2 Years',
          'strikePrice': '\$69.99',
          'price': '\$32.99',
          'saveText': 'SAVE 53%',
          'monthlyBreakdown': '\$1.37 / month',
          'subtitle': '2 Years multi-company access.',
          'tag': 'EXTENDED VALUE',
          'color': Color(0xFFD97706),
          'features': [
            'Up to 10 Company Profiles',
            'Unlimited Everything',
            'VIP Priority Support',
          ],
          'missing': [],
        },
        {
          'id': '5yr',
          'name': 'Platinum',
          'duration': '5 Years',
          'strikePrice': '\$119.99',
          'price': '\$54.99',
          'saveText': 'SAVE 54%',
          'monthlyBreakdown': '\$0.91 / month',
          'subtitle': 'Ultimate scale for 10 firms.',
          'tag': 'BEST VALUE',
          'color': Color(0xFF0D9488),
          'features': [
            'Up to 10 Company Profiles for 5 Years',
            'Unlimited Everything with VIP SLA',
          ],
          'missing': [],
        },
      ],
    ],
  };

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 0.86,
      initialPage: _currentCardIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showCurrencySelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    'Select Billing Currency',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ..._pricingMatrix.keys.map((curr) {
                  final isSelected = curr == _currency;
                  return ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor: isSelected ? AppColors.primaryLight : null,
                    leading: CircleAvatar(
                      backgroundColor: isSelected
                          ? AppColors.primary
                          : AppColors.surfaceVariant,
                      foregroundColor: isSelected
                          ? Colors.white
                          : AppColors.textPrimary,
                      child: Text(
                        _currencySymbols[curr] ?? curr,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      curr == 'INR'
                          ? 'INR (Indian Rupee - ₹)'
                          : 'USD (US Dollar - \$)',
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check, color: AppColors.primary)
                        : null,
                    onTap: () {
                      setState(() => _currency = curr);
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      await Clipboard.setData(ClipboardData(text: phoneNumber));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Phone number $phoneNumber copied to clipboard!'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  Future<void> _sendEmail(String email) async {
    final uri = Uri.parse(
      'mailto:$email?subject=RedInvoice%20Subscription%20Query',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      await Clipboard.setData(ClipboardData(text: email));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email $email copied to clipboard!'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  void _buyPlan(Map<String, dynamic> plan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.verified, color: AppColors.primary, size: 24),
            const SizedBox(width: 8),
            Text(
              '${plan['name']} Plan',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selected: ${plan['name']} (${plan['duration']})',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
            const SizedBox(height: 6),
            Text(
              'Tier: ${_companyTiers[_selectedCompanyTier]}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.canvas,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Amount:',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  Text(
                    plan['price'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Instant activation • 100% money back guarantee for 7 days.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Activated ${plan['name']} (${plan['duration']}) successfully!',
                  ),
                  backgroundColor: AppColors.statusPaidText,
                ),
              );
              Navigator.of(context).pop();
            },
            child: const Text('Proceed to Payment'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyPlans = _pricingMatrix[_currency] ?? _pricingMatrix['INR']!;
    final safeTierIndex = _selectedCompanyTier.clamp(
      0,
      currencyPlans.length - 1,
    );
    final currentPlans = currencyPlans[safeTierIndex];

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Subscription Plans',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          // Currency Selector Pill in AppBar
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 10, bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: _showCurrencySelector,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _currencySymbols[_currency] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _currency,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // 1. Discount Motivation Deal of the Day Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFFDE68A),
                  ), // Warm amber border
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.local_fire_department_rounded,
                        color: Color(0xFFD97706),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'LIMITED TIME OFFER',
                                style: TextStyle(
                                  color: Color(0xFFB45309),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'SAVE UP TO 58%',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'Special discount applied across all multi-year packages!',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Company Tier Switcher (Single, Three, Five, Unlimited)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: List.generate(_companyTiers.length, (index) {
                    final isSelected = _selectedCompanyTier == index;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedCompanyTier = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.textPrimary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _companyTiers[index]
                                .split(' ')
                                .first, // Just 'Single', 'Three', 'Five', 'Unlimited'
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Company count subtitle
            Text(
              'Selected Scope: ${_companyTiers[_selectedCompanyTier]}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),

            // 3. Swipeable Plan Cards (PageView)
            SizedBox(
              height: 490,
              child: PageView.builder(
                controller: _pageController,
                itemCount: currentPlans.length,
                onPageChanged: (idx) => setState(() => _currentCardIndex = idx),
                itemBuilder: (context, index) {
                  final plan = currentPlans[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 8.0,
                    ),
                    child: _buildPlanCard(plan),
                  );
                },
              ),
            ),

            // 4. Dot Indicator for Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(currentPlans.length, (i) {
                final isCurrent = _currentCardIndex == i;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isCurrent ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? AppColors.primary
                        : AppColors.borderStrong,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // 5. Support & Assistance Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.headset_mic_outlined,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'For any queries, contact us',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        // Call Support Button
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _makePhoneCall('+918441061235'),
                            icon: const Icon(
                              Icons.phone_outlined,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            label: const Text(
                              '+91 8441061235',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 8,
                              ),
                              side: BorderSide(
                                color: AppColors.primary.withValues(alpha: 0.3),
                              ),
                              backgroundColor: AppColors.primary.withValues(
                                alpha: 0.04,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Email Support Button
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _sendEmail('support@redinvoice.app'),
                            icon: const Icon(
                              Icons.mail_outline,
                              size: 16,
                              color: Color(0xFF0D9488),
                            ),
                            label: const Text(
                              'Email Support',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 8,
                              ),
                              side: BorderSide(
                                color: const Color(
                                  0xFF0D9488,
                                ).withValues(alpha: 0.3),
                              ),
                              backgroundColor: const Color(
                                0xFF0D9488,
                              ).withValues(alpha: 0.04),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 6. Security & Trust Badges
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.verified_user_outlined,
                    color: AppColors.textMuted,
                    size: 15,
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    '256-bit SSL Encrypted',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 1,
                    height: 10,
                    color: AppColors.borderStrong,
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.autorenew,
                    color: AppColors.textMuted,
                    size: 15,
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    'Cancel Anytime',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    final String name = plan['name'];
    final String duration = plan['duration'];
    final String strikePrice = plan['strikePrice'];
    final String price = plan['price'];
    final String saveText = plan['saveText'];
    final String monthlyBreakdown = plan['monthlyBreakdown'];
    final String subtitle = plan['subtitle'];
    final String? tag = plan['tag'];
    final Color color = plan['color'];
    final List<String> features = List<String>.from(plan['features'] as List);
    final List<String> missing = List<String>.from(plan['missing'] as List);

    final bool isPopular = tag == 'MOST POPULAR';
    final bool isBestValue = tag == 'BEST VALUE';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isPopular
                  ? AppColors.primary
                  : (isBestValue ? const Color(0xFF0D9488) : AppColors.border),
              width: (isPopular || isBestValue) ? 2 : 1,
            ),
            boxShadow: [
              if (isPopular || isBestValue)
                BoxShadow(
                  color: color.withValues(alpha: 0.14),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Card Header
                Padding(
                  padding: const EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 22,
                    bottom: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: color,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              duration,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1, color: AppColors.border),

                // Pricing Section
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            price,
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            strikePrice,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.textMuted,
                              decoration: TextDecoration.lineThrough,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          // Monthly breakdown pill
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              monthlyBreakdown,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        saveText,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF059669), // Crisp green
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Features List (Scrollable)
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 4,
                    ),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      ...features.map((f) => _buildCheckItem(f, true, color)),
                      ...missing.map(
                        (m) =>
                            _buildCheckItem(m, false, AppColors.borderStrong),
                      ),
                    ],
                  ),
                ),

                // Choose Plan Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: () => _buyPlan(plan),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: (isPopular || isBestValue) ? 4 : 0,
                      shadowColor: color.withValues(alpha: 0.4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Choose $name',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_rounded, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Top Badge Tag (Most Popular / Best Value)
        if (tag != null)
          Positioned(
            top: -10,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCheckItem(String text, bool included, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: included
                  ? iconColor.withValues(alpha: 0.12)
                  : AppColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(
              included ? Icons.check : Icons.close,
              color: included ? iconColor : AppColors.textMuted,
              size: 13,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: included ? AppColors.textPrimary : AppColors.textMuted,
                height: 1.25,
                decoration: included
                    ? TextDecoration.none
                    : TextDecoration.lineThrough,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
