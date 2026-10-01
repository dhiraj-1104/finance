import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ezbookkeeping/features/accounts/data/models/account_item.dart';
import 'package:ezbookkeeping/features/accounts/widgets/account_picker_sheet.dart';

final sampleTestCategories = [
  const AccountItem(
    id: 'cat_cash',
    name: 'Cash',
    category: 'Cash',
    balance: 245.04,
    displayBalance: r'$ 245.04+',
    subAccounts: [
      AccountItem(
        id: '1',
        name: 'Wallet (US Dollar)',
        category: 'Cash',
        currency: 'USD',
        balance: 235.30,
      ),
      AccountItem(
        id: '2',
        name: 'Wallet (Euro)',
        category: 'Cash',
        currency: 'EUR',
        balance: 8.50,
      ),
      AccountItem(
        id: '3',
        name: 's',
        category: 'Cash',
        currency: 'SAR',
        balance: 1360.00,
        displayBalance: 'SAR 1,360.00',
      ),
    ],
  ),
  const AccountItem(
    id: 'cat_checking',
    name: 'Checking Account',
    category: 'Checking Account',
    balance: 3521.00,
    displayBalance: r'$ 3,521.00',
    subAccounts: [
      AccountItem(
        id: '4',
        name: 'Bank Account (Chase)',
        category: 'Checking Account',
        currency: 'USD',
        balance: 3521.00,
      ),
    ],
  ),
  const AccountItem(
    id: 'cat_credit',
    name: 'Credit Card',
    category: 'Credit Card',
    balance: 1958.78,
    displayBalance: r'$ 1,958.78',
    subAccounts: [
      AccountItem(
        id: '5',
        name: 'Visa Platinum',
        category: 'Credit Card',
        currency: 'USD',
        balance: 1958.78,
      ),
    ],
  ),
  const AccountItem(
    id: 'cat_savings',
    name: 'Savings Account',
    category: 'Savings Account',
    balance: 0.00,
    displayBalance: r'$ 0.00',
    subAccounts: [],
  ),
];

