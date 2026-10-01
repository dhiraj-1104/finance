import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/features/accounts/data/models/add_account_request_model.dart';
import 'package:ezbookkeeping/features/accounts/domain/entities/account.dart';
import 'package:ezbookkeeping/features/accounts/domain/repositories/accounts_repository.dart';
import 'package:ezbookkeeping/features/accounts/domain/usecases/get_accounts_use_case.dart';
import 'package:ezbookkeeping/features/accounts/presentation/account_list_screen.dart';
import 'package:ezbookkeeping/features/accounts/presentation/add_account_screen.dart';
import 'package:ezbookkeeping/features/accounts/presentation/bloc/accounts_bloc.dart';
import 'package:ezbookkeeping/features/accounts/presentation/bloc/accounts_state.dart';

class FakeAccountsBloc extends AccountsBloc {
  final AccountsState initialState;

  FakeAccountsBloc(this.initialState)
      : super(
          getAccounts: (GetAccountsUseCase).toString() == '' ? getIt() : _FakeGetAccountsUseCase(),
        );

  @override
  AccountsState get state => initialState;

  @override
  Stream<AccountsState> get stream => Stream.value(initialState);
}

class _FakeGetAccountsUseCase extends GetAccountsUseCase {
  _FakeGetAccountsUseCase() : super(FakeAccountsRepo());
}

class FakeAccountsRepo implements AccountsRepository {
  @override
  Future<Either<Failure, List<Account>>> getAccounts({bool visibleOnly = false}) async {
    return const Right([]);
  }

  @override
  Future<Either<Failure, Account>> addAccount(AddAccountRequestModel request) async {
    throw UnimplementedError();
  }
}

void main() {
  late PreferencesController preferencesController;

  setUp(() {
    if (getIt.isRegistered<PreferencesController>()) {
      getIt.unregister<PreferencesController>();
    }
    preferencesController = PreferencesController();
    getIt.registerSingleton<PreferencesController>(preferencesController);
  });

  tearDown(() {
    if (getIt.isRegistered<PreferencesController>()) {
      getIt.unregister<PreferencesController>();
    }
  });

  group('Category Sequence Tests in Account & Add Account Screens', () {
    testWidgets(
        'AddAccountScreen displays categories in the sequence configured in PreferencesController',
        (tester) async {
      final customOrder = [
        'Investment Account',
        'Credit Card',
        'Savings Account',
        'Cash',
        'Checking Account',
      ];
      preferencesController.setAccountCategories(customOrder);

      await tester.pumpWidget(
        const MaterialApp(
          home: AddAccountScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap to open Account Category picker
      await tester.tap(find.text('Account Category').first);
      await tester.pumpAndSettle();

      // Verify custom categories are rendered
      for (final cat in customOrder) {
        expect(find.text(cat), findsWidgets);
      }

      // Verify first displayed category is Investment Account
      final listTiles = tester.widgetList<ListTile>(find.byType(ListTile)).toList();
      expect((listTiles.first.title as Text).data, 'Investment Account');
    });

    testWidgets(
        'AccountListScreen renders account groups sorted by PreferencesController category sequence',
        (tester) async {
      final customOrder = [
        'Investment Account',
        'Credit Card',
        'Cash',
      ];
      preferencesController.setAccountCategories(customOrder);

      const accCash = Account(
        id: '1',
        name: 'Cash In Hand',
        parentId: '0',
        category: 1, // Cash
        type: 1,
        icon: '1',
        iconType: 0,
        color: '#000000',
        currency: 'USD',
        balance: 10000,
      );

      const accCard = Account(
        id: '2',
        name: 'My Visa',
        parentId: '0',
        category: 3, // Credit Card
        type: 1,
        icon: '100',
        iconType: 0,
        color: '#000000',
        currency: 'USD',
        balance: 5000,
      );

      const accInvest = Account(
        id: '3',
        name: 'Crypto Wallet',
        parentId: '0',
        category: 5, // Investment Account
        type: 1,
        icon: '200',
        iconType: 0,
        color: '#000000',
        currency: 'USD',
        balance: 250000,
      );

      final fakeBloc = FakeAccountsBloc(
        const AccountsLoaded(accounts: [accCash, accCard, accInvest]),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: AccountListScreen(bloc: fakeBloc),
        ),
      );
      await tester.pumpAndSettle();

      // Verify items appear in custom sequence: Crypto Wallet (Investment) -> My Visa (Credit Card) -> Cash In Hand (Cash)
      final textWidgets = tester.widgetList<Text>(find.byType(Text)).map((t) => t.data).where((t) => t != null).toList();
      final cryptoIndex = textWidgets.indexOf('Crypto Wallet');
      final visaIndex = textWidgets.indexOf('My Visa');
      final cashIndex = textWidgets.indexOf('Cash In Hand');

      expect(cryptoIndex, isNot(-1));
      expect(visaIndex, isNot(-1));
      expect(cashIndex, isNot(-1));
      expect(cryptoIndex < visaIndex, isTrue);
      expect(visaIndex < cashIndex, isTrue);
    });
  });
}
