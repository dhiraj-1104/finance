import 'dart:convert';
import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/features/categories/data/models/add_category_request_model.dart';
import 'package:ezbookkeeping/features/categories/domain/repositories/categories_repository.dart';
import 'package:ezbookkeeping/features/categories/models/category_item.dart';
import 'package:ezbookkeeping/features/statistics/data/datasources/statistics_remote_data_source.dart';
import 'package:ezbookkeeping/features/statistics/data/models/statistics_request.dart';
import 'package:ezbookkeeping/features/statistics/data/repositories/statistics_repository_impl.dart';
import 'package:ezbookkeeping/features/statistics/domain/entities/statistic_category_item.dart';
import 'package:ezbookkeeping/features/statistics/domain/entities/statistic_data.dart';
import 'package:ezbookkeeping/features/statistics/domain/repositories/statistics_repository.dart';
import 'package:ezbookkeeping/features/statistics/domain/usecases/get_statistics_use_case.dart';
import 'package:ezbookkeeping/features/statistics/presentation/bloc/statistics_bloc.dart';
import 'package:ezbookkeeping/features/statistics/presentation/bloc/statistics_event.dart';
import 'package:ezbookkeeping/features/statistics/presentation/bloc/statistics_state.dart';
import 'package:ezbookkeeping/features/statistics/presentation/widgets/sort_action_sheet.dart';

class _MockCategoriesRepository implements CategoriesRepository {
  final Map<String, CategoryItem> _categories;
  _MockCategoriesRepository([Map<String, CategoryItem>? categories])
    : _categories = categories ?? {};

  @override
  Future<Either<Failure, CategoryItem>> addCategory(
    AddCategoryRequestModel request,
  ) async {
    final cat = CategoryItem(
      id: 'cat_${DateTime.now().millisecondsSinceEpoch}',
      name: request.name,
      categoryIconId: request.icon,
      icon: Icons.category,
      color: const Color(0xFF000000),
      type: request.type == 1
          ? CategoryType.income
          : (request.type == 3 ? CategoryType.transfer : CategoryType.expense),
      isPrimary: request.parentId == '0',
      parentId: request.parentId == '0' ? null : request.parentId,
      description: request.comment,
    );
    _categories[cat.id] = cat;
    return Right(cat);
  }

  @override
  Future<List<CategoryItem>> getCategories({bool forceRefresh = false}) async =>
      _categories.values.toList();

  @override
  Future<Map<String, CategoryItem>> getCategoriesMap({
    bool forceRefresh = false,
  }) async => _categories;

  @override
  Future<Map<String, String>> getCategoryNameMap({
    bool forceRefresh = false,
  }) async => _categories.map((k, v) => MapEntry(k, v.name));

  @override
  void clearCache() {}

