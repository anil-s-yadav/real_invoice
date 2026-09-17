import 'package:equatable/equatable.dart';
import '../domain/business_profile_model.dart';

abstract class BusinessProfileState extends Equatable {
  const BusinessProfileState();

  @override
  List<Object?> get props => [];
}

class BusinessProfileInitial extends BusinessProfileState {
  const BusinessProfileInitial();
}

class BusinessProfileLoading extends BusinessProfileState {
  const BusinessProfileLoading();
}

class BusinessProfileLoaded extends BusinessProfileState {
  final BusinessProfile profile;

  const BusinessProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class BusinessProfileError extends BusinessProfileState {
  final String message;

  const BusinessProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
