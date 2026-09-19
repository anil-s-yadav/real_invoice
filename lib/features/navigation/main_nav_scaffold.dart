import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/status_badge.dart';
import '../catalog/presentation/catalog_screen.dart';
import '../documents/domain/document_model.dart';
import '../documents/presentation/document_list_screen.dart';
import '../home/presentation/home_screen.dart';
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
        onNavigateToCustomers: () => _navigateToIndex(2),
        onNavigateToProducts: () => _navigateToIndex(2),
        onNavigateToSettings: () => _navigateToIndex(3),
      ),
      DocumentListScreen(key: _docListKey),
      const CatalogScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _navigateToIndex,
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primaryLight,
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
