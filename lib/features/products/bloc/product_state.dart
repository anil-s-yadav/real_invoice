import 'package:equatable/equatable.dart';
import '../domain/product_model.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {
  const ProductInitial();
}

class ProductLoading extends ProductState {
  const ProductLoading();
}

class ProductLoaded extends ProductState {
  final List<ProductItem> products;
  final String searchQuery;

  const ProductLoaded(this.products, {this.searchQuery = ''});

  List<ProductItem> get filteredProducts {
    if (searchQuery.trim().isEmpty) return products;
    final q = searchQuery.toLowerCase();
    return products.where((p) {
      return p.title.toLowerCase().contains(q) ||
          (p.description?.toLowerCase().contains(q) ?? false) ||
          (p.hsnSacCode?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  @override
  List<Object?> get props => [products, searchQuery];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}