  @override
  bool get isCacheValid => true;
}

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
      jsonEncode({
        'success': true,
        'result': {'items': []},
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class FakeStatisticsRepository implements StatisticsRepository {
  StatisticData? dataToReturn;
  Failure? failureToReturn;
  StatisticsRequest? lastRequest;

  @override
  Future<Either<Failure, StatisticData>> getStatistics(
    StatisticsRequest request,
  ) async {
    lastRequest = request;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(
      dataToReturn ??
          const StatisticData(
            totalAmount: 3000.0,
            categories: [
              StatisticCategoryItem(
                id: '1',
                name: 'Food & Drink',
                icon: Icons.restaurant,
                color: Color(0xFFF38426),
                amount: 2000.0,
                percentage: 66.67,
              ),
              StatisticCategoryItem(
                id: '2',
                name: 'Clothing',
                icon: Icons.checkroom,
                color: Color(0xFF3AC79F),
                amount: 1000.0,
                percentage: 33.33,
              ),
            ],
          ),
    );
  }
}

void main() {
  group('Statistics Remote Data Source Tests', () {
    late Dio dio;
    late MockHttpAdapter mockAdapter;
    late StatisticsRemoteDataSource dataSource;

    setUp(() {
      mockAdapter = MockHttpAdapter();
      dio = Dio(
        BaseOptions(baseUrl: 'https://ezbookkeeping-demo.mayswind.net'),
      );
      dio.httpClientAdapter = mockAdapter;
      dataSource = StatisticsRemoteDataSourceImpl(dio: dio);
    });

    test('getStatistics passes query parameters to API endpoint', () async {
      mockAdapter.handler = (options) async {
        expect(options.path, equals('/api/v1/transactions/statistics.json'));
        expect(options.queryParameters['chart_data_type'], equals(1));
        expect(options.queryParameters['start_time'], equals(1000));
        expect(options.queryParameters['end_time'], equals(2000));

        return ResponseBody.fromString(
          jsonEncode({
            'success': true,
            'result': {
              'items': [
                {
                  'name': 'Housing',
                  'categoryIconId': '200',
                  'amount': 241500,
                  'color': 'C14660',
                },
              ],
            },
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await dataSource.getStatistics(
        const StatisticsRequest(
          startTime: 1000,
          endTime: 2000,
          chartDataType: 1,
        ),
      );

      expect(result['success'], isTrue);
      expect(result['result']['items'], isList);
    });
  });

  group('Statistics Repository Tests', () {
    late Dio dio;
    late MockHttpAdapter mockAdapter;
    late StatisticsRemoteDataSource dataSource;
    late StatisticsRepository repository;

    setUp(() {
      mockAdapter = MockHttpAdapter();
      dio = Dio(
        BaseOptions(baseUrl: 'https://ezbookkeeping-demo.mayswind.net'),
      );
      dio.httpClientAdapter = mockAdapter;
      dataSource = StatisticsRemoteDataSourceImpl(dio: dio);
      repository = StatisticsRepositoryImpl(remoteDataSource: dataSource);
    });

    test('parses items from API response and computes percentages', () async {
      mockAdapter.handler = (options) async {
        return ResponseBody.fromString(
          jsonEncode({
            'success': true,
            'result': {
              'items': [
                {
                  'name': 'Housing',
                  'categoryIconId': '200',
                  'amount': 200000,
                  'color': 'C14660',
                },
                {
                  'name': 'Food',
                  'categoryIconId': '1',
                  'amount': 100000,
                  'color': 'F38426',
                },
              ],
            },
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.getStatistics(const StatisticsRequest());
      expect(result.isRight(), isTrue);
      final data = result.getOrElse(() => throw Exception());

      expect(data.totalAmount, equals(3000.0));
      expect(data.categories.length, equals(2));
      expect(data.categories[0].name, equals('Housing'));
      expect(data.categories[0].amount, equals(2000.0));
      expect(data.categories[0].percentage, equals(66.67));
    });

    test(
      'hydrates category name and icon from CategoriesRepository when API returns only categoryId',
      () async {
        final fakeCategoriesRepo = _MockCategoriesRepository({
          '3843885834860232704': const CategoryItem(
            id: '3843885834860232704',
            name: 'Housing & Houseware',
            categoryIconId: '200',
            icon: Icons.home,
            color: Color(0xFFC14660),
          ),
        });

        final repoWithCategories = StatisticsRepositoryImpl(
          remoteDataSource: dataSource,
          categoriesRepository: fakeCategoriesRepo,
        );

        mockAdapter.handler = (options) async {
          return ResponseBody.fromString(
            jsonEncode({
              'success': true,
              'result': [
                {'categoryId': '3843885834860232704', 'totalAmount': '241500'},
              ],
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        final result = await repoWithCategories.getStatistics(
          const StatisticsRequest(),
        );
        expect(result.isRight(), isTrue);
        final data = result.getOrElse(() => throw Exception());

        expect(data.totalAmount, equals(2415.0));
        expect(data.categories.length, equals(1));
        expect(data.categories[0].name, equals('Housing & Houseware'));
        expect(data.categories[0].amount, equals(2415.0));
        expect(data.categories[0].percentage, equals(100.0));
      },
    );

    test('returns empty StatisticData when API returns empty items', () async {
      mockAdapter.handler = (options) async {
        return ResponseBody.fromString(
          jsonEncode({
            'success': true,
            'result': {'items': []},
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final result = await repository.getStatistics(const StatisticsRequest());
      expect(result.isRight(), isTrue);
      final data = result.getOrElse(() => throw Exception());

      expect(data.categories.isEmpty, isTrue);
      expect(data.totalAmount, equals(0.0));
    });

    test('returns Failure when API throws an exception', () async {
      mockAdapter.handler = (options) async {
        throw DioException(
          requestOptions: options,
          error: 'Network failure',
          type: DioExceptionType.connectionError,
        );
      };

      final result = await repository.getStatistics(const StatisticsRequest());
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left but got Right'),
      );
    });
  });

  group('StatisticsBloc Tests', () {
    late FakeStatisticsRepository fakeRepo;
    late GetStatisticsUseCase useCase;
    late StatisticsBloc bloc;

    setUp(() {
      fakeRepo = FakeStatisticsRepository();
      useCase = GetStatisticsUseCase(fakeRepo);
      bloc = StatisticsBloc(getStatistics: useCase);
    });

    tearDown(() async {
      await bloc.close();
    });

    test('initial state is StatisticsInitial', () {
      expect(bloc.state, isA<StatisticsInitial>());
    });

    test(
      'LoadStatistics emits StatisticsLoading then StatisticsLoaded',
      () async {
        final states = <StatisticsState>[];
        final sub = bloc.stream.listen(states.add);

        bloc.add(const LoadStatistics());
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(states, [
          isA<StatisticsLoading>(),
          isA<StatisticsLoaded>().having(
            (s) => s.categories.length,
            'categories count',
            equals(2),
          ),
        ]);

        await sub.cancel();
      },
    );

    test(
      'ChangePeriod, ChangeScope, ChangeSortType and SelectCategoryIndex update state',
      () async {
        final states = <StatisticsState>[];
        final sub = bloc.stream.listen(states.add);

        bloc.add(const LoadStatistics());
        await Future<void>.delayed(const Duration(milliseconds: 30));

        bloc.add(const ChangePeriod('This week'));
        await Future<void>.delayed(const Duration(milliseconds: 30));

        bloc.add(const ChangeScope('Income By Primary Category'));
        await Future<void>.delayed(const Duration(milliseconds: 30));

        bloc.add(const ChangeSortType(StatisticSortType.name));
        await Future<void>.delayed(const Duration(milliseconds: 30));

        bloc.add(const SelectCategoryIndex(1));
        await Future<void>.delayed(const Duration(milliseconds: 30));

        final lastState = bloc.state as StatisticsLoaded;
        expect(lastState.period, equals('This week'));
        expect(lastState.scope, equals('Income By Primary Category'));
        expect(lastState.sortType, equals(StatisticSortType.name));
        expect(lastState.selectedCategoryIndex, equals(1));

        await sub.cancel();
      },
    );
  });

  group('GetIt Dependency Injection for Statistics', () {
    setUp(() async {
      await getIt.reset();
    });

    tearDown(() async {
      await getIt.reset();
    });

    test('registers and resolves all Statistics dependencies', () async {
      final customDio = Dio(
        BaseOptions(baseUrl: 'https://ezbookkeeping-demo.mayswind.net'),
      );

      await setupDependencies(dio: customDio);

      expect(getIt<StatisticsRemoteDataSource>(), isNotNull);
      expect(getIt<StatisticsRepository>(), isNotNull);
      expect(getIt<GetStatisticsUseCase>(), isNotNull);

      final bloc1 = getIt<StatisticsBloc>();
      final bloc2 = getIt<StatisticsBloc>();
      expect(bloc1, isNotNull);
      expect(bloc2, isNotNull);
      expect(identical(bloc1, bloc2), isFalse);

      await bloc1.close();
      await bloc2.close();
    });
  });
}
