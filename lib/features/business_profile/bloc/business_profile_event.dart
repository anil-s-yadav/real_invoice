import 'package:equatable/equatable.dart';
import '../domain/business_profile_model.dart';

abstract class BusinessProfileEvent extends Equatable {
  const BusinessProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadBusinessProfileEvent extends BusinessProfileEvent {
  final String? profileId;
  const LoadBusinessProfileEvent([this.profileId]);

  @override
  List<Object?> get props => [profileId];
}

class UpdateBusinessProfileEvent extends BusinessProfileEvent {
  final BusinessProfile profile;

  const UpdateBusinessProfileEvent(this.profile);

  @override
  List<Object?> get props => [profile];
}
