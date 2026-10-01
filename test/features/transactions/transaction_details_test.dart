import 'dart:convert';
import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/core/network/api_endpoints.dart';
import 'package:ezbookkeeping/features/transactions/data/datasources/transaction_remote_data_source.dart';
import 'package:ezbookkeeping/features/transactions/data/models/transaction_details_response_model.dart';
import 'package:ezbookkeeping/features/transactions/data/models/transaction_list_request.dart';
import 'package:ezbookkeeping/features/transactions/data/models/transaction_model.dart';
import 'package:ezbookkeeping/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:ezbookkeeping/features/transactions/domain/entities/transaction.dart';
import 'package:ezbookkeeping/features/transactions/domain/entities/transaction_list_result.dart';
import 'package:ezbookkeeping/features/transactions/domain/entities/transaction_picture_info.dart';
import 'package:ezbookkeeping/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:ezbookkeeping/features/transactions/domain/usecases/get_transaction_details.dart';
import 'package:ezbookkeeping/features/transactions/domain/usecases/get_transactions.dart';
import 'package:ezbookkeeping/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:ezbookkeeping/features/transactions/presentation/bloc/transaction_details_bloc.dart';
import 'package:ezbookkeeping/features/transactions/presentation/bloc/transaction_details_event.dart';
import 'package:ezbookkeeping/features/transactions/presentation/bloc/transaction_details_state.dart';
import 'package:ezbookkeeping/features/transactions/presentation/transaction_details_screen.dart';
import 'package:ezbookkeeping/features/transactions/presentation/transaction_list_screen.dart';

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
        'result': {
          'id': '3843885841436901429',
          'timeSequenceId': '1790644217000',
          'type': 3,
          'categoryId': '3843885835128668182',
          'time': 1790644217,
          'utcOffset': -300,
          'sourceAccountId': '3843885834860232708',
          'sourceAmount': 16000,
          'hideAmount': false,
          'tagIds': ['1', '2'],
          'comment': 'gas bill',
          'editable': true,
          'pictures': [
            {'id': 'pic_1', 'originalUrl': 'https://example.com/pic1.jpg'},
          ],
        },
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

class FakeDetailsTransactionRepository implements TransactionRepository {
  FakeDetailsTransactionRepository({
    this.transactionToReturn,
    this.failureToReturn,
  });

  Transaction? transactionToReturn;
  Failure? failureToReturn;
  String? lastTransactionId;

  @override
  Future<Either<Failure, TransactionListResult>> getTransactions([
    TransactionListRequest? request,
  ]) async {
    return const Right(
      TransactionListResult(
        items: [
          Transaction(
            id: '3843885841436901429',
            timeSequenceId: '1790644217000',
            type: 3,
            categoryId: '1',
            time: 1789984800,
            utcOffset: -300,
            sourceAccountId: '3843885834860232704',
            sourceAmount: 16000,
            comment: 'gas bill',
          ),
        ],
        nextTimeSequenceId: '0',
      ),
    );
  }

