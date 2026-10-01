import 'package:equatable/equatable.dart';
import 'package:ezbookkeeping/features/profile/domain/entities/user_profile.dart';

/// Base class for all update user profile states.
abstract class UpdateUserProfileState extends Equatable {
  const UpdateUserProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state when no update has been submitted.
class UpdateUserProfileInitial extends UpdateUserProfileState {
  const UpdateUserProfileInitial();
}

/// State indicating that a profile update request is actively in flight.
class UpdateUserProfileLoading extends UpdateUserProfileState {
  const UpdateUserProfileLoading();
}

/// State indicating that the profile was successfully updated.
class UpdateUserProfileSuccess extends UpdateUserProfileState {
  const UpdateUserProfileSuccess({required this.updatedProfile});

  final UserProfile updatedProfile;

  @override
  List<Object?> get props => [updatedProfile];
}

/// State indicating that the profile update request failed.
class UpdateUserProfileFailure extends UpdateUserProfileState {
  const UpdateUserProfileFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
