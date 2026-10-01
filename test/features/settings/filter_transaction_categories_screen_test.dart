import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/features/categories/models/category_item.dart';
import 'package:ezbookkeeping/features/settings/presentation/filter_transaction_categories_screen.dart';

void main() {
  const sampleCategories = [
    CategoryItem(
      id: 'cat_income_1',
      name: 'Occupational Earnings',
      icon: Icons.work_outline_rounded,
      color: Color(0xFFE65100),
      type: CategoryType.income,
      subCategories: [
        CategoryItem(
          id: 'sub_1',
          name: 'Salary Income',
          icon: Icons.account_balance_wallet_outlined,
          color: Color(0xFFE65100),
          type: CategoryType.income,
          parentId: 'cat_income_1',
        ),
        CategoryItem(
          id: 'sub_2',
          name: 'Bonus Income',
          icon: Icons.emoji_events_outlined,
          color: Color(0xFFE65100),
          type: CategoryType.income,
          parentId: 'cat_income_1',
        ),
        CategoryItem(
          id: 'sub_hidden',
          name: 'Hidden Side Income',
          icon: Icons.lightbulb_outline_rounded,
          color: Color(0xFFE65100),
          type: CategoryType.income,
          parentId: 'cat_income_1',
          hidden: true,
        ),
      ],
    ),
    CategoryItem(
      id: 'cat_income_2',
      name: 'Finance & Investment',
      icon: Icons.account_balance_rounded,
      color: Color(0xFFC86D3B),
      type: CategoryType.income,
      subCategories: [
        CategoryItem(
          id: 'sub_3',
          name: 'Investment Income',
          icon: Icons.show_chart_rounded,
          color: Color(0xFFC86D3B),
          type: CategoryType.income,
          parentId: 'cat_income_2',
        ),
      ],
    ),
  ];

  group('FilterTransactionCategoriesScreen Widget Tests', () {
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
      'renders top bar, search pill, and hierarchical categories matching mockup',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: FilterTransactionCategoriesScreen(
              initialCategories: sampleCategories,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Top bar
        expect(find.text('Filter Transaction Categories'), findsOneWidget);
        expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
        expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);
        expect(find.byIcon(Icons.check_rounded), findsWidgets);

        // Search pill
        expect(find.text('Find category'), findsOneWidget);

        // Category group header
        expect(find.text('Income Categories'), findsOneWidget);

        // Primary categories
        expect(find.text('Occupational Earnings'), findsOneWidget);
        expect(find.text('Finance & Investment'), findsOneWidget);

        // Subcategories
        expect(find.text('Salary Income'), findsOneWidget);
        expect(find.text('Bonus Income'), findsOneWidget);
        expect(find.text('Investment Income'), findsOneWidget);

        // Hidden category should not be visible initially
        expect(find.text('Hidden Side Income'), findsNothing);
      },
    );

    testWidgets('search filters hierarchical categories correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FilterTransactionCategoriesScreen(
            initialCategories: sampleCategories,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Occupational Earnings'), findsOneWidget);
      expect(find.text('Salary Income'), findsOneWidget);
      expect(find.text('Finance & Investment'), findsOneWidget);

      // Search for 'Investment'
      await tester.enterText(find.byType(TextField), 'Investment');
      await tester.pumpAndSettle();

      expect(find.text('Finance & Investment'), findsOneWidget);
      expect(find.text('Investment Income'), findsOneWidget);
      expect(find.text('Occupational Earnings'), findsNothing);
      expect(find.text('Salary Income'), findsNothing);
    });

    testWidgets('toggling subcategory updates selection', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FilterTransactionCategoriesScreen(
            initialCategories: sampleCategories,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap 'Salary Income' to unselect
      await tester.tap(find.text('Salary Income'));
      await tester.pumpAndSettle();

      // Tap checkmark to save
      await tester.tap(find.byIcon(Icons.check_rounded).first);
      await tester.pumpAndSettle();

      expect(controller.overviewCategoryIds.contains('sub_1'), isFalse);
      expect(controller.overviewCategoryIds.contains('sub_2'), isTrue);
      expect(controller.overviewCategoryIds.contains('cat_income_1'), isTrue);
      expect(controller.categoriesInOverview, 'Selected Categories');
    });

    testWidgets(
      'toggling primary category toggles all visible child subcategories',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: FilterTransactionCategoriesScreen(
              initialCategories: sampleCategories,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap 'Occupational Earnings' primary category to deselect all its subcategories
        await tester.tap(find.text('Occupational Earnings'));
        await tester.pumpAndSettle();

        // Tap checkmark to save
        await tester.tap(find.byIcon(Icons.check_rounded).first);
        await tester.pumpAndSettle();

        expect(
          controller.overviewCategoryIds.contains('cat_income_1'),
          isFalse,
        );
        expect(controller.overviewCategoryIds.contains('sub_1'), isFalse);
        expect(controller.overviewCategoryIds.contains('sub_2'), isFalse);
        expect(controller.overviewCategoryIds.contains('cat_income_2'), isTrue);
      },
    );

    testWidgets(
      '3-dots menu bottom sheet actions matching media_1790832256968.png',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: FilterTransactionCategoriesScreen(
              initialCategories: sampleCategories,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tap 3-dots menu button
        await tester.tap(find.byIcon(Icons.more_horiz_rounded));
        await tester.pumpAndSettle();

        // Verify bottom sheet modal elements
        expect(find.text('Select All'), findsOneWidget);
        expect(find.text('Select None'), findsOneWidget);
        expect(find.text('Invert Selection'), findsOneWidget);
        expect(find.text('Show Hidden Transaction Categories'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);

        // Tap 'Select None'
        await tester.tap(find.text('Select None'));
        await tester.pumpAndSettle();

        // Tap checkmark to save
        await tester.tap(find.byIcon(Icons.check_rounded).first);
        await tester.pumpAndSettle();

        expect(controller.overviewCategoryIds, isEmpty);
        expect(controller.categoriesInOverview, 'None');
      },
    );

    testWidgets(
      'Show Hidden Transaction Categories toggle reveals hidden categories',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: FilterTransactionCategoriesScreen(
              initialCategories: sampleCategories,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Hidden Side Income'), findsNothing);

        // Open bottom sheet
        await tester.tap(find.byIcon(Icons.more_horiz_rounded));
        await tester.pumpAndSettle();

        // Toggle hidden categories
        await tester.tap(find.text('Show Hidden Transaction Categories'));
        await tester.pumpAndSettle();

        // Hidden category should now be visible
        expect(find.text('Hidden Side Income'), findsOneWidget);

        // Open bottom sheet again to verify toggle text updated
        await tester.tap(find.byIcon(Icons.more_horiz_rounded));
        await tester.pumpAndSettle();

        expect(find.text('Hide Hidden Transaction Categories'), findsOneWidget);
      },
    );
  });
}
