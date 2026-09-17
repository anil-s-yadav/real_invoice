import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/product_repository.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository repository;

  ProductBloc({required this.repository}) : super(const ProductInitial()) {
    on<LoadProductsEvent>(_onLoadProducts);
    on<SaveProductEvent>(_onSaveProduct);
    on<DeleteProductEvent>(_onDeleteProduct);
  }

  Future<void> _onLoadProducts(
    LoadProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    emit(const ProductLoading());
    try {
      final products = await repository.getAllProducts();
      emit(ProductLoaded(products, searchQuery: event.searchQuery ?? ''));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onSaveProduct(
    SaveProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await repository.saveProduct(event.product);
      final products = await repository.getAllProducts();
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> _onDeleteProduct(
    DeleteProductEvent event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await repository.deleteProduct(event.id);
      final products = await repository.getAllProducts();
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}
