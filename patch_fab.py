with open('d:/real_invoice/lib/features/business_profile/presentation/manage_company_list_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

import_statement = "import '../../subscription/presentation/subscription_screen.dart';"
if import_statement not in content:
    # it's probably already there since _buildPremiumBanner uses it
    pass

fab_original = """      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const OnboardingScreen(isAddingNewCompany: true),
            ),
          );
          _loadData();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Company'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),"""

fab_new = """      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final subState = context.read<SubscriptionBloc>().state;
          final maxAllowed = subState.plan?.maxCompaniesAllowed ?? 1;
          
          if (_profiles.length >= maxAllowed) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Company limit reached. Please upgrade your plan.'),
                backgroundColor: Colors.orange,
              ),
            );
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
            );
            return;
          }

          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const OnboardingScreen(isAddingNewCompany: true),
            ),
          );
          _loadData();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Company'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),"""

content = content.replace(fab_original, fab_new)

with open('d:/real_invoice/lib/features/business_profile/presentation/manage_company_list_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print("manage_company_list_screen patched")