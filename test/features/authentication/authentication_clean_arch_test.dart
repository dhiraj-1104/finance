import 'dart:convert';
import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ezbookkeeping/app/router/app_router.dart';
import 'package:ezbookkeeping/app/router/app_routes.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/features/authentication/presentation/login_screen.dart';
import 'package:ezbookkeeping/features/home/presentation/home_screen.dart';
import 'package:ezbookkeeping/core/error/exceptions.dart';
import 'package:ezbookkeeping/core/network/api_endpoints.dart';
import 'package:ezbookkeeping/core/network/interceptors/auth_interceptor.dart';
import 'package:ezbookkeeping/core/storage/token_storage.dart';
import 'package:ezbookkeeping/features/authentication/data/datasources/authentication_remote_data_source.dart';
import 'package:ezbookkeeping/features/authentication/data/models/login_request_model.dart';
import 'package:ezbookkeeping/features/authentication/data/models/login_response_model.dart';
import 'package:ezbookkeeping/features/authentication/data/models/login_result_model.dart';
import 'package:ezbookkeeping/features/authentication/data/models/user_model.dart';
import 'package:ezbookkeeping/features/authentication/data/repositories/authentication_repository_impl.dart';
import 'package:ezbookkeeping/features/authentication/domain/entities/login_result.dart';
import 'package:ezbookkeeping/features/authentication/data/models/register_request_model.dart';
import 'package:ezbookkeeping/features/authentication/domain/entities/user.dart';
import 'package:ezbookkeeping/features/authentication/domain/repositories/authentication_repository.dart';
import 'package:ezbookkeeping/features/authentication/domain/usecases/login.dart';
import 'package:ezbookkeeping/features/authentication/domain/usecases/logout.dart';
import 'package:ezbookkeeping/features/authentication/domain/usecases/register.dart';
import 'package:ezbookkeeping/features/authentication/presentation/bloc/authentication_bloc.dart';
import 'package:ezbookkeeping/features/authentication/presentation/bloc/authentication_event.dart';
import 'package:ezbookkeeping/features/authentication/presentation/bloc/authentication_state.dart';

/// Test in-memory implementation of [TokenStorage]
class TestTokenStorage implements TokenStorage {
  String? _token;

  @override
  Future<void> saveToken(String token) async {
    _token = token;
  }

  @override
  Future<String?> getToken() async => _token;

  @override
  Future<void> clearToken() async {
    _token = null;
  }
}

/// Custom mock adapter to simulate HTTP responses
class MockHttpAdapter implements HttpClientAdapter {
  MockHttpAdapter({this.handler});

