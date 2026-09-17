import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object?> get props => [];
}

class CheckSubscriptionStatusEvent extends SubscriptionEvent {
  const CheckSubscriptionStatusEvent();
}

abstract class SubscriptionState extends Equatable {
  const SubscriptionState();

  @override
  List<Object?> get props => [];
}

class FreeTierState extends SubscriptionState {
  const FreeTierState();
}

class PremiumTierState extends SubscriptionState {
  final DateTime? expiryDate;

  const PremiumTierState({this.expiryDate});

  @override
  List<Object?> get props => [expiryDate];
}

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  SubscriptionBloc() : super(const FreeTierState()) {
    on<CheckSubscriptionStatusEvent>((event, emit) {
      emit(const FreeTierState());
    });
  }
}
