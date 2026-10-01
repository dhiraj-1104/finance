import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/features/accounts/domain/entities/account.dart';
import 'package:ezbookkeeping/features/settings/presentation/filter_accounts_screen.dart';

void main() {
  const sampleAccounts = [
    Account(
      id: 'acc_1',
      name: 'Debit',
      parentId: '0',
      category: 1, // Cash
      type: 1,
      icon: '1',
      iconType: 1,
      color: '000000',
      currency: 'USD',
      balance: 150000,
    ),
    Account(
      id: 'acc_2',
      name: 'c1',
      parentId: '0',
      category: 1, // Cash
      type: 1,
      icon: '1',
      iconType: 1,
      color: '000000',
      currency: 'USD',
      balance: 50000,
    ),
    Account(
      id: 'acc_3',
      name: 'a1',
      parentId: '0',
      category: 6, // Savings Account
      type: 1,
      icon: '1',
      iconType: 1,
      color: '000000',
      currency: 'USD',
      balance: 200000,
    ),
  ];

  group('FilterAccountsScreen Widget Tests', () {
    late PreferencesController controller;

    setUp(() {
      if (getIt.isRegistered<PreferencesController>()) {
        getIt.unregister<PreferencesController>();
      }
      controller = PreferencesController();
      getIt.registerSingleton<PreferencesController>(controller);
    });

    tearDown(() {
      if (getIt.isRegistered<PreferencesController>()) {
        getIt.unregister<PreferencesController>();
      }
    });

    testWidgets(
      'renders top bar, search pill, and category cards with accounts',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: FilterAccountsScreen(initialAccounts: sampleAccounts),
          ),
        );
        await tester.pumpAndSettle();

        // Top bar elements
        expect(find.text('Filter Accounts'), findsOneWidget);
        expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
        expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);
        expect(find.byIcon(Icons.check_rounded), findsWidgets);

        // Search pill
        expect(find.text('Find account'), findsOneWidget);

        // Category cards
        expect(find.text('Cash'), findsOneWidget);
        expect(find.text('Savings Account'), findsOneWidget);

        // Accounts
        expect(find.text('Debit'), findsOneWidget);
        expect(find.text('c1'), findsOneWidget);
        expect(find.text('a1'), findsOneWidget);
      },
    );

    testWidgets('search filters account list by account name', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FilterAccountsScreen(initialAccounts: sampleAccounts),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Debit'), findsOneWidget);
      expect(find.text('a1'), findsOneWidget);

      // Search for 'Debit'
      await tester.enterText(find.byType(TextField), 'Debit');
      await tester.pumpAndSettle();

      expect(find.widgetWithText(InkWell, 'Debit'), findsOneWidget);
      expect(find.widgetWithText(InkWell, 'a1'), findsNothing);
      expect(find.widgetWithText(InkWell, 'c1'), findsNothing);
    });

    testWidgets('tapping account row toggles selection', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FilterAccountsScreen(initialAccounts: sampleAccounts),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on 'Debit' to toggle
      await tester.tap(find.text('Debit'));
      await tester.pumpAndSettle();

      // Debit is now unselected, save to verify
      await tester.tap(find.byIcon(Icons.check_rounded).first);
      await tester.pumpAndSettle();

      expect(controller.overviewAccountIds.contains('acc_1'), isFalse);
      expect(controller.overviewAccountIds.contains('acc_2'), isTrue);
      expect(controller.overviewAccountIds.contains('acc_3'), isTrue);
    });

    testWidgets(
      '3-dots Action Sheet actions (Select None, Select All, Invert Selection, Cancel)',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: FilterAccountsScreen(initialAccounts: sampleAccounts),
          ),
        );
        await tester.pumpAndSettle();

        // Open Action Sheet
        await tester.tap(find.byIcon(Icons.more_horiz_rounded));
        await tester.pumpAndSettle();

        expect(find.text('Select None'), findsOneWidget);
        expect(find.text('Select All'), findsOneWidget);
        expect(find.text('Invert Selection'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);

        // Tap Select None
        await tester.tap(find.text('Select None'));
        await tester.pumpAndSettle();

        // Save and verify
        await tester.tap(find.byIcon(Icons.check_rounded).first);
        await tester.pumpAndSettle();

        expect(controller.overviewAccountIds, isEmpty);
        expect(controller.accountsInOverview, 'None');
      },
    );

    testWidgets('collapsing and expanding category cards', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FilterAccountsScreen(initialAccounts: sampleAccounts),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Debit'), findsOneWidget);

      // Tap 'Cash' category header to collapse
      await tester.tap(find.text('Cash'));
      await tester.pumpAndSettle();

      // Cash accounts should be collapsed
      expect(find.text('Debit'), findsNothing);
      expect(find.text('c1'), findsNothing);
      expect(find.text('a1'), findsOneWidget);

      // Tap 'Cash' again to expand
      await tester.tap(find.text('Cash'));
      await tester.pumpAndSettle();

      expect(find.text('Debit'), findsOneWidget);
    });
  });
}
