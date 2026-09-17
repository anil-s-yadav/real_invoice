import 'package:equatable/equatable.dart';
import '../domain/customer_model.dart';

abstract class CustomerState extends Equatable {
  const CustomerState();

  @override
  List<Object?> get props => [];
}

class CustomerInitial extends CustomerState {
  const CustomerInitial();
}

class CustomerLoading extends CustomerState {
  const CustomerLoading();
}

class CustomerLoaded extends CustomerState {
  final List<Customer> customers;
  final String searchQuery;

  const CustomerLoaded(this.customers, {this.searchQuery = ''});

  List<Customer> get filteredCustomers {
    if (searchQuery.trim().isEmpty) return customers;
    final q = searchQuery.toLowerCase();
    return customers.where((c) {
      return c.name.toLowerCase().contains(q) ||
          (c.phone?.toLowerCase().contains(q) ?? false) ||
          (c.email?.toLowerCase().contains(q) ?? false) ||
          (c.gstin?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  @override
  List<Object?> get props => [customers, searchQuery];
}

class CustomerError extends CustomerState {
  final String message;

  const CustomerError(this.message);

  @override
  List<Object?> get props => [message];
}
