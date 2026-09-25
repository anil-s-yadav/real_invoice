import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../subscription/domain/subscription_plan_model.dart';
import '../../subscription/data/subscription_repository.dart';

abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();

  @override
  List<Object?> get props => [];
}

class CheckSubscriptionStatusEvent extends SubscriptionEvent {
  const CheckSubscriptionStatusEvent();
}

class ActivateSubscriptionEvent extends SubscriptionEvent {
  final SubscriptionPlanModel plan;
  const ActivateSubscriptionEvent(this.plan);

  @override
  List<Object?> get props => [plan];
}

abstract class SubscriptionState extends Equatable {
  final SubscriptionPlanModel? plan;
  const SubscriptionState([this.plan]);

  @override
  List<Object?> get props => [plan];
}

class FreeTierState extends SubscriptionState {
  const FreeTierState([super.plan]);
}

class PremiumTierState extends SubscriptionState {
  final DateTime? expiryDate;

  const PremiumTierState({this.expiryDate, SubscriptionPlanModel? plan})
      : super(plan);

  @override
  List<Object?> get props => [expiryDate, plan];
}

class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final SubscriptionRepository? repository;

  SubscriptionBloc({this.repository}) : super(const FreeTierState()) {
    on<CheckSubscriptionStatusEvent>(_onCheckStatus);
    on<ActivateSubscriptionEvent>(_onActivatePlan);
  }

  Future<void> _onCheckStatus(
    CheckSubscriptionStatusEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    final repo = repository ?? SubscriptionRepository();
    final plan = await repo.getCurrentPlan();

    if (plan.isFree || !plan.isActive) {
      emit(FreeTierState(plan));
    } else {
      emit(PremiumTierState(expiryDate: plan.expiryDate, plan: plan));
    }
  }

  Future<void> _onActivatePlan(
    ActivateSubscriptionEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    final repo = repository ?? SubscriptionRepository();
    await repo.saveOrUpgradePlan(event.plan);

    if (event.plan.isFree || !event.plan.isActive) {
      emit(FreeTierState(event.plan));
    } else {
      emit(PremiumTierState(
        expiryDate: event.plan.expiryDate,
        plan: event.plan,
      ));
    }
  }
}
