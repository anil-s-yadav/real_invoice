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

class ObserveSubscriptionEvent extends SubscriptionEvent {
  const ObserveSubscriptionEvent();
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
    on<ObserveSubscriptionEvent>(_onObserveStatus);
    on<ActivateSubscriptionEvent>(_onActivatePlan);
  }

  Future<void> _onCheckStatus(
    CheckSubscriptionStatusEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    final repo = repository ?? SubscriptionRepository();
    final plan = await repo.getCurrentPlan();

    bool isEligible = await _checkEligibility(repo);
    _emitPlanState(plan, isEligible, emit);
  }

  Future<void> _onObserveStatus(
    ObserveSubscriptionEvent event,
    Emitter<SubscriptionState> emit,
  ) async {
    final repo = repository ?? SubscriptionRepository();
    
    // Check initial eligibility
    final isEligible = await _checkEligibility(repo);
    
    await emit.forEach<SubscriptionPlanModel>(
      repo.currentPlanStream(),
      onData: (plan) {
        if (plan.isFree || !plan.isActive) {
          return FreeTierState(plan: plan, isEligibleForWelcomeOffer: isEligible);
        } else {
          return PremiumTierState(
            expiryDate: plan.expiryDate,
            plan: plan,
            isEligibleForWelcomeOffer: isEligible,
          );
        }
      },
      onError: (_, __) => state,
    );
  }

  Future<bool> _checkEligibility(SubscriptionRepository repo) async {
    try {
      final history = await repo.getPlanHistory();
      return !history.any((p) => !p.isFree);
    } catch (_) {
      return false;
    }
  }

  void _emitPlanState(SubscriptionPlanModel plan, bool isEligible, Emitter<SubscriptionState> emit) {
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
    // State will automatically update if we are observing the stream.
    // However, if we aren't observing, we manually emit here as a fallback.
    _emitPlanState(event.plan, false, emit);
  }
}
