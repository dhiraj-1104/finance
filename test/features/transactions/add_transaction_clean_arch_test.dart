import 'dart:convert';
import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/core/network/api_endpoints.dart';
import 'package:ezbookkeeping/features/accounts/domain/entities/account.dart';
import 'package:ezbookkeeping/features/accounts/domain/repositories/accounts_repository.dart';
import 'package:ezbookkeeping/features/categories/data/models/add_category_request_model.dart';
import 'package:ezbookkeeping/features/categories/domain/repositories/categories_repository.dart';
import 'package:ezbookkeeping/features/categories/models/category_item.dart';
import 'package:ezbookkeeping/features/home/presentation/add_transaction_screen.dart';
import 'package:ezbookkeeping/features/transactions/data/datasources/transaction_remote_data_source.dart';
import 'package:ezbookkeeping/features/transactions/data/models/add_transaction_request_model.dart';
import 'package:ezbookkeeping/features/transactions/data/models/add_transaction_response_model.dart';
import 'package:ezbookkeeping/features/transactions/data/models/transaction_list_request.dart';
import 'package:ezbookkeeping/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:ezbookkeeping/features/transactions/domain/entities/transaction.dart';
import 'package:ezbookkeeping/features/transactions/domain/entities/transaction_list_result.dart';
import 'package:ezbookkeeping/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:ezbookkeeping/features/transactions/domain/usecases/add_transaction_use_case.dart';
import 'package:ezbookkeeping/features/transactions/domain/usecases/get_transactions.dart';
import 'package:ezbookkeeping/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:ezbookkeeping/features/transactions/presentation/bloc/transaction_event.dart';
import 'package:ezbookkeeping/features/transactions/presentation/bloc/transaction_state.dart';

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
          'id': '3845233750350757888',
          'timeSequenceId': '1790576477000',
          'type': 3,
          'categoryId': '3845184654713815072',
          'time': 1790576477,
          'utcOffset': 330,
          'sourceAccountId': '3845184654445379585',
          'sourceAmount': 52000,
          'hideAmount': false,
          'tagIds': [],
          'comment': '',
          'editable': true,
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

class FakeTransactionRepository implements TransactionRepository {
  FakeTransactionRepository({
    this.resultToReturn,
    this.transactionToReturn,
    this.failureToReturn,
  });

  TransactionListResult? resultToReturn;
  Transaction? transactionToReturn;
  Failure? failureToReturn;
  AddTransactionRequestModel? lastAddRequest;
  TransactionListRequest? lastListRequest;

  @override
  Future<Either<Failure, TransactionListResult>> getTransactions([
    TransactionListRequest? request,
  ]) async {
    lastListRequest = request;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(
      resultToReturn ??
          const TransactionListResult(items: [], nextTimeSequenceId: '0'),
    );
  }

  @override
  Future<Either<Failure, Transaction>> getTransactionById(String id) async {
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(
      transactionToReturn ??
          const Transaction(
            id: '3845233750350757888',
            timeSequenceId: '1790576477000',
            type: 3,
            categoryId: '3845184654713815072',
            time: 1790576477,
            utcOffset: 330,
            sourceAccountId: '3845184654445379585',
            sourceAmount: 52000,
          ),
    );
  }

  @override
  Future<Either<Failure, Transaction>> addTransaction(
    AddTransactionRequestModel request,
  ) async {
    lastAddRequest = request;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(
      transactionToReturn ??
          Transaction(
            id: '3845233750350757888',
            timeSequenceId: '1790576477000',
            type: request.type,
            categoryId: request.categoryId,
            time: request.time,
            utcOffset: request.utcOffset,
            sourceAccountId: request.sourceAccountId,
            sourceAmount: request.sourceAmount,
            comment: request.comment,
            tagIds: request.tagIds,
          ),
    );
  }
}

class _MockCategoriesRepository implements CategoriesRepository {
  final List<CategoryItem> _categories;
  _MockCategoriesRepository([List<CategoryItem>? categories])
    : _categories =
          categories ??
          const [
            CategoryItem(
              id: '3845184654713815072',
              name: 'Food & Drink',
              categoryIconId: '1',
              icon: Icons.restaurant_outlined,
              color: Color(0xFFFF6B22),
              subCategories: [
                CategoryItem(
                  id: '3845184654713815073',
                  name: 'Food',
                  categoryIconId: '2',
                  icon: Icons.dinner_dining_outlined,
                  color: Color(0xFFFF6B22),
                  isPrimary: false,
                  parentId: '3845184654713815072',
                ),
              ],
            ),
          ];

