import 'dart:convert';
import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/core/network/api_endpoints.dart';
import 'package:ezbookkeeping/features/accounts/data/models/add_account_request_model.dart';
import 'package:ezbookkeeping/features/accounts/domain/entities/account.dart';
import 'package:ezbookkeeping/features/accounts/domain/repositories/accounts_repository.dart';
import 'package:flutter/material.dart';
import 'package:ezbookkeeping/core/utils/uuid_helper.dart';
import 'package:ezbookkeeping/features/categories/data/datasources/categories_remote_data_source.dart';
import 'package:ezbookkeeping/features/categories/data/models/add_category_request_model.dart';
import 'package:ezbookkeeping/features/categories/data/models/category_list_response_model.dart';
import 'package:ezbookkeeping/features/categories/data/repositories/categories_repository_impl.dart';
import 'package:ezbookkeeping/features/categories/domain/repositories/categories_repository.dart';
import 'package:ezbookkeeping/features/categories/domain/usecases/add_transaction_category_use_case.dart';
import 'package:ezbookkeeping/features/categories/domain/usecases/get_transaction_categories_use_case.dart';
import 'package:ezbookkeeping/features/categories/models/category_item.dart';
import 'package:ezbookkeeping/features/categories/presentation/bloc/categories_bloc.dart';
import 'package:ezbookkeeping/features/categories/presentation/bloc/categories_event.dart';
import 'package:ezbookkeeping/features/categories/presentation/bloc/categories_state.dart';
import 'package:ezbookkeeping/features/categories/utils/category_icon_helper.dart';
import 'package:ezbookkeeping/features/transactions/data/models/add_transaction_request_model.dart';
import 'package:ezbookkeeping/features/transactions/data/models/transaction_list_request.dart';
import 'package:ezbookkeeping/features/transactions/domain/entities/transaction.dart';
import 'package:ezbookkeeping/features/transactions/domain/entities/transaction_list_result.dart';
import 'package:ezbookkeeping/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:ezbookkeeping/features/transactions/domain/usecases/get_transactions.dart';
import 'package:ezbookkeeping/features/transactions/models/transaction_item.dart';

class MockHttpAdapter implements HttpClientAdapter {
  MockHttpAdapter({this.handler});

