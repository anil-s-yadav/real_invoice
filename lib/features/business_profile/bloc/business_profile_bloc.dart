import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/business_profile_repository.dart';
import 'business_profile_event.dart';
import 'business_profile_state.dart';

class BusinessProfileBloc extends Bloc<BusinessProfileEvent, BusinessProfileState> {
  final BusinessProfileRepository repository;

  BusinessProfileBloc({required this.repository}) : super(const BusinessProfileInitial()) {
    on<LoadBusinessProfileEvent>(_onLoadProfile);
    on<UpdateBusinessProfileEvent>(_onUpdateProfile);
  }

  Future<void> _onLoadProfile(
    LoadBusinessProfileEvent event,
    Emitter<BusinessProfileState> emit,
  ) async {
    emit(const BusinessProfileLoading());
    try {
      final profile = await repository.getProfile(event.profileId);
      emit(BusinessProfileLoaded(profile));
    } catch (e) {
      emit(BusinessProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateBusinessProfileEvent event,
    Emitter<BusinessProfileState> emit,
  ) async {
    emit(const BusinessProfileLoading());
    try {
      final savedProfile = await repository.saveProfile(event.profile);
      emit(BusinessProfileLoaded(savedProfile));
    } catch (e) {
      emit(BusinessProfileError(e.toString()));
    }
  }
}
