import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ezbookkeeping/app/app.dart';
import 'package:ezbookkeeping/app/router/app_router.dart';
import 'package:ezbookkeeping/app/router/app_routes.dart';
import 'package:ezbookkeeping/core/theme/theme_controller.dart';
import 'package:ezbookkeeping/features/accounts/presentation/account_list_screen.dart';
import 'package:ezbookkeeping/features/accounts/presentation/add_account_screen.dart';
import 'package:ezbookkeeping/features/transactions/presentation/transaction_list_screen.dart';
import 'package:ezbookkeeping/features/home/presentation/add_transaction_screen.dart';
import 'package:ezbookkeeping/features/home/presentation/home_screen.dart';
import 'package:ezbookkeeping/features/settings/presentation/settings_screen.dart';
import 'package:ezbookkeeping/features/settings/presentation/user_profile_screen.dart';
import 'package:ezbookkeeping/features/settings/presentation/data_management_screen.dart';
import 'package:ezbookkeeping/features/settings/presentation/two_factor_auth_screen.dart';
import 'package:ezbookkeeping/features/settings/presentation/application_lock_screen.dart';
import 'package:ezbookkeeping/features/settings/presentation/exchange_rates_data_screen.dart';
import 'package:ezbookkeeping/features/settings/presentation/about_screen.dart';
import 'package:ezbookkeeping/features/settings/presentation/device_and_sessions_screen.dart';
import 'package:ezbookkeeping/features/settings/presentation/text_size_screen.dart';
import 'package:ezbookkeeping/features/settings/widgets/timezone_picker_sheet.dart';
import 'package:ezbookkeeping/features/categories/presentation/transaction_categories_screen.dart';
import 'package:ezbookkeeping/features/categories/presentation/primary_categories_screen.dart';
import 'package:ezbookkeeping/features/categories/presentation/secondary_categories_screen.dart';
import 'package:ezbookkeeping/features/categories/presentation/add_category_screen.dart';
import 'package:ezbookkeeping/features/categories/models/category_item.dart';
import 'package:ezbookkeeping/features/tags/presentation/transaction_tags_screen.dart';
import 'package:ezbookkeeping/features/templates/presentation/transaction_templates_screen.dart';
import 'package:ezbookkeeping/features/templates/presentation/add_transaction_template_screen.dart';
import 'package:ezbookkeeping/features/templates/models/transaction_template.dart';
import 'package:dartz/dartz.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/features/categories/data/models/add_category_request_model.dart';
import 'package:ezbookkeeping/features/categories/domain/repositories/categories_repository.dart';

class _WidgetTestMockCategoriesRepo implements CategoriesRepository {
  @override
  Future<Either<Failure, CategoryItem>> addCategory(
    AddCategoryRequestModel request,
  ) async {
    return Right(
      CategoryItem(
        id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
        name: request.name,
        categoryIconId: request.icon,
        icon: Icons.category,
        color: const Color(0xFF000000),
        type: request.type == 1
            ? CategoryType.income
            : (request.type == 3
                  ? CategoryType.transfer
                  : CategoryType.expense),
        isPrimary: request.parentId == '0',
        parentId: request.parentId == '0' ? null : request.parentId,
        description: request.comment,
      ),
    );
  }

  static const _sampleCategories = [
    CategoryItem(
      id: '1',
      name: 'Food & Drink',
      categoryIconId: '1',
      icon: Icons.restaurant_outlined,
      color: Color(0xFFFF6B22),
      type: CategoryType.expense,
      subCategories: [
        CategoryItem(
          id: '2',
          name: 'Food',
          categoryIconId: '2',
          icon: Icons.dinner_dining_outlined,
          color: Color(0xFFFF6B22),
          type: CategoryType.expense,
          isPrimary: false,
          parentId: '1',
        ),
        CategoryItem(
          id: '30',
          name: 'Drink',
          categoryIconId: '30',
          icon: Icons.local_cafe_outlined,
          color: Color(0xFFFF6B22),
          type: CategoryType.expense,
          isPrimary: false,
          parentId: '1',
        ),
        CategoryItem(
          id: '70',
          name: 'Fruit & Snack',
          categoryIconId: '70',
          icon: Icons.icecream_outlined,
          color: Color(0xFFFF6B22),
          type: CategoryType.expense,
          isPrimary: false,
          parentId: '1',
        ),
      ],
    ),
    CategoryItem(
      id: '100',
      name: 'Clothing & Appearance',
      categoryIconId: '100',
      icon: Icons.person_outline_rounded,
      color: Color(0xFF673AB7),
      type: CategoryType.expense,
    ),
    CategoryItem(
      id: '200',
      name: 'Housing & Houseware',
      categoryIconId: '200',
      icon: Icons.home_outlined,
      color: Color(0xFF000000),
      type: CategoryType.expense,
    ),
    CategoryItem(
      id: '300',
      name: 'Transportation',
      categoryIconId: '300',
      icon: Icons.alt_route_outlined,
      color: Color(0xFF009688),
      type: CategoryType.expense,
    ),
    CategoryItem(
      id: '400',
      name: 'Communication',
      categoryIconId: '400',
      icon: Icons.phone_android_outlined,
      color: Color(0xFF2196F3),
      type: CategoryType.expense,
    ),
    CategoryItem(
      id: '500',
      name: 'Entertainment',
      categoryIconId: '500',
      icon: Icons.movie_outlined,
      color: Color(0xFFE91E63),
      type: CategoryType.expense,
    ),
    CategoryItem(
      id: '600',
      name: 'Education & Studying',
      categoryIconId: '600',
      icon: Icons.school_outlined,
      color: Color(0xFF9C27B0),
      type: CategoryType.expense,
    ),
    CategoryItem(
      id: '700',
      name: 'Gifts & Donations',
      categoryIconId: '700',
      icon: Icons.card_giftcard_outlined,
      color: Color(0xFFFF9800),
      type: CategoryType.expense,
    ),
    CategoryItem(
      id: '800',
      name: 'Medical & Healthcare',
      categoryIconId: '800',
      icon: Icons.local_hospital_outlined,
      color: Color(0xFFF44336),
      type: CategoryType.expense,
    ),
    CategoryItem(
      id: '900',
      name: 'Finance & Insurance',
      categoryIconId: '900',
      icon: Icons.account_balance_outlined,
      color: Color(0xFF607D8B),
      type: CategoryType.expense,
    ),
    CategoryItem(
      id: '1000',
      name: 'Miscellaneous',
      categoryIconId: '1000',
      icon: Icons.category_outlined,
      color: Color(0xFF8E8E93),
      type: CategoryType.expense,
    ),
    CategoryItem(
      id: '2000',
      name: 'Occupational Earnings',
      categoryIconId: '2000',
      icon: Icons.work_outline_rounded,
      color: Color(0xFFFF6B22),
      type: CategoryType.income,
      subCategories: [
        CategoryItem(
          id: '2010',
          name: 'Salary Income',
          categoryIconId: '2010',
          icon: Icons.attach_money_rounded,
          color: Color(0xFFFF6B22),
          type: CategoryType.income,
          isPrimary: false,
          parentId: '2000',
        ),
      ],
    ),
  ];

  @override
  bool get isCacheValid => true;

  @override
  void clearCache() {}

  @override
  Future<List<CategoryItem>> getCategories({bool forceRefresh = false}) async =>
      _sampleCategories;

