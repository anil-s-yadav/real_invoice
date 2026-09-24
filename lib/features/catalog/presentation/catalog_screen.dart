import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../customers/bloc/customer_bloc.dart';
import '../../customers/bloc/customer_state.dart';
import '../../customers/presentation/customer_list_screen.dart';
import '../../products/bloc/product_bloc.dart';
import '../../products/bloc/product_state.dart';
import '../../products/presentation/product_list_screen.dart';

class CatalogScreen extends StatefulWidget {
  final int initialTabIndex;

  const CatalogScreen({super.key, this.initialTabIndex = 0});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerBloc, CustomerState>(
      builder: (context, customerState) {
        final customersCount = customerState is CustomerLoaded
            ? customerState.customers.length
            : 0;
        return BlocBuilder<ProductBloc, ProductState>(
          builder: (context, productState) {
            final productsCount = productState is ProductLoaded
                ? productState.products.length
                : 0;

            final isDark = Theme.of(context).brightness == Brightness.dark;

            return DefaultTabController(
              length: 2,
              initialIndex: widget.initialTabIndex,
              child: Scaffold(
                appBar: AppBar(
                  title: TabBar(
                    indicator: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.border.withValues(alpha: 0.5),
                        width: 0.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.2 : 0.06,
                          ),
                          blurRadius: 5,
                          offset: const Offset(0, 1.5),
                        ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    splashFactory: NoSplash.splashFactory,
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                    labelPadding: EdgeInsets.zero,
                    tabs: [
                      Tab(
                        child: _buildTabItem(
                          icon: Icons.people_alt_rounded,
                          label: 'Clients',
                          count: customersCount,
                          color: const Color(0xFF2563EB),
                          lightColor: const Color(0xFFEFF6FF),
                        ),
                      ),
                      Tab(
                        child: _buildTabItem(
                          icon: Icons.inventory_2_rounded,
                          label: 'Items',
                          count: productsCount,
                          color: const Color(0xFFEA580C),
                          lightColor: const Color(0xFFFFF7ED),
                        ),
                      ),
                    ],
                  ),
                ),
                body: SafeArea(
                  child: Column(
                    children: [
                      Expanded(
                        child: TabBarView(
                          children: const [
                            CustomerListScreen(),
                            ProductListScreen(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTabItem({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
    required Color lightColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 7),
        Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
          decoration: BoxDecoration(
            color: lightColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withValues(alpha: 0.25),
              width: 0.8,
            ),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}
