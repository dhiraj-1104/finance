import 'dart:convert';
import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/core/network/api_endpoints.dart';
import 'package:ezbookkeeping/features/accounts/data/models/add_account_request_model.dart';
import 'package:ezbookkeeping/features/accounts/domain/entities/account.dart';
import 'package:ezbookkeeping/features/accounts/domain/repositories/accounts_repository.dart';
import 'package:ezbookkeeping/features/categories/data/models/add_category_request_model.dart';
import 'package:ezbookkeeping/features/categories/domain/repositories/categories_repository.dart';
import 'package:ezbookkeeping/features/categories/models/category_item.dart';
import 'package:ezbookkeeping/features/transactions/data/datasources/transaction_remote_data_source.dart';
import 'package:ezbookkeeping/features/transactions/data/models/add_transaction_request_model.dart';
import 'package:ezbookkeeping/features/transactions/data/models/transaction_list_request.dart';
import 'package:ezbookkeeping/features/transactions/data/models/transaction_list_response_model.dart';
import 'package:ezbookkeeping/features/transactions/data/models/transaction_model.dart';
import 'package:ezbookkeeping/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:ezbookkeeping/features/transactions/domain/entities/transaction.dart';
import 'package:ezbookkeeping/features/transactions/domain/entities/transaction_list_result.dart';
import 'package:ezbookkeeping/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:ezbookkeeping/features/transactions/domain/usecases/add_transaction_use_case.dart';
import 'package:ezbookkeeping/features/transactions/domain/usecases/get_transactions.dart';
import 'package:ezbookkeeping/features/transactions/models/transaction_item.dart';
import 'package:ezbookkeeping/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:ezbookkeeping/features/transactions/presentation/bloc/transaction_event.dart';
import 'package:ezbookkeeping/features/transactions/presentation/bloc/transaction_state.dart';
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
        'result': {'items': [], 'nextTimeSequenceId': '0', 'totalCount': 0},
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
    this.failureToReturn,
    this.transactionToReturn,
  });

  TransactionListResult? resultToReturn;
  Transaction? transactionToReturn;
  Failure? failureToReturn;
  TransactionListRequest? lastRequest;
  String? lastTransactionId;

  @override
  Future<Either<Failure, TransactionListResult>> getTransactions([
    TransactionListRequest? request,
  ]) async {
    lastRequest = request;
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
    lastTransactionId = id;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(
      transactionToReturn ??
          const Transaction(
            id: 'test_id',
            timeSequenceId: '0',
            type: 3,
            categoryId: 'cat_1',
            time: 0,
            utcOffset: 0,
            sourceAccountId: 'acc_1',
            sourceAmount: 1000,
          ),
    );
  }

  AddTransactionRequestModel? lastAddRequest;

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
          const Transaction(
            id: 'test_id',
            timeSequenceId: '0',
            type: 3,
            categoryId: 'cat_1',
            time: 0,
            utcOffset: 0,
            sourceAccountId: 'acc_1',
            sourceAmount: 1000,
          ),
    );
  }
}

class FakeAccountsRepository implements AccountsRepository {
  FakeAccountsRepository({this.accountsToReturn, this.failureToReturn});

  List<Account>? accountsToReturn;
  Failure? failureToReturn;
  int getAccountsCallCount = 0;

