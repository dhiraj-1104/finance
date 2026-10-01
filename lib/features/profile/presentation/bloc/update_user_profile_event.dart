import 'package:equatable/equatable.dart';
import 'package:ezbookkeeping/features/profile/data/models/update_user_profile_request_model.dart';

/// Base class for all update user profile events.
abstract class UpdateUserProfileEvent extends Equatable {
  const UpdateUserProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched when the user submits an updated profile form.
class UpdateUserProfileSubmitted extends UpdateUserProfileEvent {
  const UpdateUserProfileSubmitted(this.request);

  final UpdateUserProfileRequestModel request;

  @override
  List<Object?> get props => [request];
}

/// Dispatched to reset the update state back to initial (e.g. after showing a snackbar).
class ResetUpdateUserProfileState extends UpdateUserProfileEvent {
  const ResetUpdateUserProfileState();
}
