import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/features/home/presentation/home_page_layout_screen.dart';
import 'package:ezbookkeeping/features/home/presentation/home_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FakeSecureStorage extends FlutterSecureStorage {
  final Map<String, String> _data = {};

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      _data[key] = value;
    } else {
      _data.remove(key);
    }
  }

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _data[key];
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _data.remove(key);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeSecureStorage fakeSecureStorage;
  late PreferencesStorage preferencesStorage;
  late PreferencesController preferencesController;

  setUp(() async {
    if (getIt.isRegistered<PreferencesController>()) {
      getIt.unregister<PreferencesController>();
    }
    fakeSecureStorage = FakeSecureStorage();
    preferencesStorage = PreferencesStorage(secureStorage: fakeSecureStorage);
    preferencesController = PreferencesController(storage: preferencesStorage);
    getIt.registerSingleton<PreferencesController>(preferencesController);
  });

  tearDown(() {
    if (getIt.isRegistered<PreferencesController>()) {
      getIt.unregister<PreferencesController>();
    }
  });

  group('HomeLayoutWidget Model Tests', () {
    test('defaultHomeLayoutJson parses into default widgets', () {
      final widgets = defaultHomeLayoutWidgets;
      expect(widgets.length, 2);
      expect(widgets[0].type, 'current-month-overview');
      expect(widgets[0].displayName, 'Current Month Overview');
      expect(widgets[0].settings['lightBackgroundColor'], 'edddcd');
      expect(widgets[1].type, 'period-income-expense');
      expect(widgets[1].displayName, 'Period Income & Expense');
    });

    test('toJson and fromJson roundtrip serialization', () {
      const widget = HomeLayoutWidget(
        id: 'test-net-assets',
        type: 'net-assets',
        settings: {
          'height': 3,
          'lightBackgroundColor': 'edddcd',
          'darkBackgroundColor': '7f5e4b',
        },
      );
      final jsonMap = widget.toJson();
      final restored = HomeLayoutWidget.fromJson(jsonMap);

      expect(restored.id, 'test-net-assets');
      expect(restored.type, 'net-assets');
      expect(restored.displayName, 'Net Assets');
      expect(restored.settings['lightBackgroundColor'], 'edddcd');
      expect(restored.settings['darkBackgroundColor'], '7f5e4b');
    });

    test('copyWith works correctly', () {
      const widget = HomeLayoutWidget(
        id: 'widget-1',
        type: 'period-income-expense',
      );
      final copied = widget.copyWith(id: 'widget-2');
      expect(copied.id, 'widget-2');
      expect(copied.type, 'period-income-expense');
    });

    test('account-balance displayName is Account Balance', () {
      const widget = HomeLayoutWidget(
        id: 'w-account-balance',
        type: 'account-balance',
      );
      expect(widget.displayName, 'Account Balance');
    });

    test('month-expense displayName is Month Expense', () {
      const widget = HomeLayoutWidget(
        id: 'w-month-expense',
        type: 'month-expense',
      );
      expect(widget.displayName, 'Month Expense');
    });

    test(
        'period-net-income-savings-rate displayName is Period Net Income and Savings Rate',
        () {
      const widget = HomeLayoutWidget(
        id: 'w-savings-rate',
        type: 'period-net-income-savings-rate',
      );
      expect(widget.displayName, 'Period Net Income and Savings Rate');
    });

    test(
        'expense-category-ranking displayName is Expense Category Ranking',
        () {
      const widget = HomeLayoutWidget(
        id: 'w-ranking',
        type: 'expense-category-ranking',
      );
      expect(widget.displayName, 'Expense Category Ranking');
    });

    test('recent-transactions displayName is Recent Transactions', () {
      const widget = HomeLayoutWidget(
        id: 'w-recent',
        type: 'recent-transactions',
      );
      expect(widget.displayName, 'Recent Transactions');
    });

    test('transaction-calendar displayName is Transaction Calendar', () {
      const widget = HomeLayoutWidget(
        id: 'w-calendar',
        type: 'transaction-calendar',
      );
      expect(widget.displayName, 'Transaction Calendar');
    });

    test('add-transaction-button displayName is Add Transaction Button', () {
      const widget = HomeLayoutWidget(
        id: 'w-btn',
        type: 'add-transaction-button',
      );
      expect(widget.displayName, 'Add Transaction Button');
    });
  });

  group('PreferencesController Home Layout Management', () {
    test('defaults to default home layout', () {
      expect(preferencesController.homeLayoutWidgets.length, 2);
      expect(preferencesController.homeLayoutWidgets[0].type,
          'current-month-overview');
      expect(preferencesController.homeLayoutWidgets[1].type,
          'period-income-expense');
    });

    test('setHomeLayoutWidgets updates controller and persists to storage',
        () async {
      final newWidgets = [
        const HomeLayoutWidget(
          id: 'w-net-assets',
          type: 'net-assets',
        ),
      ];
      preferencesController.setHomeLayoutWidgets(newWidgets);

      expect(preferencesController.homeLayoutWidgets.length, 1);
      expect(preferencesController.homeLayoutWidgets[0].type, 'net-assets');

      // Verify persistence
      final savedJson = await preferencesStorage.getHomeLayoutJson();
      expect(savedJson, isNotNull);
      final decoded = jsonDecode(savedJson!);
      expect((decoded['widgets'] as List).length, 1);
      expect(decoded['widgets'][0]['type'], 'net-assets');
    });

    test('clearHomeLayout empties the layout', () {
      preferencesController.clearHomeLayout();
      expect(preferencesController.homeLayoutWidgets.isEmpty, isTrue);
    });

    test('resetHomeLayoutToDefault restores default layout', () {
      preferencesController.clearHomeLayout();
      expect(preferencesController.homeLayoutWidgets.isEmpty, isTrue);

      preferencesController.resetHomeLayoutToDefault();
      expect(preferencesController.homeLayoutWidgets.length, 2);
      expect(preferencesController.homeLayoutWidgets[0].type,
          'current-month-overview');
    });
  });

  group('HomePageLayoutScreen Widget Tests', () {
    void setupScreenSize(WidgetTester tester) {
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(500, 1000);
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    }

    testWidgets('renders top bar, actions button, and initial widgets',
        (tester) async {
      setupScreenSize(tester);

      await tester.pumpWidget(
        const MaterialApp(
          home: HomePageLayoutScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Home Page Layout'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);

      // Default widgets preview
      expect(find.textContaining('·Expense'), findsWidgets);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('This week'), findsOneWidget);
      expect(find.text('This month'), findsOneWidget);
      expect(find.text('This year'), findsOneWidget);
    });

    testWidgets('tapping ... opens action sheet with options', (tester) async {
      setupScreenSize(tester);

      await tester.pumpWidget(
        const MaterialApp(
          home: HomePageLayoutScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      expect(find.text('Add Widget'), findsOneWidget);
      expect(find.text('Reset to Default'), findsOneWidget);
      expect(find.text('Clear Layout'), findsOneWidget);
      expect(find.text('Import Layout'), findsOneWidget);
      expect(find.text('Export Layout'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('tapping Clear Layout clears preview widgets', (tester) async {
      setupScreenSize(tester);

      await tester.pumpWidget(
        const MaterialApp(
          home: HomePageLayoutScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Clear Layout'));
      await tester.pumpAndSettle();

      expect(find.text('No widgets in layout'), findsOneWidget);
    });

    testWidgets('tapping Reset to Default restores preview widgets',
        (tester) async {
      setupScreenSize(tester);

      preferencesController.clearHomeLayout();

      await tester.pumpWidget(
        const MaterialApp(
          home: HomePageLayoutScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No widgets in layout'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Reset to Default'));
      await tester.pumpAndSettle();

      expect(find.textContaining('·Expense'), findsWidgets);
      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('Export Layout dialog displays JSON and copy option',
        (tester) async {
      setupScreenSize(tester);

      await tester.pumpWidget(
        const MaterialApp(
          home: HomePageLayoutScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Export Layout'));
      await tester.pumpAndSettle();

      expect(find.text('Export Layout'), findsOneWidget);
      expect(find.byIcon(Icons.copy_outlined), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
    });

    testWidgets('Import Layout dialog allows importing valid JSON',
        (tester) async {
      setupScreenSize(tester);

      await tester.pumpWidget(
        const MaterialApp(
          home: HomePageLayoutScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Import Layout'));
      await tester.pumpAndSettle();

      expect(find.text('Import Layout'), findsOneWidget);
      expect(find.text('Import'), findsOneWidget);

      const customJson = '''{
  "widgets": [
    {
      "id": "test-net-assets",
      "type": "net-assets",
      "settings": {}
    }
  ]
}''';
      await tester.enterText(find.byType(TextField), customJson);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Import'));
      await tester.pumpAndSettle();

      expect(find.text('Net assets'), findsOneWidget);
    });

    testWidgets('Save button persists widgets and pops', (tester) async {
      setupScreenSize(tester);

      await tester.pumpWidget(
        const MaterialApp(
          home: HomePageLayoutScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Clear layout and save
      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear Layout'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.check));
      await tester.pump();

      expect(preferencesController.homeLayoutWidgets.isEmpty, isTrue);
    });

    testWidgets('tapping Add Widget allows adding Account Balance',
        (tester) async {
      setupScreenSize(tester);

      await tester.pumpWidget(
        const MaterialApp(
          home: HomePageLayoutScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Widget'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Account Balance'), findsOneWidget);
      expect(
        find.text('Balances of Wallet, Bank Account, and Credit Card'),
        findsOneWidget,
      );

      await tester.tap(find.textContaining('Account Balance'));
      await tester.pumpAndSettle();

      expect(find.text('Wallet'), findsOneWidget);
      expect(find.text('Bank Account'), findsOneWidget);
      expect(find.text('Credit Card'), findsOneWidget);
    });

    testWidgets('tapping Add Widget allows adding Month Expense',
        (tester) async {
      setupScreenSize(tester);

      await tester.pumpWidget(
        const MaterialApp(
          home: HomePageLayoutScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Widget'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Expense Progress'), findsOneWidget);
      expect(
        find.text('Month elapsed progress and estimated month-end expense'),
        findsOneWidget,
      );

      await tester.tap(find.textContaining('Expense Progress'));
      await tester.pumpAndSettle();

      expect(find.text(r'$ 5,541.25'), findsOneWidget);
      expect(find.text('Month elapsed'), findsOneWidget);
      expect(find.text('Estimated month-end expense'), findsOneWidget);
      expect(find.text('Last month total'), findsOneWidget);
    });

    testWidgets(
        'tapping Add Widget allows adding Period Net Income and Savings Rate',
        (tester) async {
      setupScreenSize(tester);

      await tester.pumpWidget(
        const MaterialApp(
          home: HomePageLayoutScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Widget'));
      await tester.pumpAndSettle();

      expect(
        find.text('Period Net Income and Savings Rate'),
        findsOneWidget,
      );
      expect(
        find.text('Net income, savings rate, and income/expense breakdown'),
        findsOneWidget,
      );

      await tester.tap(find.text('Period Net Income and Savings Rate'));
      await tester.pumpAndSettle();

      expect(find.text('Net Income'), findsOneWidget);
      expect(find.text(r'$ 658.75'), findsOneWidget);
      expect(find.text('Savings Rate'), findsOneWidget);
      expect(find.text('10.62%'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Expense'), findsOneWidget);
      expect(find.text(r'$ 6,200.00'), findsWidgets);
      expect(find.text(r'$ 5,541.25'), findsWidgets);
    });

    testWidgets(
        'tapping Add Widget allows adding Expense Category Ranking',
        (tester) async {
      setupScreenSize(tester);

      await tester.pumpWidget(
        const MaterialApp(
          home: HomePageLayoutScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Widget'));
      await tester.pumpAndSettle();

      expect(
        find.text('Expense Category Ranking'),
        findsOneWidget,
      );
      expect(
        find.text('Top expense categories ranked by percentage and amount'),
        findsOneWidget,
      );

      await tester.tap(find.text('Expense Category Ranking'));
      await tester.pumpAndSettle();

      expect(find.text('Housing & Houseware'), findsOneWidget);
      expect(find.text('Transportation'), findsOneWidget);
      expect(find.text('Food & Drink'), findsOneWidget);
      expect(find.text('Entertainment'), findsOneWidget);
      expect(find.text(r'$ 2,428.62'), findsOneWidget);
      expect(find.text(r'$ 1,095.93'), findsOneWidget);
      expect(find.text(r'$ 852.06'), findsOneWidget);
      expect(find.text(r'$ 465.98'), findsOneWidget);
    });

    testWidgets(
        'tapping Add Widget allows adding Recent Transactions',
        (tester) async {
      setupScreenSize(tester);

      await tester.pumpWidget(
        const MaterialApp(
          home: HomePageLayoutScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Widget'));
      await tester.pumpAndSettle();

      expect(
        find.text('Recent Transactions'),
        findsOneWidget,
      );
      expect(
        find.text('List of recent income, expense, and transfer records'),
        findsOneWidget,
      );

      await tester.tap(find.text('Recent Transactions'));
      await tester.pumpAndSettle();

      expect(find.text('Utilities Expense'), findsOneWidget);
      expect(find.text('gas bill'), findsOneWidget);
      expect(find.text('08:10 PM · Credit Card'), findsOneWidget);
      expect(find.text(r'$ 160.00'), findsOneWidget);
      expect(find.text('Credit Card Repay...'), findsOneWidget);
      expect(find.text('07:36 PM · Bank Account → Credit Card'), findsOneWidget);
      expect(find.text(r'$ 1,500.00'), findsOneWidget);
      expect(find.text('Investment Income'), findsOneWidget);
      expect(find.text('02:15 PM · Bank Account'), findsOneWidget);
      expect(find.text(r'$ 200.00'), findsOneWidget);
    });

    testWidgets(
        'tapping Add Widget allows adding Transaction Calendar',
        (tester) async {
      setupScreenSize(tester);

      await tester.pumpWidget(
        const MaterialApp(
          home: HomePageLayoutScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Clear Layout'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Widget'));
      await tester.pumpAndSettle();

      expect(
        find.text('Transaction Calendar'),
        findsOneWidget,
      );
      expect(
        find.text('Monthly calendar view of daily income and expense totals'),
        findsOneWidget,
      );

      await tester.scrollUntilVisible(
        find.widgetWithText(ListTile, 'Transaction Calendar'),
        50.0,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Transaction Calendar'));
      await tester.pumpAndSettle();

      expect(find.text('Sun'), findsOneWidget);
      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('Tue'), findsOneWidget);
      expect(find.text('Wed'), findsOneWidget);
      expect(find.text('Thu'), findsOneWidget);
      expect(find.text('Fri'), findsOneWidget);
      expect(find.text('Sat'), findsOneWidget);
      expect(find.text('6,000.00'), findsOneWidget);
      expect(find.text('29.12'), findsOneWidget);
      expect(find.text('1,075.30'), findsOneWidget);
      expect(find.text('2,075.00'), findsOneWidget);
    });

    testWidgets(
        'tapping Add Widget allows adding Add Transaction Button',
        (tester) async {
      setupScreenSize(tester);

      await tester.pumpWidget(
        const MaterialApp(
          home: HomePageLayoutScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Clear Layout'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.more_horiz));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add Widget'));
      await tester.pumpAndSettle();

      expect(
        find.text('Add Transaction Button'),
        findsOneWidget,
      );
      expect(
        find.text('Quick action button to record a new transaction'),
        findsOneWidget,
      );

      await tester.scrollUntilVisible(
        find.widgetWithText(ListTile, 'Add Transaction Button'),
        50.0,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Add Transaction Button'));
      await tester.pumpAndSettle();

      expect(find.text('Add Transaction'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsWidgets);
      expect(find.byIcon(Icons.keyboard_arrow_down), findsNothing);
    });
  });

  group('HomeScreen Dynamic Layout Reflection', () {
    testWidgets(
        'HomeScreen reflects layout updates dynamically from PreferencesController',
        (tester) async {
      // Set initial layout to net-assets only
      preferencesController.setHomeLayoutWidgets([
        const HomeLayoutWidget(
          id: 'test-net-assets',
          type: 'net-assets',
        ),
      ]);

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Net assets is visible
      expect(find.text('Net assets'), findsOneWidget);
      // Period card is not rendered
      expect(find.text('This week'), findsNothing);

      // Now dynamically update PreferencesController layout to include period card
      preferencesController.setHomeLayoutWidgets([
        const HomeLayoutWidget(
          id: 'period-1',
          type: 'period-income-expense',
        ),
      ]);
      await tester.pumpAndSettle();

      // Period card is now visible, net assets is gone!
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('This week'), findsOneWidget);
      expect(find.text('Net assets'), findsNothing);
    });

    testWidgets('HomeScreen renders Account Balance widget correctly',
        (tester) async {
      preferencesController.setHomeLayoutWidgets([
        const HomeLayoutWidget(
          id: 'account-balance-1',
          type: 'account-balance',
        ),
      ]);

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Wallet'), findsOneWidget);
      expect(find.text('Bank Account'), findsOneWidget);
      expect(find.text('Credit Card'), findsOneWidget);
      expect(find.text(r'$ 0.00'), findsWidgets);
    });

    testWidgets('HomeScreen renders Month Expense widget correctly',
        (tester) async {
      preferencesController.setHomeLayoutWidgets([
        const HomeLayoutWidget(
          id: 'month-expense-1',
          type: 'month-expense',
        ),
      ]);

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(r'$ 5,541.25'), findsOneWidget);
      expect(find.text('Month elapsed'), findsOneWidget);
      expect(find.text('Estimated month-end expense'), findsOneWidget);
      expect(find.text('Last month total'), findsOneWidget);
    });

    testWidgets(
        'HomeScreen renders Period Net Income and Savings Rate widget correctly',
        (tester) async {
      preferencesController.setHomeLayoutWidgets([
        const HomeLayoutWidget(
          id: 'savings-rate-1',
          type: 'period-net-income-savings-rate',
        ),
      ]);

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Net Income'), findsOneWidget);
      expect(find.text(r'$ 658.75'), findsOneWidget);
      expect(find.text('Savings Rate'), findsOneWidget);
      expect(find.text('10.62%'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Expense'), findsOneWidget);
      expect(find.text(r'$ 6,200.00'), findsWidgets);
      expect(find.text(r'$ 5,541.25'), findsWidgets);
    });

    testWidgets(
        'HomeScreen renders Expense Category Ranking widget correctly',
        (tester) async {
      preferencesController.setHomeLayoutWidgets([
        const HomeLayoutWidget(
          id: 'category-ranking-1',
          type: 'expense-category-ranking',
        ),
      ]);

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Housing & Houseware'), findsOneWidget);
      expect(find.text('Transportation'), findsOneWidget);
      expect(find.text('Food & Drink'), findsOneWidget);
      expect(find.text('Entertainment'), findsOneWidget);
      expect(find.text(r'$ 2,428.62'), findsOneWidget);
      expect(find.text(r'$ 1,095.93'), findsOneWidget);
      expect(find.text(r'$ 852.06'), findsOneWidget);
      expect(find.text(r'$ 465.98'), findsOneWidget);
    });

    testWidgets('HomeScreen renders Recent Transactions widget correctly',
        (tester) async {
      preferencesController.setHomeLayoutWidgets([
        const HomeLayoutWidget(
          id: 'recent-1',
          type: 'recent-transactions',
        ),
      ]);

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Utilities Expense'), findsOneWidget);
      expect(find.text('gas bill'), findsOneWidget);
      expect(find.text('08:10 PM · Credit Card'), findsOneWidget);
      expect(find.text(r'$ 160.00'), findsOneWidget);
      expect(find.text('Credit Card Repay...'), findsOneWidget);
      expect(find.text('07:36 PM · Bank Account → Credit Card'), findsOneWidget);
      expect(find.text(r'$ 1,500.00'), findsOneWidget);
      expect(find.text('Investment Income'), findsOneWidget);
      expect(find.text('02:15 PM · Bank Account'), findsOneWidget);
      expect(find.text(r'$ 200.00'), findsOneWidget);
    });

    testWidgets('HomeScreen renders Transaction Calendar widget correctly',
        (tester) async {
      preferencesController.setHomeLayoutWidgets([
        const HomeLayoutWidget(
          id: 'calendar-1',
          type: 'transaction-calendar',
        ),
      ]);

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sun'), findsOneWidget);
      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('Tue'), findsOneWidget);
      expect(find.text('Wed'), findsOneWidget);
      expect(find.text('Thu'), findsOneWidget);
      expect(find.text('Fri'), findsOneWidget);
      expect(find.text('Sat'), findsOneWidget);
      expect(find.text('6,000.00'), findsOneWidget);
      expect(find.text('29.12'), findsOneWidget);
      expect(find.text('1,075.30'), findsOneWidget);
      expect(find.text('2,075.00'), findsOneWidget);
    });

    testWidgets('HomeScreen renders Add Transaction Button widget correctly',
        (tester) async {
      preferencesController.setHomeLayoutWidgets([
        const HomeLayoutWidget(
          id: 'btn-1',
          type: 'add-transaction-button',
        ),
      ]);

      await tester.pumpWidget(
        const MaterialApp(
          home: HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Add Transaction'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsWidgets);
      expect(find.byIcon(Icons.keyboard_arrow_down), findsNothing);
    });
  });
}
