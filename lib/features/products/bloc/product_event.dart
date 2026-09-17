import 'package:equatable/equatable.dart';
import '../domain/product_model.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadProductsEvent extends ProductEvent {
  final String? searchQuery;

  const LoadProductsEvent({this.searchQuery});

  @override
  List<Object?> get props => [searchQuery];
}

class SaveProductEvent extends ProductEvent {
  final ProductItem product;

  const SaveProductEvent(this.product);

  @override
  List<Object?> get props => [product];
}

class DeleteProductEvent extends ProductEvent {
  final String id;

  const DeleteProductEvent(this.id);

  @override
  List<Object?> get props => [id];
}