void main() {
  setUp(() async {
    await getIt.reset();
  });

  group('AccountItem Unit Tests', () {
    test('AccountItem formats balance correctly for USD, EUR, and SAR', () {
      const usdAcc = AccountItem(
        id: '1',
        name: 'USD Account',
        category: 'Cash',
        currency: 'USD',
        balance: 235.30,
      );
      expect(usdAcc.formattedBalance, r'$ 235.30');

      const eurAcc = AccountItem(
        id: '2',
        name: 'EUR Account',
        category: 'Cash',
        currency: 'EUR',
        balance: 8.50,
      );
      expect(eurAcc.formattedBalance, '€ 8.50');

      const sarAcc = AccountItem(
        id: '3',
        name: 'SAR Account',
        category: 'Cash',
        currency: 'SAR',
        balance: 1360.00,
      );
      expect(sarAcc.formattedBalance, 'SAR 1360.00');

      const customAcc = AccountItem(
        id: '4',
        name: 'Custom Display',
        category: 'Cash',
        balance: 245.04,
        displayBalance: r'$ 245.04+',
      );
      expect(customAcc.formattedBalance, r'$ 245.04+');
    });

    test('sample categories structure', () {
      expect(sampleTestCategories.length, 4);
      expect(sampleTestCategories.map((c) => c.name), [
        'Cash',
        'Checking Account',
        'Credit Card',
        'Savings Account',
      ]);

      final cash = sampleTestCategories.first;
      expect(cash.subAccounts.length, 3);
      expect(cash.subAccounts.map((s) => s.name), [
        'Wallet (US Dollar)',
        'Wallet (Euro)',
        's',
      ]);
    });
  });

  group('AccountPickerSheet Widget Tests', () {
    Widget buildTestWidget({
      String? selectedAccountName,
      String? selectedAccountId,
      ValueChanged<AccountItem>? onAccountSelected,
      Brightness brightness = Brightness.light,
      List<AccountItem>? accounts,
    }) {
      return MaterialApp(
        theme: ThemeData(brightness: brightness, useMaterial3: true),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  AccountPickerSheet.show(
                    context,
                    selectedAccountName: selectedAccountName,
                    selectedAccountId: selectedAccountId,
                    onAccountSelected: onAccountSelected ?? (_) {},
                    accounts: accounts ?? sampleTestCategories,
                  );
                },
                child: const Text('Open Picker'),
              );
            },
          ),
        ),
      );
    }

    testWidgets('Renders header with circular close button and search input', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.text('Open Picker'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      expect(find.text('Find account'), findsOneWidget);
    });

    testWidgets('Renders 2-column layout with categories and sub-accounts', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(selectedAccountName: 'Wallet (US Dollar)'),
      );
      await tester.tap(find.text('Open Picker'));
      await tester.pumpAndSettle();

      // Left column: Cash, Checking Account, Credit Card, Savings Account
      expect(find.text('Cash'), findsOneWidget);
      expect(find.text(r'$ 245.04+'), findsOneWidget);
      expect(find.text('Checking Account'), findsOneWidget);
      expect(find.text(r'$ 3,521.00'), findsOneWidget);
      expect(find.text('Credit Card'), findsOneWidget);
      expect(find.text(r'$ 1,958.78'), findsOneWidget);

      // Right column: Cash sub-accounts
      expect(find.text('Wallet (US Dollar)'), findsOneWidget);
      expect(find.text(r'$ 235.30'), findsOneWidget);
      expect(find.text('Wallet (Euro)'), findsOneWidget);
      expect(find.text('€ 8.50'), findsOneWidget);
      expect(find.text('s'), findsOneWidget);
      expect(find.text('SAR 1,360.00'), findsOneWidget);

      // Selected checkmark on Wallet (US Dollar)
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets(
      'Tapping a sub-account calls onAccountSelected and closes sheet',
      (tester) async {
        AccountItem? selected;
        await tester.pumpWidget(
          buildTestWidget(onAccountSelected: (acc) => selected = acc),
        );
        await tester.tap(find.text('Open Picker'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Wallet (Euro)'));
        await tester.pumpAndSettle();

        expect(selected, isNotNull);
        expect(selected!.name, 'Wallet (Euro)');
        expect(selected!.currency, 'EUR');
        // Modal should be dismissed
        expect(find.text('Find account'), findsNothing);
      },
    );

    testWidgets('Tapping another category switches displayed sub-accounts', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.text('Open Picker'));
      await tester.pumpAndSettle();

      // Initially shows Cash sub-accounts
      expect(find.text('Wallet (US Dollar)'), findsOneWidget);

      // Tap Checking Account
      await tester.tap(find.text('Checking Account'));
      await tester.pumpAndSettle();

      // Now shows Bank Account (Chase)
      expect(find.text('Bank Account (Chase)'), findsOneWidget);
    });

    testWidgets('Searching filters accounts in real time', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.text('Open Picker'));
      await tester.pumpAndSettle();

      // Enter search query
      await tester.enterText(find.byType(TextField), 'Euro');
      await tester.pumpAndSettle();

      expect(find.text('Wallet (Euro)'), findsOneWidget);
      expect(find.text('Wallet (US Dollar)'), findsNothing);

      // Search for something not existing
      await tester.enterText(find.byType(TextField), 'NonExistentAccountXYZ');
      await tester.pumpAndSettle();

      expect(find.text('No accounts found'), findsOneWidget);

      // Clear search
      await tester.tap(find.byIcon(Icons.cancel));
      await tester.pumpAndSettle();

      expect(find.text('Cash'), findsOneWidget);
      expect(find.text('Wallet (US Dollar)'), findsOneWidget);
    });

    testWidgets('Circular close button dismisses modal sheet', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.text('Open Picker'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Find account'), findsNothing);
    });

    testWidgets('Renders properly in Dark Theme', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(brightness: Brightness.dark, selectedAccountName: 's'),
      );
      await tester.tap(find.text('Open Picker'));
      await tester.pumpAndSettle();

      expect(find.text('Cash'), findsOneWidget);
      expect(find.text('s'), findsOneWidget);
      expect(find.text('SAR 1,360.00'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });
  });
}