  Future<ResponseBody> Function(RequestOptions options)? handler;
  RequestOptions? lastRequestOptions;
  int requestCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequestOptions = options;
    requestCount++;
    if (handler != null) {
      return handler!(options);
    }
    return ResponseBody.fromString(
      jsonEncode({
        'success': true,
        'result': [
          {
            'id': '3844071375568371751',
            'name': 'Books & Newspaper & Magazines',
            'parentId': '0',
            'type': 3,
            'categoryIconId': '610',
            'color': 'cddc39',
          },
          {
            'id': '3844071375568371726',
            'name': 'Clothing',
            'parentId': '0',
            'type': 3,
            'categoryIconId': '110',
            'color': '673ab7',
          },
          {
            'id': '3844071375568371790',
            'name': 'Salary Income',
            'parentId': '0',
            'type': 2,
            'categoryIconId': '2010',
            'color': '4caf50',
          },
        ],
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

class FakeTransactionRepo implements TransactionRepository {
  FakeTransactionRepo({required this.items});
  final List<Transaction> items;

  @override
  Future<Either<Failure, TransactionListResult>> getTransactions([
    TransactionListRequest? request,
  ]) async {
    return Right(TransactionListResult(items: items, nextTimeSequenceId: '0'));
  }

  @override
  Future<Either<Failure, Transaction>> getTransactionById(String id) async {
    return Right(items.firstWhere((t) => t.id == id));
  }

  @override
  Future<Either<Failure, Transaction>> addTransaction(
    AddTransactionRequestModel request,
  ) async {
    final newTx = Transaction(
      id: 'mock_new_id',
      timeSequenceId: 'mock_time_seq',
      type: request.type,
      categoryId: request.categoryId,
      time: request.time,
      utcOffset: request.utcOffset,
      sourceAccountId: request.sourceAccountId,
      sourceAmount: request.sourceAmount,
      hideAmount: request.hideAmount,
      comment: request.comment,
      tagIds: request.tagIds,
    );
    return Right(newTx);
  }
}

class FakeAccountsRepo implements AccountsRepository {
  @override
  Future<Either<Failure, List<Account>>> getAccounts({
    bool visibleOnly = false,
  }) async {
    return const Right([
      Account(
        id: 'acc_wallet',
        name: 'Wallet (US Dollar)',
        parentId: '0',
        category: 1,
        type: 1,
        icon: '1',
        iconType: 1,
        color: '4CAF50',
        currency: 'USD',
        balance: 100000,
      ),
    ]);
  }

  @override
  Future<Either<Failure, Account>> addAccount(
    AddAccountRequestModel request,
  ) async {
    return const Right(
      Account(
        id: 'mock_created_id',
        name: 'Mock Created',
        parentId: '0',
        category: 1,
        type: 1,
        icon: '1',
        iconType: 0,
        color: '000000',
        currency: 'USD',
        balance: 500000,
      ),
    );
  }
}

void main() {
  group('CategoryModel & CategoryListResponseModel JSON Parsing', () {
    test('correctly parses category list JSON with subcategories', () {
      final json = {
        'success': true,
        'result': [
          {
            'id': '3844071375568371751',
            'name': 'Books & Newspaper & Magazines',
            'parentId': '0',
            'type': 3,
            'categoryIconId': '610',
            'color': 'cddc39',
            'subCategories': [
              {
                'id': '3844071375568371752',
                'name': 'Novels',
                'parentId': '3844071375568371751',
                'type': 3,
                'categoryIconId': '610',
                'color': 'cddc39',
              },
            ],
          },
        ],
      };

      final response = CategoryListResponseModel.fromJson(json);
      expect(response.success, true);
      expect(response.result.length, 1);

      final model = response.result.first;
      expect(model.id, '3844071375568371751');
      expect(model.name, 'Books & Newspaper & Magazines');
      expect(model.subCategories.length, 1);
      expect(model.subCategories.first.name, 'Novels');

      final entity = model.toEntity();
      expect(entity.id, '3844071375568371751');
      expect(entity.name, 'Books & Newspaper & Magazines');
      expect(entity.subCategories.length, 1);
    });

    test('correctly parses map-grouped category list JSON from API', () {
      final json = {
        'success': true,
        'result': {
          '1': [
            {
              'id': '3845184654713815093',
              'name': 'Occupational Earnings',
              'parentId': '0',
              'type': 1,
              'icon': '2000',
              'color': 'ff6b22',
              'subCategories': [
                {
                  'id': '3845184654713815096',
                  'name': 'Salary Income',
                  'parentId': '3845184654713815093',
                  'type': 1,
                  'icon': '2010',
                  'color': 'ff6b22',
                },
              ],
            },
          ],
          '2': [
            {
              'id': '3845184654713815040',
              'name': 'Food & Drink',
              'parentId': '0',
              'type': 2,
              'icon': '1',
              'color': 'ff6b22',
              'subCategories': [
                {
                  'id': '3845184654713815051',
                  'name': 'Food',
                  'parentId': '3845184654713815040',
                  'type': 2,
                  'icon': '2',
                  'color': 'ff6b22',
                },
              ],
            },
          ],
        },
      };

      final response = CategoryListResponseModel.fromJson(json);
      expect(response.success, true);
      expect(response.result.length, 2);

      final incomePrimary = response.result.firstWhere(
        (c) => c.name == 'Occupational Earnings',
      );
      expect(incomePrimary.type, 1);
      final incomeEntity = incomePrimary.toEntity();
      expect(incomeEntity.type, CategoryType.income);
      expect(incomeEntity.subCategories.length, 1);
      expect(incomeEntity.subCategories.first.id, '3845184654713815096');

      final expensePrimary = response.result.firstWhere(
        (c) => c.name == 'Food & Drink',
      );
      expect(expensePrimary.type, 2);
      final expenseEntity = expensePrimary.toEntity();
      expect(expenseEntity.type, CategoryType.expense);
      expect(expenseEntity.subCategories.length, 1);
      expect(expenseEntity.subCategories.first.id, '3845184654713815051');
    });
  });

  group('CategoriesRepository In-Memory Caching & Concurrency', () {
    late Dio dio;
    late MockHttpAdapter mockAdapter;
    late CategoriesRemoteDataSource remoteDataSource;
    late CategoriesRepository repository;

    setUp(() {
      mockAdapter = MockHttpAdapter();
      dio = Dio(
        BaseOptions(baseUrl: 'https://ezbookkeeping-demo.mayswind.net'),
      );
      dio.httpClientAdapter = mockAdapter;
      remoteDataSource = CategoriesRemoteDataSourceImpl(dio: dio);
      repository = CategoriesRepositoryImpl(remoteDataSource: remoteDataSource);
    });

    test(
      'fetches categories from API on first request and stores in memory',
      () async {
        expect(repository.isCacheValid, false);
        expect(mockAdapter.requestCount, 0);

        final categories = await repository.getCategories();

        expect(categories.length, 3);
        expect(mockAdapter.requestCount, 1);
        expect(
          mockAdapter.lastRequestOptions?.path,
          ApiEndpoints.transactionCategoriesList,
        );
        expect(repository.isCacheValid, true);

        // Verify category lookup map
        final map = await repository.getCategoriesMap();
        expect(map.containsKey('3844071375568371751'), true);
        expect(
          map['3844071375568371751']?.name,
          'Books & Newspaper & Magazines',
        );
        expect(map['3844071375568371726']?.name, 'Clothing');
        expect(map['3844071375568371790']?.name, 'Salary Income');
      },
    );

    test(
      'uses in-memory cache for subsequent requests without network call',
      () async {
        await repository.getCategories();
        expect(mockAdapter.requestCount, 1);

        // Call multiple times
        final cached1 = await repository.getCategories();
        final cached2 = await repository.getCategories();
        final map = await repository.getCategoriesMap();

        expect(cached1.length, 3);
        expect(cached2.length, 3);
        expect(map.length >= 3, true);
        expect(mockAdapter.requestCount, 1); // No new network requests!
      },
    );

    test(
      'deduplicates simultaneous in-flight requests to a single network call',
      () async {
        expect(mockAdapter.requestCount, 0);

        // Trigger 5 parallel simultaneous requests
        final results = await Future.wait([
          repository.getCategories(),
          repository.getCategories(),
          repository.getCategories(),
          repository.getCategories(),
          repository.getCategories(),
        ]);

        expect(results.length, 5);
        for (final res in results) {
          expect(res.length, 3);
        }
        expect(mockAdapter.requestCount, 1); // Exactly 1 network request sent!
      },
    );

    test(
      'forceRefresh invalidates cache and triggers new API request',
      () async {
        await repository.getCategories();
        expect(mockAdapter.requestCount, 1);

        await repository.getCategories(forceRefresh: true);
        expect(mockAdapter.requestCount, 2);
      },
    );

    test('clearCache resets in-memory cache for logout lifecycle', () async {
      await repository.getCategories();
      expect(repository.isCacheValid, true);

      repository.clearCache();
      expect(repository.isCacheValid, false);

      await repository.getCategories();
      expect(mockAdapter.requestCount, 2); // Fetched fresh after clear
    });
  });

  group('Transaction Hydration with Stored Categories', () {
    late CategoriesRepository categoriesRepo;
    late MockHttpAdapter mockAdapter;

    setUp(() {
      mockAdapter = MockHttpAdapter();
      final dio = Dio(
        BaseOptions(baseUrl: 'https://ezbookkeeping-demo.mayswind.net'),
      );
      dio.httpClientAdapter = mockAdapter;
      final remoteDataSource = CategoriesRemoteDataSourceImpl(dio: dio);
      categoriesRepo = CategoriesRepositoryImpl(
        remoteDataSource: remoteDataSource,
      );
    });

    test(
      'GetTransactions resolves stored categories by categoryId and displays category name',
      () async {
        final fakeTxRepo = FakeTransactionRepo(
          items: [
            const Transaction(
              id: 'tx_1',
              timeSequenceId: 'tx_1',
              type: 3,
              categoryId: '3844071375568371751', // Stored Books ID
              time: 1789984800,
              utcOffset: 0,
              sourceAccountId: 'acc_wallet',
              sourceAmount: 3500,
              comment: 'book purchase',
            ),
            const Transaction(
              id: 'tx_2',
              timeSequenceId: 'tx_2',
              type: 3,
              categoryId: '3844071375568371726', // Stored Clothing ID
              time: 1789984800,
              utcOffset: 0,
              sourceAccountId: 'acc_wallet',
              sourceAmount: 7500,
              comment: 'winter jacket',
            ),
          ],
        );

        final fakeAccounts = FakeAccountsRepo();
        final getTransactions = GetTransactions(
          fakeTxRepo,
          accountsRepository: fakeAccounts,
          categoriesRepository: categoriesRepo,
        );

        final resultEither = await getTransactions();
        expect(resultEither.isRight(), true);
        final result = resultEither.getOrElse(() => throw Exception());

        expect(result.items.length, 2);

        // First transaction
        final tx1 = result.items[0];
        expect(tx1.category, isNotNull);
        expect(tx1.category!.name, 'Books & Newspaper & Magazines');
        expect(tx1.displayTitle, 'Books & Newspaper & Magazines');
        expect(tx1.comment, 'book purchase');

        final uiItem1 = TransactionItem.fromEntity(tx1);
        expect(uiItem1.category, 'Books & Newspaper & Magazines');
        expect(uiItem1.note, 'book purchase');

        // Second transaction
        final tx2 = result.items[1];
        expect(tx2.category, isNotNull);
        expect(tx2.category!.name, 'Clothing');
        expect(tx2.displayTitle, 'Clothing');
        expect(tx2.comment, 'winter jacket');

        final uiItem2 = TransactionItem.fromEntity(tx2);
        expect(uiItem2.category, 'Clothing');
        expect(uiItem2.note, 'winter jacket');
      },
    );

    test('unknown categoryId handles safely without crashing', () async {
      final fakeTxRepo = FakeTransactionRepo(
        items: [
          const Transaction(
            id: 'tx_unknown',
            timeSequenceId: 'tx_unknown',
            type: 3,
            categoryId: 'non_existent_cat_id_9999',
            time: 1789984800,
            utcOffset: 0,
            sourceAccountId: 'acc_wallet',
            sourceAmount: 1200,
          ),
        ],
      );

      final getTransactions = GetTransactions(
        fakeTxRepo,
        accountsRepository: FakeAccountsRepo(),
        categoriesRepository: categoriesRepo,
      );

      final resultEither = await getTransactions();
      expect(resultEither.isRight(), true);
      final result = resultEither.getOrElse(() => throw Exception());
      expect(result.items.length, 1);
      final item = result.items.first;
      expect(item.category, isNull);
      expect(item.displayTitle, 'Expense');
    });
  });

  group('AddCategoryRequestModel & CategoryIconHelper', () {
    test('AddCategoryRequestModel serializes correctly to JSON', () {
      const model = AddCategoryRequestModel(
        name: 'Testing',
        type: 2,
        parentId: '0',
        icon: '1',
        iconType: 0,
        color: '000000',
        comment: 'test comment',
        clientSessionId: '9be85957-b77c-802d-a2c7-de14e1bf7513',
      );

      final json = model.toJson();
      expect(json['name'], 'Testing');
      expect(json['type'], 2);
      expect(json['parentId'], '0');
      expect(json['icon'], '1');
      expect(json['iconType'], 0);
      expect(json['color'], '000000');
      expect(json['comment'], 'test comment');
      expect(json['clientSessionId'], '9be85957-b77c-802d-a2c7-de14e1bf7513');
    });

    test(
      'CategoryIconHelper converts colors to clean 6-character hex strings',
      () {
        expect(
          CategoryIconHelper.colorToHex(const Color(0xFF000000)),
          '000000',
        );
        expect(
          CategoryIconHelper.colorToHex(const Color(0xFFFF6B22)),
          'ff6b22',
        );
        expect(
          CategoryIconHelper.colorToHex(const Color(0xFF4CAF50)),
          '4caf50',
        );
      },
    );

    test('UuidHelper generates valid v4 UUID', () {
      final uuid = UuidHelper.generate();
      expect(uuid.length, 36);
      expect(uuid[14], '4'); // RFC4122 version 4
    });
  });

  group('Add Category RemoteDataSource, Repository, UseCase, and Bloc', () {
    late Dio dio;
    late MockHttpAdapter mockAdapter;
    late CategoriesRemoteDataSource remoteDataSource;
    late CategoriesRepository repository;

    setUp(() {
      mockAdapter = MockHttpAdapter(
        handler: (options) async {
          if (options.path == ApiEndpoints.addCategory) {
            final data = options.data is String
                ? jsonDecode(options.data as String)
                : options.data as Map<String, dynamic>;
            return ResponseBody.fromString(
              jsonEncode({
                'success': true,
                'result': {
                  'id': '99990001',
                  'name': data['name'],
                  'parentId': data['parentId'],
                  'type': data['type'],
                  'categoryIconId': data['icon'],
                  'color': data['color'],
                  'comment': data['comment'],
                },
              }),
              200,
              headers: {
                Headers.contentTypeHeader: [Headers.jsonContentType],
              },
            );
          }
          return ResponseBody.fromString(
            jsonEncode({
              'success': true,
              'result': [
                {
                  'id': '101',
                  'name': 'Food & Drink',
                  'parentId': '0',
                  'type': 2,
                  'categoryIconId': '1',
                  'color': 'ff6b22',
                },
              ],
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        },
      );

      dio = Dio(
        BaseOptions(baseUrl: 'https://ezbookkeeping-demo.mayswind.net'),
      );
      dio.httpClientAdapter = mockAdapter;
      remoteDataSource = CategoriesRemoteDataSourceImpl(dio: dio);
      repository = CategoriesRepositoryImpl(remoteDataSource: remoteDataSource);
    });

    test(
      'RemoteDataSource.addCategory posts to ApiEndpoints.addCategory',
      () async {
        const request = AddCategoryRequestModel(
          name: 'Entertainment',
          type: 2,
          parentId: '0',
          icon: '10',
          iconType: 0,
          color: 'ff6b22',
          comment: 'movies',
          clientSessionId: 'test-session-id',
        );

        final response = await remoteDataSource.addCategory(request);
        expect(response.id, '99990001');
        expect(response.name, 'Entertainment');
        expect(mockAdapter.lastRequestOptions?.path, ApiEndpoints.addCategory);
        expect(mockAdapter.lastRequestOptions?.method, 'POST');
      },
    );

    test(
      'addCategory supports Expense Subcategories (type 2 with parentId)',
      () async {
        // Prime cache with primary category id 101
        await repository.getCategories();

        const subRequest = AddCategoryRequestModel(
          name: 'Fine Dining',
          type: 2,
          parentId: '101',
          icon: '2',
          iconType: 0,
          color: 'ff6b22',
          comment: 'restaurant subcategory',
          clientSessionId: 'uuid-sub-exp',
        );

        final result = await repository.addCategory(subRequest);
        expect(result.isRight(), true);
        final sub = result.getOrElse(() => throw Exception());
        expect(sub.name, 'Fine Dining');
        expect(sub.parentId, '101');
        expect(sub.isPrimary, false);

        final all = await repository.getCategories();
        final parent = all.firstWhere((c) => c.id == '101');
        expect(parent.subCategories.any((s) => s.name == 'Fine Dining'), true);
      },
    );

    test(
      'addCategory supports Income Primary Categories (type 1, parentId 0)',
      () async {
        const incomeReq = AddCategoryRequestModel(
          name: 'Investments & Dividends',
          type: 1,
          parentId: '0',
          icon: '2000',
          iconType: 0,
          color: '000000',
          comment: '',
          clientSessionId: 'uuid-inc-prim',
        );

        final result = await repository.addCategory(incomeReq);
        expect(result.isRight(), true);
        final inc = result.getOrElse(() => throw Exception());
        expect(inc.name, 'Investments & Dividends');
        expect(inc.type, CategoryType.income);
        expect(inc.isPrimary, true);
      },
    );

    test(
      'addCategory supports Transfer Categories (type 3, parentId 0 & sub)',
      () async {
        const transferReq = AddCategoryRequestModel(
          name: 'Account Transfers',
          type: 3,
          parentId: '0',
          icon: '300',
          iconType: 0,
          color: '009688',
          comment: 'transfer cat',
          clientSessionId: 'uuid-trans',
        );

        final result = await repository.addCategory(transferReq);
        expect(result.isRight(), true);
        final tr = result.getOrElse(() => throw Exception());
        expect(tr.name, 'Account Transfers');
        expect(tr.type, CategoryType.transfer);
      },
    );

    test(
      'Repository.addCategory updates local in-memory cache and map',
      () async {
        // Prime cache
        final initialCategories = await repository.getCategories();
        expect(initialCategories.length, 1);

        const request = AddCategoryRequestModel(
          name: 'Health Care',
          type: 2,
          parentId: '0',
          icon: '20',
          iconType: 0,
          color: '4caf50',
          comment: 'medicine',
          clientSessionId: 'uuid-1234',
        );

        final result = await repository.addCategory(request);
        expect(result.isRight(), true);
        final created = result.getOrElse(() => throw Exception());
        expect(created.id, '99990001');
        expect(created.name, 'Health Care');

        // Check cache updated in-memory
        final updatedList = await repository.getCategories();
        expect(updatedList.length, 2);
        expect(updatedList.any((c) => c.name == 'Health Care'), true);

        final map = await repository.getCategoriesMap();
        expect(map.containsKey('99990001'), true);
        expect(map['99990001']?.name, 'Health Care');
      },
    );

    test('AddTransactionCategoryUseCase executes through repository', () async {
      final useCase = AddTransactionCategoryUseCase(repository);
      const request = AddCategoryRequestModel(
        name: 'Bills & Utilities',
        type: 2,
        parentId: '0',
        icon: '30',
        iconType: 0,
        color: '2196f3',
        comment: 'electricity',
        clientSessionId: 'uuid-5678',
      );

      final result = await useCase(request);
      expect(result.isRight(), true);
      expect(
        result.getOrElse(() => throw Exception()).name,
        'Bills & Utilities',
      );
    });

    test(
      'CategoriesBloc handles LoadCategoriesRequested and AddCategoryRequested',
      () async {
        final getUseCase = GetTransactionCategoriesUseCase(repository);
        final addUseCase = AddTransactionCategoryUseCase(repository);
        final bloc = CategoriesBloc(
          getCategories: getUseCase,
          addCategory: addUseCase,
        );

        expect(bloc.state, isA<CategoriesInitial>());

        bloc.add(const LoadCategoriesRequested());
        await expectLater(
          bloc.stream,
          emitsInOrder([isA<CategoriesLoading>(), isA<CategoriesLoaded>()]),
        );

        const request = AddCategoryRequestModel(
          name: 'Shopping',
          type: 2,
          parentId: '0',
          icon: '40',
          iconType: 0,
          color: 'e91e63',
          comment: '',
          clientSessionId: 'uuid-bloc-test',
        );

        bloc.add(const AddCategoryRequested(request));
        await expectLater(
          bloc.stream,
          emitsInOrder([
            isA<CategoryAdding>(),
            isA<CategoryAddSuccess>(),
            isA<CategoriesLoading>(),
            isA<CategoriesLoaded>(),
          ]),
        );

        await bloc.close();
      },
    );
  });

  group('ServiceLocator Categories Registration', () {
    setUp(() async {
      await getIt.reset();
    });

    tearDown(() async {
      await getIt.reset();
    });

    test(
      'registers all Categories dependencies and injects into GetTransactions',
      () async {
        final mockDio = Dio(
          BaseOptions(baseUrl: 'https://ezbookkeeping-demo.mayswind.net'),
        );
        mockDio.httpClientAdapter = MockHttpAdapter();

        await setupDependencies(dio: mockDio);

        expect(getIt.isRegistered<CategoriesRemoteDataSource>(), true);
        expect(getIt.isRegistered<CategoriesRepository>(), true);
        expect(getIt.isRegistered<GetTransactionCategoriesUseCase>(), true);
        expect(getIt.isRegistered<AddTransactionCategoryUseCase>(), true);
        expect(getIt.isRegistered<CategoriesBloc>(), true);
        expect(getIt.isRegistered<GetTransactions>(), true);

        final useCase = getIt<GetTransactionCategoriesUseCase>();
        expect(useCase, isNotNull);

        final categories = await useCase();
        expect(categories.length, 3);
      },
    );
  });
}