  @override
  Future<Either<Failure, Transaction>> getTransactionById(String id) async {
    lastTransactionId = id;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(
      transactionToReturn ??
          const Transaction(
            id: '3843885841436901429',
            timeSequenceId: '1790644217000',
            type: 3,
            categoryId: '3843885835128668182',
            categoryName: 'Housing & Houseware > Utilities Expense',
            time: 1790644217,
            utcOffset: -300,
            sourceAccountId: '3843885834860232708',
            sourceAmount: 16000,
            hideAmount: false,
            tagIds: ['1', '2'],
            comment: 'gas bill',
            editable: true,
            pictures: [
              TransactionPictureInfo(
                id: 'pic_1',
                originalUrl: 'https://example.com/pic1.jpg',
              ),
            ],
          ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final Map<String, dynamic> sampleDetailsJson = {
    'success': true,
    'result': {
      'id': '3843885841436901429',
      'timeSequenceId': '1790644217000',
      'type': 3,
      'categoryId': '3843885835128668182',
      'time': 1790644217,
      'utcOffset': -300,
      'sourceAccountId': '3843885834860232708',
      'sourceAmount': 16000,
      'destinationAccountId': '3843885834860232709',
      'destinationAmount': 16000,
      'hideAmount': false,
      'tagIds': ['1'],
      'comment': 'gas bill',
      'editable': true,
      'pictures': [
        {'id': 'pic_1', 'originalUrl': 'https://example.com/pic1.jpg'},
      ],
    },
  };

  group('Transaction Details Model Tests', () {
    test('TransactionDetailsResponseModel parses correctly from json', () {
      final model = TransactionDetailsResponseModel.fromJson(sampleDetailsJson);
      expect(model.success, isTrue);
      expect(model.result, isNotNull);

      final tx = model.result!;
      expect(tx.id, equals('3843885841436901429'));
      expect(tx.type, equals(3));
      expect(tx.categoryId, equals('3843885835128668182'));
      expect(tx.time, equals(1790644217));
      expect(tx.utcOffset, equals(-300));
      expect(tx.sourceAccountId, equals('3843885834860232708'));
      expect(tx.sourceAmount, equals(16000));
      expect(tx.destinationAccountId, equals('3843885834860232709'));
      expect(tx.destinationAmount, equals(16000));
      expect(tx.hideAmount, isFalse);
      expect(tx.tagIds, equals(['1']));
      expect(tx.comment, equals('gas bill'));
      expect(tx.editable, isTrue);
      expect(tx.pictures.length, equals(1));
      expect(tx.pictures.first.id, equals('pic_1'));
    });

    test(
      'TransactionModel converts to Transaction domain entity correctly',
      () {
        final model = TransactionModel.fromJson(
          sampleDetailsJson['result'] as Map<String, dynamic>,
        );
        final entity = model.toEntity();

        expect(entity.id, equals('3843885841436901429'));
        expect(entity.isExpense, isTrue);
        expect(entity.sourceAmount, equals(16000));
        expect(entity.comment, equals('gas bill'));
        expect(entity.pictures.length, equals(1));
      },
    );

    test('TransactionModel handles null optional fields gracefully', () {
      final json = {
        'id': 'tx_minimal',
        'type': 1,
        'sourceAccountId': 'acc_1',
        'sourceAmount': 500,
      };
      final model = TransactionModel.fromJson(json);
      expect(model.id, equals('tx_minimal'));
      expect(model.destinationAccountId, isNull);
      expect(model.destinationAmount, isNull);
      expect(model.pictures, isEmpty);
      expect(model.tagIds, isEmpty);
    });
  });

  group('Transaction Remote Data Source Tests', () {
    late Dio dio;
    late MockHttpAdapter mockAdapter;
    late TransactionRemoteDataSourceImpl dataSource;

    setUp(() {
      mockAdapter = MockHttpAdapter();
      dio = Dio(BaseOptions(baseUrl: 'https://test.api.ezbookkeeping.net'));
      dio.httpClientAdapter = mockAdapter;
      dataSource = TransactionRemoteDataSourceImpl(dio: dio);
    });

    test(
      'getTransactionById calls endpoint with required 5 query parameters',
      () async {
        final response = await dataSource.getTransactionById(
          '3843885841436901429',
        );

        expect(response.success, isTrue);
        expect(response.result?.id, equals('3843885841436901429'));

        final options = mockAdapter.lastRequestOptions;
        expect(options, isNotNull);
        expect(options!.path, equals(ApiEndpoints.transactionGet));
        expect(options.queryParameters['id'], equals('3843885841436901429'));
        expect(options.queryParameters['with_pictures'], isTrue);
        expect(options.queryParameters['trim_account'], isTrue);
        expect(options.queryParameters['trim_category'], isTrue);
        expect(options.queryParameters['trim_tag'], isTrue);
      },
    );
  });

  group('Transaction Repository & UseCase Tests', () {
    late TransactionRepositoryImpl repository;
    late Dio dio;
    late MockHttpAdapter mockAdapter;
    late TransactionRemoteDataSourceImpl remoteDataSource;

    setUp(() {
      mockAdapter = MockHttpAdapter();
      dio = Dio(BaseOptions(baseUrl: 'https://test.api.ezbookkeeping.net'));
      dio.httpClientAdapter = mockAdapter;
      remoteDataSource = TransactionRemoteDataSourceImpl(dio: dio);
      repository = TransactionRepositoryImpl(
        remoteDataSource: remoteDataSource,
      );
    });

    test('getTransactionById returns Transaction entity on success', () async {
      final result = await repository.getTransactionById('12345');
      expect(result.isRight(), isTrue);
      final transaction = result.getOrElse(() => throw Exception());
      expect(transaction.id, equals('3843885841436901429'));
      expect(transaction.comment, equals('gas bill'));
    });

    test(
      'getTransactionById returns Left(ServerFailure) on error response',
      () async {
        mockAdapter.handler = (opts) async {
          return ResponseBody.fromString(
            jsonEncode({'success': false, 'result': null}),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        final result = await repository.getTransactionById('12345');
        expect(result.isLeft(), isTrue);
      },
    );

    test('GetTransactionDetails usecase delegates to repository', () async {
      final fakeRepo = FakeDetailsTransactionRepository();
      final useCase = GetTransactionDetails(fakeRepo);

      final resultEither = await useCase('tx_999');
      expect(fakeRepo.lastTransactionId, equals('tx_999'));
      expect(resultEither.isRight(), isTrue);
      final result = resultEither.getOrElse(() => throw Exception());
      expect(result.id, equals('3843885841436901429'));
    });
  });

  group('TransactionDetailsBloc Tests', () {
    late FakeDetailsTransactionRepository fakeRepo;
    late GetTransactionDetails useCase;
    late TransactionDetailsBloc bloc;

    setUp(() {
      fakeRepo = FakeDetailsTransactionRepository();
      useCase = GetTransactionDetails(fakeRepo);
      bloc = TransactionDetailsBloc(getTransactionDetails: useCase);
    });

    tearDown(() async {
      await bloc.close();
    });

    test('initial state is TransactionDetailsInitial', () {
      expect(bloc.state, isA<TransactionDetailsInitial>());
    });

    test(
      'LoadTransactionDetails emits Loading then Loaded on success',
      () async {
        final states = <TransactionDetailsState>[];
        final subscription = bloc.stream.listen(states.add);

        bloc.add(
          const LoadTransactionDetails(transactionId: '3843885841436901429'),
        );
        await Future.delayed(const Duration(milliseconds: 100));

        expect(states.length, equals(2));
        expect(states[0], isA<TransactionDetailsLoading>());
        expect(states[1], isA<TransactionDetailsLoaded>());

        final loaded = states[1] as TransactionDetailsLoaded;
        expect(loaded.transaction.id, equals('3843885841436901429'));
        expect(loaded.transaction.comment, equals('gas bill'));

        await subscription.cancel();
      },
    );

    test(
      'LoadTransactionDetails emits Loading then Error on failure',
      () async {
        fakeRepo.failureToReturn = const ServerFailure('Transaction not found');
        final states = <TransactionDetailsState>[];
        final subscription = bloc.stream.listen(states.add);

        bloc.add(const LoadTransactionDetails(transactionId: 'invalid_id'));
        await Future.delayed(const Duration(milliseconds: 100));

        expect(states.length, equals(2));
        expect(states[0], isA<TransactionDetailsLoading>());
        expect(states[1], isA<TransactionDetailsError>());

        final error = states[1] as TransactionDetailsError;
        expect(error.message, equals('Transaction not found'));

        await subscription.cancel();
      },
    );
  });

  group('TransactionDetailsScreen Widget Tests', () {
    late FakeDetailsTransactionRepository fakeRepo;
    late GetTransactionDetails useCase;
    late TransactionDetailsBloc bloc;

    setUp(() {
      fakeRepo = FakeDetailsTransactionRepository();
      useCase = GetTransactionDetails(fakeRepo);
      bloc = TransactionDetailsBloc(getTransactionDetails: useCase);
    });

    tearDown(() {
      bloc.close();
    });

    testWidgets(
      'renders loaded transaction details with cards and edit action',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: TransactionDetailsScreen(
              transactionId: '3843885841436901429',
              bloc: bloc,
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        });
        await tester.pump();

        expect(find.text('Transaction Detail'), findsOneWidget);
        expect(find.text('Expense Amount'), findsOneWidget);
        expect(find.text(r'$ 160.00'), findsOneWidget);
        expect(find.text('Housing & Houseware'), findsOneWidget);
        expect(find.text('Utilities Expense'), findsOneWidget);
        expect(find.text('Credit Card'), findsOneWidget);
        expect(find.text('Transaction Time'), findsOneWidget);
        expect(find.text('Transaction Timezone'), findsOneWidget);
        expect(find.text('Geographic Location'), findsOneWidget);
        expect(find.text('gas bill'), findsOneWidget);
        expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);
      },
    );

    testWidgets('renders error state and retries on button tap', (
      tester,
    ) async {
      fakeRepo.failureToReturn = const ServerFailure(
        'Server connection failed',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: TransactionDetailsScreen(
            transactionId: '3843885841436901429',
            bloc: bloc,
          ),
        ),
      );

      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      expect(find.text('Server connection failed'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      // Change repo to return success on retry
      fakeRepo.failureToReturn = null;
      await tester.tap(find.text('Retry'));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      expect(find.text('gas bill'), findsOneWidget);
    });

    testWidgets(
      'tapping transaction item in TransactionListScreen opens TransactionDetailsScreen with transactionId',
      (tester) async {
        if (!getIt.isRegistered<TransactionDetailsBloc>()) {
          getIt.registerFactory<TransactionDetailsBloc>(() => bloc);
        }

        final listBloc = TransactionBloc(
          getTransactions: GetTransactions(fakeRepo),
        );

        await tester.pumpWidget(
          MaterialApp(home: TransactionListScreen(bloc: listBloc)),
        );
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        });
        await tester.pump();

        // Tap the transaction item with comment 'gas bill'
        final itemFinder = find.text('gas bill').first;
        await tester.tap(itemFinder);
        await tester.pump(const Duration(milliseconds: 350));
        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        });
        await tester.pump();

        // Verifies TransactionDetailsScreen is opened
        expect(find.byType(TransactionDetailsScreen), findsOneWidget);
        expect(find.text('Transaction Detail'), findsOneWidget);

        listBloc.close();
      },
    );

    testWidgets('renders fetched category and hierarchy in category section', (
      tester,
    ) async {
      fakeRepo.transactionToReturn = const Transaction(
        id: 'tx_food_custom',
        timeSequenceId: '1790644217001',
        type: 3,
        categoryId: '2',
        categoryName: 'Food',
        time: 1790644217,
        utcOffset: 0,
        sourceAccountId: '3843885834860232704',
        sourceAmount: 2500,
        comment: 'lunch at bistro',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: TransactionDetailsScreen(
            transactionId: 'tx_food_custom',
            bloc: bloc,
          ),
        ),
      );

      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('lunch at bistro'), findsOneWidget);
    });
  });
}
