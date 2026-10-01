import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/features/settings/presentation/preferences_screen.dart';
import 'package:ezbookkeeping/features/home/presentation/home_page_layout_screen.dart';
import 'package:ezbookkeeping/features/accounts/presentation/account_list_screen.dart';

void main() {
  Widget createTestWidget() {
    return const MaterialApp(home: PreferencesScreen());
  }

  group('PreferencesScreen Widget Tests', () {
    setUp(() {
      if (getIt.isRegistered<PreferencesController>()) {
        getIt.unregister<PreferencesController>();
      }
      getIt.registerSingleton<PreferencesController>(PreferencesController());
    });

    tearDown(() {
      if (getIt.isRegistered<PreferencesController>()) {
        getIt.unregister<PreferencesController>();
      }
    });

    testWidgets('renders all section headers and key preference items', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Top bar
      expect(find.text('Preferences'), findsOneWidget);

      // Section 1: General Settings
      expect(find.text('General Settings'), findsOneWidget);
      expect(find.text('Show Account Balance'), findsOneWidget);
      expect(find.text('Account Category Order'), findsOneWidget);
      expect(find.text('Chart Color Scheme'), findsOneWidget);
      expect(find.text('Auto-update Exchange Rates Data'), findsOneWidget);

      // Section 2: Overview Page
      expect(find.text('Overview Page'), findsOneWidget);
      expect(find.text('Home Page Layout'), findsOneWidget);
      expect(find.text('Show Amount'), findsOneWidget);
      expect(find.text('Timezone Used for Statistics'), findsOneWidget);
      expect(
        find.text('Accounts Included in Overview Statistics'),
        findsOneWidget,
      );
      expect(
        find.text('Transaction Categories Included in Overview Statistics'),
        findsOneWidget,
      );
      expect(
        find.text('Transaction Tags Included in Overview Statistics'),
        findsOneWidget,
      );

      // Section 3: Transaction List Page
      expect(find.text('Transaction List Page'), findsOneWidget);
      expect(find.text('Show Monthly Total Amount'), findsOneWidget);
      expect(find.text('Total Amount Calculation Method'), findsOneWidget);
      expect(find.text('Show Transaction Tags'), findsOneWidget);
      expect(
        find.text('Default Keyword Search Matching Mode'),
        findsOneWidget,
      );

      // Scroll to view remaining sections
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -600),
      );
      await tester.pumpAndSettle();

      // Section 4: Transaction Edit Page
      expect(find.text('Transaction Edit Page'), findsOneWidget);
      expect(find.text('Quick Save Button Style'), findsOneWidget);
      expect(find.text('Quick Add Button Action'), findsOneWidget);
      expect(find.text('Automatically Save Draft'), findsOneWidget);
      expect(find.text('Automatically Add Geolocation'), findsOneWidget);
      expect(find.text('Always Show Transaction Pictures'), findsOneWidget);
      expect(find.text('Transaction Picture Upload Quality'), findsOneWidget);

      // Section 5: AI Clipboard Text Recognition
      expect(find.text('AI Clipboard Text Recognition'), findsOneWidget);
      expect(
        find.text(
          'Always Require Confirmation of Clipboard Content Before Submission',
        ),
        findsOneWidget,
      );

      // Section 6: AI Image Recognition
      expect(find.text('AI Image Recognition'), findsOneWidget);
      expect(
        find.text('Auto Upload AI Recognition Image as Transaction Picture'),
        findsOneWidget,
      );

      // Scroll further
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -600),
      );
      await tester.pumpAndSettle();

      // Section 7: Account List Page
      expect(find.text('Account List Page'), findsOneWidget);
      expect(find.text('Accounts Included in Total'), findsOneWidget);
      expect(find.text('Default Credit Card Amount'), findsOneWidget);
      expect(
        find.text('Default Date Range for Reconciliation Statement Page'),
        findsOneWidget,
      );

      // Section 8: Exchange Rates Data Page
      expect(find.text('Exchange Rates Data Page'), findsOneWidget);
      expect(find.text('Sort by'), findsOneWidget);
    });

    testWidgets('toggles switches properly and updates PreferencesController', (
      WidgetTester tester,
    ) async {
      final controller = getIt<PreferencesController>();
      expect(controller.showAccountBalance, isTrue);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find first CupertinoSwitch (Show Account Balance)
      final switchFinder = find.byType(CupertinoSwitch);
      expect(switchFinder, findsWidgets);

      final firstSwitch = tester.widget<CupertinoSwitch>(switchFinder.first);
      expect(firstSwitch.value, isTrue);

      // Tap to toggle
      await tester.tap(switchFinder.first);
      await tester.pumpAndSettle();

      final updatedSwitch = tester.widget<CupertinoSwitch>(
        find.byType(CupertinoSwitch).first,
      );
      expect(updatedSwitch.value, isFalse);
      expect(controller.showAccountBalance, isFalse);
    });

    testWidgets(
      'toggling Auto-update Exchange Rates Data updates PreferencesController',
      (WidgetTester tester) async {
        final controller = getIt<PreferencesController>();
        expect(controller.autoUpdateExchangeRates, isTrue);

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Find switch for Auto-update Exchange Rates Data (second switch on screen)
        final switchFinder = find.byType(CupertinoSwitch);
        expect(switchFinder, findsWidgets);

        // Tap the second switch (Auto-update Exchange Rates Data)
        await tester.tap(switchFinder.at(1));
        await tester.pumpAndSettle();

        expect(controller.autoUpdateExchangeRates, isFalse);
      },
    );

    testWidgets('opens HomePageLayoutScreen on Home Page Layout tap', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on 'Home Page Layout'
      await tester.tap(find.text('Home Page Layout'));
      await tester.pumpAndSettle();

      // HomePageLayoutScreen should be visible
      expect(find.byType(HomePageLayoutScreen), findsOneWidget);
    });

    testWidgets(
      'AccountListScreen defaults eye toggle based on Show Account Balance preference (true)',
      (WidgetTester tester) async {
        final controller = getIt<PreferencesController>();
        controller.setShowAccountBalance(true);

        await tester.pumpWidget(const MaterialApp(home: AccountListScreen()));
        await tester.pumpAndSettle();

        // When Show Account Balance is true, balance is shown by default (not hidden as r'$ *.**')
        expect(find.byIcon(Icons.visibility_off_outlined), findsWidgets);
      },
    );

    testWidgets(
      'AccountListScreen defaults eye toggle based on Show Account Balance preference (false)',
      (WidgetTester tester) async {
        final controller = getIt<PreferencesController>();
        controller.setShowAccountBalance(false);

        await tester.pumpWidget(const MaterialApp(home: AccountListScreen()));
        await tester.pumpAndSettle();

        // When Show Account Balance is false, balance is hidden by default (*.**) and eye icon is visibility_outlined
        expect(find.text(r'$ *.**'), findsOneWidget);
        expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      },
    );

    testWidgets(
      'Default Credit Card Amount opens popup dialog and changes preference',
      (WidgetTester tester) async {
        final controller = getIt<PreferencesController>();
        expect(controller.defaultCreditCardAmount, 'Outstanding Balance');

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Scroll down to Account List Page section
        await tester.scrollUntilVisible(
          find.text('Default Credit Card Amount'),
          200,
          scrollable: find.byType(Scrollable),
        );
        await tester.pumpAndSettle();

        // Verify Default Credit Card Amount item is visible
        expect(find.text('Default Credit Card Amount'), findsOneWidget);

        // Tap to open floating dialog picker
        await tester.tap(find.text('Default Credit Card Amount'));
        await tester.pumpAndSettle();

        // Verify dialog items
        expect(find.text('Outstanding Balance'), findsWidgets);
        expect(find.text('Available Credit'), findsOneWidget);
        expect(find.byIcon(Icons.check_rounded), findsOneWidget);

        // Tap 'Available Credit'
        await tester.tap(find.text('Available Credit'));
        await tester.pumpAndSettle();

        // Verify dialog dismissed and controller updated
        expect(controller.defaultCreditCardAmount, 'Available Credit');
      },
    );

    testWidgets(
      'Exchange Rates Sort by opens popup dialog and changes preference',
      (WidgetTester tester) async {
        final controller = getIt<PreferencesController>();
        expect(controller.exchangeRatesSortBy, 'Currency Name');

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        // Scroll down to Exchange Rates Data Page section
        await tester.scrollUntilVisible(
          find.text('Sort by'),
          200,
          scrollable: find.byType(Scrollable),
        );
        await tester.pumpAndSettle();

        // Verify Sort by item is visible
        expect(find.text('Sort by'), findsOneWidget);

        // Tap to open floating dialog picker
        await tester.tap(find.text('Sort by'));
        await tester.pumpAndSettle();

        // Verify dialog items
        expect(find.text('Currency Name'), findsWidgets);
        expect(find.text('Currency Code'), findsOneWidget);
        expect(find.text('Exchange Rate'), findsOneWidget);
        expect(find.byIcon(Icons.check_rounded), findsOneWidget);

        // Tap 'Currency Code'
        await tester.tap(find.text('Currency Code'));
        await tester.pumpAndSettle();

        // Verify dialog dismissed and controller updated
        expect(controller.exchangeRatesSortBy, 'Currency Code');
      },
    );

    testWidgets(
      'Total Amount Calculation Method opens popup dialog and changes preference',
      (WidgetTester tester) async {
        final controller = getIt<PreferencesController>();
        expect(controller.totalAmountCalculationMethod, 'Inflows and Outflows');

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        await tester.scrollUntilVisible(
          find.text('Total Amount Calculation Method'),
          200,
          scrollable: find.byType(Scrollable),
        );
        await tester.pumpAndSettle();

        // Tap to open floating dialog picker
        await tester.tap(find.text('Total Amount Calculation Method'));
        await tester.pumpAndSettle();

        // Verify dialog items
        expect(find.text('Inflows and Outflows'), findsWidgets);
        expect(find.text('Outflows Only'), findsOneWidget);
        expect(find.text('Inflows Only'), findsOneWidget);
        expect(find.text('All Transactions'), findsOneWidget);

        // Tap 'Outflows Only'
        await tester.tap(find.text('Outflows Only'));
        await tester.pumpAndSettle();

        expect(controller.totalAmountCalculationMethod, 'Outflows Only');
      },
    );

    testWidgets(
      'Quick Save Button Style opens popup dialog and changes preference',
      (WidgetTester tester) async {
        final controller = getIt<PreferencesController>();
        expect(
          controller.quickSaveButtonStyle,
          'Bottom Right Floating',
        );

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        await tester.scrollUntilVisible(
          find.text('Quick Save Button Style'),
          200,
          scrollable: find.byType(Scrollable),
        );
        await tester.pumpAndSettle();

        // Tap to open floating dialog picker
        await tester.tap(find.text('Quick Save Button Style'));
        await tester.pumpAndSettle();

        // Verify options from screenshot
        expect(find.text('Disabled'), findsWidgets);
        expect(find.text('Bottom Fixed'), findsOneWidget);
        expect(find.text('Bottom Left Floating'), findsOneWidget);
        expect(find.text('Bottom Center Floating'), findsOneWidget);
        expect(find.text('Bottom Right Floating'), findsWidgets);

        // Tap 'Bottom Fixed'
        await tester.tap(find.text('Bottom Fixed'));
        await tester.pumpAndSettle();

        expect(controller.quickSaveButtonStyle, 'Bottom Fixed');
      },
    );
  });
}
