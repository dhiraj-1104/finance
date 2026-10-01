import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:ezbookkeeping/features/categories/data/models/add_category_request_model.dart';
import 'package:ezbookkeeping/features/categories/domain/repositories/categories_repository.dart';
import 'package:ezbookkeeping/features/categories/models/category_item.dart';
import 'package:ezbookkeeping/features/categories/utils/category_icon_helper.dart';
import 'package:ezbookkeeping/features/categories/widgets/category_picker_sheet.dart';

List<CategoryItem> _createSampleExpenseCategories() {
  return [
    const CategoryItem(
      id: 'cat_food_drink',
      name: 'Food & Drink',
      categoryIconId: '1',
      icon: Icons.restaurant_outlined,
      color: Color(0xFFFF6B22),
      type: CategoryType.expense,
      subCategories: [
        CategoryItem(
          id: 'cat_food',
          name: 'Food',
          categoryIconId: '2',
          icon: Icons.dinner_dining_outlined,
          color: Color(0xFFFF6B22),
          type: CategoryType.expense,
          isPrimary: false,
          parentId: 'cat_food_drink',
        ),
        CategoryItem(
          id: 'cat_drink',
          name: 'Drink',
          categoryIconId: '30',
          icon: Icons.local_cafe_outlined,
          color: Color(0xFFFF6B22),
          type: CategoryType.expense,
          isPrimary: false,
          parentId: 'cat_food_drink',
        ),
        CategoryItem(
          id: 'cat_snack',
          name: 'Fruit & Snack',
          categoryIconId: '70',
          icon: Icons.icecream_outlined,
          color: Color(0xFFFF6B22),
          type: CategoryType.expense,
          isPrimary: false,
          parentId: 'cat_food_drink',
        ),
      ],
    ),
    const CategoryItem(
      id: 'cat_clothing',
      name: 'Clothing & Appearance',
      categoryIconId: '100',
      icon: Icons.person_outline_rounded,
      color: Color(0xFF5AC8FA),
      type: CategoryType.expense,
      subCategories: [
        CategoryItem(
          id: 'cat_clothing_sub',
          name: 'Clothing',
          categoryIconId: '110',
          icon: Icons.checkroom_outlined,
          color: Color(0xFF5AC8FA),
          type: CategoryType.expense,
          isPrimary: false,
          parentId: 'cat_clothing',
        ),
        CategoryItem(
          id: 'cat_jewelry',
          name: 'Jewelry',
          categoryIconId: '170',
          icon: Icons.diamond_outlined,
          color: Color(0xFF5AC8FA),
          type: CategoryType.expense,
          isPrimary: false,
          parentId: 'cat_clothing',
        ),
      ],
    ),
    const CategoryItem(
      id: 'cat_transportation',
      name: 'Transportation',
      categoryIconId: '300',
      icon: Icons.alt_route_outlined,
      color: Color(0xFF34C759),
      type: CategoryType.expense,
      subCategories: [
        CategoryItem(
          id: 'cat_transit',
          name: 'Public Transit',
          categoryIconId: '310',
          icon: Icons.directions_bus_outlined,
          color: Color(0xFF34C759),
          type: CategoryType.expense,
          isPrimary: false,
          parentId: 'cat_transportation',
        ),
        CategoryItem(
          id: 'cat_taxi',
          name: 'Taxi & Car Rental',
          categoryIconId: '320',
          icon: Icons.local_taxi_outlined,
          color: Color(0xFF34C759),
          type: CategoryType.expense,
          isPrimary: false,
          parentId: 'cat_transportation',
        ),
      ],
    ),
  ];
}

List<CategoryItem> _createSampleIncomeCategories() {
  return [
    const CategoryItem(
      id: 'cat_earnings',
      name: 'Occupational Earnings',
      categoryIconId: '2000',
      icon: Icons.work_outline_rounded,
      color: Color(0xFFFF6B22),
      type: CategoryType.income,
      subCategories: [
        CategoryItem(
          id: 'cat_salary',
          name: 'Salary Income',
          categoryIconId: '2010',
          icon: Icons.attach_money_rounded,
          color: Color(0xFFFF6B22),
          type: CategoryType.income,
          isPrimary: false,
          parentId: 'cat_earnings',
        ),
        CategoryItem(
          id: 'cat_bonus',
          name: 'Bonus Income',
          categoryIconId: '2020',
          icon: Icons.card_giftcard_outlined,
          color: Color(0xFFFF6B22),
          type: CategoryType.income,
          isPrimary: false,
          parentId: 'cat_earnings',
        ),
      ],
    ),
  ];
}

