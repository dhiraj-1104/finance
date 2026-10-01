import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:ezbookkeeping/core/error/exceptions.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/core/network/api_endpoints.dart';
import 'package:ezbookkeeping/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:ezbookkeeping/features/profile/data/models/update_user_profile_request_model.dart';
import 'package:ezbookkeeping/features/profile/data/models/user_profile_model.dart';
import 'package:ezbookkeeping/features/profile/data/models/user_profile_response_model.dart';
import 'package:ezbookkeeping/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:ezbookkeeping/features/profile/domain/entities/user_profile.dart';
import 'package:ezbookkeeping/features/profile/domain/repositories/profile_repository.dart';
import 'package:ezbookkeeping/features/profile/domain/usecases/get_user_profile_use_case.dart';
import 'package:ezbookkeeping/features/profile/domain/usecases/update_user_profile_use_case.dart';
import 'package:ezbookkeeping/features/profile/presentation/bloc/update_user_profile_bloc.dart';
import 'package:ezbookkeeping/features/profile/presentation/bloc/update_user_profile_event.dart';
import 'package:ezbookkeeping/features/profile/presentation/bloc/update_user_profile_state.dart';
import 'package:ezbookkeeping/features/profile/presentation/bloc/user_profile_bloc.dart';
import 'package:ezbookkeeping/features/profile/presentation/bloc/user_profile_event.dart';
import 'package:ezbookkeeping/features/profile/presentation/bloc/user_profile_state.dart';
import 'package:ezbookkeeping/features/settings/presentation/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _MockDioAdapter implements HttpClientAdapter {
  _MockDioAdapter(this.handler);

  final Future<ResponseBody> Function(RequestOptions options) handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

class _FakeProfileRepository implements ProfileRepository {
  Either<Failure, UserProfile>? result;
  Either<Failure, UserProfile>? updateResult;

  @override
  Future<Either<Failure, UserProfile>> getUserProfile() async {
    return result ??
        const Right(
          UserProfile(
            username: 'demo',
            email: 'ezbookkeeping@mayswind.net',
            nickname: 'demo',
            avatar: '',
            avatarProvider: 'internal',
            defaultAccountId: '0',
            useLastReconciledTime: false,
            transactionEditScope: 1,
            language: '',
            defaultCurrency: 'USD',
            firstDayOfWeek: 0,
            fiscalYearStart: 257,
            calendarDisplayType: 0,
            dateDisplayType: 0,
            longDateFormat: 0,
            shortDateFormat: 0,
            longTimeFormat: 0,
            shortTimeFormat: 0,
            fiscalYearFormat: 0,
            currencyDisplayType: 0,
            numeralSystem: 0,
            decimalSeparator: 0,
            digitGroupingSymbol: 0,
            digitGrouping: 0,
            coordinateDisplayType: 0,
            expenseAmountColor: 0,
            incomeAmountColor: 0,
            emailVerified: false,
            lastLoginAt: 1790673188,
          ),
        );
  }

  @override
  Future<Either<Failure, UserProfile>> updateUserProfile(
    UpdateUserProfileRequestModel request,
  ) async {
    return updateResult ??
        Right(request.toEntity(username: 'demo', emailVerified: true));
  }
}