  Future<ResponseBody> Function(RequestOptions options)? handler;
  RequestOptions? lastRequestOptions;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequestOptions = options;
    if (handler != null) {
      return handler!(options);
    }
    return ResponseBody.fromString(
      jsonEncode({'success': true}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Fake repository for use case & bloc unit tests
class FakeAuthenticationRepository implements AuthenticationRepository {
  FakeAuthenticationRepository({this.resultToReturn, this.failureToReturn});

  LoginResult? resultToReturn;
  Failure? failureToReturn;

  String? lastLoginName;
  String? lastPassword;
  String? lastUsername;
  String? lastEmail;
  String? lastNickname;
  String? lastLanguage;
  String? lastDefaultCurrency;
  bool logoutCalled = false;

  @override
  Future<Either<Failure, LoginResult>> login({
    required String loginName,
    required String password,
  }) async {
    lastLoginName = loginName;
    lastPassword = password;

    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }

    return Right(
      resultToReturn ??
          const LoginResult(
            token: 'default-test-token',
            need2FA: false,
            user: User(
              username: 'testuser',
              email: 'test@example.com',
              nickname: 'Tester',
            ),
          ),
    );
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
    lastUsername = username;
    lastEmail = email;
    lastNickname = nickname;
    lastPassword = password;
    lastLanguage = language;
    lastDefaultCurrency = defaultCurrency;

    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }

    return Right(
      resultToReturn ??
          const LoginResult(
            token: 'default-register-token',
            need2FA: false,
            user: User(
              username: 'testuser',
              email: 'test@example.com',
              nickname: 'Tester',
            ),
          ),
    );
  }

  @override
  Future<Either<Failure, void>> logout() async {
    logoutCalled = true;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return const Right(null);
  }
}

/// Fake remote data source for repository tests
class FakeAuthenticationRemoteDataSource
    implements AuthenticationRemoteDataSource {
  FakeAuthenticationRemoteDataSource({
    this.responseToReturn,
    this.resultToReturn,
    this.returnNullResult = false,
    this.logoutResultToReturn = true,
    this.errorToThrow,
  });

  LoginResponseModel? responseToReturn;
  LoginResultModel? resultToReturn;
  bool returnNullResult;
  bool logoutResultToReturn;
  Exception? errorToThrow;
  LoginRequestModel? lastRequest;
  RegisterRequestModel? lastRegisterRequest;
  bool logoutCalled = false;

  @override
  Future<LoginResultModel?> login(LoginRequestModel request) async {
    lastRequest = request;
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    if (returnNullResult) {
      return null;
    }
    if (resultToReturn != null) {
      return resultToReturn;
    }
    if (responseToReturn != null) {
      return responseToReturn!.result;
    }
    return const LoginResultModel(
      token: 'valid-jwt-token-12345',
      need2FA: false,
      user: UserModel(
        username: 'demo',
        email: 'demo@ezbookkeeping.mayswind.net',
        nickname: 'Demo User',
      ),
    );
  }

  @override
  Future<LoginResponseModel> register(RegisterRequestModel request) async {
    lastRegisterRequest = request;
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    return responseToReturn ??
        const LoginResponseModel(
          success: true,
          result: LoginResultModel(
            token: 'valid-jwt-token-12345',
            need2FA: false,
            user: UserModel(
              username: 'demo',
              email: 'demo@ezbookkeeping.mayswind.net',
              nickname: 'Demo User',
            ),
          ),
        );
  }

  @override
  Future<bool> logout() async {
    logoutCalled = true;
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    return logoutResultToReturn;
  }
}

void main() {
  group('Authentication Domain & Data Models Test', () {
    const sampleUserJson = {
      'username': 'demo',
      'email': 'ezbookkeeping@mayswind.net',
      'nickname': 'demo',
      'avatar': 'avatar.png',
      'avatarProvider': 'internal',
      'defaultAccountId': '10',
      'useLastReconciledTime': true,
      'transactionEditScope': 2,
      'language': 'en',
      'defaultCurrency': 'EUR',
      'firstDayOfWeek': 1,
      'fiscalYearStart': 101,
      'calendarDisplayType': 1,
      'dateDisplayType': 2,
      'longDateFormat': 3,
      'shortDateFormat': 4,
      'longTimeFormat': 5,
      'shortTimeFormat': 6,
      'fiscalYearFormat': 7,
      'currencyDisplayType': 8,
      'numeralSystem': 9,
      'decimalSeparator': 1,
      'digitGroupingSymbol': 2,
      'digitGrouping': 3,
      'coordinateDisplayType': 4,
      'expenseAmountColor': 1,
      'incomeAmountColor': 2,
      'emailVerified': true,
    };

    test(
      'LoginRequestModel serialization, deserialization & toString redaction',
      () {
        const request = LoginRequestModel(
          loginName: 'demo_user',
          password: 'secret_password',
        );
        final json = request.toJson();

        expect(json['loginName'], equals('demo_user'));
        expect(json['password'], equals('secret_password'));

        final fromJson = LoginRequestModel.fromJson(json);
        expect(fromJson, equals(request));
        expect(fromJson.hashCode, equals(request.hashCode));

        // Sensitive password must be protected in toString
        expect(request.toString(), contains('password: [PROTECTED]'));
        expect(request.toString(), isNot(contains('secret_password')));
      },
    );

    test(
      'RegisterRequestModel serialization, deserialization & toString redaction',
      () {
        const request = RegisterRequestModel(
          username: 'test',
          email: 'test@gmail.com',
          nickname: 'test_nick',
          password: 'Test@1122',
          language: 'en',
        );
        final json = request.toJson();

        expect(json['username'], equals('test'));
        expect(json['email'], equals('test@gmail.com'));
        expect(json['nickname'], equals('test_nick'));
        expect(json['password'], equals('Test@1122'));
        expect(json['language'], equals('en'));

        final fromJson = RegisterRequestModel.fromJson(json);
        expect(fromJson, equals(request));
        expect(fromJson.hashCode, equals(request.hashCode));

        // Sensitive password must be protected in toString
        expect(request.toString(), contains('password: [PROTECTED]'));
        expect(request.toString(), isNot(contains('Test@1122')));
      },
    );

    test('UserModel and User entity conversion with full 28 attributes', () {
      final userModel = UserModel.fromJson(sampleUserJson);
      expect(userModel.username, equals('demo'));
      expect(userModel.email, equals('ezbookkeeping@mayswind.net'));
      expect(userModel.defaultCurrency, equals('EUR'));
      expect(userModel.transactionEditScope, equals(2));
      expect(userModel.emailVerified, isTrue);

      final userEntity = userModel.toEntity();
      expect(userEntity.username, equals('demo'));
      expect(userEntity.email, equals('ezbookkeeping@mayswind.net'));
      expect(userEntity.nickname, equals('demo'));
      expect(userEntity.defaultCurrency, equals('EUR'));
      expect(userEntity.emailVerified, isTrue);

      expect(userEntity, equals(userModel.toEntity()));
      expect(userEntity.hashCode, equals(userModel.toEntity().hashCode));
    });

    test(
      'LoginResultModel and LoginResult entity conversion preserves 2FA and notification',
      () {
        final resultModel = LoginResultModel(
          token: 'sample-jwt-token',
          need2FA: true,
          user: UserModel.fromJson(sampleUserJson),
          notificationContent: 'Demo environment notice',
        );

        final entity = resultModel.toEntity();
        expect(entity.token, equals('sample-jwt-token'));
        expect(entity.need2FA, isTrue);
        expect(entity.notificationContent, equals('Demo environment notice'));
        expect(entity.user.username, equals('demo'));
        expect(entity.user.defaultCurrency, equals('EUR'));

        expect(entity, equals(resultModel.toEntity()));
      },
    );

    test(
      'LoginResponseModel deserialization handles missing and null data defensively',
      () {
        final nullResponse = LoginResponseModel.fromJson(null);
        expect(nullResponse.success, isFalse);
        expect(nullResponse.result, isNull);

        final successResponse = LoginResponseModel.fromJson({
          'success': true,
          'result': {
            'token': 'jwt-abc',
            'need2FA': false,
            'user': {
              'username': 'u1',
              'email': 'e1@mail.com',
              'nickname': 'nick',
            },
            'notificationContent': null,
          },
        });

        expect(successResponse.success, isTrue);
        expect(successResponse.result?.token, equals('jwt-abc'));
        expect(successResponse.result?.user.username, equals('u1'));
      },
    );
  });

  group('AuthenticationRemoteDataSource Test', () {
    late Dio dio;
    late MockHttpAdapter mockAdapter;
    late AuthenticationRemoteDataSource remoteDataSource;

    setUp(() {
      dio = Dio(
        BaseOptions(baseUrl: 'https://ezbookkeeping-demo.mayswind.net'),
      );
      mockAdapter = MockHttpAdapter();
      dio.httpClientAdapter = mockAdapter;

      remoteDataSource = AuthenticationRemoteDataSourceImpl(dio: dio);
    });

    test(
      'login sends POST to /api/authorize.json with requiresAuth=false and payload',
      () async {
        mockAdapter.handler = (options) async {
          expect(options.path, equals(ApiEndpoints.authorize));
          expect(options.method, equals('POST'));
          expect(options.extra[AuthInterceptor.requiresAuthKey], isFalse);
          expect(
            options.data,
            equals({'loginName': 'demo', 'password': 'ezbookkeeping'}),
          );

          return ResponseBody.fromString(
            jsonEncode({
              'success': true,
              'result': {
                'token': 'mock-jwt-token-response',
                'need2FA': false,
                'user': {
                  'username': 'demo',
                  'email': 'ezbookkeeping@mayswind.net',
                  'nickname': 'demo',
                  'defaultCurrency': 'USD',
                },
                'notificationContent': 'Welcome to demo',
              },
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        final response = await remoteDataSource.login(
          const LoginRequestModel(loginName: 'demo', password: 'ezbookkeeping'),
        );

        expect(response, isNotNull);
        expect(response!.token, equals('mock-jwt-token-response'));
        expect(response.user.username, equals('demo'));
        expect(response.notificationContent, equals('Welcome to demo'));
      },
    );

    test('login throws UnauthorizedException on HTTP 401 error', () async {
      mockAdapter.handler = (options) async {
        return ResponseBody.fromString(
          jsonEncode({'error': 'Invalid credentials', 'success': false}),
          401,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      expect(
        () => remoteDataSource.login(
          const LoginRequestModel(loginName: 'wrong', password: 'bad'),
        ),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test(
      'register sends POST to /api/register.json with requiresAuth=false and payload',
      () async {
        mockAdapter.handler = (options) async {
          expect(options.path, equals(ApiEndpoints.register));
          expect(options.method, equals('POST'));
          expect(options.extra[AuthInterceptor.requiresAuthKey], isFalse);
          expect(
            options.data,
            equals({
              'username': 'testuser',
              'email': 'test@example.com',
              'nickname': 'Tester',
              'password': 'Password@123',
              'language': 'en',
              'defaultCurrency': 'USD',
              'categories': [],
            }),
          );

          return ResponseBody.fromString(
            jsonEncode({
              'success': true,
              'result': {
                'token': 'mock-register-token',
                'need2FA': false,
                'user': {
                  'username': 'testuser',
                  'email': 'test@example.com',
                  'nickname': 'Tester',
                  'language': 'en',
                },
                'notificationContent': 'Registered successfully',
                'needVerifyEmail': false,
                'presetCategoriesSaved': false,
              },
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        final response = await remoteDataSource.register(
          const RegisterRequestModel(
            username: 'testuser',
            email: 'test@example.com',
            nickname: 'Tester',
            password: 'Password@123',
            language: 'en',
          ),
        );

        expect(response.success, isTrue);
        expect(response.result, isNotNull);
        expect(response.result!.token, equals('mock-register-token'));
        expect(response.result!.user.username, equals('testuser'));
        expect(
          response.result!.notificationContent,
          equals('Registered successfully'),
        );
      },
    );

    test(
      'logout sends POST to /api/logout.json and returns true on success',
      () async {
        mockAdapter.handler = (options) async {
          expect(options.path, equals(ApiEndpoints.logout));
          expect(options.method, equals('POST'));
          return ResponseBody.fromString(
            jsonEncode({'result': true, 'success': true}),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        final result = await remoteDataSource.logout();
        expect(result, isTrue);
      },
    );

    test(
      'logout returns false when success is false or result is false',
      () async {
        mockAdapter.handler = (options) async {
          return ResponseBody.fromString(
            jsonEncode({'result': false, 'success': false}),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        final result = await remoteDataSource.logout();
        expect(result, isFalse);
      },
    );
  });

  group('AuthenticationRepositoryImpl Test', () {
    late FakeAuthenticationRemoteDataSource fakeDataSource;
    late TestTokenStorage testTokenStorage;
    late AuthenticationRepository repository;

    setUp(() {
      fakeDataSource = FakeAuthenticationRemoteDataSource();
      testTokenStorage = TestTokenStorage();
      repository = AuthenticationRepositoryImpl(
        remoteDataSource: fakeDataSource,
        tokenStorage: testTokenStorage,
      );
    });

    test(
      'successful login saves token to TokenStorage and returns LoginResult entity',
      () async {
        final resultEither = await repository.login(
          loginName: 'demo',
          password: 'ezbookkeeping',
        );

        expect(resultEither.isRight(), isTrue);
        final result = resultEither.getOrElse(() => throw Exception());
        expect(result.token, equals('valid-jwt-token-12345'));
        expect(result.need2FA, isFalse);
        expect(result.user.username, equals('demo'));

        final storedToken = await testTokenStorage.getToken();
        expect(storedToken, equals('valid-jwt-token-12345'));
      },
    );

    test(
      'login with empty token skips saving to TokenStorage without error',
      () async {
        fakeDataSource.responseToReturn = const LoginResponseModel(
          success: true,
          result: LoginResultModel(
            token: '',
            need2FA: true,
            user: UserModel(
              username: 'demo_user',
              email: 'demo@test.com',
              nickname: 'Demo',
            ),
          ),
        );

        final resultEither = await repository.login(
          loginName: 'demo_user',
          password: 'pwd',
        );

        expect(resultEither.isRight(), isTrue);
        final result = resultEither.getOrElse(() => throw Exception());
        expect(result.token, isEmpty);
        expect(result.need2FA, isTrue);
        final storedToken = await testTokenStorage.getToken();
        expect(storedToken, isNull);
      },
    );

    test(
      'login returns Left(ValidationFailure) on empty credentials',
      () async {
        final res1 = await repository.login(loginName: '   ', password: 'pwd');
        expect(res1.isLeft(), isTrue);

        final res2 = await repository.login(loginName: 'demo', password: '');
        expect(res2.isLeft(), isTrue);
      },
    );

    test(
      'login returns Left(UnauthorizedFailure) if response.success is false or result is null',
      () async {
        fakeDataSource.responseToReturn = const LoginResponseModel(
          success: false,
          result: null,
        );

        final result = await repository.login(
          loginName: 'demo',
          password: 'wrong',
        );
        expect(result.isLeft(), isTrue);
      },
    );

    test(
      'logout calls remoteDataSource.logout and clears token from TokenStorage',
      () async {
        await testTokenStorage.saveToken('existing-jwt-token');
        expect(await testTokenStorage.getToken(), equals('existing-jwt-token'));

        await repository.logout();

        expect(fakeDataSource.logoutCalled, isTrue);
        expect(await testTokenStorage.getToken(), isNull);
      },
    );

    test(
      'logout clears token from TokenStorage even if remoteDataSource throws error',
      () async {
        await testTokenStorage.saveToken('existing-jwt-token');
        fakeDataSource.errorToThrow = const ServerException(
          'Server error',
          500,
        );

        await repository.logout();

        expect(fakeDataSource.logoutCalled, isTrue);
        expect(await testTokenStorage.getToken(), isNull);
      },
    );

    test(
      'successful register saves token to TokenStorage and returns LoginResult entity',
      () async {
        final resultEither = await repository.register(
          username: 'newuser',
          email: 'newuser@example.com',
          nickname: 'New User',
          password: 'Password@123',
          language: 'en',
        );

        expect(resultEither.isRight(), isTrue);
        final result = resultEither.getOrElse(() => throw Exception());
        expect(result.token, equals('valid-jwt-token-12345'));
        expect(result.user.username, equals('demo'));

        final storedToken = await testTokenStorage.getToken();
        expect(storedToken, equals('valid-jwt-token-12345'));
      },
    );

    test(
      'register returns Left(ValidationFailure) on invalid input fields',
      () async {
        final res1 = await repository.register(
          username: '   ',
          email: 'test@example.com',
          nickname: 'nick',
          password: 'Password@123',
          language: 'en',
        );
        expect(res1.isLeft(), isTrue);

        final res2 = await repository.register(
          username: 'validuser',
          email: 'invalid-email',
          nickname: 'nick',
          password: 'Password@123',
          language: 'en',
        );
        expect(res2.isLeft(), isTrue);

        final res3 = await repository.register(
          username: 'validuser',
          email: 'valid@mail.com',
          nickname: 'nick',
          password: '123', // < 6 chars
          language: 'en',
        );
        expect(res3.isLeft(), isTrue);
      },
    );
  });

  group('Login, Register & Logout Use Case Tests', () {
    late FakeAuthenticationRepository fakeRepository;
    late Login loginUseCase;
    late Register registerUseCase;
    late Logout logoutUseCase;

    setUp(() {
      fakeRepository = FakeAuthenticationRepository();
      loginUseCase = Login(fakeRepository);
      registerUseCase = Register(fakeRepository);
      logoutUseCase = Logout(fakeRepository);
    });

    test('Login correctly delegates login parameters to repository', () async {
      final result = await loginUseCase(
        loginName: 'demo_user',
        password: 'secure_password_123',
      );

      expect(result.isRight(), isTrue);
      expect(
        result.getOrElse(() => throw Exception()).token,
        equals('default-test-token'),
      );
      expect(fakeRepository.lastLoginName, equals('demo_user'));
      expect(fakeRepository.lastPassword, equals('secure_password_123'));
    });

    test(
      'Register correctly delegates registration parameters to repository',
      () async {
        final result = await registerUseCase(
          username: 'test_user',
          email: 'test@mail.com',
          nickname: 'Tester',
          password: 'Password@123',
          language: 'en',
          defaultCurrency: 'EUR',
        );

        expect(result.isRight(), isTrue);
        expect(
          result.getOrElse(() => throw Exception()).token,
          equals('default-register-token'),
        );
        expect(fakeRepository.lastUsername, equals('test_user'));
        expect(fakeRepository.lastEmail, equals('test@mail.com'));
        expect(fakeRepository.lastNickname, equals('Tester'));
        expect(fakeRepository.lastPassword, equals('Password@123'));
        expect(fakeRepository.lastLanguage, equals('en'));
        expect(fakeRepository.lastDefaultCurrency, equals('EUR'));
      },
    );

    test('Logout correctly invokes repository.logout', () async {
      expect(fakeRepository.logoutCalled, isFalse);
      await logoutUseCase();
      expect(fakeRepository.logoutCalled, isTrue);
    });
  });

  group('AuthenticationBloc Test', () {
    late FakeAuthenticationRepository fakeRepository;
    late Login loginUseCase;
    late Register registerUseCase;
    late Logout logoutUseCase;
    late AuthenticationBloc bloc;

    setUp(() {
      fakeRepository = FakeAuthenticationRepository();
      loginUseCase = Login(fakeRepository);
      registerUseCase = Register(fakeRepository);
      logoutUseCase = Logout(fakeRepository);
      bloc = AuthenticationBloc(
        login: loginUseCase,
        register: registerUseCase,
        logout: logoutUseCase,
      );
    });

    tearDown(() async {
      await bloc.close();
    });

    test('initial state is AuthenticationInitial', () {
      expect(bloc.state, isA<AuthenticationInitial>());
    });

    test(
      'LoginRequested event emits Loading then Success upon valid credentials',
      () async {
        final states = <AuthenticationState>[];
        final subscription = bloc.stream.listen(states.add);

        bloc.add(
          const LoginRequested(loginName: 'demo', password: 'ezbookkeeping'),
        );

        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(states, [
          isA<AuthenticationLoading>(),
          isA<AuthenticationSuccess>().having(
            (s) => s.loginResult.token,
            'token',
            equals('default-test-token'),
          ),
        ]);
        expect(bloc.state, isA<AuthenticationSuccess>());

        await subscription.cancel();
      },
    );

    test(
      'RegisterRequested event emits Loading then Success upon valid registration',
      () async {
        final states = <AuthenticationState>[];
        final subscription = bloc.stream.listen(states.add);

        bloc.add(
          const RegisterRequested(
            username: 'test',
            email: 'test@gmail.com',
            nickname: 'test',
            password: 'Test@1122',
            language: 'en',
          ),
        );

        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(states, [
          isA<AuthenticationLoading>(),
          isA<AuthenticationSuccess>().having(
            (s) => s.loginResult.token,
            'token',
            equals('default-register-token'),
          ),
        ]);
        expect(bloc.state, isA<AuthenticationSuccess>());

        await subscription.cancel();
      },
    );

    test(
      'RegisterRequested event emits Loading then Failure when repository returns failure',
      () async {
        fakeRepository.failureToReturn = const ValidationFailure(
          'Username is already taken',
        );

        final states = <AuthenticationState>[];
        final subscription = bloc.stream.listen(states.add);

        bloc.add(
          const RegisterRequested(
            username: 'duplicate',
            email: 'dup@gmail.com',
            nickname: 'dup',
            password: 'Test@1122',
            language: 'en',
          ),
        );

        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(states, [
          isA<AuthenticationLoading>(),
          isA<AuthenticationFailure>().having(
            (s) => s.message,
            'message',
            equals('Username is already taken'),
          ),
        ]);
        expect(bloc.state, isA<AuthenticationFailure>());

        await subscription.cancel();
      },
    );

    test(
      'LoginRequested event emits Loading then Failure when validation or network error occurs',
      () async {
        fakeRepository.failureToReturn = const UnauthorizedFailure(
          'Invalid username or password',
        );

        final states = <AuthenticationState>[];
        final subscription = bloc.stream.listen(states.add);

        bloc.add(
          const LoginRequested(loginName: 'demo', password: 'wrong_password'),
        );

        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(states, [
          isA<AuthenticationLoading>(),
          isA<AuthenticationFailure>().having(
            (s) => s.message,
            'message',
            equals('Invalid username or password'),
          ),
        ]);
        expect(bloc.state, isA<AuthenticationFailure>());

        await subscription.cancel();
      },
    );

    test(
      'LogoutRequested event invokes logout use case and emits Loading then Initial state',
      () async {
        final states = <AuthenticationState>[];
        final subscription = bloc.stream.listen(states.add);

        bloc.add(const LogoutRequested());

        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(states, [
          isA<AuthenticationLoading>(),
          isA<AuthenticationInitial>(),
        ]);
        expect(bloc.state, isA<AuthenticationInitial>());
        expect(fakeRepository.logoutCalled, isTrue);

        await subscription.cancel();
      },
    );
  });

  group('GetIt Dependency Injection Test', () {
    setUp(() async {
      await getIt.reset();
    });

    tearDown(() async {
      await getIt.reset();
    });

    test(
      'setupDependencies registers complete dependency graph and resolves correctly',
      () async {
        final testStorage = TestTokenStorage();
        final customDio = Dio(
          BaseOptions(baseUrl: 'https://ezbookkeeping-demo.mayswind.net'),
        );

        await setupDependencies(tokenStorage: testStorage, dio: customDio);

        // Verify all services in graph resolve
        expect(getIt<TokenStorage>(), isNotNull);
        expect(getIt<TokenStorage>(), equals(testStorage));

        expect(getIt<Dio>(), isNotNull);
        expect(getIt<Dio>(), equals(customDio));

        expect(getIt<AuthenticationRemoteDataSource>(), isNotNull);
        expect(getIt<AuthenticationRepository>(), isNotNull);
        expect(getIt<Login>(), isNotNull);
        expect(getIt<Register>(), isNotNull);
        expect(getIt<Logout>(), isNotNull);

        // Verify factory creates independent instances
        final bloc1 = getIt<AuthenticationBloc>();
        final bloc2 = getIt<AuthenticationBloc>();
        expect(bloc1, isNotNull);
        expect(bloc2, isNotNull);
        expect(
          identical(bloc1, bloc2),
          isFalse,
        ); // factory produces distinct instances

        await bloc1.close();
        await bloc2.close();
      },
    );
  });

  group('App Router Auth Redirection Tests', () {
    setUp(() async {
      await getIt.reset();
    });

    tearDown(() async {
      await getIt.reset();
    });

    testWidgets(
      'redirects unauthenticated user from Home to Login screen when TokenStorage has no token',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final testStorage = TestTokenStorage(); // null token
        final dio = Dio(
          BaseOptions(baseUrl: 'https://ezbookkeeping-demo.mayswind.net'),
        );
        dio.httpClientAdapter = MockHttpAdapter();
        await setupDependencies(tokenStorage: testStorage, dio: dio);

        await tester.pumpWidget(MaterialApp.router(routerConfig: appRouter));
        appRouter.go(AppRoutes.home);
        await tester.pumpAndSettle();

        expect(find.byType(LoginScreen), findsOneWidget);
        expect(find.text('Log In'), findsWidgets);
      },
    );

    testWidgets(
      'allows authenticated user to stay on Home screen when TokenStorage has valid token',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final testStorage = TestTokenStorage();
        await testStorage.saveToken('valid-auth-token');
        final dio = Dio(
          BaseOptions(baseUrl: 'https://ezbookkeeping-demo.mayswind.net'),
        );
        dio.httpClientAdapter = MockHttpAdapter();
        await setupDependencies(tokenStorage: testStorage, dio: dio);

        await tester.pumpWidget(MaterialApp.router(routerConfig: appRouter));
        appRouter.go(AppRoutes.home);
        await tester.pumpAndSettle();

        expect(find.byType(HomeScreen), findsOneWidget);
        expect(find.text('ezBookkeeping'), findsOneWidget);
      },
    );

    testWidgets(
      'redirects authenticated user from Login to Home screen when TokenStorage has valid token',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final testStorage = TestTokenStorage();
        await testStorage.saveToken('valid-auth-token');
        final dio = Dio(
          BaseOptions(baseUrl: 'https://ezbookkeeping-demo.mayswind.net'),
        );
        dio.httpClientAdapter = MockHttpAdapter();
        await setupDependencies(tokenStorage: testStorage, dio: dio);

        await tester.pumpWidget(MaterialApp.router(routerConfig: appRouter));
        appRouter.go(AppRoutes.login);
        await tester.pumpAndSettle();

        expect(find.byType(HomeScreen), findsOneWidget);
      },
    );
  });
}
