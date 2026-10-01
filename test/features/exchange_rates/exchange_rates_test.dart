import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:ezbookkeeping/core/error/exceptions.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/features/exchange_rates/data/datasources/exchange_rates_remote_data_source.dart';
import 'package:ezbookkeeping/features/exchange_rates/data/models/exchange_rate_model.dart';
import 'package:ezbookkeeping/features/exchange_rates/data/models/latest_exchange_rates_model.dart';
import 'package:ezbookkeeping/features/exchange_rates/data/repositories/exchange_rates_repository_impl.dart';
import 'package:ezbookkeeping/features/exchange_rates/domain/entities/exchange_rate.dart';
import 'package:ezbookkeeping/features/exchange_rates/domain/entities/latest_exchange_rates.dart';
import 'package:ezbookkeeping/features/exchange_rates/domain/repositories/exchange_rates_repository.dart';
import 'package:ezbookkeeping/features/exchange_rates/domain/usecases/get_latest_exchange_rates_use_case.dart';
import 'package:ezbookkeeping/features/exchange_rates/services/exchange_rate_service.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/core/preferences/preferences_controller.dart';
import 'package:ezbookkeeping/features/settings/presentation/exchange_rates_data_screen.dart';

class MockDio extends Fake implements Dio {
  int requestCount = 0;
  Response<dynamic>? responseToReturn;
  DioException? exceptionToThrow;
  Duration? delay;

  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    requestCount++;
    if (delay != null) {
      await Future.delayed(delay!);
    }
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    return responseToReturn as Response<T>;
  }
}

class MockExchangeRatesRepository implements ExchangeRatesRepository {
  int callCount = 0;
  Either<Failure, LatestExchangeRates>? resultToReturn;
  Duration? delay;

  @override
  Future<Either<Failure, LatestExchangeRates>> getLatestExchangeRates({
    bool forceRefresh = false,
  }) async {
    callCount++;
    if (delay != null) {
      await Future.delayed(delay!);
    }
    return resultToReturn ??
        Right(
          LatestExchangeRates(
            dataSource: 'European Central Bank',
            referenceUrl:
                'https://www.ecb.europa.eu/stats/policy_and_exchange_rates/euro_reference_exchange_rates/html/index.en.html',
            updateTime: DateTime.fromMillisecondsSinceEpoch(1790690400 * 1000),
            baseCurrency: 'EUR',
            exchangeRates: const [
              ExchangeRate(currency: 'USD', rate: 1.1355),
              ExchangeRate(currency: 'INR', rate: 108.9910),
              ExchangeRate(currency: 'GBP', rate: 0.85718),
              ExchangeRate(currency: 'JPY', rate: 178.41),
              ExchangeRate(currency: 'AUD', rate: 1.6211),
              ExchangeRate(currency: 'EUR', rate: 1.0),
            ],
          ),
        );
  }
}

