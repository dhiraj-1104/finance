import 'package:equatable/equatable.dart';

/// Base class for profile retrieval events.
abstract class UserProfileEvent extends Equatable {
  const UserProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched when requesting to load the authenticated user's profile.
class GetUserProfileRequested extends UserProfileEvent {
  const GetUserProfileRequested();
}

/// Dispatched when requesting a silent/pull-to-refresh of the user's profile.
class RefreshUserProfileRequested extends UserProfileEvent {
  const RefreshUserProfileRequested();
}
