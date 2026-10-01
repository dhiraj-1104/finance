import 'package:equatable/equatable.dart';
import 'package:ezbookkeeping/features/profile/domain/entities/user_profile.dart';

/// Base class for profile retrieval states.
abstract class UserProfileState extends Equatable {
  const UserProfileState();

  @override
  List<Object?> get props => [];
}

/// Initial state when profile has not yet been fetched.
class UserProfileInitial extends UserProfileState {
  const UserProfileInitial();
}

/// State indicating that profile data is actively being fetched.
class UserProfileLoading extends UserProfileState {
  const UserProfileLoading();
}

/// State indicating that the user profile was successfully retrieved.
class UserProfileLoaded extends UserProfileState {
  const UserProfileLoaded({required this.profile});

  final UserProfile profile;

  @override
  List<Object?> get props => [profile];
}

/// State indicating an error occurred while fetching the profile.
class UserProfileError extends UserProfileState {
  const UserProfileError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
