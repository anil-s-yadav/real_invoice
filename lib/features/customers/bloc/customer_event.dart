import 'package:equatable/equatable.dart';
import '../domain/customer_model.dart';

abstract class CustomerEvent extends Equatable {
  const CustomerEvent();

  @override
  List<Object?> get props => [];
}

class LoadCustomersEvent extends CustomerEvent {
  final String? searchQuery;

  const LoadCustomersEvent({this.searchQuery});

  @override
  List<Object?> get props => [searchQuery];
}

class SaveCustomerEvent extends CustomerEvent {
  final Customer customer;

  const SaveCustomerEvent(this.customer);

  @override
  List<Object?> get props => [customer];
}

class DeleteCustomerEvent extends CustomerEvent {
  final String id;

  const DeleteCustomerEvent(this.id);

  @override
  List<Object?> get props => [id];
}
