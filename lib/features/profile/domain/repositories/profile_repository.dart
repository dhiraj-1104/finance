import 'package:dartz/dartz.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/features/profile/data/models/update_user_profile_request_model.dart';
import 'package:ezbookkeeping/features/profile/domain/entities/user_profile.dart';

/// Domain contract for user profile operations.
abstract class ProfileRepository {
  /// Retrieves the authenticated user's profile and configuration.
  Future<Either<Failure, UserProfile>> getUserProfile();

  /// Updates the authenticated user's profile and configuration.
  Future<Either<Failure, UserProfile>> updateUserProfile(
    UpdateUserProfileRequestModel request,
  );
}
