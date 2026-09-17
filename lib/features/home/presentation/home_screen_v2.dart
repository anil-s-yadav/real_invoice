import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../business_profile/presentation/business_profile_screen.dart';
import '../../documents/domain/document_model.dart';
import '../../documents/presentation/document_editor_screen.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../../subscription/presentation/subscription_screen.dart';

class HomeScreenV2 extends StatelessWidget {
  final VoidCallback onNavigateToDocuments;
  final VoidCallback onNavigateToCustomers;
  final VoidCallback onNavigateToProducts;
  final VoidCallback onNavigateToSettings;

  const HomeScreenV2({
    super.key,
    required this.onNavigateToDocuments,
    required this.onNavigateToCustomers,
    required this.onNavigateToProducts,
    required this.onNavigateToSettings,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final profile = state is HomeLoaded ? state.profile : null;
        final businessName = profile?.businessName;
        final isProfileConfigured = businessName != null && businessName.trim().isNotEmpty;
        final stats = state is HomeLoaded ? state.stats : null;

        return Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          body: RefreshIndicator(
            color: Colors.white,
            backgroundColor: const Color(0xFF1E293B),
            onRefresh: () async {
              context.read<HomeBloc>().add(const LoadHomeDataEvent());
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _buildNeobankHeader(context, isProfileConfigured, businessName, stats),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 32, bottom: 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: _buildMinimalPromoBanner(context),
                          ),
                          const SizedBox(height: 40),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              'Create New',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 160,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              children: [
                                _buildTallActionCard(context, 'Invoice', 'Get paid faster', Icons.receipt_long, DocumentType.invoice, const Color(0xFF4F46E5)),
                                _buildTallActionCard(context, 'Quotation', 'Win more deals', Icons.request_quote, DocumentType.quotation, const Color(0xFF0D9488)),
                                _buildTallActionCard(context, 'Receipt', 'Proof of payment', Icons.fact_check, DocumentType.receipt, const Color(0xFFEA580C)),
                                _buildTallActionCard(context, 'Proforma', 'Advance billing', Icons.description, DocumentType.proforma, const Color(0xFF475569)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              'Manage Business',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              children: [
                                _buildSleekListTile('Customers & Clients', Icons.people_alt, onNavigateToCustomers),
                                const SizedBox(height: 12),
                                _buildSleekListTile('Products & Services', Icons.inventory_2, onNavigateToProducts),
                                const SizedBox(height: 12),
                                _buildSleekListTile('Company Profiles', Icons.business, () {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BusinessProfileScreen()));
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNeobankHeader(BuildContext context, bool isProfileConfigured, String? businessName, stats) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getGreeting(),
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isProfileConfigured ? businessName! : 'Set up business',
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.5),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BusinessProfileScreen())),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
                    gradient: const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF3730A3)]),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    isProfileConfigured ? businessName![0].toUpperCase() : 'B',
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          Text(
            'Total Outstanding',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          if (stats != null)
            Text(
              CurrencyFormatter.formatCompact(stats.unpaidTotal),
              style: const TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.w300, letterSpacing: -2, height: 1.1),
            )
          else
            const Text(
              '₹0',
              style: TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.w300, letterSpacing: -2, height: 1.1),
            ),
          const SizedBox(height: 32),
          if (stats != null)
            Row(
              children: [
                _buildGlassPill('Overdue', stats.overdueTotal, const Color(0xFFEF4444)),
                const SizedBox(width: 12),
                _buildGlassPill('Collected', stats.paidTotal, const Color(0xFF10B981)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildGlassPill(String label, double amount, Color accentColor) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(width: 6, height: 6, decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  CurrencyFormatter.formatCompact(amount),
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMinimalPromoBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SubscriptionScreen())),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.workspace_premium, color: Color(0xFFFBBF24), size: 24),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('RedInvoice Pro', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                  SizedBox(height: 2),
                  Text('Claim your 1-Year Free Premium', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildTallActionCard(BuildContext context, String title, String subtitle, IconData icon, DocumentType type, Color color) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DocumentEditorScreen(initialType: type))),
      child: Container(
        width: 130,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleekListTile(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: const Color(0xFF64748B), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1), size: 20),
          ],
        ),
      ),
    );
  }
}