void main() {
  group('CategoryIconHelper & CategoryItem Model Tests', () {
    test('CategoryIconHelper parses hex color correctly', () {
      expect(CategoryIconHelper.parseColor('ff6b22'), const Color(0xFFFF6B22));
      expect(CategoryIconHelper.parseColor('#673ab7'), const Color(0xFF673AB7));
      expect(CategoryIconHelper.parseColor('009688'), const Color(0xFF009688));
      expect(CategoryIconHelper.parseColor(null), const Color(0xFF8E8E93));
    });

    test('CategoryIconHelper maps known icon IDs and names to icons', () {
      expect(CategoryIconHelper.getIcon('1'), Icons.restaurant_outlined);
      expect(CategoryIconHelper.getIcon('2'), Icons.dinner_dining_outlined);
      expect(CategoryIconHelper.getIcon('30'), Icons.local_cafe_outlined);
      expect(CategoryIconHelper.getIcon('70'), Icons.icecream_outlined);
      expect(CategoryIconHelper.getIcon('100'), Icons.person_outline_rounded);
      expect(CategoryIconHelper.getIcon('200'), Icons.home_outlined);
      expect(CategoryIconHelper.getIcon('300'), Icons.alt_route_outlined);
      expect(CategoryIconHelper.getIcon('4000'), Icons.swap_horiz_rounded);
      expect(
        CategoryIconHelper.getIcon('unknown_id', categoryName: 'Food & Coffee'),
        Icons.restaurant_outlined,
      );
    });

    test('CategoryItem fromJson deserializes properly', () {
      final json = {
        'id': '3845184654713815072',
        'name': 'Food & Dining',
        'categoryIconId': '1',
        'color': 'ff6b22',
        'subCategories': [
          {
            'id': '3845184654713815073',
            'name': 'Groceries',
            'categoryIconId': '2',
            'color': 'ff6b22',
          },
        ],
      };

      final cat = CategoryItem.fromJson(json, type: CategoryType.expense);
      expect(cat.id, '3845184654713815072');
      expect(cat.name, 'Food & Dining');
      expect(cat.categoryIconId, '1');
      expect(cat.color, const Color(0xFFFF6B22));
      expect(cat.subCategories.length, 1);
      expect(cat.subCategories.first.id, '3845184654713815073');
      expect(cat.subCategories.first.name, 'Groceries');
      expect(cat.subCategories.first.parentId, '3845184654713815072');
    });

    test('CategorySelection formats full display name correctly', () {
      final primary = const CategoryItem(
        id: '1',
        name: 'Food & Drink',
        icon: Icons.restaurant_outlined,
        color: Colors.orange,
      );
      final sub = const CategoryItem(
        id: '2',
        name: 'Food',
        icon: Icons.dinner_dining_outlined,
        color: Colors.orange,
        isPrimary: false,
      );

      final selectionWithSub = CategorySelection(
        primary: primary,
        subCategory: sub,
      );
      expect(selectionWithSub.displayName, 'Food');
      expect(selectionWithSub.parentName, 'Food & Drink');
      expect(selectionWithSub.fullDisplayName, 'Food & Drink > Food');

      final selectionPrimaryOnly = CategorySelection(primary: primary);
      expect(selectionPrimaryOnly.displayName, 'Food & Drink');
      expect(selectionPrimaryOnly.fullDisplayName, 'Food & Drink');
    });
  });

  group('CategoryPickerSheet Widget Tests', () {
    testWidgets(
      'renders top drag handle, circular close button, and search input',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final categories = _createSampleExpenseCategories();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      CategoryPickerSheet.show(
                        context,
                        categories: categories,
                        initialPrimaryCategory: 'Food & Drink',
                        initialSubCategory: 'Food',
                        onCategorySelected: (_) {},
                      );
                    },
                    child: const Text('Open Picker'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open Picker'));
        await tester.pumpAndSettle();

        // Verify Header elements
        expect(find.byIcon(Icons.close_rounded), findsOneWidget);
        expect(find.text('Find category'), findsOneWidget);
        expect(find.byIcon(Icons.search_rounded), findsOneWidget);

        // Verify Primary Categories
        expect(find.text('Food & Drink'), findsOneWidget);
        expect(find.text('Clothing & Appearance'), findsOneWidget);
        expect(find.text('Transportation'), findsOneWidget);

        // Verify subcategories under expanded 'Food & Drink'
        expect(find.text('Food'), findsOneWidget);
        expect(find.text('Drink'), findsOneWidget);
        expect(find.text('Fruit & Snack'), findsOneWidget);
      },
    );

    testWidgets('toggles primary category expansion on tap', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final categories = _createSampleExpenseCategories();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    CategoryPickerSheet.show(
                      context,
                      categories: categories,
                      initialPrimaryCategory: 'Transportation',
                      onCategorySelected: (_) {},
                    );
                  },
                  child: const Text('Open Picker'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Picker'));
      await tester.pumpAndSettle();

      // Transportation subcategories should be visible
      expect(find.text('Public Transit'), findsOneWidget);
      expect(find.text('Taxi & Car Rental'), findsOneWidget);

      // Tap 'Clothing & Appearance' to expand it
      await tester.tap(find.text('Clothing & Appearance'));
      await tester.pumpAndSettle();

      expect(find.text('Clothing'), findsOneWidget);
      expect(find.text('Jewelry'), findsOneWidget);
    });

    testWidgets('selects subcategory and dismisses sheet', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final categories = _createSampleExpenseCategories();
      CategorySelection? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    CategoryPickerSheet.show(
                      context,
                      categories: categories,
                      initialPrimaryCategory: 'Food & Drink',
                      onCategorySelected: (sel) => selected = sel,
                    );
                  },
                  child: const Text('Open Picker'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Picker'));
      await tester.pumpAndSettle();

      // Tap 'Drink' subcategory
      await tester.tap(find.text('Drink'));
      await tester.pumpAndSettle();

      // Sheet should be dismissed
      expect(find.byType(CategoryPickerSheet), findsNothing);
      expect(selected, isNotNull);
      expect(selected!.parentName, 'Food & Drink');
      expect(selected!.childName, 'Drink');
    });

    testWidgets('filters categories dynamically using search input', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final categories = _createSampleExpenseCategories();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    CategoryPickerSheet.show(
                      context,
                      categories: categories,
                      onCategorySelected: (_) {},
                    );
                  },
                  child: const Text('Open Picker'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Picker'));
      await tester.pumpAndSettle();

      // Enter search text 'Taxi'
      await tester.enterText(find.byType(TextField), 'Taxi');
      await tester.pumpAndSettle();

      // Should show Transportation > Taxi & Car Rental
      expect(find.text('Transportation'), findsOneWidget);
      expect(find.text('Taxi & Car Rental'), findsOneWidget);
      expect(find.text('Food & Drink'), findsNothing);

      // Clear search with clear icon
      await tester.tap(find.byIcon(Icons.cancel_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Food & Drink'), findsOneWidget);
    });

    testWidgets('supports Income Category types', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final incomeCategories = _createSampleIncomeCategories();
      CategorySelection? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    CategoryPickerSheet.show(
                      context,
                      categories: incomeCategories,
                      categoryType: CategoryType.income,
                      onCategorySelected: (sel) => selected = sel,
                    );
                  },
                  child: const Text('Open Income Picker'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Income Picker'));
      await tester.pumpAndSettle();

      expect(find.text('Occupational Earnings'), findsOneWidget);
      expect(find.text('Salary Income'), findsOneWidget);
      expect(find.text('Bonus Income'), findsOneWidget);

      await tester.tap(find.text('Salary Income'));
      await tester.pumpAndSettle();

      expect(selected, isNotNull);
      expect(selected!.parentName, 'Occupational Earnings');
      expect(selected!.childName, 'Salary Income');
    });

    testWidgets(
      'renders categories loaded dynamically from CategoriesRepository',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final mockRepo = _MockCustomCategoriesRepository([
          const CategoryItem(
            id: 'custom_1',
            name: 'Custom Cloud Category',
            icon: Icons.cloud,
            color: Colors.blue,
            type: CategoryType.expense,
            subCategories: [
              CategoryItem(
                id: 'custom_sub_1',
                name: 'Cloud Sub Item',
                icon: Icons.cloud_queue,
                color: Colors.blue,
                type: CategoryType.expense,
                isPrimary: false,
              ),
            ],
          ),
        ]);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      CategoryPickerSheet.show(
                        context,
                        categoriesRepository: mockRepo,
                        onCategorySelected: (_) {},
                      );
                    },
                    child: const Text('Open Repo Picker'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Open Repo Picker'));
        await tester.pumpAndSettle();

        expect(find.text('Custom Cloud Category'), findsOneWidget);
        expect(find.text('Cloud Sub Item'), findsOneWidget);
      },
    );
  });
}

class _MockCustomCategoriesRepository implements CategoriesRepository {
  _MockCustomCategoriesRepository(this._categories);

  final List<CategoryItem> _categories;

  @override
  bool get isCacheValid => true;

  @override
  void clearCache() {}

  @override
  Future<Either<Failure, CategoryItem>> addCategory(
    AddCategoryRequestModel request,
  ) async {
    final newCat = CategoryItem(
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
    _categories.add(newCat);
    return Right(newCat);
  }

  @override
  Future<List<CategoryItem>> getCategories({bool forceRefresh = false}) async {
    return _categories;
  }

  @override
  Future<Map<String, CategoryItem>> getCategoriesMap({
    bool forceRefresh = false,
  }) async {
    final map = <String, CategoryItem>{};
    for (final cat in _categories) {
      map[cat.id] = cat;
      for (final sub in cat.subCategories) {
        map[sub.id] = sub;
      }
    }
    return map;
  }

  @override
  Future<Map<String, String>> getCategoryNameMap({
    bool forceRefresh = false,
  }) async {
    final map = await getCategoriesMap(forceRefresh: forceRefresh);
    return map.map((key, value) => MapEntry(key, value.name));
  }
}
