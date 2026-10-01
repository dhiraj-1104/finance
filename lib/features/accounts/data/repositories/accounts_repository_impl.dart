import 'package:dartz/dartz.dart';
import 'package:ezbookkeeping/core/error/exceptions.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/features/accounts/data/datasources/accounts_remote_data_source.dart';
import 'package:ezbookkeeping/features/accounts/data/models/add_account_request_model.dart';
import 'package:ezbookkeeping/features/accounts/domain/entities/account.dart';
import 'package:ezbookkeeping/features/accounts/domain/repositories/accounts_repository.dart';

/// Implementation of [AccountsRepository] delegating to [AccountsRemoteDataSource].
class AccountsRepositoryImpl implements AccountsRepository {
  const AccountsRepositoryImpl({required this.remoteDataSource});

  final AccountsRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<Account>>> getAccounts({
    bool visibleOnly = false,
  }) async {
    try {
      final response = await remoteDataSource.getAccounts(
        visibleOnly: visibleOnly,
      );

      if (!response.success) {
        return const Left(ServerFailure('Failed to retrieve accounts.', 400));
      }

      return Right(response.result.map((m) => m.toEntity()).toList());
    } on NoInternetConnectionException catch (e) {
      return Left(NoInternetConnectionFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.statusCode));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message, e.statusCode));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on AppException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(SomethingWentWrongFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Account>> addAccount(
    AddAccountRequestModel request,
  ) async {
    try {
      final accountModel = await remoteDataSource.addAccount(request);
      return Right(accountModel.toEntity());
    } on NoInternetConnectionException catch (e) {
      return Left(NoInternetConnectionFailure(e.message, e.statusCode));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message, e.statusCode));
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(e.message, e.statusCode));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, e.statusCode));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message, e.statusCode));
    } on AppException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(SomethingWentWrongFailure(e.toString()));
    }
  }
}