  @override
  Future<Map<String, CategoryItem>> getCategoriesMap({
    bool forceRefresh = false,
  }) async {
    final map = <String, CategoryItem>{};
    for (final c in _sampleCategories) {
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
  setUpAll(() {
    if (getIt.isRegistered<CategoriesRepository>()) {
      getIt.unregister<CategoriesRepository>();
    }
    getIt.registerSingleton<CategoriesRepository>(
      _WidgetTestMockCategoriesRepo(),
    );
  });
  testWidgets(
    'HomeScreen renders with ezBookkeeping and add transaction button',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
      await tester.pumpAndSettle();

      expect(find.text('ezBookkeeping'), findsOneWidget);
      expect(find.text('·Expense'), findsOneWidget);
      expect(find.textContaining('Monthly income'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    },
  );

  testWidgets('AddTransactionScreen renders matching mockup components', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AddTransactionScreen()));
    await tester.pumpAndSettle();

    // Verify Title & Header icons
    expect(find.text('Add Transaction'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    // Verify Segmented Type Tabs
    expect(find.text('Expense'), findsOneWidget);
    expect(find.text('Income'), findsOneWidget);
    expect(find.text('Transfer'), findsOneWidget);

    // Verify Amount Display
    expect(find.text('Expense Amount'), findsOneWidget);
    expect(find.text('\$ 0.00'), findsOneWidget);

    // Verify Fields
    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Food & Drink'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Account'), findsOneWidget);
    expect(find.text('Wallet (US Dollar)'), findsOneWidget);
    expect(find.text('Transaction Time'), findsOneWidget);
    expect(find.text('Transaction Timezone'), findsOneWidget);
    expect(find.text('(UTC+05:30) System Default'), findsOneWidget);
    expect(find.text('Geographic Location'), findsOneWidget);
    expect(find.text('No Location'), findsOneWidget);
    expect(find.text('Tags'), findsOneWidget);
    expect(find.text('None'), findsOneWidget);
    expect(find.text('Description'), findsOneWidget);

    // Verify Bottom Save Button
    expect(find.text('Save'), findsOneWidget);

    // Tap 'Income' tab and verify amount label changes
    await tester.tap(find.text('Income'));
    await tester.pumpAndSettle();
    expect(find.text('Income Amount'), findsOneWidget);

    // Tap 'Transfer' tab
    await tester.tap(find.text('Transfer'));
    await tester.pumpAndSettle();
    expect(find.text('Transfer Amount'), findsOneWidget);
  });