  @override
  Future<Either<Failure, List<Account>>> getAccounts({
    bool visibleOnly = false,
  }) async {
    getAccountsCallCount++;
    if (failureToReturn != null) return Left(failureToReturn!);
    return Right(
      accountsToReturn ??
          [
            const Account(
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
            const Account(
              id: 'acc_credit',
              name: 'Credit Card',
              parentId: '0',
              category: 3,
              type: 1,
              icon: '2',
              iconType: 1,
              color: '2196F3',
              currency: 'EUR',
              balance: 500000,
            ),
          ],
    );
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

class FakeCategoriesRepository implements CategoriesRepository {
  FakeCategoriesRepository({this.categoriesToReturn});

  List<CategoryItem>? categoriesToReturn;

  @override
  bool get isCacheValid => true;

  @override
  void clearCache() {}

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
    categoriesToReturn = [...?categoriesToReturn, cat];
    return Right(cat);
  }

  @override
  Future<List<CategoryItem>> getCategories({bool forceRefresh = false}) async {
    return categoriesToReturn ??
        const [
          CategoryItem(
            id: '610',
            name: 'Books & Newspaper & Magazines',
            categoryIconId: '610',
            icon: Icons.school_outlined,
            color: Color(0xFF9C27B0),
            type: CategoryType.expense,
          ),
          CategoryItem(
            id: '3843885835128668160',
            name: 'Food',
            categoryIconId: '2',
            icon: Icons.restaurant_outlined,
            color: Color(0xFFFF6B22),
            type: CategoryType.expense,
          ),
          CategoryItem(
            id: '2',
            name: 'Food',
            categoryIconId: '2',
            icon: Icons.restaurant_outlined,
            color: Color(0xFFFF6B22),
            type: CategoryType.expense,
          ),
        ];
  }

  @override
  Future<Map<String, CategoryItem>> getCategoriesMap({
    bool forceRefresh = false,
  }) async {
    final cats = await getCategories(forceRefresh: forceRefresh);
    final map = <String, CategoryItem>{};
    for (final c in cats) {
      map[c.id] = c;
      for (final s in c.subCategories) {
        map[s.id] = s;
      }
    }
    return map;
  }

  @override
  Future<Map<String, String>> getCategoryNameMap({
    bool forceRefresh = false,
  }) async {
    final map = await getCategoriesMap(forceRefresh: forceRefresh);
    return map.map((k, v) => MapEntry(k, v.name));
  }
}

void main() {
  final Map<String, dynamic> sampleApiResponse = {
    'success': true,
    'result': {
      'items': [
        {
          'id': '201633519177113600',
          'timeSequenceId': '201633519177113600',
          'type': 3,
          'categoryId': '200508535230758912',
          'time': 1789984800,
          'utcOffset': -300,
          'sourceAccountId': '200508535230758913',
          'sourceAmount': 1700,
          'hideAmount': false,
          'tagIds': <String>[],
          'comment': 'Cinema ticket',
          'editable': true,
        },
        {
          'id': '201633519177113601',
          'timeSequenceId': '201633519177113601',
          'type': 2,
          'categoryId': '200508535230758914',
          'time': 1789985800,
          'utcOffset': 0,
          'sourceAccountId': '200508535230758913',
          'sourceAmount': 5000,
          'hideAmount': false,
          'tagIds': ['travel'],
          'comment': 'Freelance income',
          'editable': true,
        },
        {
          'id': '201633519177113602',
          'timeSequenceId': '201633519177113602',
          'type': 4,
          'categoryId': '0',
          'time': 1789986800,
          'utcOffset': 330,
          'sourceAccountId': '200508535230758913',
          'destinationAccountId': '200508535230758915',
          'sourceAmount': 2000,
          'destinationAmount': 2000,
          'hideAmount': false,
          'tagIds': <String>[],
          'comment': 'Transfer to Savings',
          'editable': true,
        },
      ],
      'nextTimeSequenceId': '1789984800',
      'totalCount': 3,
    },
  };

  group('TransactionListRequest Models', () {
    test('default values match API requirements', () {
      const req = TransactionListRequest();
      expect(req.maxTime, 0);
      expect(req.minTime, 0);
      expect(req.type, 0);
      expect(req.count, 50);
      expect(req.page, 1);
      expect(req.trimAccount, true);
      expect(req.trimCategory, true);
      expect(req.trimTag, true);

      final qp = req.toQueryParameters();
      expect(qp['max_time'], 0);
      expect(qp['min_time'], 0);
      expect(qp['type'], 0);
      expect(qp['count'], 50);
      expect(qp['page'], 1);
      expect(qp['trim_account'], true);
      expect(qp['trim_category'], true);
      expect(qp['trim_tag'], true);
    });

    test('toQueryParameters formats custom values correctly', () {
      const req = TransactionListRequest(
        maxTime: 1789984800,
        minTime: 1789000000,
        type: 3,
        categoryIds: 'cat1,cat2',
        accountIds: 'acc1',
        tagFilter: 'tag1',
        amountFilter: '100:500',
        keyword: 'lunch',
        matchMode: 1,
        mustHavePictures: true,
        count: 20,
        page: 2,
        withCount: true,
        withPictures: true,
        trimAccount: false,
        trimCategory: false,
        trimTag: false,
      );

      final qp = req.toQueryParameters();
      expect(qp['max_time'], 1789984800);
      expect(qp['min_time'], 1789000000);
      expect(qp['type'], 3);
      expect(qp['category_ids'], 'cat1,cat2');
      expect(qp['account_ids'], 'acc1');
      expect(qp['tag_filter'], 'tag1');
      expect(qp['amount_filter'], '100:500');
      expect(qp['keyword'], 'lunch');
      expect(qp['match_mode'], 1);
      expect(qp['must_have_pictures'], true);
      expect(qp['count'], 20);
      expect(qp['page'], 2);
      expect(qp['with_count'], true);
      expect(qp['with_pictures'], true);
      expect(qp['trim_account'], false);
      expect(qp['trim_category'], false);
      expect(qp['trim_tag'], false);
    });
  });

  group('Transaction Data Models & Entity Mapping', () {
    test('TransactionModel parses JSON accurately and converts to Entity', () {
      final resultMap = sampleApiResponse['result'] as Map<String, dynamic>;
      final itemsList = resultMap['items'] as List<dynamic>;
      final json = itemsList[0] as Map<String, dynamic>;
      final model = TransactionModel.fromJson(json);

      expect(model.id, '201633519177113600');
      expect(model.type, 3);
      expect(model.sourceAmount, 1700);
      expect(model.utcOffset, -300);
      expect(model.comment, 'Cinema ticket');
      expect(model.destinationAccountId, isNull);

      final entity = model.toEntity();
      expect(entity.id, model.id);
      expect(entity.isExpense, true);
      expect(entity.isIncome, false);
      expect(entity.isTransfer, false);
    });

    test('TransactionListResponseModel parses full response JSON', () {
      final responseModel = TransactionListResponseModel.fromJson(
        sampleApiResponse,
      );
      expect(responseModel.success, true);
      expect(responseModel.result, isNotNull);
      expect(responseModel.result!.items.length, 3);
      expect(responseModel.result!.nextTimeSequenceId, '1789984800');

      final domainResult = responseModel.result!.toEntity();
      expect(domainResult.items.length, 3);
      expect(domainResult.items[0].sourceAmount, 1700);
      expect(domainResult.items[1].isIncome, true);
      expect(domainResult.items[2].isTransfer, true);
      expect(domainResult.items[2].destinationAccountId, '200508535230758915');
    });
  });

  group('TransactionItem UI Mapper', () {
    test('fromEntity correctly maps expense transaction with UTC offset', () {
      const tx = Transaction(
        id: '1',
        timeSequenceId: '1',
        type: 3,
        categoryId: 'cat_food',
        time: 1789984800,
        utcOffset: -300,
        sourceAccountId: 'acc1',
        sourceAmount: 1750,
        comment: 'Delicious meal',
      );

      final item = TransactionItem.fromEntity(tx);
      expect(item.id, '1');
      expect(item.amount, 17.50);
      expect(item.formattedAmount, r'$ 17.50');
      expect(item.note, 'Delicious meal');
      expect(item.type, 3);
      expect(item.time.contains('UTC-05:00'), true);
    });

    test('fromEntity correctly maps income transaction', () {
      const tx = Transaction(
        id: '2',
        timeSequenceId: '2',
        type: 2,
        categoryId: 'cat_salary',
        time: 1789984800,
        utcOffset: 0,
        sourceAccountId: 'acc1',
        sourceAmount: 300000,
        comment: 'Monthly salary',
      );

      final item = TransactionItem.fromEntity(tx);
      expect(item.amount, 3000.0);
      expect(item.formattedAmount, r'$ 3000.00');
      expect(item.type, 2);
      expect(item.time.contains('UTC+00:00'), true);
    });

    test('fromEntity correctly maps transfer transaction', () {
      const tx = Transaction(
        id: '3',
        timeSequenceId: '3',
        type: 4,
        categoryId: '',
        time: 1789984800,
        utcOffset: 330,
        sourceAccountId: 'acc1',
        destinationAccountId: 'acc2',
        sourceAmount: 5000,
        destinationAmount: 5000,
      );

      final item = TransactionItem.fromEntity(tx);
      expect(item.category, 'Transfer');
      expect(item.amount, 50.0);
      expect(item.type, 4);
      expect(item.time.contains('UTC+05:30'), true);
    });
  });

  group('Transaction Remote DataSource & Repository', () {
    late Dio dio;
    late MockHttpAdapter mockAdapter;
    late TransactionRemoteDataSource remoteDataSource;
    late TransactionRepository repository;

    setUp(() {
      mockAdapter = MockHttpAdapter(
        handler: (options) async {
          return ResponseBody.fromString(
            jsonEncode(sampleApiResponse),
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
      remoteDataSource = TransactionRemoteDataSourceImpl(dio: dio);
      repository = TransactionRepositoryImpl(
        remoteDataSource: remoteDataSource,
      );
    });

    test(
      'RemoteDataSource calls correct endpoint with query parameters',
      () async {
        const req = TransactionListRequest(count: 25, page: 1);
        final response = await remoteDataSource.getTransactions(req);

        expect(response.success, true);
        expect(response.result?.items.length, 3);
        expect(
          mockAdapter.lastRequestOptions?.path,
          ApiEndpoints.transactionList,
        );
        expect(mockAdapter.lastRequestOptions?.queryParameters['count'], 25);
      },
    );

    test('Repository converts response to domain entity', () async {
      const req = TransactionListRequest();
      final result = await repository.getTransactions(req);

      expect(result.isRight(), true);
      final data = result.getOrElse(() => throw Exception());
      expect(data.items.length, 3);
      expect(data.nextTimeSequenceId, '1789984800');
    });

    test(
      'Repository handles API failure and returns Left(UnauthorizedFailure)',
      () async {
        mockAdapter.handler = (options) async {
          return ResponseBody.fromString(
            jsonEncode({
              'success': false,
              'errorMessage': 'Unauthorized request',
              'errorCode': 200001,
            }),
            401,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        final result = await repository.getTransactions(
          const TransactionListRequest(),
        );
        expect(result.isLeft(), true);
      },
    );
  });

  group('GetTransactions UseCase & Hydration Flow', () {
    test('executes repository and forwards result', () async {
      final fakeRepo = FakeTransactionRepository(
        resultToReturn: const TransactionListResult(
          items: [
            Transaction(
              id: 'tx_1',
              timeSequenceId: 'tx_1',
              type: 3,
              categoryId: 'cat_1',
              time: 1000,
              utcOffset: 0,
              sourceAccountId: 'acc_1',
              sourceAmount: 1200,
            ),
          ],
          nextTimeSequenceId: '0',
        ),
      );

      final useCase = GetTransactions(fakeRepo);
      final resultEither = await useCase(const TransactionListRequest(page: 1));

      expect(resultEither.isRight(), true);
      final result = resultEither.getOrElse(() => throw Exception());
      expect(result.items.length, 1);
      expect(result.items.first.id, 'tx_1');
      expect(fakeRepo.lastRequest?.page, 1);
    });

    test(
      'hydrates category when categoryId matches known category or iconId',
      () async {
        final fakeRepo = FakeTransactionRepository(
          resultToReturn: const TransactionListResult(
            items: [
              Transaction(
                id: 'tx_books',
                timeSequenceId: 'tx_books',
                type: 3,
                categoryId: '610', // Books & Newspaper & Magazines
                time: 1789984800,
                utcOffset: 0,
                sourceAccountId: 'acc_wallet',
                sourceAmount: 3500,
                comment: 'book purchase',
              ),
              Transaction(
                id: 'tx_backend_id',
                timeSequenceId: 'tx_backend_id',
                type: 3,
                categoryId: '3843885835128668160', // Food
                time: 1789984800,
                utcOffset: 0,
                sourceAccountId: 'acc_wallet',
                sourceAmount: 2000,
                comment: 'dinner',
              ),
            ],
            nextTimeSequenceId: '0',
          ),
        );

        final fakeAccounts = FakeAccountsRepository();
        final fakeCategories = FakeCategoriesRepository();
        final useCase = GetTransactions(
          fakeRepo,
          accountsRepository: fakeAccounts,
          categoriesRepository: fakeCategories,
        );
        final resultEither = await useCase();

        expect(resultEither.isRight(), true);
        final result = resultEither.getOrElse(() => throw Exception());
        expect(result.items.length, 2);

        // Books transaction
        final bookTx = result.items[0];
        expect(bookTx.category, isNotNull);
        expect(bookTx.category!.name, 'Books & Newspaper & Magazines');
        expect(bookTx.displayTitle, 'Books & Newspaper & Magazines');
        expect(bookTx.comment, 'book purchase');

        // Food transaction
        final foodTx = result.items[1];
        expect(foodTx.category, isNotNull);
        expect(foodTx.category!.name, 'Food');
        expect(foodTx.displayTitle, 'Food');
      },
    );

    test('handles missing category gracefully with fallback', () async {
      final fakeRepo = FakeTransactionRepository(
        resultToReturn: const TransactionListResult(
          items: [
            Transaction(
              id: 'tx_unknown_cat',
              timeSequenceId: 'tx_unknown_cat',
              type: 3,
              categoryId: '99999999999',
              time: 1789984800,
              utcOffset: 0,
              sourceAccountId: 'acc_wallet',
              sourceAmount: 1500,
            ),
          ],
          nextTimeSequenceId: '0',
        ),
      );

      final useCase = GetTransactions(fakeRepo);
      final resultEither = await useCase();

      expect(resultEither.isRight(), true);
      final result = resultEither.getOrElse(() => throw Exception());
      expect(result.items.length, 1);
      final item = result.items.first;
      expect(item.category, isNull);
      expect(item.displayTitle, 'Expense');
    });

    test('hydrates source account and currency symbol', () async {
      final fakeRepo = FakeTransactionRepository(
        resultToReturn: const TransactionListResult(
          items: [
            Transaction(
              id: 'tx_acc',
              timeSequenceId: 'tx_acc',
              type: 3,
              categoryId: '2',
              time: 1789984800,
              utcOffset: 0,
              sourceAccountId: 'acc_wallet',
              sourceAmount: 1500,
            ),
            Transaction(
              id: 'tx_acc2',
              timeSequenceId: 'tx_acc2',
              type: 3,
              categoryId: '2',
              time: 1789984800,
              utcOffset: 0,
              sourceAccountId: 'acc_credit',
              sourceAmount: 5000,
            ),
          ],
          nextTimeSequenceId: '0',
        ),
      );

      final fakeAccounts = FakeAccountsRepository();
      final useCase = GetTransactions(
        fakeRepo,
        accountsRepository: fakeAccounts,
      );
      final resultEither = await useCase();

      expect(resultEither.isRight(), true);
      final result = resultEither.getOrElse(() => throw Exception());
      expect(result.items[0].sourceAccount, isNotNull);
      expect(result.items[0].sourceAccount!.name, 'Wallet (US Dollar)');
      expect(result.items[0].sourceAccount!.currencySymbol, r'$');

      expect(result.items[1].sourceAccount, isNotNull);
      expect(result.items[1].sourceAccount!.name, 'Credit Card');
      expect(result.items[1].sourceAccount!.currencySymbol, '€');
    });

    test('handles missing account gracefully with fallback', () async {
      final fakeRepo = FakeTransactionRepository(
        resultToReturn: const TransactionListResult(
          items: [
            Transaction(
              id: 'tx_no_acc',
              timeSequenceId: 'tx_no_acc',
              type: 3,
              categoryId: '2',
              time: 1789984800,
              utcOffset: 0,
              sourceAccountId: 'non_existent_account',
              sourceAmount: 1000,
            ),
          ],
          nextTimeSequenceId: '0',
        ),
      );

      final fakeAccounts = FakeAccountsRepository();
      final useCase = GetTransactions(
        fakeRepo,
        accountsRepository: fakeAccounts,
      );
      final resultEither = await useCase();

      expect(resultEither.isRight(), true);
      final result = resultEither.getOrElse(() => throw Exception());
      expect(result.items.first.sourceAccount, isNull);
    });

    test('handles modify balance transaction display title', () async {
      final fakeRepo = FakeTransactionRepository(
        resultToReturn: const TransactionListResult(
          items: [
            Transaction(
              id: 'tx_mod',
              timeSequenceId: 'tx_mod',
              type: 1, // Modify Balance
              categoryId: '2',
              time: 1789984800,
              utcOffset: 0,
              sourceAccountId: 'acc_wallet',
              sourceAmount: 50000,
            ),
          ],
          nextTimeSequenceId: '0',
        ),
      );

      final useCase = GetTransactions(fakeRepo);
      final resultEither = await useCase();

      expect(resultEither.isRight(), true);
      final result = resultEither.getOrElse(() => throw Exception());
      expect(result.items.first.displayTitle, 'Modify Balance');
      expect(result.items.first.isModifyBalance, true);
    });

    test(
      'fetches accounts in a single batch without N+1 requests for multiple transactions',
      () async {
        final transactions = List.generate(
          50,
          (i) => Transaction(
            id: 'tx_$i',
            timeSequenceId: 'tx_$i',
            type: 3,
            categoryId: '2',
            time: 1789984800 + i * 10,
            utcOffset: 0,
            sourceAccountId: i % 2 == 0 ? 'acc_wallet' : 'acc_credit',
            sourceAmount: 1000 + i * 100,
          ),
        );

        final fakeRepo = FakeTransactionRepository(
          resultToReturn: TransactionListResult(
            items: transactions,
            nextTimeSequenceId: '0',
          ),
        );

        final fakeAccounts = FakeAccountsRepository();
        final fakeCategories = FakeCategoriesRepository();
        final useCase = GetTransactions(
          fakeRepo,
          accountsRepository: fakeAccounts,
          categoriesRepository: fakeCategories,
        );
        final resultEither = await useCase();

        expect(resultEither.isRight(), true);
        final result = resultEither.getOrElse(() => throw Exception());
        expect(result.items.length, 50);
        expect(fakeAccounts.getAccountsCallCount, 1); // Exactly 1 call, no N+1!
        for (final item in result.items) {
          expect(item.category, isNotNull);
          expect(item.sourceAccount, isNotNull);
        }
      },
    );
  });

  group('TransactionBloc', () {
    late FakeTransactionRepository fakeRepo;
    late GetTransactions getTransactions;
    late TransactionBloc bloc;

    setUp(() {
      fakeRepo = FakeTransactionRepository(
        resultToReturn: const TransactionListResult(
          items: [
            Transaction(
              id: '1',
              timeSequenceId: '1',
              type: 3,
              categoryId: 'food',
              time: 1789984800,
              utcOffset: 0,
              sourceAccountId: 'acc1',
              sourceAmount: 1500,
            ),
          ],
          nextTimeSequenceId: '0',
        ),
      );
      getTransactions = GetTransactions(fakeRepo);
      bloc = TransactionBloc(getTransactions: getTransactions);
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is TransactionInitial', () {
      expect(bloc.state, isA<TransactionInitial>());
    });

    test(
      'emits [TransactionLoading, TransactionLoaded] on LoadTransactions success',
      () async {
        final expectedStates = [
          isA<TransactionLoading>(),
          isA<TransactionLoaded>(),
        ];

        expectLater(bloc.stream, emitsInOrder(expectedStates));
        bloc.add(const LoadTransactions());
      },
    );

    test('emits [TransactionLoading, TransactionError] on failure', () async {
      fakeRepo.failureToReturn = const NetworkFailure(
        'Network connection failed',
      );

      final expectedStates = [
        isA<TransactionLoading>(),
        isA<TransactionError>().having(
          (e) => e.message,
          'message',
          'Network connection failed',
        ),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));
      bloc.add(const LoadTransactions());
    });

    test('emits TransactionLoaded on RefreshTransactions event', () async {
      final expectedStates = [isA<TransactionLoaded>()];

      expectLater(bloc.stream, emitsInOrder(expectedStates));
      bloc.add(const RefreshTransactions());
    });
  });

  group('TransactionListScreen Widget Tests', () {
    late FakeTransactionRepository fakeRepo;
    late GetTransactions getTransactions;
    late TransactionBloc bloc;

    setUp(() {
      fakeRepo = FakeTransactionRepository(
        resultToReturn: const TransactionListResult(
          items: [
            Transaction(
              id: '1',
              timeSequenceId: '1',
              type: 3,
              categoryId: 'food',
              time: 1789984800,
              utcOffset: 0,
              sourceAccountId: 'acc1',
              sourceAmount: 1850,
              comment: 'Lunch with colleagues',
            ),
            Transaction(
              id: '2',
              timeSequenceId: '2',
              type: 2,
              categoryId: 'salary',
              time: 1789984800,
              utcOffset: 0,
              sourceAccountId: 'acc1',
              sourceAmount: 50000,
              comment: 'Bonus pay',
            ),
          ],
          nextTimeSequenceId: '0',
        ),
      );
      getTransactions = GetTransactions(fakeRepo);
      bloc = TransactionBloc(getTransactions: getTransactions);
    });

    tearDown(() {
      bloc.close();
    });

    testWidgets(
      'renders loaded transactions, month header amounts, and items',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(home: TransactionListScreen(bloc: bloc)),
        );

        // Initially Loading
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        });
        await tester.pump();

        // Verify Screen Elements
        expect(find.text('Transaction List'), findsOneWidget);
        expect(find.text('Lunch with colleagues'), findsOneWidget);
        expect(find.text('Bonus pay'), findsOneWidget);
        expect(find.text(r'+$ 500.00'), findsOneWidget); // Month header income
        expect(find.text(r'$ 500.00'), findsOneWidget); // Item income amount
        expect(find.text(r'-$ 18.50'), findsOneWidget); // Month header expense
        expect(find.text(r'$ 18.50'), findsOneWidget); // Item expense amount
      },
    );

    testWidgets('displays error state and retries on button tap', (
      tester,
    ) async {
      fakeRepo.failureToReturn = const ServerFailure(
        'Could not connect to ezBookkeeping server',
      );

      await tester.pumpWidget(
        MaterialApp(home: TransactionListScreen(bloc: bloc)),
      );

      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      expect(
        find.text('Could not connect to ezBookkeeping server'),
        findsOneWidget,
      );
      expect(find.text('Retry'), findsOneWidget);

      // Clear error and tap retry
      fakeRepo.failureToReturn = null;
      await tester.tap(find.text('Retry'));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      expect(find.text('Lunch with colleagues'), findsOneWidget);
    });

    testWidgets('displays empty state when no transactions exist', (
      tester,
    ) async {
      fakeRepo.resultToReturn = const TransactionListResult(
        items: [],
        nextTimeSequenceId: '0',
      );

      await tester.pumpWidget(
        MaterialApp(home: TransactionListScreen(bloc: bloc)),
      );

      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      expect(find.text('No transactions found'), findsOneWidget);
    });

    testWidgets(
      'TransactionListScreen initializes with accountId and passes to request',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: TransactionListScreen(
              bloc: bloc,
              accountId: '3843885834860232705',
              accountName: 'Wallet (US Dollar)',
            ),
          ),
        );

        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        });
        await tester.pump();

        expect(fakeRepo.lastRequest?.accountIds, equals('3843885834860232705'));
        expect(find.text('Wallet (US Dollar)'), findsOneWidget);
      },
    );
  });

  group('ServiceLocator Registration', () {
    setUp(() async {
      await getIt.reset();
    });

    tearDown(() async {
      await getIt.reset();
    });

    test('registers all transaction dependencies properly', () async {
      final mockDio = Dio(
        BaseOptions(baseUrl: 'https://ezbookkeeping-demo.mayswind.net'),
      );
      mockDio.httpClientAdapter = MockHttpAdapter();

      await setupDependencies(dio: mockDio);

      expect(getIt.isRegistered<TransactionRemoteDataSource>(), true);
      expect(getIt.isRegistered<TransactionRepository>(), true);
      expect(getIt.isRegistered<GetTransactions>(), true);
      expect(getIt.isRegistered<AddTransactionUseCase>(), true);
      expect(getIt.isRegistered<TransactionBloc>(), true);

      final resolvedBloc = getIt<TransactionBloc>();
      expect(resolvedBloc, isNotNull);
      await resolvedBloc.close();
    });
  });
}
