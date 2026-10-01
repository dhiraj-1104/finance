import 'package:dartz/dartz.dart';
import 'package:ezbookkeeping/core/error/exceptions.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/core/storage/token_storage.dart';
import 'package:ezbookkeeping/features/authentication/data/datasources/authentication_remote_data_source.dart';
import 'package:ezbookkeeping/features/authentication/data/models/login_request_model.dart';
import 'package:ezbookkeeping/features/authentication/data/models/register_request_model.dart';
import 'package:ezbookkeeping/features/authentication/domain/entities/login_result.dart';
import 'package:ezbookkeeping/features/authentication/domain/repositories/authentication_repository.dart';

/// Concrete implementation of [AuthenticationRepository].
/// Coordinates remote data fetching, response verification, token persistence, and domain mapping.
class AuthenticationRepositoryImpl implements AuthenticationRepository {
  final AuthenticationRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;

  AuthenticationRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
  });

  @override
  Future<Either<Failure, LoginResult>> login({
    required String loginName,
    required String password,
  }) async {
    final trimmedLoginName = loginName.trim();
    if (trimmedLoginName.isEmpty) {
      return const Left(ValidationFailure('Username/Email cannot be empty.'));
    }
    if (password.isEmpty) {
      return const Left(ValidationFailure('Password cannot be empty.'));
    }

    try {
      final request = LoginRequestModel(
        loginName: trimmedLoginName,
        password: password,
      );

      final response = await remoteDataSource.login(request);

      if (response == null) {
        return const Left(
          UnauthorizedFailure(
            'Authentication failed. Please check your credentials.',
          ),
        );
      }

      final resultModel = response;
      final token = resultModel.token.trim();

      // Defensively store token if non-empty
      if (token.isNotEmpty) {
        await tokenStorage.saveToken(token);
      }

      return Right(resultModel.toEntity());
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
  Future<Either<Failure, LoginResult>> register({
    required String username,
    required String email,
    required String nickname,
    required String password,
    required String language,
    String defaultCurrency = 'USD',
    List categories = const [],
  }) async {
    final trimmedUsername = username.trim();
    final trimmedEmail = email.trim();
    final trimmedNickname = nickname.trim();
    final trimmedLanguage = language.trim();
    final trimmedDefaultCurrency = defaultCurrency.trim();

    if (trimmedUsername.isEmpty) {
      return const Left(ValidationFailure('Username cannot be empty.'));
    }
    if (trimmedEmail.isEmpty || !trimmedEmail.contains('@')) {
      return const Left(
        ValidationFailure('Please enter a valid email address.'),
      );
    }
    if (password.isEmpty) {
      return const Left(ValidationFailure('Password cannot be empty.'));
    }
    if (password.length < 6) {
      return const Left(
        ValidationFailure('Password must be at least 6 characters.'),
      );
    }

    try {
      final request = RegisterRequestModel(
        username: trimmedUsername,
        email: trimmedEmail,
        nickname: trimmedNickname.isEmpty ? trimmedUsername : trimmedNickname,
        password: password,
        language: trimmedLanguage.isEmpty ? 'en' : trimmedLanguage,
        defaultCurrency: trimmedDefaultCurrency.isEmpty
            ? 'USD'
            : trimmedDefaultCurrency,
      );

      final response = await remoteDataSource.register(request);

      if (!response.success || response.result == null) {
        return const Left(
          ServerFailure('Registration failed. Please try again.'),
        );
      }

      final resultModel = response.result!;
      final token = resultModel.token.trim();

      // Defensively store token if non-empty
      if (token.isNotEmpty) {
        await tokenStorage.saveToken(token);
      }

      return Right(resultModel.toEntity());
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
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
    } catch (_) {
      // Defensively catch network/API errors to ensure local tokens and state are always cleared
    } finally {
      await tokenStorage.clearToken();
    }
    return const Right(null);
  }
}
