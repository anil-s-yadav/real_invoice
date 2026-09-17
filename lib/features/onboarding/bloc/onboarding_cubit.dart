import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingCubit extends Cubit<bool> {
  static const String _onboardingKey = 'hasCompletedOnboarding';
  
  OnboardingCubit() : super(false) {
    _loadOnboardingStatus();
  }

  Future<void> _loadOnboardingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasCompleted = prefs.getBool(_onboardingKey) ?? false;
    emit(hasCompleted);
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
    emit(true);
  }
}
