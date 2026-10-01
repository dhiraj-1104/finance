import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/core/network/api_endpoints.dart';
import 'package:ezbookkeeping/features/accounts/data/datasources/accounts_remote_data_source.dart';
import 'package:ezbookkeeping/features/accounts/data/models/account_list_response_model.dart';
import 'package:ezbookkeeping/features/accounts/data/models/account_model.dart';
import 'package:ezbookkeeping/features/accounts/data/models/account_response_model.dart';
import 'package:ezbookkeeping/features/accounts/data/models/add_account_request_model.dart';
import 'package:ezbookkeeping/features/accounts/data/repositories/accounts_repository_impl.dart';
import 'package:ezbookkeeping/features/accounts/domain/entities/account.dart';
import 'package:ezbookkeeping/features/accounts/domain/repositories/accounts_repository.dart';
import 'package:ezbookkeeping/features/accounts/domain/usecases/add_account_use_case.dart';
import 'package:ezbookkeeping/features/accounts/domain/usecases/get_accounts_use_case.dart';
import 'package:ezbookkeeping/features/accounts/data/models/account_item.dart';
import 'package:ezbookkeeping/features/accounts/presentation/account_list_screen.dart';
import 'package:ezbookkeeping/features/accounts/presentation/add_account_screen.dart';
import 'package:ezbookkeeping/features/accounts/presentation/bloc/accounts_bloc.dart';
import 'package:ezbookkeeping/features/accounts/presentation/bloc/accounts_event.dart';
import 'package:ezbookkeeping/features/accounts/presentation/bloc/accounts_state.dart';

// Fake RemoteDataSource for testing
class FakeAccountsRemoteDataSource implements AccountsRemoteDataSource {
  AccountListResponseModel? responseToReturn;
  AccountModel? addAccountModelToReturn;
  Exception? errorToThrow;
  String? lastEndpoint;
  Map<String, dynamic>? lastQueryParams;
  Map<String, dynamic>? lastPostData;

  @override
  Future<AccountListResponseModel> getAccounts({
    bool visibleOnly = false,
  }) async {
    lastEndpoint = ApiEndpoints.accountList;
    lastQueryParams = {'visible_only': visibleOnly};

    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    return responseToReturn ??
        const AccountListResponseModel(result: [], success: true);
  }

  @override
  Future<AccountModel> addAccount(AddAccountRequestModel request) async {
    lastEndpoint = ApiEndpoints.addAccount;
    lastPostData = request.toJson();

    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    return addAccountModelToReturn ??
        const AccountModel(
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
        );
  }
}

// Fake Repository for BLoC and Widget testing
class FakeAccountsRepository implements AccountsRepository {
  List<Account>? accountsToReturn;
  Account? accountCreatedToReturn;
  Failure? failureToReturn;
  Failure? addAccountFailureToReturn;
  bool? lastVisibleOnly;
  AddAccountRequestModel? lastAddRequest;

  @override
  Future<Either<Failure, List<Account>>> getAccounts({
    bool visibleOnly = false,
  }) async {
    lastVisibleOnly = visibleOnly;
    if (failureToReturn != null) {
      return Left(failureToReturn!);
    }
    return Right(accountsToReturn ?? []);
  }

