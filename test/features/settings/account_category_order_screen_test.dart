import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/features/settings/presentation/account_category_order_screen.dart';

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

  Widget createTestWidget({PreferencesController? controller}) {
    return MaterialApp(
      home: AccountCategoryOrderScreen(controller: controller),
    );
  }

  group('AccountCategoryOrderScreen Widget Tests', () {
    testWidgets('renders top app bar, title, and all 9 account categories in order',
        (tester) async {
      await tester.pumpWidget(createTestWidget(controller: preferencesController));
      await tester.pumpAndSettle();

      // Verify title and buttons
      expect(find.text('Account Category Order'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      // Verify all 9 default category names
      for (final category in PreferencesController.defaultAccountCategories) {
        expect(find.text(category), findsOneWidget);
      }

      // Verify 9 drag handle listeners are present
      expect(find.byType(ReorderableDragStartListener), findsNWidgets(9));
    });

    testWidgets('opens more actions sheet and shows Reset to Default & Cancel buttons',
        (tester) async {
      await tester.pumpWidget(createTestWidget(controller: preferencesController));
      await tester.pumpAndSettle();

      // Tap on more (...) button
      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();

      // Bottom sheet with action buttons should be visible
      expect(find.text('Reset to Default'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Tap Cancel to dismiss
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel'), findsNothing);
    });

    testWidgets('Reset to Default resets category order in state',
        (tester) async {
      // Initialize controller with custom categories
      final customOrder = [
        'Investment Account',
        'Cash',
        'Checking Account',
      ];
      final customController =
          PreferencesController(accountCategories: customOrder);

      await tester.pumpWidget(createTestWidget(controller: customController));
      await tester.pumpAndSettle();

      // Initially only 3 items
      expect(find.text('Investment Account'), findsOneWidget);
      expect(find.text('Cash'), findsOneWidget);
      expect(find.text('Certificate of Deposit'), findsNothing);

      // Tap more actions (...)
      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();

      // Tap Reset to Default
      await tester.tap(find.text('Reset to Default'));
      await tester.pumpAndSettle();

      // All 9 default categories should now be visible
      for (final category in PreferencesController.defaultAccountCategories) {
        expect(find.text(category), findsOneWidget);
      }
    });

    testWidgets('Tapping checkmark (✓) saves order in PreferencesController',
        (tester) async {
      await tester.pumpWidget(createTestWidget(controller: preferencesController));
      await tester.pumpAndSettle();

      // Tap checkmark button
      await tester.tap(find.byIcon(Icons.check_rounded));
      await tester.pumpAndSettle();

      expect(preferencesController.accountCategoryOrder, 'Custom');
      expect(
        preferencesController.accountCategories,
        PreferencesController.defaultAccountCategories,
      );
    });

    testWidgets('Reordering category tiles updates the list order',
        (tester) async {
      await tester.pumpWidget(createTestWidget(controller: preferencesController));
      await tester.pumpAndSettle();

      final firstTileFinder = find.byType(ReorderableDragStartListener).first;

      // Long press / drag the first drag handle downwards
      final testGesture = await tester.startGesture(tester.getCenter(firstTileFinder));
      await tester.pump(const Duration(milliseconds: 300));
      await testGesture.moveBy(const Offset(0, 150));
      await tester.pumpAndSettle();
      await testGesture.up();
      await tester.pumpAndSettle();

      // Verify list is still intact and can be saved
      await tester.tap(find.byIcon(Icons.check_rounded));
      await tester.pumpAndSettle();

      expect(preferencesController.accountCategories.length, 9);
    });
  });
}
