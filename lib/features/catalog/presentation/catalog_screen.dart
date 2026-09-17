import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_typography.dart';
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

class _CatalogScreenState extends State<CatalogScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerBloc, CustomerState>(
      builder: (context, customerState) {
        final customersCount = customerState is CustomerLoaded ? customerState.customers.length : 0;
        return BlocBuilder<ProductBloc, ProductState>(
          builder: (context, productState) {
            final productsCount = productState is ProductLoaded ? productState.products.length : 0;

            return Scaffold(
              backgroundColor: AppColors.canvas,
              appBar: AppBar(
                title: const Text('Directory', style: TextStyle(fontWeight: FontWeight.bold)),
                centerTitle: true,
                backgroundColor: AppColors.canvas,
                foregroundColor: AppColors.textPrimary,
                elevation: 0,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: AppDimensions.lg, vertical: 8),
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: AppDimensions.roundedMd,
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.textSecondary,
                      labelStyle: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
                      unselectedLabelStyle: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w600),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      tabs: [
                        Tab(text: 'Clients ($customersCount)'),
                        Tab(text: 'Items ($productsCount)'),
                      ],
                    ),
                  ),
                ),
              ),
              body: TabBarView(
                controller: _tabController,
                children: const [
                  CustomerListScreen(),
                  ProductListScreen(),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