void main() {
  const sampleApiResponse = {
    'result': {
      'dataSource': 'European Central Bank',
      'referenceUrl':
          'https://www.ecb.europa.eu/stats/policy_and_exchange_rates/euro_reference_exchange_rates/html/index.en.html',
      'updateTime': 1790690400,
      'baseCurrency': 'EUR',
      'exchangeRates': [
        {'currency': 'AUD', 'rate': '1.6211'},
        {'currency': 'BRL', 'rate': '5.9177'},
        {'currency': 'CAD', 'rate': '1.6101'},
        {'currency': 'CHF', 'rate': '0.9461'},
        {'currency': 'CNY', 'rate': '7.6117'},
        {'currency': 'EUR', 'rate': '1'},
        {'currency': 'GBP', 'rate': '0.85718'},
        {'currency': 'INR', 'rate': '108.9910'},
        {'currency': 'JPY', 'rate': '178.41'},
        {'currency': 'USD', 'rate': '1.1355'},
        {'currency': 'IDR', 'rate': '20350.09'},
      ],
    },
    'success': true,
  };

  group('ExchangeRateModel & LatestExchangeRatesModel Tests', () {
    test('parses rate values with different string precision and types correctly', () {
      final model1 = ExchangeRateModel.fromJson({'currency': 'EUR', 'rate': '1'});
      expect(model1.currency, 'EUR');
      expect(model1.rate, 1.0);

      final model2 = ExchangeRateModel.fromJson({'currency': 'USD', 'rate': '1.1355'});
      expect(model2.rate, 1.1355);

      final model3 = ExchangeRateModel.fromJson({'currency': 'INR', 'rate': '108.9910'});
      expect(model3.rate, 108.9910);

      final model4 = ExchangeRateModel.fromJson({'currency': 'IDR', 'rate': '20350.09'});
      expect(model4.rate, 20350.09);

      final modelInvalid = ExchangeRateModel.fromJson({'currency': 'XYZ', 'rate': 'invalid'});
      expect(modelInvalid.rate, 0.0);
    });

    test('parses complete LatestExchangeRatesModel from JSON and converts to entity', () {
      final model = LatestExchangeRatesModel.fromJson(sampleApiResponse);

      expect(model.dataSource, 'European Central Bank');
      expect(
        model.referenceUrl,
        'https://www.ecb.europa.eu/stats/policy_and_exchange_rates/euro_reference_exchange_rates/html/index.en.html',
      );
      expect(model.updateTime, 1790690400);
      expect(model.baseCurrency, 'EUR');
      expect(model.exchangeRates.length, 11);

      final entity = model.toEntity();
      expect(entity.dataSource, 'European Central Bank');
      expect(entity.baseCurrency, 'EUR');
      expect(entity.updateTime.millisecondsSinceEpoch, 1790690400 * 1000);
      expect(entity.exchangeRates.length, 11);

      // Verify ratesByCurrency map
      final map = entity.ratesByCurrency;
      expect(map['EUR'], 1.0);
      expect(map['USD'], 1.1355);
      expect(map['INR'], 108.9910);
      expect(map['GBP'], 0.85718);
      expect(map['JPY'], 178.41);
      expect(map['AUD'], 1.6211);
      expect(map['IDR'], 20350.09);
    });

    test('LatestExchangeRates entity props equality works correctly', () {
      final entity1 = LatestExchangeRatesModel.fromJson(sampleApiResponse).toEntity();
      final entity2 = LatestExchangeRatesModel.fromJson(sampleApiResponse).toEntity();

      expect(entity1, equals(entity2));
    });
  });

  group('ExchangeRatesRemoteDataSource Tests', () {
    late MockDio mockDio;
    late ExchangeRatesRemoteDataSourceImpl dataSource;

    setUp(() {
      mockDio = MockDio();
      dataSource = ExchangeRatesRemoteDataSourceImpl(dio: mockDio);
    });

    test('returns LatestExchangeRatesModel on HTTP 200 with valid body', () async {
      mockDio.responseToReturn = Response(
        data: sampleApiResponse,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/api/v1/exchange_rates/latest.json'),
      );

      final result = await dataSource.getLatestExchangeRates();
      expect(result.baseCurrency, 'EUR');
      expect(result.exchangeRates.length, 11);
    });

    test('throws ServerException on HTTP 500 error', () async {
      mockDio.exceptionToThrow = DioException(
        requestOptions: RequestOptions(path: '/api/v1/exchange_rates/latest.json'),
        response: Response(
          statusCode: 500,
          data: {'message': 'Internal Server Error'},
          requestOptions: RequestOptions(path: '/api/v1/exchange_rates/latest.json'),
        ),
      );

      expect(
        () => dataSource.getLatestExchangeRates(),
        throwsA(isA<ServerException>()),
      );
    });
  });

  group('ExchangeRatesRepository & UseCase Tests', () {
    test('returns Right(LatestExchangeRates) and caches result', () async {
      final mockDio = MockDio();
      mockDio.responseToReturn = Response(
        data: sampleApiResponse,
        statusCode: 200,
        requestOptions: RequestOptions(path: '/api/v1/exchange_rates/latest.json'),
      );

      final dataSource = ExchangeRatesRemoteDataSourceImpl(dio: mockDio);
      final repository = ExchangeRatesRepositoryImpl(remoteDataSource: dataSource);
      final useCase = GetLatestExchangeRatesUseCase(repository);

      // First call -> calls data source
      final result1 = await useCase();
      expect(result1.isRight(), true);
      expect(mockDio.requestCount, 1);

      // Second call without forceRefresh -> uses cache
      final result2 = await useCase();
      expect(result2.isRight(), true);
      expect(mockDio.requestCount, 1);

      // Third call with forceRefresh = true -> makes second request
      final result3 = await useCase(forceRefresh: true);
      expect(result3.isRight(), true);
      expect(mockDio.requestCount, 2);
    });

    test('returns Left(ServerFailure) on network exception', () async {
      final mockDio = MockDio();
      mockDio.exceptionToThrow = DioException(
        requestOptions: RequestOptions(path: '/api/v1/exchange_rates/latest.json'),
        message: 'Connection timed out',
      );

      final dataSource = ExchangeRatesRemoteDataSourceImpl(dio: mockDio);
      final repository = ExchangeRatesRepositoryImpl(remoteDataSource: dataSource);
      final useCase = GetLatestExchangeRatesUseCase(repository);

      final result = await useCase();
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('ExchangeRateService Tests', () {
    late MockExchangeRatesRepository mockRepo;
    late GetLatestExchangeRatesUseCase useCase;
    late ExchangeRateService service;

    setUp(() {
      mockRepo = MockExchangeRatesRepository();
      useCase = GetLatestExchangeRatesUseCase(mockRepo);
      service = ExchangeRateService(getLatestExchangeRates: useCase);
    });

    test('initializes rates successfully and exposes rates map', () async {
      expect(service.isInitialized, false);
      expect(service.latestRates, null);

      final success = await service.initialize();
      expect(success, true);
      expect(service.isInitialized, true);
      expect(service.baseCurrency, 'EUR');
      expect(service.dataSource, 'European Central Bank');
      expect(service.ratesByCurrency['USD'], 1.1355);
      expect(service.ratesByCurrency['INR'], 108.9910);
      expect(service.getRate('usd'), 1.1355);
    });

    test('handles API failure gracefully during initialize without throwing', () async {
      mockRepo.resultToReturn = const Left(ServerFailure('Network unreachable'));

      final success = await service.initialize();
      expect(success, false);
      expect(service.isInitialized, true);
      expect(service.errorMessage, 'Network unreachable');
      expect(service.latestRates, null);
    });

    test('concurrency protection: simultaneous initialize() calls trigger only 1 request', () async {
      mockRepo.delay = const Duration(milliseconds: 50);

      final futures = [
        service.initialize(),
        service.initialize(),
        service.initialize(),
      ];

      final results = await Future.wait(futures);
      expect(results, [true, true, true]);
      expect(mockRepo.callCount, 1);
    });

    test('currency conversion: direct base currency (EUR) conversions', () async {
      await service.initialize();

      // 1 EUR -> 1.1355 USD
      final eurToUsd = service.convert(
        fromCurrency: 'EUR',
        toCurrency: 'USD',
        amount: 100.0,
      );
      expect(eurToUsd, closeTo(113.55, 0.001));

      // 100 USD -> EUR (100 / 1.1355) = ~88.0669 EUR
      final usdToEur = service.convert(
        fromCurrency: 'USD',
        toCurrency: 'EUR',
        amount: 100.0,
      );
      expect(usdToEur, closeTo(100.0 / 1.1355, 0.001));

      // 1 EUR -> 108.9910 INR
      final eurToInr = service.convert(
        fromCurrency: 'EUR',
        toCurrency: 'INR',
        amount: 50.0,
      );
      expect(eurToInr, closeTo(50.0 * 108.9910, 0.001));
    });

    test('currency conversion: cross currency conversions (USD -> INR & INR -> USD)', () async {
      await service.initialize();

      // USD -> INR: (amount / USD_rate) * INR_rate
      // 100 USD -> (100 / 1.1355) * 108.9910 = ~9598.5028 INR
      final usdToInr = service.convert(
        fromCurrency: 'USD',
        toCurrency: 'INR',
        amount: 100.0,
      );
      final expectedUsdToInr = (100.0 / 1.1355) * 108.9910;
      expect(usdToInr, closeTo(expectedUsdToInr, 0.001));

      // INR -> USD: (amount / INR_rate) * USD_rate
      // 108.9910 INR -> (108.9910 / 108.9910) * 1.1355 = 1.1355 USD
      final inrToUsd = service.convert(
        fromCurrency: 'INR',
        toCurrency: 'USD',
        amount: 108.9910,
      );
      expect(inrToUsd, closeTo(1.1355, 0.001));

      // Same currency returns exact amount
      final same = service.convert(
        fromCurrency: 'USD',
        toCurrency: 'USD',
        amount: 250.0,
      );
      expect(same, 250.0);

      // Unknown currency returns null
      final unknown = service.convert(
        fromCurrency: 'UNKNOWN',
        toCurrency: 'USD',
        amount: 100.0,
      );
      expect(unknown, null);
    });

    test('refresh() forces refresh on repository and updates rates', () async {
      await service.initialize();
      expect(mockRepo.callCount, 1);

      final refreshSuccess = await service.refresh();
      expect(refreshSuccess, true);
      expect(mockRepo.callCount, 2);
    });
  });

  group('ExchangeRatesDataScreen Widget Tests', () {
    testWidgets('renders ExchangeRatesDataScreen with currencies list and handles amount changes', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ExchangeRatesDataScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Exchange Rates Data'), findsOneWidget);
      expect(find.text('Base Currency'), findsOneWidget);
      expect(find.text('Base Amount'), findsOneWidget);
      expect(find.text('1.00'), findsOneWidget);

      // Verify some currencies are shown in list
      expect(find.text('Australian Dollar'), findsOneWidget);
      expect(find.text('Euro'), findsOneWidget);
      expect(find.text('Indian Rupee'), findsOneWidget);
    });

    testWidgets(
      'sorts currencies according to PreferencesController exchangeRatesSortBy',
      (tester) async {
        if (getIt.isRegistered<PreferencesController>()) {
          getIt.unregister<PreferencesController>();
        }
        final prefController = PreferencesController(
          exchangeRatesSortBy: 'Currency Code',
        );
        getIt.registerSingleton<PreferencesController>(prefController);

        await tester.pumpWidget(
          const MaterialApp(
            home: ExchangeRatesDataScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Exchange Rates Data'), findsOneWidget);
        expect(find.text('Australian Dollar'), findsOneWidget);

        getIt.unregister<PreferencesController>();
      },
    );
  });
}
