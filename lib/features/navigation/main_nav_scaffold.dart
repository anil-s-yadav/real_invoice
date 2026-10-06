import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/status_badge.dart';
import '../catalog/presentation/catalog_screen.dart';
import '../documents/domain/document_model.dart';
import '../documents/presentation/document_list_screen.dart';
import '../home/presentation/home_screen.dart';
import '../reports/presentation/reports_screen.dart';
import '../settings/presentation/settings_screen.dart';

class MainNavScaffold extends StatefulWidget {
  const MainNavScaffold({super.key});

  @override
  State<MainNavScaffold> createState() => _MainNavScaffoldState();
}

class _MainNavScaffoldState extends State<MainNavScaffold> {
  int _currentIndex = 0;
  final GlobalKey<DocumentListScreenState> _docListKey =
      GlobalKey<DocumentListScreenState>();

  void _navigateToIndex(int index) {
    setState(() => _currentIndex = index);
  }

  void _navigateToDocumentsWithFilter({
    DocumentType? type,
    DocumentStatus? status,
  }) {
    setState(() => _currentIndex = 1);
    if (_docListKey.currentState != null) {
      _docListKey.currentState!.setFilter(
        type: type,
        status: status,
        clearType: type == null,
        clearStatus: status == null,
      );
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _docListKey.currentState?.setFilter(
          type: type,
          status: status,
          clearType: type == null,
          clearStatus: status == null,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        onNavigateToDocuments: ({type, status}) {
          if (type != null || status != null) {
            _navigateToDocumentsWithFilter(type: type, status: status);
          } else {
            _navigateToIndex(1);
          }
        },
        onNavigateToCustomers: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CatalogScreen(initialTabIndex: 0))),
        onNavigateToProducts: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CatalogScreen(initialTabIndex: 1))),
        onNavigateToSettings: () => _navigateToIndex(3),
      ),
      DocumentListScreen(key: _docListKey),
      const CatalogScreen(),
      const ReportsScreen(),
      const SettingsScreen(),
    ];

    final isWideScreen = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      body: Row(
        children: [
          if (isWideScreen)
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: _navigateToIndex,
              labelType: NavigationRailLabelType.all,
              backgroundColor: Theme.of(context).colorScheme.surface,
              useIndicator: true,
              indicatorColor: AppColors.primary.withValues(alpha: 0.1),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home, color: AppColors.primary),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(Icons.receipt_long, color: AppColors.primary),
                  label: Text('Documents'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.folder_outlined),
                  selectedIcon: Icon(Icons.folder, color: AppColors.primary),
                  label: Text('Catalog'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.analytics_outlined),
                  selectedIcon: Icon(Icons.analytics, color: AppColors.primary),
                  label: Text('Analytics'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.tune_outlined),
                  selectedIcon: Icon(Icons.tune, color: AppColors.primary),
                  label: Text('Settings'),
                ),
              ],
            ),
          if (isWideScreen)
            VerticalDivider(
              thickness: 1,
              width: 1,
              color: Theme.of(context).colorScheme.outline,
            ),
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: isWideScreen
          ? null
          : Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                    width: 1,
                  ),
                ),
              ),
              child: NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: _navigateToIndex,
                backgroundColor: Colors.transparent,
                elevation: 0,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home, color: AppColors.primary),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.receipt_long_outlined),
                    selectedIcon: Icon(Icons.receipt_long, color: AppColors.primary),
                    label: 'Documents',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.folder_outlined),
                    selectedIcon: Icon(Icons.folder, color: AppColors.primary),
                    label: 'Catalog',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.analytics_outlined),
                    selectedIcon: Icon(Icons.analytics, color: AppColors.primary),
                    label: 'Analytics',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.tune_outlined),
                    selectedIcon: Icon(Icons.tune, color: AppColors.primary),
                    label: 'Settings',
                  ),
                ],
              ),
            ),
    );
  }
}