  @override
  Future<Either<Failure, CategoryItem>> addCategory(
    AddCategoryRequestModel request,
  ) async {
    final cat = CategoryItem(
      id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
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
    _categories.add(cat);
    return Right(cat);
  }

  @override
  Future<List<CategoryItem>> getCategories({bool forceRefresh = false}) async =>
      _categories;

  @override
  Future<Map<String, CategoryItem>> getCategoriesMap({
    bool forceRefresh = false,
  }) async => {for (final c in _categories) c.id: c};

  @override
  Future<Map<String, String>> getCategoryNameMap({
    bool forceRefresh = false,
  }) async => {for (final c in _categories) c.id: c.name};

  @override
  void clearCache() {}

  @override
  bool get isCacheValid => true;
}

class _MockAccountsRepository implements AccountsRepository {
  final List<Account> _accounts;
  _MockAccountsRepository([List<Account>? accounts])
    : _accounts = accounts ?? const [];

  @override
  Future<Either<Failure, List<Account>>> getAccounts({
    bool visibleOnly = false,
  }) async {
    return Right(_accounts);
  }

  @override
  Future<Either<Failure, Account>> addAccount(dynamic request) async {
    throw UnimplementedError();
  }
}

void main() {
  group('AddTransactionRequestModel & AddTransactionResponseModel Tests', () {
    test(
      'AddTransactionRequestModel serializes correctly to expected JSON',
      () {
        const request = AddTransactionRequestModel(
          type: 3,
          categoryId: '3845184654713815072',
          time: 1790576477,
          utcOffset: 330,
          sourceAccountId: '3845184654445379585',
          sourceAmount: 52000,
          hideAmount: false,
          tagIds: ['tag_1', 'tag_2'],
          comment: 'Lunch with team',
        );

        final json = request.toJson();

        expect(json['type'], equals(3));
        expect(json['categoryId'], equals('3845184654713815072'));
        expect(json['time'], equals(1790576477));
        expect(json['utcOffset'], equals(330));
        expect(json['sourceAccountId'], equals('3845184654445379585'));
        expect(json['sourceAmount'], equals(52000));
        expect(json['hideAmount'], isFalse);
        expect(json['tagIds'], equals(['tag_1', 'tag_2']));
        expect(json['comment'], equals('Lunch with team'));
      },
    );

    test(
      'AddTransactionRequestModel includes transfer fields when present',
      () {
        const request = AddTransactionRequestModel(
          type: 4,
          categoryId: '0',
          time: 1790576477,
          utcOffset: 330,
          sourceAccountId: 'acc_source',
          sourceAmount: 10000,
          destinationAccountId: 'acc_dest',
          destinationAmount: 10000,
        );

        final json = request.toJson();

        expect(json['type'], equals(4));
        expect(json['destinationAccountId'], equals('acc_dest'));
        expect(json['destinationAmount'], equals(10000));
      },
    );

    test('AddTransactionRequestModel deserializes correctly from JSON', () {
      final json = {
        'type': 3,
        'categoryId': '3845184654713815072',
        'time': 1790576477,
        'utcOffset': 330,
        'sourceAccountId': '3845184654445379585',
        'sourceAmount': 52000,
        'hideAmount': false,
        'tagIds': ['tag_1'],
        'comment': 'Test note',
      };

      final model = AddTransactionRequestModel.fromJson(json);

      expect(model.type, equals(3));
      expect(model.categoryId, equals('3845184654713815072'));
      expect(model.time, equals(1790576477));
      expect(model.utcOffset, equals(330));
      expect(model.sourceAccountId, equals('3845184654445379585'));
      expect(model.sourceAmount, equals(52000));
      expect(model.hideAmount, isFalse);
      expect(model.tagIds, equals(['tag_1']));
      expect(model.comment, equals('Test note'));
    });

    test(
      'AddTransactionResponseModel parses sample response and converts to entity',
      () {
        final sampleResponse = {
          'result': {
            'id': '3845233750350757888',
            'timeSequenceId': '1790576477000',
            'type': 3,
            'categoryId': '3845184654713815072',
            'time': 1790576477,
            'utcOffset': 330,
            'sourceAccountId': '3845184654445379585',
            'sourceAmount': 52000,
            'hideAmount': false,
            'tagIds': [],
            'comment': '',
            'editable': true,
          },
          'success': true,
        };

        final responseModel = AddTransactionResponseModel.fromJson(
          sampleResponse,
        );

        expect(responseModel.success, isTrue);
        expect(responseModel.result, isNotNull);
        expect(responseModel.result!.id, equals('3845233750350757888'));
        expect(responseModel.result!.type, equals(3));
        expect(responseModel.result!.categoryId, equals('3845184654713815072'));
        expect(
          responseModel.result!.sourceAccountId,
          equals('3845184654445379585'),
        );
        expect(responseModel.result!.sourceAmount, equals(52000));

        final entity = responseModel.toEntity();
        expect(entity, isNotNull);
        expect(entity!.id, equals('3845233750350757888'));
        expect(entity.sourceAmount, equals(52000));
      },
    );
  });

  group('Transaction Remote DataSource & Repository Tests', () {
    late Dio dio;
    late MockHttpAdapter mockAdapter;
    late TransactionRemoteDataSource remoteDataSource;
    late TransactionRepository repository;

    setUp(() {
      mockAdapter = MockHttpAdapter();
      dio = Dio(
        BaseOptions(baseUrl: 'https://ezbookkeeping-demo.mayswind.net'),
      );
      dio.httpClientAdapter = mockAdapter;
      remoteDataSource = TransactionRemoteDataSourceImpl(dio: dio);
      repository = TransactionRepositoryImpl(
        remoteDataSource: remoteDataSource,
      );
    });

    test(
      'RemoteDataSource calls addTransaction endpoint with POST data',
      () async {
        mockAdapter.handler = (options) async {
          expect(options.path, equals(ApiEndpoints.addTransaction));
          expect(options.method, equals('POST'));
          expect(options.data['sourceAmount'], equals(52000));
          expect(options.data['categoryId'], equals('3845184654713815072'));

          return ResponseBody.fromString(
            jsonEncode({
              'success': true,
              'result': {
                'id': '3845233750350757888',
                'timeSequenceId': '1790576477000',
                'type': 3,
                'categoryId': '3845184654713815072',
                'time': 1790576477,
                'utcOffset': 330,
                'sourceAccountId': '3845184654445379585',
                'sourceAmount': 52000,
                'hideAmount': false,
                'tagIds': [],
                'comment': '',
                'editable': true,
              },
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        const request = AddTransactionRequestModel(
          type: 3,
          categoryId: '3845184654713815072',
          time: 1790576477,
          utcOffset: 330,
          sourceAccountId: '3845184654445379585',
          sourceAmount: 52000,
        );

        final response = await remoteDataSource.addTransaction(request);
        expect(response.success, isTrue);
        expect(response.result?.id, equals('3845233750350757888'));
      },
    );

    test(
      'Repository addTransaction returns Right(Transaction) on success',
      () async {
        const request = AddTransactionRequestModel(
          type: 3,
          categoryId: '3845184654713815072',
          time: 1790576477,
          utcOffset: 330,
          sourceAccountId: '3845184654445379585',
          sourceAmount: 52000,
        );

        final result = await repository.addTransaction(request);

        expect(result.isRight(), isTrue);
        final transaction = result.getOrElse(() => throw Exception());
        expect(transaction.id, equals('3845233750350757888'));
        expect(transaction.sourceAmount, equals(52000));
      },
    );

    test(
      'Repository addTransaction returns Left(ServerFailure) on failure response',
      () async {
        mockAdapter.handler = (options) async {
          return ResponseBody.fromString(
            jsonEncode({'success': false, 'result': null}),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        const request = AddTransactionRequestModel(
          type: 3,
          categoryId: '3845184654713815072',
          time: 1790576477,
          utcOffset: 330,
          sourceAccountId: '3845184654445379585',
          sourceAmount: 52000,
        );

        final result = await repository.addTransaction(request);

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) => expect(failure, isA<ServerFailure>()),
          (_) => fail('Expected Left but got Right'),
        );
      },
    );
  });

  group('AddTransactionUseCase Tests', () {
    late FakeTransactionRepository fakeRepo;
    late AddTransactionUseCase useCase;

    setUp(() {
      fakeRepo = FakeTransactionRepository();
      useCase = AddTransactionUseCase(fakeRepo);
    });

    test('executes repository and forwards result', () async {
      const request = AddTransactionRequestModel(
        type: 3,
        categoryId: '3845184654713815072',
        time: 1790576477,
        utcOffset: 330,
        sourceAccountId: '3845184654445379585',
        sourceAmount: 52000,
      );

      final result = await useCase(request);

      expect(result.isRight(), isTrue);
      expect(fakeRepo.lastAddRequest, equals(request));
    });
  });

  group('TransactionBloc AddTransactionRequested Tests', () {
    late FakeTransactionRepository fakeRepo;
    late GetTransactions getTransactions;
    late AddTransactionUseCase addTransaction;
    late TransactionBloc bloc;

    setUp(() {
      fakeRepo = FakeTransactionRepository();
      getTransactions = GetTransactions(fakeRepo);
      addTransaction = AddTransactionUseCase(fakeRepo);
      bloc = TransactionBloc(
        getTransactions: getTransactions,
        addTransaction: addTransaction,
      );
    });

    tearDown(() async {
      await bloc.close();
    });

    test(
      'emits [TransactionCreating, TransactionCreateSuccess, TransactionLoaded] on AddTransactionRequested success',
      () async {
        final states = <TransactionState>[];
        final subscription = bloc.stream.listen(states.add);

        const request = AddTransactionRequestModel(
          type: 3,
          categoryId: '3845184654713815072',
          time: 1790576477,
          utcOffset: 330,
          sourceAccountId: '3845184654445379585',
          sourceAmount: 52000,
        );

        bloc.add(const AddTransactionRequested(request));
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(states, [
          isA<TransactionCreating>(),
          isA<TransactionCreateSuccess>().having(
            (s) => s.transaction.id,
            'transaction id',
            equals('3845233750350757888'),
          ),
          isA<TransactionLoaded>(),
        ]);

        await subscription.cancel();
      },
    );

    test(
      'emits [TransactionCreating, TransactionError] on AddTransactionRequested failure',
      () async {
        fakeRepo.failureToReturn = const ServerFailure(
          'Cannot add transaction',
          400,
        );

        final states = <TransactionState>[];
        final subscription = bloc.stream.listen(states.add);

        const request = AddTransactionRequestModel(
          type: 3,
          categoryId: '3845184654713815072',
          time: 1790576477,
          utcOffset: 330,
          sourceAccountId: '3845184654445379585',
          sourceAmount: 52000,
        );

        bloc.add(const AddTransactionRequested(request));
        await Future<void>.delayed(const Duration(milliseconds: 50));

        expect(states, [
          isA<TransactionCreating>(),
          isA<TransactionError>().having(
            (s) => s.message,
            'error message',
            equals('Cannot add transaction'),
          ),
        ]);

        await subscription.cancel();
      },
    );
  });

  group('AddTransactionScreen Widget Tests', () {
    late FakeTransactionRepository fakeRepo;
    late TransactionBloc bloc;
    late _MockCategoriesRepository mockCategoriesRepo;

    setUp(() {
      fakeRepo = FakeTransactionRepository();
      bloc = TransactionBloc(
        getTransactions: GetTransactions(fakeRepo),
        addTransaction: AddTransactionUseCase(fakeRepo),
      );
      mockCategoriesRepo = _MockCategoriesRepository();
    });

    tearDown(() async {
      await bloc.close();
    });

    Widget buildTestScreen() {
      return MaterialApp(
        home: AddTransactionScreen(
          bloc: bloc,
          categoriesRepository: mockCategoriesRepo,
        ),
      );
    }

    testWidgets('renders Add Transaction form fields and submits correctly', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestScreen());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Check header and tabs
      expect(find.text('Add Transaction'), findsOneWidget);
      expect(find.text('Expense'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Transfer'), findsOneWidget);

      // Check form fields
      expect(find.text('Food & Drink'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);

      // Tap Save button
      await tester.tap(find.text('Save'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(fakeRepo.lastAddRequest, isNotNull);
      expect(fakeRepo.lastAddRequest?.type, equals(3));
      expect(fakeRepo.lastAddRequest?.categoryId, isNotEmpty);
    });

    testWidgets(
      'passes the category ID fetched from Categories API on submit',
      (tester) async {
        const customApiCategoryId = '3845184654713815072';
        const customCategories = [
          CategoryItem(
            id: '3845184654713815000',
            name: 'Food & Drink',
            icon: Icons.restaurant_rounded,
            color: Color(0xFFFF9500),
            type: CategoryType.expense,
            isPrimary: true,
            subCategories: [
              CategoryItem(
                id: customApiCategoryId,
                name: 'Food',
                icon: Icons.fastfood_rounded,
                color: Color(0xFFFF9500),
                type: CategoryType.expense,
                isPrimary: false,
                parentId: '3845184654713815000',
              ),
            ],
          ),
        ];

        final customCategoriesRepo = _MockCategoriesRepository(
          customCategories,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: AddTransactionScreen(
              bloc: bloc,
              categoriesRepository: customCategoriesRepo,
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Tap Save
        await tester.tap(find.text('Save'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        expect(fakeRepo.lastAddRequest, isNotNull);
        expect(
          fakeRepo.lastAddRequest?.categoryId,
          equals(customApiCategoryId),
        );
      },
    );

    testWidgets(
      'passes leaf sub-account ID and never passes parent account ID on submit',
      (tester) async {
        const parentAccountId = '3845184654445379584';
        const subAccountId = '3845184654445379585';

        const customAccounts = [
          Account(
            id: parentAccountId,
            name: 'Cash',
            parentId: '0',
            category: 1,
            type: 2,
            icon: '1',
            iconType: 1,
            color: '4CAF50',
            currency: 'USD',
            balance: 50000,
            subAccounts: [
              Account(
                id: subAccountId,
                name: 'Wallet (US Dollar)',
                parentId: parentAccountId,
                category: 1,
                type: 1,
                icon: '1',
                iconType: 1,
                color: '4CAF50',
                currency: 'USD',
                balance: 50000,
              ),
            ],
          ),
        ];

        final customAccountsRepo = _MockAccountsRepository(customAccounts);

        await tester.pumpWidget(
          MaterialApp(
            home: AddTransactionScreen(
              bloc: bloc,
              categoriesRepository: mockCategoriesRepo,
              accountsRepository: customAccountsRepo,
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Tap Save
        await tester.tap(find.text('Save'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        expect(fakeRepo.lastAddRequest, isNotNull);
        expect(fakeRepo.lastAddRequest?.sourceAccountId, equals(subAccountId));
        expect(
          fakeRepo.lastAddRequest?.sourceAccountId,
          isNot(equals(parentAccountId)),
        );
      },
    );

    testWidgets(
      'Quick Save Button Style dynamically updates button layout in AddTransactionScreen',
      (WidgetTester tester) async {
        final prefController = PreferencesController();
        if (getIt.isRegistered<PreferencesController>()) {
          getIt.unregister<PreferencesController>();
        }
        getIt.registerSingleton<PreferencesController>(prefController);

        // 1. Default: Bottom Right Floating
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: AddTransactionScreen(
                bloc: bloc,
                categoriesRepository: mockCategoriesRepo,
              ),
            ),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Save button is visible
        expect(find.text('Save'), findsOneWidget);

        // 2. Change style to Disabled
        prefController.setQuickSaveButtonStyle('Disabled');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        // Save button is hidden when Disabled
        expect(find.text('Save'), findsNothing);

        // 3. Change style to Bottom Fixed
        prefController.setQuickSaveButtonStyle('Bottom Fixed');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        // Save button is back
        expect(find.text('Save'), findsOneWidget);

        // 4. Change style to Bottom Left Floating
        prefController.setQuickSaveButtonStyle('Bottom Left Floating');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        expect(find.text('Save'), findsOneWidget);

        // 5. Change style to Bottom Center Floating
        prefController.setQuickSaveButtonStyle('Bottom Center Floating');
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        expect(find.text('Save'), findsOneWidget);

        // Tap Save to ensure functionality works
        await tester.tap(find.text('Save'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        expect(fakeRepo.lastAddRequest, isNotNull);
      },
    );
  });
}
