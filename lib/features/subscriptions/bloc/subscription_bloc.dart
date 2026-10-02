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
  final bool isEligibleForWelcomeOffer;
  const SubscriptionState({this.plan, this.isEligibleForWelcomeOffer = false});

  SubscriptionPlanModel get effectivePlan {
    if (plan != null && plan!.isActive) {
      return plan!;
    }
    return SubscriptionPlanModel.defaultFree();
  }

  @override
  List<Object?> get props => [plan, isEligibleForWelcomeOffer];
}

class FreeTierState extends SubscriptionState {
  const FreeTierState({super.plan, super.isEligibleForWelcomeOffer});
}

class PremiumTierState extends SubscriptionState {
  final DateTime? expiryDate;

  const PremiumTierState({
    this.expiryDate,
    super.plan,
    super.isEligibleForWelcomeOffer,
  });

  @override
  List<Object?> get props => [expiryDate, plan, isEligibleForWelcomeOffer];
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

    bool isEligible = false;
    try {
      final history = await repo.getPlanHistory();
      // Eligible if user has no premium plan in their history
      isEligible = !history.any((p) => !p.isFree);
    } catch (_) {}

    if (plan.isFree || !plan.isActive) {
      emit(FreeTierState(plan: plan, isEligibleForWelcomeOffer: isEligible));
    } else {
      emit(
        PremiumTierState(
          expiryDate: plan.expiryDate,
          plan: plan,
          isEligibleForWelcomeOffer: isEligible,
        ),
      );
    }
  }

  Future<void> _onActivatePlan(
    ActivateSubscriptionEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    final repo = repository ?? SubscriptionRepository();
    await repo.saveOrUpgradePlan(event.plan);

    // Keep the current eligibility state (it shouldn't matter as much after activation,
    // but we can retain the old one or just evaluate it again).
    // After activating a paid plan, they are no longer eligible, but let's just pass false
    // or evaluate it. We'll pass false since they just activated a plan.
    if (event.plan.isFree || !event.plan.isActive) {
      emit(
        FreeTierState(
          plan: event.plan,
          isEligibleForWelcomeOffer: state.isEligibleForWelcomeOffer,
        ),
      );
    } else {
      emit(
        PremiumTierState(
          expiryDate: event.plan.expiryDate,
          plan: event.plan,
          isEligibleForWelcomeOffer: false,
        ),
      );
    }
  }
}
