import 'dart:convert';
import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/core/network/api_endpoints.dart';
import 'package:ezbookkeeping/features/home/data/datasources/home_remote_data_source.dart';
import 'package:ezbookkeeping/features/home/data/models/transaction_amount_period_model.dart';
import 'package:ezbookkeeping/features/home/data/models/transaction_amounts_model.dart';
import 'package:ezbookkeeping/features/home/data/models/transaction_amounts_response_model.dart';
import 'package:ezbookkeeping/features/home/data/models/transaction_currency_amount_model.dart';
import 'package:ezbookkeeping/features/home/data/repositories/home_repository_impl.dart';
import 'package:ezbookkeeping/features/home/data/utils/transaction_time_range_builder.dart';
import 'package:ezbookkeeping/features/home/domain/entities/transaction_amount_period.dart';
import 'package:ezbookkeeping/features/home/domain/entities/transaction_amounts.dart';
import 'package:ezbookkeeping/features/home/domain/entities/transaction_currency_amount.dart';
import 'package:ezbookkeeping/features/home/domain/repositories/home_repository.dart';
import 'package:ezbookkeeping/features/home/domain/usecases/get_transaction_amounts.dart';
import 'package:ezbookkeeping/features/home/presentation/bloc/home_bloc.dart';
import 'package:ezbookkeeping/features/home/presentation/bloc/home_event.dart';
import 'package:ezbookkeeping/features/home/presentation/bloc/home_state.dart';
import 'package:ezbookkeeping/features/home/presentation/utils/money_formatter.dart';

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

class FakeHomeRepository implements HomeRepository {
  FakeHomeRepository({this.resultToReturn, this.failureToReturn});

  TransactionAmounts? resultToReturn;
  Failure? failureToReturn;

  int? lastFirstDayOfWeek;
  DateTime? lastNow;
  bool? lastUseTransactionTimezone;

  @override
  Future<Either<Failure, TransactionAmounts>> getTransactionAmounts({
    int firstDayOfWeek = 0,
    DateTime? now,
    bool useTransactionTimezone = false,
  }) async {
    lastFirstDayOfWeek = firstDayOfWeek;
    lastNow = now;
    lastUseTransactionTimezone = useTransactionTimezone;

    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }

    return Right(
      resultToReturn ??
          const TransactionAmounts(
            today: TransactionAmountPeriod(
              startTime: 1000,
              endTime: 2000,
              amounts: [
                TransactionCurrencyAmount(
                  currency: 'USD',
                  incomeAmount: '0',
                  expenseAmount: '22900',
                ),
              ],
            ),
            thisWeek: TransactionAmountPeriod(
              startTime: 1000,
              endTime: 2000,
              amounts: [
                TransactionCurrencyAmount(
                  currency: 'EUR',
                  incomeAmount: '0',
                  expenseAmount: '12100',
                ),
                TransactionCurrencyAmount(
                  currency: 'USD',
                  incomeAmount: '0',
                  expenseAmount: '49800',
                ),
              ],
            ),
            thisMonth: TransactionAmountPeriod(
              startTime: 1000,
              endTime: 2000,
              amounts: [
                TransactionCurrencyAmount(
                  currency: 'USD',
                  incomeAmount: '620000',
                  expenseAmount: '541348',
                ),
              ],
            ),
            thisYear: TransactionAmountPeriod(
              startTime: 1000,
              endTime: 2000,
              amounts: [
                TransactionCurrencyAmount(
                  currency: 'USD',
                  incomeAmount: '620000',
                  expenseAmount: '541348',
                ),
              ],
            ),
          ),
    );
  }
}

class FakeHomeRemoteDataSource implements HomeRemoteDataSource {
  FakeHomeRemoteDataSource({this.responseToReturn, this.errorToThrow});

  TransactionAmountsResponseModel? responseToReturn;
  Exception? errorToThrow;

  @override
  Future<TransactionAmountsResponseModel> getTransactionAmounts({
    int firstDayOfWeek = 0,
    DateTime? now,
    bool useTransactionTimezone = false,
  }) async {
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    return responseToReturn ??
        const TransactionAmountsResponseModel(
          success: true,
          result: TransactionAmountsModel(
            today: TransactionAmountPeriodModel(
              startTime: 1789497000,
              endTime: 1789583399,
              amounts: [
                TransactionCurrencyAmountModel(
                  currency: 'USD',
                  incomeAmount: '0',
                  expenseAmount: '22900',
                ),
              ],
            ),
            thisWeek: TransactionAmountPeriodModel(
              startTime: 1789237800,
              endTime: 1789842599,
              amounts: [
                TransactionCurrencyAmountModel(
                  currency: 'EUR',
                  incomeAmount: '0',
                  expenseAmount: '12100',
                ),
                TransactionCurrencyAmountModel(
                  currency: 'USD',
                  incomeAmount: '0',
                  expenseAmount: '49800',
                ),
              ],
            ),
            thisMonth: TransactionAmountPeriodModel(
              startTime: 1788201000,
              endTime: 1790792999,
              amounts: [
                TransactionCurrencyAmountModel(
                  currency: 'USD',
                  incomeAmount: '620000',
                  expenseAmount: '541348',
                ),
              ],
            ),
            thisYear: TransactionAmountPeriodModel(
              startTime: 1767205800,
              endTime: 1798741799,
              amounts: [
                TransactionCurrencyAmountModel(
                  currency: 'USD',
                  incomeAmount: '620000',
                  expenseAmount: '541348',
                ),
              ],
            ),
          ),
        );
  }
}