void main() {
  const sampleJson = {
    "result": {
      "username": "demo",
      "email": "ezbookkeeping@mayswind.net",
      "nickname": "demo",
      "avatar": "",
      "avatarProvider": "internal",
      "defaultAccountId": "0",
      "useLastReconciledTime": false,
      "transactionEditScope": 1,
      "language": "",
      "defaultCurrency": "USD",
      "firstDayOfWeek": 0,
      "fiscalYearStart": 257,
      "calendarDisplayType": 0,
      "dateDisplayType": 0,
      "longDateFormat": 0,
      "shortDateFormat": 0,
      "longTimeFormat": 0,
      "shortTimeFormat": 0,
      "fiscalYearFormat": 0,
      "currencyDisplayType": 0,
      "numeralSystem": 0,
      "decimalSeparator": 0,
      "digitGroupingSymbol": 0,
      "digitGrouping": 0,
      "coordinateDisplayType": 0,
      "expenseAmountColor": 0,
      "incomeAmountColor": 0,
      "emailVerified": false,
      "lastLoginAt": 1790673188,
    },
    "success": true,
  };

  group('UserProfile Model & Entity Tests', () {
    test(
      'Correctly parses complete JSON response matching API specification',
      () {
        final responseModel = UserProfileResponseModel.fromJson(sampleJson);

        expect(responseModel.success, true);
        expect(responseModel.result, isNotNull);

        final model = responseModel.result!;
        expect(model.username, 'demo');
        expect(model.email, 'ezbookkeeping@mayswind.net');
        expect(model.nickname, 'demo');
        expect(model.avatar, '');
        expect(model.avatarProvider, 'internal');
        expect(model.defaultAccountId, '0');
        expect(model.useLastReconciledTime, false);
        expect(model.transactionEditScope, 1);
        expect(model.language, '');
        expect(model.defaultCurrency, 'USD');
        expect(model.firstDayOfWeek, 0);
        expect(model.fiscalYearStart, 257);
        expect(model.calendarDisplayType, 0);
        expect(model.dateDisplayType, 0);
        expect(model.longDateFormat, 0);
        expect(model.shortDateFormat, 0);
        expect(model.longTimeFormat, 0);
        expect(model.shortTimeFormat, 0);
        expect(model.fiscalYearFormat, 0);
        expect(model.currencyDisplayType, 0);
        expect(model.numeralSystem, 0);
        expect(model.decimalSeparator, 0);
        expect(model.digitGroupingSymbol, 0);
        expect(model.digitGrouping, 0);
        expect(model.coordinateDisplayType, 0);
        expect(model.expenseAmountColor, 0);
        expect(model.incomeAmountColor, 0);
        expect(model.emailVerified, false);
        expect(model.lastLoginAt, 1790673188);
      },
    );

    test(
      'Converts UserProfileModel to UserProfile domain entity accurately',
      () {
        final model = UserProfileModel.fromJson(
          sampleJson['result'] as Map<String, dynamic>,
        );
        final entity = model.toEntity();

        expect(entity.username, 'demo');
        expect(entity.email, 'ezbookkeeping@mayswind.net');
        expect(entity.nickname, 'demo');
        expect(entity.lastLoginAt, 1790673188);
        expect(entity.emailVerified, false);
        expect(entity.defaultCurrency, 'USD');
      },
    );

    test(
      'Safely handles null values and missing properties in JSON deserialization',
      () {
        final emptyModel = UserProfileModel.fromJson(null);
        expect(emptyModel.username, '');
        expect(emptyModel.email, '');
        expect(emptyModel.nickname, '');
        expect(emptyModel.lastLoginAt, 0);

        final emptyResponse = UserProfileResponseModel.fromJson(null);
        expect(emptyResponse.success, false);
        expect(emptyResponse.result, isNull);
      },
    );
  });

  group('UpdateUserProfileRequestModel Tests', () {
    test('Serializes to JSON with all 26 fields exactly matching API', () {
      const request = UpdateUserProfileRequestModel(
        email: 'ezbookkeeping@mayswind.net',
        nickname: 'demo67',
        password: 'password123',
        oldPassword: 'oldpassword123',
        calendarDisplayType: 0,
        coordinateDisplayType: 0,
        currencyDisplayType: 0,
        dateDisplayType: 0,
        decimalSeparator: 0,
        defaultAccountId: '0',
        defaultCurrency: 'USD',
        digitGrouping: 0,
        digitGroupingSymbol: 0,
        expenseAmountColor: 0,
        firstDayOfWeek: 0,
        fiscalYearFormat: 0,
        fiscalYearStart: 257,
        incomeAmountColor: 0,
        language: 'en-US',
        longDateFormat: 0,
        longTimeFormat: 0,
        numeralSystem: 0,
        shortDateFormat: 0,
        shortTimeFormat: 0,
        transactionEditScope: 1,
        useLastReconciledTime: false,
      );

      final json = request.toJson();
      expect(json['email'], 'ezbookkeeping@mayswind.net');
      expect(json['nickname'], 'demo67');
      expect(json['password'], 'password123');
      expect(json['oldPassword'], 'oldpassword123');
      expect(json['defaultCurrency'], 'USD');
      expect(json['language'], 'en-US');
      expect(json['useLastReconciledTime'], false);
      expect(json.length, 26);
    });

    test('Redacts passwords in toString()', () {
      const request = UpdateUserProfileRequestModel(
        email: 'test@example.com',
        nickname: 'test',
        password: 'secretPassword',
        oldPassword: 'secretOldPassword',
      );

      final str = request.toString();
      expect(str.contains('secretPassword'), false);
      expect(str.contains('secretOldPassword'), false);
      expect(str.contains('password: ***'), true);
      expect(str.contains('oldPassword: ***'), true);
    });
  });

  group('ProfileRemoteDataSource Tests', () {
    test(
      'Invokes GET request on ApiEndpoints.userProfile and returns UserProfileResponseModel',
      () async {
        final dio = Dio(
          BaseOptions(baseUrl: 'https://ezbookkeeping-demo.mayswind.net'),
        );
        dio.httpClientAdapter = _MockDioAdapter((options) async {
          expect(options.path, ApiEndpoints.userProfile);
          expect(options.method, 'GET');
          return ResponseBody.fromString(
            '{"result":{"username":"demo","email":"ezbookkeeping@mayswind.net","nickname":"demo","emailVerified":true,"lastLoginAt":1790673188},"success":true}',
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        });

        final dataSource = ProfileRemoteDataSourceImpl(dio: dio);
        final result = await dataSource.getUserProfile();

        expect(result.success, true);
        expect(result.result?.username, 'demo');
        expect(result.result?.emailVerified, true);
      },
    );

    test('Invokes POST request on ApiEndpoints.userProfileUpdate', () async {
      final dio = Dio(
        BaseOptions(baseUrl: 'https://ezbookkeeping-demo.mayswind.net'),
      );
      dio.httpClientAdapter = _MockDioAdapter((options) async {
        expect(options.path, ApiEndpoints.userProfileUpdate);
        expect(options.method, 'POST');
        return ResponseBody.fromString(
          '{"result":{"username":"demo","email":"updated@test.net","nickname":"demo67"},"success":true}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final dataSource = ProfileRemoteDataSourceImpl(dio: dio);
      final result = await dataSource.updateUserProfile(
        const UpdateUserProfileRequestModel(
          email: 'updated@test.net',
          nickname: 'demo67',
        ),
      );

      expect(result.success, true);
      expect(result.result?.email, 'updated@test.net');
      expect(result.result?.nickname, 'demo67');
    });

    test('Throws UnauthorizedException when server returns 401', () async {
      final dio = Dio(
        BaseOptions(baseUrl: 'https://ezbookkeeping-demo.mayswind.net'),
      );
      dio.httpClientAdapter = _MockDioAdapter((options) async {
        return ResponseBody.fromString(
          '{"errorMessage":"Unauthorized","success":false}',
          401,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final dataSource = ProfileRemoteDataSourceImpl(dio: dio);
      expect(
        () => dataSource.getUserProfile(),
        throwsA(isA<UnauthorizedException>()),
      );
    });
  });

  group('ProfileRepository & UseCase Tests', () {
    test(
      'Repository returns Right(UserProfile) on successful remote response',
      () async {
        final dio = Dio(
          BaseOptions(baseUrl: 'https://ezbookkeeping-demo.mayswind.net'),
        );
        dio.httpClientAdapter = _MockDioAdapter((options) async {
          return ResponseBody.fromString(
            '{"result":{"username":"demo","email":"demo@test.com","nickname":"Tester"},"success":true}',
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        });

        final dataSource = ProfileRemoteDataSourceImpl(dio: dio);
        final repository = ProfileRepositoryImpl(remoteDataSource: dataSource);
        final useCase = GetUserProfileUseCase(repository);

        final result = await useCase();
        expect(result.isRight(), true);
        result.fold(
          (failure) => fail('Expected Right but got Left: $failure'),
          (profile) {
            expect(profile.username, 'demo');
            expect(profile.email, 'demo@test.com');
            expect(profile.nickname, 'Tester');
          },
        );
      },
    );

    test('Repository returns Right(UserProfile) on successful update', () async {
      final dio = Dio(
        BaseOptions(baseUrl: 'https://ezbookkeeping-demo.mayswind.net'),
      );
      dio.httpClientAdapter = _MockDioAdapter((options) async {
        return ResponseBody.fromString(
          '{"result":{"username":"demo","email":"demo67@test.com","nickname":"demo67"},"success":true}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final dataSource = ProfileRemoteDataSourceImpl(dio: dio);
      final repository = ProfileRepositoryImpl(remoteDataSource: dataSource);
      final useCase = UpdateUserProfileUseCase(repository);

      final result = await useCase(
        const UpdateUserProfileRequestModel(
          email: 'demo67@test.com',
          nickname: 'demo67',
        ),
      );

      expect(result.isRight(), true);
      result.fold((failure) => fail('Expected Right but got Left: $failure'), (
        profile,
      ) {
        expect(profile.email, 'demo67@test.com');
        expect(profile.nickname, 'demo67');
      });
    });

    test(
      'Repository returns Left(ServerFailure) on failed remote response',
      () async {
        final dio = Dio(
          BaseOptions(baseUrl: 'https://ezbookkeeping-demo.mayswind.net'),
        );
        dio.httpClientAdapter = _MockDioAdapter((options) async {
          return ResponseBody.fromString(
            '{"errorMessage":"Internal Error","success":false}',
            500,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        });

        final dataSource = ProfileRemoteDataSourceImpl(dio: dio);
        final repository = ProfileRepositoryImpl(remoteDataSource: dataSource);

        final result = await repository.getUserProfile();
        expect(result.isLeft(), true);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Expected Left but got Right'),
        );
      },
    );
  });

  group('UserProfileBloc Tests (Get Profile)', () {
    test(
      'Emits [UserProfileLoading, UserProfileLoaded] when profile is fetched successfully',
      () async {
        final repository = _FakeProfileRepository();
        final useCase = GetUserProfileUseCase(repository);
        final bloc = UserProfileBloc(getUserProfile: useCase);

        expect(bloc.state, const UserProfileInitial());

        final expectedStates = [
          const UserProfileLoading(),
          isA<UserProfileLoaded>().having(
            (s) => s.profile.nickname,
            'nickname',
            'demo',
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));

        bloc.add(const GetUserProfileRequested());
      },
    );

    test(
      'Emits [UserProfileLoading, UserProfileError] when fetching fails',
      () async {
        final repository = _FakeProfileRepository();
        repository.result = const Left(ServerFailure('Connection timeout'));
        final useCase = GetUserProfileUseCase(repository);
        final bloc = UserProfileBloc(getUserProfile: useCase);

        final expectedStates = [
          const UserProfileLoading(),
          const UserProfileError(message: 'Connection timeout'),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));

        bloc.add(const GetUserProfileRequested());
      },
    );
  });

  group('UpdateUserProfileBloc Tests (Update Profile)', () {
    test(
      'Emits [UpdateUserProfileLoading, UpdateUserProfileSuccess] when update succeeds',
      () async {
        final repository = _FakeProfileRepository();
        final useCase = UpdateUserProfileUseCase(repository);
        final bloc = UpdateUserProfileBloc(updateUserProfile: useCase);

        expect(bloc.state, const UpdateUserProfileInitial());

        final expectedStates = [
          const UpdateUserProfileLoading(),
          isA<UpdateUserProfileSuccess>().having(
            (s) => s.updatedProfile.nickname,
            'nickname',
            'demo67',
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));

        bloc.add(
          const UpdateUserProfileSubmitted(
            UpdateUserProfileRequestModel(
              email: 'demo67@mayswind.net',
              nickname: 'demo67',
            ),
          ),
        );
      },
    );

    test(
      'Emits [UpdateUserProfileLoading, UpdateUserProfileFailure] when update fails',
      () async {
        final repository = _FakeProfileRepository();
        repository.updateResult = const Left(ServerFailure('Validation error'));
        final useCase = UpdateUserProfileUseCase(repository);
        final bloc = UpdateUserProfileBloc(updateUserProfile: useCase);

        final expectedStates = [
          const UpdateUserProfileLoading(),
          const UpdateUserProfileFailure(message: 'Validation error'),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));

        bloc.add(
          const UpdateUserProfileSubmitted(
            UpdateUserProfileRequestModel(
              email: 'demo67@mayswind.net',
              nickname: 'demo67',
            ),
          ),
        );
      },
    );
  });

  group('UserProfileScreen Live Integration Tests', () {
    testWidgets(
      'Populates profile data and displays verified status from UserProfileBloc',
      (tester) async {
        final repository = _FakeProfileRepository();
        repository.result = const Right(
          UserProfile(
            username: 'live_user',
            email: 'live@ezbookkeeping.net',
            nickname: 'Live User',
            emailVerified: true,
            defaultCurrency: 'USD',
            useLastReconciledTime: true,
          ),
        );
        final getUseCase = GetUserProfileUseCase(repository);
        final updateUseCase = UpdateUserProfileUseCase(repository);
        final userProfileBloc = UserProfileBloc(getUserProfile: getUseCase);
        final updateProfileBloc = UpdateUserProfileBloc(
          updateUserProfile: updateUseCase,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: MultiBlocProvider(
              providers: [
                BlocProvider<UserProfileBloc>.value(value: userProfileBloc),
                BlocProvider<UpdateUserProfileBloc>.value(
                  value: updateProfileBloc,
                ),
              ],
              child: const UserProfileScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verified status and values reflected in UI
        expect(find.text('E-mail (Verified)'), findsOneWidget);
        expect(find.text('live@ezbookkeeping.net'), findsOneWidget);
        expect(find.text('Live User'), findsOneWidget);
        expect(find.text('Enabled'), findsOneWidget);
      },
    );
  });
}
