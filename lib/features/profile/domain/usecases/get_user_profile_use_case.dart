import 'package:dartz/dartz.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/features/profile/domain/entities/user_profile.dart';
import 'package:ezbookkeeping/features/profile/domain/repositories/profile_repository.dart';

/// Single-responsibility use case for retrieving the authenticated user's profile.
class GetUserProfileUseCase {
  const GetUserProfileUseCase(this.repository);

  final ProfileRepository repository;

  Future<Either<Failure, UserProfile>> call() {
    return repository.getUserProfile();
  }
}
