import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/features/settings/presentation/statistics_settings_screen.dart';

void main() {
  Widget createTestWidget({PreferencesController? controller}) {
    return MaterialApp(
      home: StatisticsSettingsScreen(controller: controller),
    );
  }

  group('StatisticsSettingsScreen Widget Tests', () {
    late PreferencesController controller;

    setUp(() {
      controller = PreferencesController();
      if (getIt.isRegistered<PreferencesController>()) {
        getIt.unregister<PreferencesController>();
      }
      getIt.registerSingleton<PreferencesController>(controller);
    });

    tearDown(() {
      if (getIt.isRegistered<PreferencesController>()) {
        getIt.unregister<PreferencesController>();
      }
    });

    testWidgets('renders top bar and all section headers and settings items', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(controller: controller));
      await tester.pumpAndSettle();

      // Top bar
      expect(find.text('Statistics Settings'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);

      // Section 1: Common Settings
      expect(find.text('Common Settings'), findsOneWidget);
      expect(find.text('Default Chart Data Type'), findsOneWidget);
      expect(find.text('Expense By Primary Category'), findsOneWidget);
      expect(find.text('Timezone Used for Date Range'), findsOneWidget);
      expect(find.text('Default Keyword Search Matching Mode'), findsOneWidget);
      expect(find.text('Database Default'), findsOneWidget);
      expect(find.text('Default Account Filter'), findsOneWidget);
      expect(find.text('Default Transaction Category Filter'), findsOneWidget);
      expect(find.text('Default Sort Order'), findsOneWidget);
      expect(find.text('Amount'), findsOneWidget);

      // Section 2: Categorical Analysis Settings
      expect(find.text('Categorical Analysis Settings'), findsOneWidget);
      expect(find.text('Default Chart Type'), findsOneWidget);
      expect(find.text('Pie Chart'), findsOneWidget);
      expect(find.text('Default Date Range'), findsWidgets);
      expect(find.text('This month'), findsOneWidget);

      // Scroll down to see Section 3 & 4
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Section 3: Trend Analysis Settings
      expect(find.text('Trend Analysis Settings'), findsOneWidget);

      // Section 4: Asset Trends Settings
      expect(find.text('Asset Trends Settings'), findsOneWidget);
      expect(find.text('This year'), findsWidgets);
    });

    testWidgets('changing Default Chart Data Type updates value and controller', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(controller: controller));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Default Chart Data Type'));
      await tester.pumpAndSettle();

      expect(find.text('Income By Primary Category'), findsOneWidget);
      await tester.tap(find.text('Income By Primary Category'));
      await tester.pumpAndSettle();

      expect(find.text('Income By Primary Category'), findsOneWidget);
      expect(controller.statsDefaultChartDataType, 'Income By Primary Category');
    });

    testWidgets('changing Default Keyword Search Matching Mode updates value and controller', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(controller: controller));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Default Keyword Search Matching Mode'));
      await tester.pumpAndSettle();

      expect(find.text('Exact Match'), findsOneWidget);
      await tester.tap(find.text('Exact Match'));
      await tester.pumpAndSettle();

      expect(find.text('Exact Match'), findsOneWidget);
      expect(controller.statsKeywordSearchMatchingMode, 'Exact Match');
    });

    testWidgets('changing Default Sort Order updates value and controller', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(controller: controller));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Default Sort Order'),
        50.0,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Default Sort Order'));
      await tester.pumpAndSettle();

      expect(find.text('Display Order'), findsOneWidget);
      await tester.tap(find.text('Display Order'));
      await tester.pumpAndSettle();

      expect(find.text('Display Order'), findsOneWidget);
      expect(controller.statsSortOrder, 'Display Order');
    });

    testWidgets('changing Default Chart Type updates value and controller', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(controller: controller));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Default Chart Type'),
        50.0,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Default Chart Type'));
      await tester.pumpAndSettle();

      expect(find.text('Bar Chart'), findsOneWidget);
      await tester.tap(find.text('Bar Chart'));
      await tester.pumpAndSettle();

      expect(find.text('Bar Chart'), findsOneWidget);
      expect(controller.statsCategoricalChartType, 'Bar Chart');
    });

    testWidgets('changing Categorical Default Date Range updates value and controller', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createTestWidget(controller: controller));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Categorical Analysis Settings'),
        50.0,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      // Tap the categorical date range (first Default Date Range)
      await tester.tap(find.widgetWithText(Material, 'Default Date Range').first);
      await tester.pumpAndSettle();

      expect(find.text('This week'), findsOneWidget);
      await tester.tap(find.text('This week'));
      await tester.pumpAndSettle();

      expect(controller.statsCategoricalDateRange, 'This week');
    });

    testWidgets('back button triggers pop', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          StatisticsSettingsScreen(controller: controller),
                    ),
                  );
                },
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Statistics Settings'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Statistics Settings'), findsNothing);
      expect(find.text('Open'), findsOneWidget);
    });
  });
}
