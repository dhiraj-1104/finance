import 'package:dartz/dartz.dart';
import 'package:ezbookkeeping/core/error/exceptions.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:ezbookkeeping/features/profile/data/models/update_user_profile_request_model.dart';
import 'package:ezbookkeeping/features/profile/domain/entities/user_profile.dart';
import 'package:ezbookkeeping/features/profile/domain/repositories/profile_repository.dart';

/// Concrete implementation of [ProfileRepository] delegating to [ProfileRemoteDataSource].
class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl({required this.remoteDataSource});

  final ProfileRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, UserProfile>> getUserProfile() async {
    try {
      final response = await remoteDataSource.getUserProfile();

      if (!response.success || response.result == null) {
        return const Left(
          ServerFailure('Failed to retrieve user profile.', 400),
        );
      }

      return Right(response.result!.toEntity());
    } on AppException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserProfile>> updateUserProfile(
    UpdateUserProfileRequestModel request,
  ) async {
    try {
      final response = await remoteDataSource.updateUserProfile(request);

      if (!response.success) {
        return const Left(ServerFailure('Failed to update user profile.', 400));
      }

      if (response.result != null) {
        return Right(response.result!.toEntity());
      }

      // If backend returns { "success": true } without full result object,
      // fallback to constructing the entity representation from the request.
      return Right(request.toEntity());
    } on AppException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