  testWidgets(
    'SettingsScreen renders and switches themes via ThemePickerSheet',
    (tester) async {
      final themeController = ThemeController(
        initialThemeMode: ThemeMode.light,
      );

      await tester.pumpWidget(
        ThemeScope(
          controller: themeController,
          child: const MaterialApp(home: SettingsScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Title & Header
      expect(find.text('Settings'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);

      // Verify User section
      expect(find.text('demo'), findsOneWidget);
      expect(find.text('User Profile'), findsOneWidget);
      expect(find.text('Transaction Categories'), findsOneWidget);
      expect(find.text('Transaction Tags'), findsOneWidget);
      expect(find.text('Transaction Templates'), findsOneWidget);
      expect(find.text('Scheduled Transactions'), findsOneWidget);
      expect(find.text('Data Management'), findsOneWidget);
      expect(find.text('Two-Factor Authentication'), findsOneWidget);
      expect(find.text('Device & Sessions'), findsOneWidget);
      expect(find.text('Log Out'), findsOneWidget);

      // Scroll down to Application section
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      // Verify Application section
      expect(find.text('Application'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Text Size'), findsOneWidget);
      expect(find.text('Timezone'), findsOneWidget);
      expect(find.text('(UTC+05:30) System Default'), findsOneWidget);
      expect(find.text('Application Lock'), findsOneWidget);
      expect(find.text('Disabled'), findsOneWidget);

      // Open Theme picker sheet
      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();

      // Verify Theme Picker Sheet controls from mockup: ✕, Theme, 🔍
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(find.text('System Default'), findsOneWidget);
      expect(
        find.text('Light'),
        findsNWidgets(2),
      ); // in settings tile + in sheet
      expect(find.text('Dark'), findsOneWidget);

      // Select Dark mode
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      // Controller must now be Dark!
      expect(themeController.themeMode, equals(ThemeMode.dark));
      expect(find.text('Dark'), findsOneWidget);
    },
  );

  testWidgets('AccountListScreen renders matching mockup components', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AccountListScreen()));
    await tester.pumpAndSettle();

    // Verify Title & Header
    expect(find.text('Account List'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);

    // Verify Net Assets Card
    expect(find.text('Net assets'), findsOneWidget);
    expect(find.text(r'$ 0.00'), findsWidgets);
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

    // Toggle balance hide
    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

    // Verify Empty state
    expect(find.text('No available account'), findsOneWidget);
  });

  testWidgets(
    'AddAccountScreen renders matching mockup components and interacts with pickers',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: AddAccountScreen()));
      await tester.pumpAndSettle();

      // Verify Title & Header icons
      expect(find.text('Add Account'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      // Verify Card 1: Account Classification
      expect(find.text('Account Category'), findsOneWidget);
      expect(find.text('Cash'), findsOneWidget);
      expect(find.text('Account Type'), findsOneWidget);
      expect(find.text('Single Account'), findsOneWidget);

      // Verify Card 2: Account Details
      expect(find.text('Account Name'), findsOneWidget);
      expect(find.text('Account Icon'), findsOneWidget);
      expect(find.text('Account Color'), findsOneWidget);
      expect(find.text('Currency'), findsOneWidget);
      expect(find.text('Account Balance'), findsOneWidget);
      expect(find.text(r'$ 0.00'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);

      // 1. Open Category picker
      await tester.tap(find.text('Account Category'));
      await tester.pumpAndSettle();
      expect(find.text('Checking Account'), findsOneWidget);
      await tester.tap(find.text('Checking Account'));
      await tester.pumpAndSettle();
      expect(find.text('Checking Account'), findsWidgets);

      // 2. Open Account Type picker
      await tester.tap(find.text('Account Type'));
      await tester.pumpAndSettle();
      expect(find.text('Multi-sub Account'), findsOneWidget);
      await tester.tap(find.text('Multi-sub Account'));
      await tester.pumpAndSettle();
      expect(find.text('Multi-sub Account'), findsWidgets);

      // 3. Open Icon Picker Sheet and close
      await tester.tap(find.text('Account Icon'));
      await tester.pumpAndSettle();
      expect(find.text('System Icons'), findsOneWidget);
      expect(find.text('Custom Icons'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      // 4. Open Color Picker Sheet and close
      await tester.tap(find.text('Account Color'));
      await tester.pumpAndSettle();
      expect(find.text('System Colors'), findsOneWidget);
      expect(find.text('Custom Color'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      // 5. Open Currency Picker Sheet, select Euro
      await tester.tap(find.text('Currency'));
      await tester.pumpAndSettle();
      expect(find.text('Currency Name'), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      await tester.tap(find.text('Euro'));
      await tester.pumpAndSettle();

      // 6. Open Balance Editor, set 1500, confirm
      await tester.tap(find.text('Account Balance'));
      await tester.pumpAndSettle();
      expect(find.text('Initial Balance'), findsOneWidget);
      await tester.enterText(find.byType(TextField).last, '1500');
      await tester.tap(find.text('Confirm Balance'));
      await tester.pumpAndSettle();
      expect(find.text('€ 1500.00'), findsOneWidget);
    },
  );

  testWidgets('AccountListScreen navigates to AddAccountScreen on + icon tap', (
    tester,
  ) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: appRouter));
    appRouter.go(AppRoutes.accounts);
    await tester.pumpAndSettle();

    expect(find.text('Account List'), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);

    // Tap + button
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    // Should have navigated to AddAccountScreen
    expect(find.text('Add Account'), findsOneWidget);
    expect(find.text('Account Category'), findsOneWidget);
    expect(find.text('Account Name'), findsOneWidget);
  });

  testWidgets(
    'TransactionListScreen renders header, month bar, search, and empty state without mock fallback',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: TransactionListScreen()));
      await tester.pump(const Duration(milliseconds: 350));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      // Verify Header
      expect(find.text('Transaction List'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);

      // Verify Month Summary
      expect(find.text('September, 2026'), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_up_rounded), findsOneWidget);

      // Verify Empty state or loading when no live transactions are loaded
      expect(find.byType(TransactionListScreen), findsOneWidget);

      // Verify Bottom Filter Bar
      expect(find.text('Date'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Wallet'), findsOneWidget);
      expect(find.byIcon(Icons.more_vert_rounded), findsOneWidget);

      // Tap Search icon
      await tester.tap(find.byIcon(Icons.search_rounded));
      await tester.pump(const Duration(milliseconds: 350));
      expect(find.byType(TextField), findsOneWidget);
    },
  );

  testWidgets(
    'HomeScreen navigates to TransactionListScreen when period item is tapped',
    (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: appRouter));
      appRouter.go(AppRoutes.home);
      await tester.pump(const Duration(milliseconds: 350));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      // Tap on 'This month'
      await tester.tap(find.text('This month'));
      await tester.pump(const Duration(milliseconds: 350));
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();

      // Should be on TransactionListScreen
      expect(find.text('Transaction List'), findsOneWidget);
      expect(find.text('September, 2026'), findsOneWidget);
    },
  );

  testWidgets(
    'UserProfileScreen renders matching mockup components with all 7 cards',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: UserProfileScreen()));
      await tester.pumpAndSettle();

      // Top App Bar
      expect(find.text('User Profile'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      // Card 1: Account Security & Identity
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.text('E-mail (Not Verified)'), findsOneWidget);
      expect(find.text('ezbookkeeping@mayswind.net'), findsOneWidget);
      expect(find.text('Nickname'), findsOneWidget);
      expect(find.text('demo'), findsOneWidget);

      // Card 2: Account Preferences
      expect(find.text('Default Account'), findsOneWidget);
      expect(find.text('Unspecified'), findsOneWidget);
      expect(find.text('Use Last Reconciled Time'), findsOneWidget);
      expect(find.text('Disabled'), findsOneWidget);
      expect(find.text('Editable Transaction Range'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);

      // Card 3: Regional & Localization
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Default Currency'), findsOneWidget);
      expect(find.text('United States Dollar USD'), findsOneWidget);
      expect(find.text('First Day of Week'), findsOneWidget);
      expect(find.text('Sunday'), findsOneWidget);
      expect(find.text('Fiscal Year Start Date'), findsOneWidget);
      expect(find.text('January 1'), findsOneWidget);

      // Card 4: Date & Time Display Formats
      expect(find.text('Calendar Display Type'), findsOneWidget);
      expect(find.text('Date Display Type'), findsOneWidget);
      expect(find.text('Long Date Format'), findsOneWidget);
      expect(find.text('Short Date Format'), findsOneWidget);
      expect(find.text('Long Time Format'), findsOneWidget);
      expect(find.text('Short Time Format'), findsOneWidget);
      expect(find.text('Fiscal Year Format'), findsOneWidget);

      // Card 5: Number & Currency Formats
      expect(find.text('Currency Display Mode'), findsOneWidget);
      expect(find.text('Numeral System'), findsOneWidget);
      expect(find.text('Digit Grouping'), findsOneWidget);
      expect(find.text('Digit Grouping Symbol'), findsOneWidget);
      expect(find.text('Decimal Separator'), findsOneWidget);

      // Card 6: Geographic Location
      expect(find.text('Geographic Location Format'), findsOneWidget);

      // Card 7: Transaction Colors
      expect(find.text('Expense Amount Color'), findsOneWidget);
      expect(find.text('System Default (Green)'), findsOneWidget);
      expect(find.text('Income Amount Color'), findsOneWidget);
      expect(find.text('System Default (Red)'), findsOneWidget);

      // Test clear button on Nickname
      expect(find.byIcon(Icons.cancel_rounded), findsNWidgets(2));
      await tester.tap(find.byIcon(Icons.cancel_rounded).last);
      await tester.pumpAndSettle();
      expect(find.text('demo'), findsNothing);

      // Test Save button
      await tester.tap(find.byIcon(Icons.check_rounded));
      await tester.pumpAndSettle();
      expect(find.text('User profile saved successfully'), findsOneWidget);
    },
  );

  testWidgets(
    'SettingsScreen navigates to UserProfileScreen when User Profile is tapped',
    (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: appRouter));
      appRouter.go(AppRoutes.settings);
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('User Profile'), findsOneWidget);

      // Tap User Profile
      await tester.tap(find.text('User Profile'));
      await tester.pumpAndSettle();

      // Should be on UserProfileScreen
      expect(find.text('E-mail (Not Verified)'), findsOneWidget);
      expect(find.text('Default Account'), findsOneWidget);
    },
  );

  testWidgets(
    'TransactionCategoriesScreen renders category types and navigates',
    (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: appRouter));
      appRouter.go(AppRoutes.transactionCategories);
      await tester.pumpAndSettle();

      expect(find.byType(TransactionCategoriesScreen), findsOneWidget);
      expect(find.text('Transaction Categories'), findsOneWidget);
      expect(find.text('Expense'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Transfer'), findsOneWidget);

      // Tap Expense to navigate to primary categories
      await tester.tap(find.text('Expense'));
      await tester.pumpAndSettle();

      expect(find.text('Expense Primary Categories'), findsOneWidget);
    },
  );

  testWidgets(
    'PrimaryCategoriesScreen renders 11 categories and responds to actions',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PrimaryCategoriesScreen(categoryType: 'Expense'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Expense Primary Categories'), findsOneWidget);
      expect(find.text('Food & Drink'), findsOneWidget);
      expect(find.text('Clothing & Appearance'), findsOneWidget);
      expect(find.text('Housing & Houseware'), findsOneWidget);
      expect(find.text('Transportation'), findsOneWidget);
      expect(find.text('Communication'), findsOneWidget);
      expect(find.text('Entertainment'), findsOneWidget);
      expect(find.text('Education & Studying'), findsOneWidget);
      expect(find.text('Gifts & Donations'), findsOneWidget);
      expect(find.text('Medical & Healthcare'), findsOneWidget);
      expect(find.text('Finance & Insurance'), findsOneWidget);
      expect(find.text('Miscellaneous'), findsOneWidget);

      // Open options sheet via '...'
      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Sort by Name'), findsOneWidget);
      expect(find.text('Reset to Default'), findsOneWidget);

      // Tap Sort by Name
      await tester.tap(find.text('Sort by Name'));
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'SecondaryCategoriesScreen renders sub-categories and responds to actions',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SecondaryCategoriesScreen(
            primaryCategoryName: 'Food & Drink',
            categoryType: 'Expense',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Expense Secondary Categories'), findsOneWidget);
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Drink'), findsOneWidget);
      expect(find.text('Fruit & Snack'), findsOneWidget);

      // Open options sheet via '...'
      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Sort by Name'), findsOneWidget);
      expect(find.text('Reset to Default'), findsOneWidget);

      // Dismiss bottom sheet
      await tester.tap(find.text('Sort by Name'));
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'AddCategoryScreen validates empty name and saves valid category',
    (tester) async {
      CategoryItem? savedItem;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  final res = await Navigator.push<CategoryItem>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddCategoryScreen(
                        isPrimary: false,
                        primaryCategoryName: 'Food & Drink',
                      ),
                    ),
                  );
                  savedItem = res;
                },
                child: const Text('Open Add'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Add'));
      await tester.pumpAndSettle();

      expect(find.text('Add Secondary Category'), findsOneWidget);
      expect(find.text('Category Name'), findsOneWidget);
      expect(find.text('Category Icon'), findsOneWidget);
      expect(find.text('Category Color'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);

      // Tap checkmark without entering name -> shows validation error
      await tester.tap(find.byIcon(Icons.check_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Category name cannot be empty'), findsOneWidget);

      // Enter name & description
      await tester.enterText(
        find.widgetWithText(TextField, 'Your category name'),
        'Dessert',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Your category description (optional)'),
        'Sweet treats and desserts',
      );
      await tester.pumpAndSettle();

      // Tap checkmark to save
      await tester.tap(find.byIcon(Icons.check_rounded));
      await tester.pumpAndSettle();

      expect(savedItem, isNotNull);
      expect(savedItem!.name, 'Dessert');
      expect(savedItem!.parentId, 'Food & Drink');
      expect(savedItem!.isPrimary, false);
      expect(savedItem!.description, 'Sweet treats and desserts');
    },
  );

  testWidgets('SettingsScreen navigates through entire category flow', (
    tester,
  ) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: appRouter));
    appRouter.go(AppRoutes.settings);
    await tester.pumpAndSettle();

    // Scroll if needed and tap 'Transaction Categories'
    await tester.scrollUntilVisible(find.text('Transaction Categories'), 100);
    await tester.tap(find.text('Transaction Categories'));
    await tester.pumpAndSettle();

    // On TransactionCategoriesScreen
    expect(find.text('Transaction Categories'), findsOneWidget);
    expect(find.text('Expense'), findsOneWidget);

    // Tap Expense
    await tester.tap(find.text('Expense'));
    await tester.pumpAndSettle();

    // On PrimaryCategoriesScreen
    expect(find.text('Expense Primary Categories'), findsOneWidget);
    expect(find.text('Food & Drink'), findsOneWidget);

    // Tap Food & Drink
    await tester.tap(find.text('Food & Drink'));
    await tester.pumpAndSettle();

    // On SecondaryCategoriesScreen
    expect(find.text('Expense Secondary Categories'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Drink'), findsOneWidget);

    // Tap '+' to add secondary category
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    // On AddCategoryScreen
    expect(find.text('Add Secondary Category'), findsOneWidget);

    // Go back via circular back button
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Expense Secondary Categories'), findsOneWidget);
  });

  testWidgets(
    'TransactionTagsScreen renders matching mockup components with default group and tags',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TransactionTagsScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(TransactionTagsScreen), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
      expect(find.text('Default Group'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_drop_down_circle_rounded), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);

      // Verify default tags
      expect(find.text('travel'), findsOneWidget);
      expect(find.text('future'), findsOneWidget);
      expect(find.text('#'), findsNWidgets(2));
    },
  );

  testWidgets(
    'TransactionTagsScreen triggers inline tag addition and saves new tag with blue checkmark',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TransactionTagsScreen()));
      await tester.pumpAndSettle();

      // Tap + button to trigger inline entry
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Tag Title'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      // Tap checkmark when empty -> shows validation SnackBar
      await tester.tap(find.byIcon(Icons.check_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Tag title cannot be empty'), findsOneWidget);

      // Enter tag title
      await tester.enterText(
        find.widgetWithText(TextField, 'Tag Title'),
        'vacation',
      );
      await tester.pumpAndSettle();

      // Tap checkmark to save
      await tester.tap(find.byIcon(Icons.check_rounded));
      await tester.pumpAndSettle();

      expect(find.text('vacation'), findsOneWidget);
      expect(find.text('Tag Title'), findsNothing);
    },
  );

  testWidgets(
    'TransactionTagsScreen cancels inline tag addition with close button',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TransactionTagsScreen()));
      await tester.pumpAndSettle();

      // Tap + button
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Tag Title'), findsOneWidget);

      // Tap close button
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Tag Title'), findsNothing);
    },
  );

  testWidgets(
    'TransactionTagsScreen opens custom action sheet and performs sort',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TransactionTagsScreen()));
      await tester.pumpAndSettle();

      // Tap ... button to open action sheet
      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Add Tag Group'), findsOneWidget);
      expect(find.text('Sort'), findsOneWidget);
      expect(find.text('Sort by Name (A to Z)'), findsOneWidget);
      expect(find.text('Sort by Name (Z to A)'), findsOneWidget);
      expect(find.text('Show Hidden Transaction Tags'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Tap Sort by Name (A to Z)
      await tester.tap(find.text('Sort by Name (A to Z)'));
      await tester.pumpAndSettle();

      expect(find.text('Sorted by Name (A to Z)'), findsOneWidget);
      expect(find.text('Cancel'), findsNothing);
    },
  );

  testWidgets(
    'SettingsScreen navigates to TransactionTagsScreen when Transaction Tags is tapped',
    (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: appRouter));
      appRouter.go(AppRoutes.settings);
      await tester.pumpAndSettle();

      // Scroll to Transaction Tags and tap
      await tester.scrollUntilVisible(find.text('Transaction Tags'), 100);
      await tester.tap(find.text('Transaction Tags'));
      await tester.pumpAndSettle();

      expect(find.byType(TransactionTagsScreen), findsOneWidget);
      expect(find.text('Default Group'), findsOneWidget);
      expect(find.text('travel'), findsOneWidget);
      expect(find.text('future'), findsOneWidget);
    },
  );

  testWidgets('TransactionTemplatesScreen renders empty state matching mockup', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: TransactionTemplatesScreen()),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TransactionTemplatesScreen), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    expect(find.text('Transaction Templates'), findsOneWidget);
    expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);

    expect(find.text('No available template'), findsOneWidget);
    expect(
      find.text(
        'Once you add templates, you can long-press the Add button on the home page to quickly add a new transaction',
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'TransactionTemplatesScreen opens custom action sheet matching mockup and responds to actions',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: TransactionTemplatesScreen()),
      );
      await tester.pumpAndSettle();

      // Tap '...' button to open the action sheet
      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();

      // Verify action sheet options matching media_1789109548058.png
      expect(find.text('Sort'), findsOneWidget);
      expect(find.text('Show Hidden Transaction Templates'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Tap Cancel to dismiss
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel'), findsNothing);

      // Tap '...' again and tap Sort
      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sort'));
      await tester.pumpAndSettle();

      expect(find.text('Sort'), findsNothing);

      // Tap '...' again and tap Show Hidden Transaction Templates
      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Show Hidden Transaction Templates'));
      await tester.pumpAndSettle();

      // Tap '...' again and verify it now says Hide Hidden Transaction Templates
      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Hide Hidden Transaction Templates'), findsOneWidget);

      // Dismiss
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'AddTransactionTemplateScreen renders Expense mode matching mockup',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AddTransactionTemplateScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Add Transaction Template'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      // Segmented Tabs
      expect(find.text('Expense'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
      expect(find.text('Transfer'), findsOneWidget);

      // Form Card Fields
      expect(find.text('Template Name'), findsNWidgets(2)); // Label and hint
      expect(find.text('Expense Amount'), findsOneWidget);
      expect(find.text('\$ 0.00'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Food & Drink'), findsOneWidget);
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Wallet (US Dollar)'), findsOneWidget);
      expect(find.text('Tags'), findsOneWidget);
      expect(find.text('None'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(
        find.text('Your transaction description (optional)'),
        findsOneWidget,
      );

      // Bottom Save Button
      expect(find.text('Save'), findsOneWidget);
    },
  );

  testWidgets(
    'AddTransactionTemplateScreen switches to Income and Transfer modes matching mockups',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AddTransactionTemplateScreen()),
      );
      await tester.pumpAndSettle();

      // Tap Income
      await tester.tap(find.text('Income'));
      await tester.pumpAndSettle();

      expect(find.text('Income Amount'), findsOneWidget);
      expect(find.text('Occupational Earnings'), findsOneWidget);
      expect(find.text('Salary Income'), findsOneWidget);

      // Tap Transfer
      await tester.tap(find.text('Transfer'));
      await tester.pumpAndSettle();

      expect(find.text('Transfer Out Amount'), findsOneWidget);
      expect(find.text('Transfer In Amount'), findsOneWidget);
      expect(find.text('General Transfer'), findsOneWidget);
      expect(find.text('Bank Transfer'), findsOneWidget);
      expect(find.text('Source Account'), findsOneWidget);
      expect(find.text('Destination Account'), findsOneWidget);
      expect(find.text('Wallet (US Dollar)'), findsNWidgets(2));
    },
  );

  testWidgets(
    'AddTransactionTemplateScreen opens Transfer action sheet and performs actions',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: AddTransactionTemplateScreen()),
      );
      await tester.pumpAndSettle();

      // Switch to Transfer mode
      await tester.tap(find.text('Transfer'));
      await tester.pumpAndSettle();

      // Open Action Sheet via '...'
      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();

      // Verify Action Sheet options (Mockup 5)
      expect(find.text('Swap Account'), findsOneWidget);
      expect(find.text('Swap Amount'), findsOneWidget);
      expect(find.text('Swap Account and Amount'), findsOneWidget);
      expect(find.text('Paste Amount'), findsOneWidget);
      expect(find.text('Paste Destination Amount'), findsOneWidget);
      expect(find.text('Hide Amount'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Tap Swap Account
      await tester.tap(find.text('Swap Account'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel'), findsNothing);
    },
  );

  testWidgets('AddTransactionTemplateScreen validates and saves new template', (
    tester,
  ) async {
    TransactionTemplate? savedTemplate;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                final res = await Navigator.push<TransactionTemplate>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AddTransactionTemplateScreen(),
                  ),
                );
                savedTemplate = res;
              },
              child: const Text('Open Add Template'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open Add Template'));
    await tester.pumpAndSettle();

    // Tap Save checkmark without name -> shows validation
    await tester.tap(find.byIcon(Icons.check_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Template name cannot be empty'), findsOneWidget);

    // Enter Template Name
    await tester.enterText(
      find.widgetWithText(TextField, 'Template Name'),
      'Daily Coffee',
    );
    await tester.pumpAndSettle();

    // Tap Save checkmark to persist template
    await tester.tap(find.byIcon(Icons.check_rounded));
    await tester.pumpAndSettle();

    expect(savedTemplate, isNotNull);
    expect(savedTemplate!.name, 'Daily Coffee');
    expect(savedTemplate!.categoryParent, 'Food & Drink');
    expect(savedTemplate!.categoryChild, 'Food');
  });

  testWidgets('SettingsScreen navigates through Transaction Templates flow', (
    tester,
  ) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: appRouter));
    appRouter.go(AppRoutes.settings);
    await tester.pumpAndSettle();

    // Scroll to Transaction Templates and tap
    await tester.scrollUntilVisible(find.text('Transaction Templates'), 100);
    await tester.tap(find.text('Transaction Templates'));
    await tester.pumpAndSettle();

    expect(find.byType(TransactionTemplatesScreen), findsOneWidget);
    expect(find.text('No available template'), findsOneWidget);

    // Tap '+' to add a template
    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(AddTransactionTemplateScreen), findsOneWidget);
    expect(find.text('Add Transaction Template'), findsOneWidget);

    // Go back
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(TransactionTemplatesScreen), findsOneWidget);
  });

  testWidgets('DataManagementScreen renders matching mockup components', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: DataManagementScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Data Management'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);

    // Card 1: 9 Metrics matching media_1789110130654.png
    expect(find.text('Transactions'), findsOneWidget);
    expect(find.text('58'), findsOneWidget);
    expect(find.text('Transaction Pictures'), findsOneWidget);
    expect(find.text('Accounts'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('Explorations'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('Transaction Categories'), findsOneWidget);
    expect(find.text('80'), findsOneWidget);
    expect(find.text('Transaction Tags'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('Transaction Templates'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('Scheduled Transactions'), findsOneWidget);
    expect(find.text('Custom Icons'), findsOneWidget);

    // Card 2: Export Data Button
    expect(find.text('Export Data'), findsOneWidget);

    // Card 3: Danger Zone Actions
    expect(find.text('Clear All Transactions'), findsOneWidget);
    expect(find.text('Clear All Data'), findsOneWidget);
  });

  testWidgets(
    'DataManagementScreen triggers export and clear actions with confirmation',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: DataManagementScreen()));
      await tester.pumpAndSettle();

      // Scroll to Export Data and tap
      await tester.scrollUntilVisible(find.text('Export Data'), 100);
      await tester.tap(find.text('Export Data'));
      await tester.pumpAndSettle();

      expect(find.text('Export as CSV'), findsOneWidget);
      expect(find.text('Export as JSON'), findsOneWidget);

      await tester.tap(find.text('Export as CSV'));
      await tester.pumpAndSettle();

      // Scroll to Clear All Transactions and tap
      await tester.scrollUntilVisible(find.text('Clear All Transactions'), 100);
      await tester.tap(find.text('Clear All Transactions'));
      await tester.pumpAndSettle();

      expect(
        find.text('Clear All Transactions'),
        findsNWidgets(2),
      ); // Button & Dialog title
      expect(find.text('Clear'), findsOneWidget);

      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      // Verify transaction count is now 0
      expect(find.text('58'), findsNothing);
    },
  );

  testWidgets('SettingsScreen navigates to DataManagementScreen', (
    tester,
  ) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: appRouter));
    appRouter.go(AppRoutes.settings);
    await tester.pumpAndSettle();

    // Scroll to Data Management and tap
    await tester.scrollUntilVisible(find.text('Data Management'), 100);
    await tester.tap(find.text('Data Management'));
    await tester.pumpAndSettle();

    expect(find.byType(DataManagementScreen), findsOneWidget);
    expect(find.text('Data Management'), findsOneWidget);
    expect(find.text('Export Data'), findsOneWidget);

    // Tap back
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsScreen), findsOneWidget);
  });

  testWidgets(
    'TwoFactorAuthScreen renders Status Disabled and Enable button matching mockup',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TwoFactorAuthScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Two-Factor Authentication'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);

      // Card Status and Action
      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Disabled'), findsOneWidget);
      expect(find.text('Enable'), findsOneWidget);
    },
  );

  testWidgets(
    'TwoFactorAuthScreen verifies enable dialog and toggles status to Enabled',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TwoFactorAuthScreen()));
      await tester.pumpAndSettle();

      // Tap Enable button
      await tester.tap(find.text('Enable'));
      await tester.pumpAndSettle();

      expect(find.text('Enable 2FA'), findsOneWidget);
      expect(find.text('JBSWY3DPEHPK3PXP'), findsOneWidget);
      expect(find.text('Verify & Enable'), findsOneWidget);

      // Enter 6 digit code
      await tester.enterText(find.byType(TextField), '123456');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Verify & Enable'));
      await tester.pumpAndSettle();

      // Status should now be Enabled and button Disable
      expect(find.text('Enabled'), findsOneWidget);
      expect(find.text('Disable'), findsOneWidget);

      // Tap Disable and confirm
      await tester.tap(find.text('Disable'));
      await tester.pumpAndSettle();

      expect(find.text('Disable 2FA'), findsOneWidget);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Disable'));
      await tester.pumpAndSettle();

      // Status should now be Disabled
      expect(find.text('Disabled'), findsOneWidget);
      expect(find.text('Enable'), findsOneWidget);
    },
  );

  testWidgets('SettingsScreen navigates to TwoFactorAuthScreen', (
    tester,
  ) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: appRouter));
    appRouter.go(AppRoutes.settings);
    await tester.pumpAndSettle();

    // Scroll to Two-Factor Authentication and tap
    await tester.scrollUntilVisible(
      find.text('Two-Factor Authentication'),
      100,
    );
    await tester.tap(find.text('Two-Factor Authentication'));
    await tester.pumpAndSettle();

    expect(find.byType(TwoFactorAuthScreen), findsOneWidget);
    expect(find.text('Two-Factor Authentication'), findsOneWidget);
    expect(find.text('Enable'), findsOneWidget);

    // Tap back
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsScreen), findsOneWidget);
  });

  testWidgets(
    'DeviceAndSessionsScreen renders sessions list and Logout All button matching mockup',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: DeviceAndSessionsScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Device & Sessions'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
      expect(find.text('Logout All'), findsOneWidget);

      // Verify sessions and devices
      expect(find.text('Current'), findsOneWidget);
      expect(find.text('iPhone (Mobile Safari 18.5)'), findsOneWidget);
      expect(find.text('Windows 10 (Chrome 152.0.0.0)'), findsWidgets);
      expect(find.byIcon(Icons.desktop_windows_outlined), findsWidgets);
      expect(find.byIcon(Icons.smartphone_outlined), findsWidgets);
    },
  );

  testWidgets(
    'DeviceAndSessionsScreen executes Logout All confirmation and preserves Current session',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: DeviceAndSessionsScreen()),
      );
      await tester.pumpAndSettle();

      // Tap Logout All
      await tester.tap(find.text('Logout All'));
      await tester.pumpAndSettle();

      expect(
        find.text('Logout All'),
        findsNWidgets(3),
      ); // Top button, Dialog title, and Confirm button
      expect(
        find.text(
          'Are you sure you want to log out of all other active sessions?',
        ),
        findsOneWidget,
      );

      // Confirm Logout All
      await tester.tap(find.widgetWithText(ElevatedButton, 'Logout All'));
      await tester.pumpAndSettle();

      // Only Current device should remain
      expect(find.text('Current'), findsOneWidget);
      expect(find.text('Other Device'), findsNothing);
    },
  );

  testWidgets('SettingsScreen navigates to DeviceAndSessionsScreen', (
    tester,
  ) async {
    await tester.pumpWidget(MaterialApp.router(routerConfig: appRouter));
    appRouter.go(AppRoutes.settings);
    await tester.pumpAndSettle();

    // Scroll to Device & Sessions and tap
    await tester.scrollUntilVisible(find.text('Device & Sessions'), 100);
    await tester.tap(find.text('Device & Sessions'));
    await tester.pumpAndSettle();

    expect(find.byType(DeviceAndSessionsScreen), findsOneWidget);
    expect(find.text('Device & Sessions'), findsOneWidget);
    expect(find.text('Logout All'), findsOneWidget);

    // Tap back
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsScreen), findsOneWidget);
  });

  testWidgets(
    'TextSizeScreen renders preview card and text size slider matching mockup',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: TextSizeScreen()));
      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('Text Size'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      // Verify Preview Card
      expect(find.text('September, 2026'), findsOneWidget);
      expect(find.text(r'+$ 123.45'), findsOneWidget);
      expect(find.text(r'-$ 678.90'), findsOneWidget);
      expect(find.text('11'), findsOneWidget);
      expect(find.text('Fri'), findsOneWidget);
      expect(find.byIcon(Icons.rate_review_outlined), findsOneWidget);
      expect(find.text('Category Name'), findsOneWidget);
      expect(find.text(r'$ 123.45'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('# Tag Title'), findsOneWidget);
      expect(find.text('12:56 PM · Account Name'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);

      // Verify Slider card with Default label and A markers
      expect(find.text('Default'), findsOneWidget);
      expect(find.text('A'), findsNWidgets(2));
      expect(find.byType(Slider), findsOneWidget);
    },
  );

  testWidgets(
    'TextSizeScreen updates text size label and preview on slider change',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: TextSizeScreen(initialSize: 'Default')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Default'), findsOneWidget);

      // Change slider to Extra Large (index 4)
      tester.widget<Slider>(find.byType(Slider)).onChanged?.call(4.0);
      await tester.pumpAndSettle();

      expect(find.text('Extra Large'), findsOneWidget);

      // Change slider to Small (index 0)
      tester.widget<Slider>(find.byType(Slider)).onChanged?.call(0.0);
      await tester.pumpAndSettle();

      expect(find.text('Small'), findsOneWidget);
    },
  );

  testWidgets('TextSizeScreen saves selection and pops with checkmark', (
    tester,
  ) async {
    String? returnedValue;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    final res = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const TextSizeScreen(initialSize: 'Default'),
                      ),
                    );
                    returnedValue = res;
                  },
                  child: const Text('Open'),
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.byType(TextSizeScreen), findsOneWidget);

    // Update slider to Extra Large
    tester.widget<Slider>(find.byType(Slider)).onChanged?.call(4.0);
    await tester.pumpAndSettle();

    // Tap Checkmark ✓
    await tester.tap(find.byIcon(Icons.check_rounded));
    await tester.pumpAndSettle();

    expect(find.byType(TextSizeScreen), findsNothing);
    expect(returnedValue, 'Extra Large');
  });

  testWidgets(
    'SettingsScreen displays Text Size and navigates to TextSizeScreen',
    (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: appRouter));
      appRouter.go(AppRoutes.settings);
      await tester.pumpAndSettle();

      // Scroll to Text Size and tap
      await tester.scrollUntilVisible(find.text('Text Size'), 100);
      expect(find.text('Text Size'), findsOneWidget);
      expect(find.text('Default'), findsOneWidget);

      await tester.tap(find.text('Text Size'));
      await tester.pumpAndSettle();

      expect(find.byType(TextSizeScreen), findsOneWidget);
      expect(find.text('Category Name'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);
    },
  );

  testWidgets('App applies Text Size dynamically to entire application', (
    tester,
  ) async {
    appRouter.go(AppRoutes.home);
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();

    // Verify home screen is rendered
    expect(find.byType(HomeScreen), findsOneWidget);

    // Verify default text scale factor in context
    final BuildContext homeContext = tester.element(find.byType(HomeScreen));
    expect(MediaQuery.textScalerOf(homeContext).scale(10.0), 10.0);

    // Access theme controller from ThemeScope
    final themeController = ThemeScope.of(homeContext);
    expect(themeController.currentTextScale, AppTextScale.normal);

    // Change text scale to Extra Large
    themeController.setTextScale(AppTextScale.extraLarge);
    await tester.pumpAndSettle();

    // Verify updated text scaler across the entire app
    final BuildContext updatedContext = tester.element(find.byType(HomeScreen));
    expect(
      MediaQuery.textScalerOf(updatedContext).scale(10.0),
      closeTo(13.8, 0.01),
    );

    // Change text scale to Small
    themeController.setTextScale(AppTextScale.small);
    await tester.pumpAndSettle();

    final BuildContext smallContext = tester.element(find.byType(HomeScreen));
    expect(
      MediaQuery.textScalerOf(smallContext).scale(10.0),
      closeTo(8.8, 0.01),
    );
  });

  testWidgets(
    'TimezonePickerSheet renders header, circular close button, search button, and timezone list matching mockup',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TimezonePickerSheet(
              currentTimezone: '(UTC+05:30) System Default',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('Timezone'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);

      // Verify selected item with left checkmark
      expect(find.text('(UTC+05:30) System Default'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      // Verify other standard timezones in the list
      expect(find.text('(UTC+04:30) Kabul'), findsOneWidget);
      expect(find.text('(UTC+05:00) Astana'), findsOneWidget);
    },
  );

  testWidgets('TimezonePickerSheet filters timezones when searching', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TimezonePickerSheet(
            currentTimezone: '(UTC+05:30) System Default',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap search button
    await tester.tap(find.byIcon(Icons.search_rounded));
    await tester.pumpAndSettle();

    // Search text field should be visible
    expect(find.byType(TextField), findsOneWidget);

    // Enter search query
    await tester.enterText(find.byType(TextField), 'tokyo');
    await tester.pumpAndSettle();

    // Tokyo should be visible, Kabul should not
    expect(find.text('(UTC+09:00) Osaka, Sapporo, Tokyo'), findsOneWidget);
    expect(find.text('(UTC+04:30) Kabul'), findsNothing);

    // Search for Kabul
    await tester.enterText(find.byType(TextField), 'kabul');
    await tester.pumpAndSettle();

    expect(find.text('(UTC+04:30) Kabul'), findsOneWidget);
    expect(find.text('(UTC+09:00) Osaka, Sapporo, Tokyo'), findsNothing);
  });

  testWidgets(
    'TimezonePickerSheet selects timezone and returns value with left checkmark indicator',
    (tester) async {
      String? selectedTz;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: ElevatedButton(
                  onPressed: () async {
                    final res = await TimezonePickerSheet.show(
                      context,
                      currentTimezone: '(UTC+05:30) System Default',
                    );
                    selectedTz = res;
                  },
                  child: const Text('Open Timezone'),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Timezone'));
      await tester.pumpAndSettle();

      expect(find.byType(TimezonePickerSheet), findsOneWidget);

      // Select Kabul
      await tester.tap(find.text('(UTC+04:30) Kabul'));
      await tester.pumpAndSettle();

      expect(find.byType(TimezonePickerSheet), findsNothing);
      expect(selectedTz, '(UTC+04:30) Kabul');
    },
  );

  testWidgets(
    'SettingsScreen opens TimezonePickerSheet and updates selected timezone',
    (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: appRouter));
      appRouter.go(AppRoutes.settings);
      await tester.pumpAndSettle();

      // Scroll to Timezone
      await tester.scrollUntilVisible(find.text('Timezone'), 100);
      expect(find.text('Timezone'), findsOneWidget);

      // Tap Timezone
      await tester.tap(find.text('Timezone'));
      await tester.pumpAndSettle();

      expect(find.byType(TimezonePickerSheet), findsOneWidget);

      // Tap Kabul
      await tester.tap(find.text('(UTC+04:30) Kabul'));
      await tester.pumpAndSettle();

      expect(find.byType(TimezonePickerSheet), findsNothing);
      expect(find.text('(UTC+04:30) Kabul'), findsOneWidget);
    },
  );

  testWidgets(
    'SettingsScreen renders all Application section items matching mockup and toggles switches',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(MaterialApp.router(routerConfig: appRouter));
      appRouter.go(AppRoutes.settings);
      await tester.pumpAndSettle();

      // Verify Application header
      await tester.scrollUntilVisible(find.text('Application'), 100);
      expect(find.text('Application'), findsOneWidget);

      // Verify items
      expect(find.text('Exchange Rates Data'), findsOneWidget);
      expect(find.text('September 10, 2026'), findsOneWidget);

      expect(find.text('Preferences'), findsOneWidget);
      expect(find.text('Statistics Settings'), findsOneWidget);
      expect(find.text('Settings Sync'), findsOneWidget);

      expect(find.text('Enable Swipe Back'), findsOneWidget);
      expect(find.text('Enable Animation'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('About'), 100);
      expect(find.text('Browser Cache Management'), findsOneWidget);
      expect(find.text('Switch to Desktop Version'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
      expect(find.text('v2.0.0-dev (d96ba0c)'), findsOneWidget);

      // Verify toggles
      final switches = find.byType(CupertinoSwitch);
      expect(switches, findsNWidgets(2));

      // Initial switch values are true
      expect(tester.widget<CupertinoSwitch>(switches.at(0)).value, isTrue);
      expect(tester.widget<CupertinoSwitch>(switches.at(1)).value, isTrue);

      // Toggle 'Enable Swipe Back'
      await tester.tap(switches.at(0));
      await tester.pumpAndSettle();
      expect(tester.widget<CupertinoSwitch>(switches.at(0)).value, isFalse);

      // Toggle 'Enable Animation'
      await tester.tap(switches.at(1));
      await tester.pumpAndSettle();
      expect(tester.widget<CupertinoSwitch>(switches.at(1)).value, isFalse);

      // Tap Switch to Desktop Version
      await tester.tap(find.text('Switch to Desktop Version'));
      await tester.pumpAndSettle();
      expect(find.text('Switch to Desktop Version opened'), findsOneWidget);
    },
  );

  testWidgets(
    'ApplicationLockScreen renders Status Disabled and Enable button matching mockup',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ApplicationLockScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Application Lock'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Disabled'), findsOneWidget);
      expect(find.text('Enable'), findsOneWidget);
    },
  );

  testWidgets(
    'ApplicationLockScreen enables with PIN and disables with confirmation',
    (tester) async {
      await tester.pumpWidget(const MaterialApp(home: ApplicationLockScreen()));
      await tester.pumpAndSettle();

      // Tap Enable
      await tester.tap(find.text('Enable'));
      await tester.pumpAndSettle();

      expect(find.text('Set Application Lock PIN'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Try enabling with empty / short PIN
      await tester.enterText(find.byType(TextField), '12');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Enable'));
      await tester.pumpAndSettle();
      expect(find.text('Please enter a valid 4-digit PIN'), findsOneWidget);

      // Enter valid 4-digit PIN
      await tester.enterText(find.byType(TextField), '1234');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Enable'));
      await tester.pumpAndSettle();

      expect(
        find.text('Application Lock enabled successfully'),
        findsOneWidget,
      );
      expect(find.text('Enabled'), findsOneWidget);
      expect(find.text('Disable'), findsOneWidget);

      // Tap Disable
      await tester.tap(find.text('Disable'));
      await tester.pumpAndSettle();

      expect(find.text('Disable Application Lock'), findsOneWidget);

      // Confirm Disable
      await tester.tap(find.widgetWithText(ElevatedButton, 'Disable'));
      await tester.pumpAndSettle();

      expect(find.text('Application Lock disabled'), findsOneWidget);
      expect(find.text('Disabled'), findsOneWidget);
      expect(find.text('Enable'), findsOneWidget);
    },
  );

  testWidgets(
    'SettingsScreen navigates to ApplicationLockScreen and receives updated status',
    (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: appRouter));
      appRouter.go(AppRoutes.settings);
      await tester.pumpAndSettle();

      // Scroll to Application Lock
      await tester.scrollUntilVisible(find.text('Application Lock'), 100);
      expect(find.text('Application Lock'), findsOneWidget);
      expect(find.text('Disabled'), findsOneWidget);

      // Tap Application Lock to navigate
      await tester.tap(find.text('Application Lock'));
      await tester.pumpAndSettle();

      expect(find.byType(ApplicationLockScreen), findsOneWidget);

      // Enable lock
      await tester.tap(find.text('Enable'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '4321');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Enable'));
      await tester.pumpAndSettle();

      expect(find.text('Enabled'), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();

      // Should be back on SettingsScreen with Updated status
      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.text('Enabled'), findsOneWidget);
    },
  );

  testWidgets(
    'ExchangeRatesDataScreen renders matching mockup components and interacts with action sheet',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ExchangeRatesDataScreen()),
      );
      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('Exchange Rates Data'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);

      // Verify Card 1: Base Currency & Base Amount
      expect(find.text('Base Currency'), findsOneWidget);
      expect(find.text('United States Dollar'), findsOneWidget);
      expect(find.text('USD'), findsOneWidget);
      expect(find.text('Base Amount'), findsOneWidget);
      expect(find.text('1.00'), findsOneWidget);

      // Verify Card 2: Currency items from mockup
      expect(find.text('Australian Dollar'), findsOneWidget);
      expect(find.text('AUD'), findsOneWidget);
      expect(find.text('1.3917'), findsOneWidget);

      expect(find.text('Brazilian Real'), findsOneWidget);
      expect(find.text('BRL'), findsOneWidget);
      expect(find.text('5.1246'), findsOneWidget);

      expect(find.text('British Pound'), findsOneWidget);
      expect(find.text('GBP'), findsOneWidget);
      expect(find.text('0.7396'), findsOneWidget);

      expect(find.text('Euro'), findsOneWidget);
      expect(find.text('EUR'), findsOneWidget);
      expect(find.text('0.8608'), findsOneWidget);

      // Tap '...' to open custom floating action sheet
      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Refresh'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Tap Refresh
      await tester.tap(find.text('Refresh'));
      await tester.pumpAndSettle();

      expect(find.text('Exchange rates updated successfully'), findsOneWidget);
    },
  );

  testWidgets(
    'ExchangeRatesDataScreen updates base amount and dynamically recalculates rates',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: ExchangeRatesDataScreen()),
      );
      await tester.pumpAndSettle();

      // Tap Base Amount
      await tester.tap(find.text('1.00'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Base Amount'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '2.00');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Set Amount'));
      await tester.pumpAndSettle();

      expect(find.text('2.00'), findsOneWidget);
      // 1.3917 * 2 = 2.7834
      expect(find.text('2.7834'), findsOneWidget);
    },
  );

  testWidgets(
    'SettingsScreen navigates to ExchangeRatesDataScreen when tile is tapped',
    (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: appRouter));
      appRouter.go(AppRoutes.settings);
      await tester.pumpAndSettle();

      // Scroll to Exchange Rates Data
      await tester.scrollUntilVisible(find.text('Exchange Rates Data'), 100);
      expect(find.text('Exchange Rates Data'), findsOneWidget);

      // Tap tile
      await tester.tap(find.text('Exchange Rates Data'));
      await tester.pumpAndSettle();

      expect(find.byType(ExchangeRatesDataScreen), findsOneWidget);
      expect(find.text('Base Currency'), findsOneWidget);
      expect(find.text('United States Dollar'), findsOneWidget);
    },
  );

  testWidgets(
    'AboutScreen renders matching mockup components with all 3 cards and responds to taps',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: AboutScreen()));
      await tester.pumpAndSettle();

      // Header
      expect(find.text('About'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);

      // Section 1: ezBookkeeping
      expect(find.text('ezBookkeeping'), findsOneWidget);
      expect(find.text('Version'), findsOneWidget);
      expect(find.text('v2.0.0-dev (d96ba0c)'), findsOneWidget);
      expect(find.text('Build Time'), findsOneWidget);
      expect(find.text('September 10, 2026 08:43:37 PM'), findsOneWidget);
      expect(find.text('Official Website'), findsOneWidget);
      expect(find.text('Report Issue'), findsOneWidget);
      expect(find.text('Getting help'), findsOneWidget);
      expect(find.text('License'), findsOneWidget);

      // Section 2: Exchange Rates Data
      expect(find.text('Exchange Rates Data'), findsOneWidget);
      expect(find.text('European Central Bank'), findsOneWidget);

      // Section 3: Map
      expect(find.text('Map'), findsOneWidget);
      expect(find.text('OpenStreetMap'), findsOneWidget);

      // Tap License item
      await tester.tap(find.text('License'));
      await tester.pumpAndSettle();
      expect(find.text('MIT License'), findsOneWidget);

      // Tap Map Provider item
      await tester.tap(find.text('OpenStreetMap'));
      await tester.pumpAndSettle();
      expect(find.text('Map Provider: OpenStreetMap'), findsOneWidget);
    },
  );

  testWidgets(
    'SettingsScreen navigates to AboutScreen when About tile is tapped',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(MaterialApp.router(routerConfig: appRouter));
      appRouter.go(AppRoutes.settings);
      await tester.pumpAndSettle();

      // Scroll to About tile
      await tester.scrollUntilVisible(find.text('About'), 100);
      expect(find.text('About'), findsOneWidget);

      // Tap About
      await tester.tap(find.text('About'));
      await tester.pumpAndSettle();

      expect(find.byType(AboutScreen), findsOneWidget);
      expect(find.text('v2.0.0-dev (d96ba0c)'), findsOneWidget);
      expect(find.text('European Central Bank'), findsOneWidget);
    },
  );
}