void main() {
  group('Transaction Time Range Builder Tests', () {
    final fixedDateTime = DateTime(2026, 9, 16, 14, 30, 0); // Wednesday

    test('getTodayRange generates start and end of day', () {
      final range = TransactionTimeRangeBuilder.getTodayRange(fixedDateTime);
      final start = DateTime.fromMillisecondsSinceEpoch(range.$1 * 1000);
      final end = DateTime.fromMillisecondsSinceEpoch(range.$2 * 1000);

      expect(start.year, equals(2026));
      expect(start.month, equals(9));
      expect(start.day, equals(16));
      expect(start.hour, equals(0));
      expect(start.minute, equals(0));
      expect(start.second, equals(0));

      expect(end.day, equals(16));
      expect(end.hour, equals(23));
      expect(end.minute, equals(59));
      expect(end.second, equals(59));
    });

    test('getWeekRange calculates week from Sunday (firstDayOfWeek: 0)', () {
      final range = TransactionTimeRangeBuilder.getWeekRange(
        fixedDateTime,
        firstDayOfWeek: 0,
      );
      final start = DateTime.fromMillisecondsSinceEpoch(range.$1 * 1000);
      final end = DateTime.fromMillisecondsSinceEpoch(range.$2 * 1000);

      // Sept 16, 2026 is Wed. Sunday of that week was Sept 13. Saturday is Sept 19.
      expect(start.day, equals(13));
      expect(end.day, equals(19));
    });

    test('getWeekRange calculates week from Monday (firstDayOfWeek: 1)', () {
      final range = TransactionTimeRangeBuilder.getWeekRange(
        fixedDateTime,
        firstDayOfWeek: 1,
      );
      final start = DateTime.fromMillisecondsSinceEpoch(range.$1 * 1000);
      final end = DateTime.fromMillisecondsSinceEpoch(range.$2 * 1000);

      // Monday was Sept 14. Sunday is Sept 20.
      expect(start.day, equals(14));
      expect(end.day, equals(20));
    });

    test('getMonthRange calculates full month', () {
      final range = TransactionTimeRangeBuilder.getMonthRange(fixedDateTime);
      final start = DateTime.fromMillisecondsSinceEpoch(range.$1 * 1000);
      final end = DateTime.fromMillisecondsSinceEpoch(range.$2 * 1000);

      expect(start.day, equals(1));
      expect(end.day, equals(30)); // Sept has 30 days
    });

    test('getYearRange calculates full year', () {
      final range = TransactionTimeRangeBuilder.getYearRange(fixedDateTime);
      final start = DateTime.fromMillisecondsSinceEpoch(range.$1 * 1000);
      final end = DateTime.fromMillisecondsSinceEpoch(range.$2 * 1000);

      expect(start.month, equals(1));
      expect(start.day, equals(1));
      expect(end.month, equals(12));
      expect(end.day, equals(31));
    });

    test('buildAmountsQuery builds correct composite query parameter', () {
      final query = TransactionTimeRangeBuilder.buildAmountsQuery(
        now: fixedDateTime,
        firstDayOfWeek: 0,
      );
      expect(query, contains('today_'));
      expect(query, contains('thisWeek_'));
      expect(query, contains('thisMonth_'));
      expect(query, contains('thisYear_'));
      expect(query.split('|').length, equals(4));
    });
  });

  group('MoneyFormatter Tests', () {
    test(
      'formats cents and integer values safely without floating point inaccuracies',
      () {
        expect(
          MoneyFormatter.format('22900', currency: 'USD'),
          equals(r'$ 229.00'),
        );
        expect(
          MoneyFormatter.format('541348', currency: 'USD'),
          equals(r'$ 5,413.48'),
        );
        expect(
          MoneyFormatter.format('620000', currency: 'USD'),
          equals(r'$ 6,200.00'),
        );
        expect(MoneyFormatter.format('0', currency: 'USD'), equals(r'$ 0.00'));
        expect(
          MoneyFormatter.format('12100', currency: 'EUR'),
          equals('€ 121.00'),
        );
      },
    );

    test('formats negative amounts and decimals gracefully', () {
      expect(
        MoneyFormatter.format('-22900', currency: 'USD'),
        equals(r'-$ 229.00'),
      );
      expect(
        MoneyFormatter.format('150.50', currency: 'USD'),
        equals(r'$ 150.50'),
      );
    });
  });

  group('Transaction Amounts Models & Entities Tests', () {
    final sampleResponseJson = {
      'result': {
        'today': {
          'startTime': 1789497000,
          'endTime': 1789583399,
          'amounts': [
            {'currency': 'USD', 'incomeAmount': '0', 'expenseAmount': '22900'},
          ],
        },
        'thisWeek': {
          'startTime': 1789237800,
          'endTime': 1789842599,
          'amounts': [
            {'currency': 'EUR', 'incomeAmount': '0', 'expenseAmount': '12100'},
            {'currency': 'USD', 'incomeAmount': '0', 'expenseAmount': '49800'},
          ],
        },
        'thisMonth': {
          'startTime': 1788201000,
          'endTime': 1790792999,
          'amounts': [
            {'currency': 'EUR', 'incomeAmount': '0', 'expenseAmount': '17450'},
            {
              'currency': 'USD',
              'incomeAmount': '620000',
              'expenseAmount': '541348',
            },
          ],
        },
        'thisYear': {
          'startTime': 1767205800,
          'endTime': 1798741799,
          'amounts': [
            {
              'currency': 'USD',
              'incomeAmount': '620000',
              'expenseAmount': '541348',
            },
          ],
        },
      },
      'success': true,
    };

    test(
      'TransactionAmountsResponseModel correctly parses response and multi-currency amounts',
      () {
        final responseModel = TransactionAmountsResponseModel.fromJson(
          sampleResponseJson,
        );
        expect(responseModel.success, isTrue);
        expect(responseModel.result, isNotNull);

        final result = responseModel.result!;
        expect(result.today.amounts.length, equals(1));
        expect(result.today.amounts.first.currency, equals('USD'));
        expect(result.today.amounts.first.expenseAmount, equals('22900'));

        expect(result.thisWeek.amounts.length, equals(2));
        expect(result.thisWeek.amounts[0].currency, equals('EUR'));
        expect(result.thisWeek.amounts[1].currency, equals('USD'));

        final entity = result.toEntity();
        expect(entity.today.amounts.first.currency, equals('USD'));
        expect(entity.thisWeek.amounts.length, equals(2));
        expect(entity.thisMonth.amounts.length, equals(2));
      },
    );

    test(
      'handles empty and null amounts lists gracefully without crashing',
      () {
        final emptyResponse = TransactionAmountsResponseModel.fromJson({
          'success': true,
          'result': {
            'today': {'startTime': 0, 'endTime': 0, 'amounts': []},
            'thisWeek': {'startTime': 0, 'endTime': 0, 'amounts': []},
            'thisMonth': {'startTime': 0, 'endTime': 0, 'amounts': []},
            'thisYear': {'startTime': 0, 'endTime': 0, 'amounts': []},
          },
        });

        expect(emptyResponse.success, isTrue);
        final entity = emptyResponse.result!.toEntity();
        expect(entity.today.amounts, isEmpty);
      },
    );
  });

  group('HomeRemoteDataSource Tests', () {
    late Dio dio;
    late MockHttpAdapter mockAdapter;
    late HomeRemoteDataSource dataSource;

    setUp(() {
      dio = Dio(
        BaseOptions(baseUrl: 'https://ezbookkeeping-demo.mayswind.net'),
      );
      mockAdapter = MockHttpAdapter();
      dio.httpClientAdapter = mockAdapter;
      dataSource = HomeRemoteDataSourceImpl(dio: dio);
    });

    test(
      'getTransactionAmounts makes GET to /api/v1/transactions/amounts.json with query parameters',
      () async {
        mockAdapter.handler = (options) async {
          expect(options.path, equals(ApiEndpoints.transactionAmounts));
          expect(options.method, equals('GET'));
          expect(options.queryParameters['use_transaction_timezone'], isFalse);
          expect(options.queryParameters['query'], contains('today_'));
          expect(options.queryParameters['query'], contains('thisWeek_'));

          return ResponseBody.fromString(
            jsonEncode({
              'success': true,
              'result': {
                'today': {'startTime': 100, 'endTime': 200, 'amounts': []},
                'thisWeek': {'startTime': 100, 'endTime': 200, 'amounts': []},
                'thisMonth': {'startTime': 100, 'endTime': 200, 'amounts': []},
                'thisYear': {'startTime': 100, 'endTime': 200, 'amounts': []},
              },
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        final response = await dataSource.getTransactionAmounts();
        expect(response.success, isTrue);
        expect(response.result, isNotNull);
      },
    );
  });

  group('HomeRepositoryImpl Tests', () {
    late FakeHomeRemoteDataSource fakeRemoteDataSource;
    late HomeRepository repository;

    setUp(() {
      fakeRemoteDataSource = FakeHomeRemoteDataSource();
      repository = HomeRepositoryImpl(remoteDataSource: fakeRemoteDataSource);
    });

    test(
      'getTransactionAmounts returns TransactionAmounts domain entity on success',
      () async {
        final result = await repository.getTransactionAmounts();
        expect(result.isRight(), isTrue);
        final amounts = result.getOrElse(() => throw Exception());
        expect(amounts.today.amounts.length, equals(1));
        expect(amounts.thisWeek.amounts.length, equals(2));
        expect(amounts.thisWeek.amounts[0].currency, equals('EUR'));
        expect(amounts.thisWeek.amounts[1].currency, equals('USD'));
      },
    );

    test(
      'returns Left(ServerFailure) when success is false or result is null',
      () async {
        fakeRemoteDataSource.responseToReturn =
            const TransactionAmountsResponseModel(success: false, result: null);

        final result = await repository.getTransactionAmounts();
        expect(result.isLeft(), isTrue);
      },
    );
  });

  group('GetTransactionAmounts Use Case Tests', () {
    late FakeHomeRepository fakeRepository;
    late GetTransactionAmounts useCase;

    setUp(() {
      fakeRepository = FakeHomeRepository();
      useCase = GetTransactionAmounts(fakeRepository);
    });

    test('delegates parameters and returns TransactionAmounts', () async {
      final fixedDate = DateTime(2026, 9, 16);
      final result = await useCase(
        firstDayOfWeek: 1,
        now: fixedDate,
        useTransactionTimezone: true,
      );

      expect(result.isRight(), isTrue);
      final amounts = result.getOrElse(() => throw Exception());
      expect(amounts.today.amounts.length, equals(1));
      expect(fakeRepository.lastFirstDayOfWeek, equals(1));
      expect(fakeRepository.lastNow, equals(fixedDate));
      expect(fakeRepository.lastUseTransactionTimezone, isTrue);
    });
  });

  group('HomeBloc Tests', () {
    late FakeHomeRepository fakeRepository;
    late GetTransactionAmounts useCase;
    late HomeBloc bloc;

    setUp(() {
      fakeRepository = FakeHomeRepository();
      useCase = GetTransactionAmounts(fakeRepository);
      bloc = HomeBloc(getTransactionAmounts: useCase);
    });

    tearDown(() async {
      await bloc.close();
    });

    test('initial state is HomeInitial', () {
      expect(bloc.state, isA<HomeInitial>());
    });

    test(
      'LoadTransactionAmounts emits HomeLoading then HomeLoaded on success',
      () async {
        final states = <HomeState>[];
        final subscription = bloc.stream.listen(states.add);

        bloc.add(const LoadTransactionAmounts());

        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(states, [
          isA<HomeLoading>(),
          isA<HomeLoaded>().having(
            (s) => s.amounts.thisWeek.amounts.length,
            'multi-currency week amounts count',
            equals(2),
          ),
        ]);
        expect(bloc.state, isA<HomeLoaded>());

        await subscription.cancel();
      },
    );

    test(
      'LoadTransactionAmounts emits HomeLoading then HomeError on failure',
      () async {
        fakeRepository.failureToReturn = const NetworkFailure(
          'Network connection failed',
        );

        final states = <HomeState>[];
        final subscription = bloc.stream.listen(states.add);

        bloc.add(const LoadTransactionAmounts());

        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(states, [
          isA<HomeLoading>(),
          isA<HomeError>().having(
            (s) => s.message,
            'message',
            equals('Network connection failed'),
          ),
        ]);
        expect(bloc.state, isA<HomeError>());

        await subscription.cancel();
      },
    );
  });

  group('GetIt Home Dependency Registration Tests', () {
    setUp(() async {
      await getIt.reset();
    });

    tearDown(() async {
      await getIt.reset();
    });

    test(
      'setupDependencies registers and resolves Home dependencies correctly',
      () async {
        final customDio = Dio(
          BaseOptions(baseUrl: 'https://ezbookkeeping-demo.mayswind.net'),
        );

        await setupDependencies(dio: customDio);

        expect(getIt<HomeRemoteDataSource>(), isNotNull);
        expect(getIt<HomeRepository>(), isNotNull);
        expect(getIt<GetTransactionAmounts>(), isNotNull);

        // Verify HomeBloc is registered as a factory (distinct instances created)
        final bloc1 = getIt<HomeBloc>();
        final bloc2 = getIt<HomeBloc>();
        expect(bloc1, isNotNull);
        expect(bloc2, isNotNull);
        expect(identical(bloc1, bloc2), isFalse);

        await bloc1.close();
        await bloc2.close();
      },
    );
  });
}
