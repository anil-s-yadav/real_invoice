import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/customer_repository.dart';
import 'customer_event.dart';
import 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final CustomerRepository repository;

  CustomerBloc({required this.repository}) : super(const CustomerInitial()) {
    on<LoadCustomersEvent>(_onLoadCustomers);
    on<SaveCustomerEvent>(_onSaveCustomer);
    on<DeleteCustomerEvent>(_onDeleteCustomer);
  }

  Future<void> _onLoadCustomers(
    LoadCustomersEvent event,
    Emitter<CustomerState> emit,
  ) async {
    emit(const CustomerLoading());
    try {
      final customers = await repository.getAllCustomers();
      emit(CustomerLoaded(customers, searchQuery: event.searchQuery ?? ''));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onSaveCustomer(
    SaveCustomerEvent event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      await repository.saveCustomer(event.customer);
      final customers = await repository.getAllCustomers();
      emit(CustomerLoaded(customers));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }

  Future<void> _onDeleteCustomer(
    DeleteCustomerEvent event,
    Emitter<CustomerState> emit,
  ) async {
    try {
      await repository.deleteCustomer(event.id);
      final customers = await repository.getAllCustomers();
      emit(CustomerLoaded(customers));
    } catch (e) {
      emit(CustomerError(e.toString()));
    }
  }
}