  @override
  Future<Either<Failure, Account>> addAccount(
    AddAccountRequestModel request,
  ) async {
    lastAddRequest = request;
    if (addAccountFailureToReturn != null) {
      return Left(addAccountFailureToReturn!);
    }
    return Right(
      accountCreatedToReturn ??
          const Account(
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
  group('Account Data Models & Entity Mapping', () {
    const rawAccountJson = {
      'id': '3843885834860232704',
      'name': 'Wallet',
      'parentId': '0',
      'category': 1,
      'type': 2,
      'icon': '1',
      'iconType': 0,
      'color': '000000',
      'currency': '---',
      'balance': '0',
      'comment': 'Cash container',
      'displayOrder': 1,
      'isAsset': true,
      'hidden': false,
      'subAccounts': [
        {
          'id': '3843885834860232705',
          'name': 'Wallet (US Dollar)',
          'parentId': '3843885834860232704',
          'category': 1,
          'type': 1,
          'icon': '1',
          'iconType': 0,
          'color': '000000',
          'currency': 'USD',
          'balance': '23530',
          'comment': '',
          'displayOrder': 1,
          'isAsset': true,
          'hidden': false,
        },
        {
          'id': '3843885834860232706',
          'name': 'Wallet (Euro)',
          'parentId': '3843885834860232704',
          'category': 1,
          'type': 1,
          'icon': '1',
          'iconType': 0,
          'color': '2196f3',
          'currency': 'EUR',
          'balance': '850',
          'comment': '',
          'displayOrder': 2,
          'isAsset': true,
          'hidden': false,
        },
      ],
    };

    test('AccountModel parses JSON and subAccounts correctly', () {
      final model = AccountModel.fromJson(rawAccountJson);

      expect(model.id, equals('3843885834860232704'));
      expect(model.name, equals('Wallet'));
      expect(model.category, equals(1));
      expect(model.type, equals(2));
      expect(model.isAsset, isTrue);
      expect(model.subAccounts.length, equals(2));
      expect(model.subAccounts[0].name, equals('Wallet (US Dollar)'));
      expect(model.subAccounts[0].balance, equals(23530));
      expect(model.subAccounts[0].currency, equals('USD'));
      expect(model.subAccounts[1].name, equals('Wallet (Euro)'));
      expect(model.subAccounts[1].balance, equals(850));
      expect(model.subAccounts[1].color, equals('2196f3'));
    });

    test('AccountModel converts to domain Account entity', () {
      final model = AccountModel.fromJson(rawAccountJson);
      final entity = model.toEntity();

      expect(entity.id, equals('3843885834860232704'));
      expect(entity.name, equals('Wallet'));
      expect(entity.categoryName, equals('Cash'));
      expect(entity.isParentAccount, isTrue);
      expect(entity.subAccounts.length, equals(2));
      expect(entity.subAccounts[0].actualBalance, equals(235.30));
      expect(entity.subAccounts[0].formattedBalance, equals(r'$ 235.30'));
      expect(entity.subAccounts[1].actualBalance, equals(8.50));
      expect(entity.subAccounts[1].formattedBalance, equals('€ 8.50'));
    });

    test('AccountListResponseModel parses envelope with items and success', () {
      final fullResponseJson = {
        'success': true,
        'result': [rawAccountJson],
      };

      final responseModel = AccountListResponseModel.fromJson(fullResponseJson);
      expect(responseModel.success, isTrue);
      expect(responseModel.result.length, equals(1));
      expect(responseModel.result[0].name, equals('Wallet'));
    });
  });

  group('AddAccountRequestModel & AccountResponseModel', () {
    test('AddAccountRequestModel serializes correctly to JSON', () {
      const request = AddAccountRequestModel(
        name: 'cash',
        parentId: '0',
        category: 1,
        type: 1,
        icon: '1',
        iconType: 0,
        color: '000000',
        currency: 'USD',
        balance: '500000',
        balanceTime: 1727100000,
        comment: 'My test account',
      );

      final json = request.toJson();
      expect(json['name'], equals('cash'));
      expect(json['parentId'], equals('0'));
      expect(json['category'], equals(1));
      expect(json['type'], equals(1));
      expect(json['icon'], equals('1'));
      expect(json['iconType'], equals(0));
      expect(json['color'], equals('000000'));
      expect(json['currency'], equals('USD'));
      expect(json['balance'], equals('500000'));
      expect(json['balanceTime'], equals(1727100000));
      expect(json['comment'], equals('My test account'));
    });

    test('AddAccountRequestModel deserializes correctly from JSON', () {
      final json = {
        'name': 'savings',
        'parentId': '0',
        'category': 6,
        'type': 1,
        'icon': '2',
        'iconType': 0,
        'color': 'ff9800',
        'currency': 'EUR',
        'balance': '120000',
        'balanceTime': 1727100000,
        'comment': '',
      };

      final model = AddAccountRequestModel.fromJson(json);
      expect(model.name, equals('savings'));
      expect(model.category, equals(6));
      expect(model.color, equals('ff9800'));
      expect(model.currency, equals('EUR'));
      expect(model.balance, equals('120000'));
      expect(model.balanceTime, equals(1727100000));
    });

    test('AccountResponseModel parses single account response', () {
      final responseJson = {
        'result': {
          'id': '3844343008359088128',
          'name': 'cash',
          'parentId': '0',
          'category': 1,
          'type': 1,
          'icon': '1',
          'iconType': 0,
          'color': '000000',
          'currency': 'USD',
          'balance': '500000',
          'comment': '',
          'displayOrder': 2,
          'isAsset': true,
          'hidden': false,
        },
        'success': true,
      };

      final response = AccountResponseModel.fromJson(responseJson);
      expect(response.success, isTrue);
      expect(response.result, isNotNull);
      expect(response.result!.id, equals('3844343008359088128'));
      expect(response.result!.name, equals('cash'));
      expect(response.result!.balance, equals(500000));
      expect(response.result!.currency, equals('USD'));
    });
  });

  group('AccountItem UI Mapper', () {
    test('AccountItem.fromEntity converts entity accurately', () {
      const parentEntity = Account(
        id: '1',
        name: 'Wallet',
        parentId: '0',
        category: 1,
        type: 2,
        icon: '1',
        iconType: 0,
        color: '000000',
        currency: '---',
        balance: 0,
        subAccounts: [
          Account(
            id: '2',
            name: 'Wallet (US Dollar)',
            parentId: '1',
            category: 1,
            type: 1,
            icon: '1',
            iconType: 0,
            color: '000000',
            currency: 'USD',
            balance: 23530,
          ),
          Account(
            id: '3',
            name: 'Wallet (Euro)',
            parentId: '1',
            category: 1,
            type: 1,
            icon: '1',
            iconType: 0,
            color: '2196f3',
            currency: 'EUR',
            balance: 850,
          ),
        ],
      );

      final uiItem = AccountItem.fromEntity(parentEntity);
      expect(uiItem.name, equals('Wallet'));
      expect(uiItem.hasSubAccounts, isTrue);
      expect(uiItem.subAccounts.length, equals(2));
      expect(uiItem.subAccounts[0].name, equals('Wallet (US Dollar)'));
      expect(uiItem.subAccounts[0].balance, equals(235.30));
      expect(uiItem.subAccounts[1].color, equals(const Color(0xFF2196F3)));
    });
  });

  group('Accounts Remote DataSource & Repository', () {
    late FakeAccountsRemoteDataSource fakeDataSource;
    late AccountsRepositoryImpl repository;

    setUp(() {
      fakeDataSource = FakeAccountsRemoteDataSource();
      repository = AccountsRepositoryImpl(remoteDataSource: fakeDataSource);
    });

    test(
      'RemoteDataSource calls accountList endpoint with visible_only',
      () async {
        fakeDataSource.responseToReturn = const AccountListResponseModel(
          result: [],
          success: true,
        );

        await fakeDataSource.getAccounts(visibleOnly: false);
        expect(fakeDataSource.lastEndpoint, equals(ApiEndpoints.accountList));
        expect(fakeDataSource.lastQueryParams, equals({'visible_only': false}));
      },
    );

    test(
      'RemoteDataSource calls addAccount endpoint with request body',
      () async {
        const request = AddAccountRequestModel(
          name: 'Investment',
          parentId: '0',
          category: 4,
          type: 1,
          icon: '1',
          iconType: 0,
          color: 'ff0000',
          currency: 'USD',
          balance: '100000',
          comment: '',
        );

        fakeDataSource.addAccountModelToReturn = const AccountModel(
          id: 'new_inv_id',
          name: 'Investment',
          parentId: '0',
          category: 4,
          type: 1,
          icon: '1',
          iconType: 0,
          color: 'ff0000',
          currency: 'USD',
          balance: 100000,
        );

        final resp = await fakeDataSource.addAccount(request);
        expect(fakeDataSource.lastEndpoint, equals(ApiEndpoints.addAccount));
        expect(fakeDataSource.lastPostData?['name'], equals('Investment'));
        expect(resp.id, equals('new_inv_id'));
      },
    );

    test(
      'Repository converts response to domain entities on getAccounts success',
      () async {
        fakeDataSource.responseToReturn = const AccountListResponseModel(
          result: [
            AccountModel(
              id: 'acc_1',
              name: 'Bank Account',
              parentId: '0',
              category: 2,
              type: 1,
              icon: '100',
              iconType: 0,
              color: 'ff2d55',
              currency: 'USD',
              balance: 352100,
            ),
          ],
          success: true,
        );

        final result = await repository.getAccounts();
        expect(result.isRight(), isTrue);
        expect(result.getOrElse(() => []), hasLength(1));
      },
    );

    test(
      'Repository returns Left(ServerFailure) when getAccounts success is false',
      () async {
        fakeDataSource.responseToReturn = const AccountListResponseModel(
          result: [],
          success: false,
        );

        final result = await repository.getAccounts();
        expect(result.isLeft(), isTrue);
      },
    );

    test('Repository addAccount returns Right(Account) on success', () async {
      const request = AddAccountRequestModel(
        name: 'Cash',
        parentId: '0',
        category: 1,
        type: 1,
        icon: '1',
        iconType: 0,
        color: '000000',
        currency: 'USD',
        balance: '500000',
        comment: '',
      );

      fakeDataSource.addAccountModelToReturn = const AccountModel(
        id: '3844343008359088128',
        name: 'Cash',
        parentId: '0',
        category: 1,
        type: 1,
        icon: '1',
        iconType: 0,
        color: '000000',
        currency: 'USD',
        balance: 500000,
      );

      final result = await repository.addAccount(request);
      expect(result.isRight(), isTrue);
      result.fold((f) => fail('Expected success'), (account) {
        expect(account.id, equals('3844343008359088128'));
        expect(account.name, equals('Cash'));
        expect(account.actualBalance, equals(5000.0));
      });
    });

    test(
      'Repository addAccount returns Left(ServerFailure) on failure response',
      () async {
        const request = AddAccountRequestModel(
          name: 'Fail Account',
          parentId: '0',
          category: 1,
          type: 1,
          icon: '1',
          iconType: 0,
          color: '000000',
          currency: 'USD',
          balance: '0',
          comment: '',
        );

        fakeDataSource.errorToThrow = Exception('Failed to create account.');

        final result = await repository.addAccount(request);
        expect(result.isLeft(), isTrue);
      },
    );
  });

  group('UseCases', () {
    test(
      'GetAccountsUseCase executes repository and forwards result',
      () async {
        final fakeRepo = FakeAccountsRepository();
        fakeRepo.accountsToReturn = [
          const Account(
            id: 'acc_test',
            name: 'Savings',
            parentId: '0',
            category: 6,
            type: 1,
            icon: '1',
            iconType: 0,
            color: '000000',
            currency: 'USD',
            balance: 10000,
          ),
        ];

        final useCase = GetAccountsUseCase(fakeRepo);
        final result = await useCase();

        expect(result.isRight(), isTrue);
        final accounts = result.getOrElse(() => []);
        expect(accounts.length, equals(1));
        expect(accounts.first.name, equals('Savings'));
        expect(fakeRepo.lastVisibleOnly, isFalse);
      },
    );

    test('AddAccountUseCase executes repository and forwards result', () async {
      final fakeRepo = FakeAccountsRepository();
      fakeRepo.accountCreatedToReturn = const Account(
        id: 'acc_new_1',
        name: 'Investment',
        parentId: '0',
        category: 4,
        type: 1,
        icon: '1',
        iconType: 0,
        color: 'ff0000',
        currency: 'USD',
        balance: 200000,
      );

      const request = AddAccountRequestModel(
        name: 'Investment',
        parentId: '0',
        category: 4,
        type: 1,
        icon: '1',
        iconType: 0,
        color: 'ff0000',
        currency: 'USD',
        balance: '200000',
        comment: '',
      );

      final useCase = AddAccountUseCase(fakeRepo);
      final result = await useCase(request);

      expect(result.isRight(), isTrue);
      expect(
        result
            .getOrElse(
              () => const Account(
                id: '',
                name: '',
                parentId: '',
                category: 0,
                type: 0,
                icon: '',
                iconType: 0,
                color: '',
                currency: '',
                balance: 0,
              ),
            )
            .name,
        equals('Investment'),
      );
      expect(fakeRepo.lastAddRequest?.name, equals('Investment'));
    });
  });

  group('AccountsBloc', () {
    late FakeAccountsRepository fakeRepo;
    late GetAccountsUseCase getAccountsUseCase;
    late AddAccountUseCase addAccountUseCase;
    late AccountsBloc bloc;

    setUp(() {
      fakeRepo = FakeAccountsRepository();
      getAccountsUseCase = GetAccountsUseCase(fakeRepo);
      addAccountUseCase = AddAccountUseCase(fakeRepo);
      bloc = AccountsBloc(
        getAccounts: getAccountsUseCase,
        addAccount: addAccountUseCase,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is AccountsInitial', () {
      expect(bloc.state, isA<AccountsInitial>());
    });

    test('emits [AccountsLoading, AccountsLoaded] on LoadAccounts success', () {
      fakeRepo.accountsToReturn = [
        const Account(
          id: '1',
          name: 'Cash Account',
          parentId: '0',
          category: 1,
          type: 1,
          icon: '1',
          iconType: 0,
          color: '000000',
          currency: 'USD',
          balance: 5000,
        ),
      ];

      expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AccountsLoading>(),
          isA<AccountsLoaded>().having(
            (s) => s.accounts.first.name,
            'name',
            'Cash Account',
          ),
        ]),
      );

      bloc.add(const LoadAccounts());
    });

    test('emits [AccountsLoading, AccountsError] on LoadAccounts failure', () {
      fakeRepo.failureToReturn = const UnauthorizedFailure(
        'Unauthorized access',
      );

      expectLater(
        bloc.stream,
        emitsInOrder([
          isA<AccountsLoading>(),
          isA<AccountsError>().having(
            (s) => s.message,
            'message',
            'Unauthorized access',
          ),
        ]),
      );

      bloc.add(const LoadAccounts());
    });

    test('emits AccountsLoaded on RefreshAccounts event', () {
      fakeRepo.accountsToReturn = [];

      expectLater(bloc.stream, emitsInOrder([isA<AccountsLoaded>()]));

      bloc.add(const RefreshAccounts());
    });

    test(
      'emits [AccountCreating, AccountCreateSuccess, AccountsLoading, AccountsLoaded] on AddAccountRequested success',
      () {
        fakeRepo.accountCreatedToReturn = const Account(
          id: 'new_cash',
          name: 'New Cash Account',
          parentId: '0',
          category: 1,
          type: 1,
          icon: '1',
          iconType: 0,
          color: '000000',
          currency: 'USD',
          balance: 500000,
        );
        fakeRepo.accountsToReturn = [fakeRepo.accountCreatedToReturn!];

        const request = AddAccountRequestModel(
          name: 'New Cash Account',
          parentId: '0',
          category: 1,
          type: 1,
          icon: '1',
          iconType: 0,
          color: '000000',
          currency: 'USD',
          balance: '500000',
          comment: '',
        );

        expectLater(
          bloc.stream,
          emitsInOrder([
            isA<AccountCreating>(),
            isA<AccountCreateSuccess>().having(
              (s) => s.newAccount.name,
              'name',
              'New Cash Account',
            ),
            isA<AccountsLoading>(),
            isA<AccountsLoaded>().having((s) => s.accounts.length, 'length', 1),
          ]),
        );

        bloc.add(const AddAccountRequested(request));
      },
    );

    test(
      'emits [AccountCreating, AccountsError] on AddAccountRequested failure',
      () {
        fakeRepo.addAccountFailureToReturn = const ServerFailure(
          'Backend validation error',
        );

        const request = AddAccountRequestModel(
          name: 'Invalid Account',
          parentId: '0',
          category: 1,
          type: 1,
          icon: '1',
          iconType: 0,
          color: '000000',
          currency: 'USD',
          balance: '0',
          comment: '',
        );

        expectLater(
          bloc.stream,
          emitsInOrder([
            isA<AccountCreating>(),
            isA<AccountsError>().having(
              (s) => s.message,
              'message',
              'Backend validation error',
            ),
          ]),
        );

        bloc.add(const AddAccountRequested(request));
      },
    );
  });

  group('AccountListScreen Widget Tests', () {
    late FakeAccountsRepository fakeRepo;
    late GetAccountsUseCase useCase;
    late AccountsBloc bloc;

    setUp(() {
      fakeRepo = FakeAccountsRepository();
      fakeRepo.accountsToReturn = [
        const Account(
          id: '1',
          name: 'Wallet',
          parentId: '0',
          category: 1,
          type: 2,
          icon: '1',
          iconType: 0,
          color: '000000',
          currency: '---',
          balance: 0,
          isAsset: true,
          subAccounts: [
            Account(
              id: '2',
              name: 'Wallet (US Dollar)',
              parentId: '1',
              category: 1,
              type: 1,
              icon: '1',
              iconType: 0,
              color: '000000',
              currency: 'USD',
              balance: 23530,
              isAsset: true,
            ),
            Account(
              id: '3',
              name: 'Wallet (Euro)',
              parentId: '1',
              category: 1,
              type: 1,
              icon: '1',
              iconType: 0,
              color: '2196f3',
              currency: 'EUR',
              balance: 850,
              isAsset: true,
            ),
          ],
        ),
        const Account(
          id: '4',
          name: 'Bank Account',
          parentId: '0',
          category: 2,
          type: 1,
          icon: '100',
          iconType: 0,
          color: 'ff2d55',
          currency: 'USD',
          balance: 352100,
          isAsset: true,
        ),
        const Account(
          id: '5',
          name: 'Credit Card',
          parentId: '0',
          category: 3,
          type: 1,
          icon: '100',
          iconType: 0,
          color: '673ab7',
          currency: 'USD',
          balance: -195878,
          isLiability: true,
        ),
      ];

      useCase = GetAccountsUseCase(fakeRepo);
      bloc = AccountsBloc(getAccounts: useCase);
    });

    tearDown(() {
      bloc.close();
    });

    testWidgets('renders loaded accounts, hero net assets, and items', (
      tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: AccountListScreen(bloc: bloc)));

      // Loading initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      // Verify Screen Elements
      expect(find.text('Account List'), findsOneWidget);
      expect(find.text('Net assets'), findsOneWidget);
      expect(find.text('Wallet'), findsWidgets);
      expect(find.text('Wallet (US Dollar)'), findsOneWidget);
      expect(find.text('Wallet (Euro)'), findsOneWidget);
      expect(find.text('Bank Account'), findsWidgets);
      expect(find.text('Credit Card'), findsWidgets);
    });

    testWidgets('displays error state and retries on button tap', (
      tester,
    ) async {
      fakeRepo.failureToReturn = const ServerFailure(
        'Could not connect to ezBookkeeping server',
      );

      await tester.pumpWidget(MaterialApp(home: AccountListScreen(bloc: bloc)));

      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      // Verify Error state
      expect(
        find.text('Could not connect to ezBookkeeping server'),
        findsOneWidget,
      );
      expect(find.text('Retry'), findsOneWidget);

      // Clear error and retry
      fakeRepo.failureToReturn = null;
      fakeRepo.accountsToReturn = [];

      await tester.tap(find.text('Retry'));
      await tester.pump();

      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      expect(find.text('No available account'), findsOneWidget);
      expect(find.text('Net assets'), findsOneWidget);
      expect(find.text(r'$ 0.00'), findsOneWidget);
    });

    testWidgets(
      'renders empty state with Hero card and No available account when accounts list is empty',
      (tester) async {
        fakeRepo.accountsToReturn = [];

        await tester.pumpWidget(
          MaterialApp(home: AccountListScreen(bloc: bloc)),
        );

        await tester.runAsync(() async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        });
        await tester.pump();

        // Verify Hero Card with zero assets
        expect(find.text('Account List'), findsOneWidget);
        expect(find.text('Net assets'), findsOneWidget);
        expect(find.text(r'$ 0.00'), findsOneWidget);
        expect(
          find.text('Total assets \$ 0.00 | Total liabilities \$ 0.00'),
          findsOneWidget,
        );

        // Verify No available account card
        expect(find.text('No available account'), findsOneWidget);

        // Verify Top Bar buttons
        expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
        expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);
        expect(find.byIcon(Icons.add_rounded), findsOneWidget);
      },
    );
  });

  group('AddAccountScreen Widget Tests', () {
    late FakeAccountsRepository fakeRepo;
    late GetAccountsUseCase getAccountsUseCase;
    late AddAccountUseCase addAccountUseCase;
    late AccountsBloc bloc;

    setUp(() {
      fakeRepo = FakeAccountsRepository();
      getAccountsUseCase = GetAccountsUseCase(fakeRepo);
      addAccountUseCase = AddAccountUseCase(fakeRepo);
      bloc = AccountsBloc(
        getAccounts: getAccountsUseCase,
        addAccount: addAccountUseCase,
      );
    });

    tearDown(() {
      bloc.close();
    });

    testWidgets('renders Add Account form fields and submits correctly', (
      tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: AddAccountScreen(bloc: bloc)));
      await tester.pumpAndSettle();

      expect(find.text('Add Account'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      expect(find.text('Account Name'), findsOneWidget);
      expect(find.text('Account Category'), findsOneWidget);
      expect(find.text('Account Type'), findsOneWidget);
      expect(find.text('Currency'), findsOneWidget);
      expect(find.text('Account Balance'), findsOneWidget);

      // Enter account name
      final nameField = find.widgetWithText(TextField, '');
      expect(nameField, findsWidgets);
      await tester.enterText(nameField.first, 'My Checking Account');
      await tester.pumpAndSettle();

      // Tap Check/Save button
      await tester.tap(find.byIcon(Icons.check_rounded));
      await tester.pump();

      expect(fakeRepo.lastAddRequest, isNotNull);
      expect(fakeRepo.lastAddRequest!.name, equals('My Checking Account'));
      expect(fakeRepo.lastAddRequest!.currency, equals('USD'));
      expect(fakeRepo.lastAddRequest!.category, equals(1)); // Cash default
      expect(fakeRepo.lastAddRequest!.balanceTime, isNotNull);
    });
  });

  group('AccountItem Credit Card Mapping', () {
    test('displays outstanding balance by default', () {
      const ccAccount = Account(
        id: 'cc_1',
        name: 'Visa Gold',
        parentId: '0',
        category: 3,
        type: 1,
        icon: '1',
        iconType: 1,
        color: 'C86D3B',
        currency: 'USD',
        balance: 25000,
        creditCardLimit: '100000',
        subAccounts: [],
      );

      final item = AccountItem.fromEntity(ccAccount);
      expect(item.balance, 250.0);
      expect(item.formattedBalance, r'$ 250.00');
    });

    test(
      'displays available credit when defaultCreditCardAmount is Available Credit',
      () {
        const ccAccount = Account(
          id: 'cc_1',
          name: 'Visa Gold',
          parentId: '0',
          category: 3,
          type: 1,
          icon: '1',
          iconType: 1,
          color: 'C86D3B',
          currency: 'USD',
          balance: 25000,
          creditCardLimit: '100000',
          subAccounts: [],
        );

        final item = AccountItem.fromEntity(
          ccAccount,
          defaultCreditCardAmount: 'Available Credit',
        );
        expect(item.balance, 750.0);
        expect(item.formattedBalance, r'$ 750.00');
      },
    );
  });

  group('ServiceLocator Registration', () {
    test('registers all accounts dependencies properly', () async {
      await setupDependencies();

      expect(getIt.isRegistered<AccountsRemoteDataSource>(), isTrue);
      expect(getIt.isRegistered<AccountsRepository>(), isTrue);
      expect(getIt.isRegistered<GetAccountsUseCase>(), isTrue);
      expect(getIt.isRegistered<AddAccountUseCase>(), isTrue);
      expect(getIt.isRegistered<AccountsBloc>(), isTrue);
    });
  });
}
