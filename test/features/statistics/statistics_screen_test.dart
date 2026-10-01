import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ezbookkeeping/features/statistics/presentation/statistics_screen.dart';
import 'package:ezbookkeeping/features/statistics/presentation/widgets/period_popup_menu.dart';
import 'package:ezbookkeeping/features/statistics/presentation/widgets/chart_scope_sheet.dart';
import 'package:ezbookkeeping/features/statistics/presentation/widgets/sort_action_sheet.dart';

import 'package:ezbookkeeping/features/categories/utils/category_icon_helper.dart';
import 'package:ezbookkeeping/features/statistics/domain/entities/statistic_category_item.dart';
import 'package:ezbookkeeping/features/statistics/domain/entities/statistic_data.dart';
import 'package:ezbookkeeping/features/statistics/domain/repositories/statistics_repository.dart';
import 'package:ezbookkeeping/features/statistics/domain/usecases/get_statistics_use_case.dart';
import 'package:ezbookkeeping/features/statistics/data/models/statistics_request.dart';
import 'package:ezbookkeeping/features/statistics/presentation/bloc/statistics_bloc.dart';
import 'package:ezbookkeeping/core/error/failures.dart';
import 'package:dartz/dartz.dart';

class _FakeStatsRepo implements StatisticsRepository {
  final List<StatisticCategoryItem> items;
  _FakeStatsRepo(this.items);

  @override
  Future<Either<Failure, StatisticData>> getStatistics(
    StatisticsRequest request,
  ) async {
    final total = items.fold<double>(0, (sum, c) => sum + c.amount);
    return Right(StatisticData(totalAmount: total, categories: items));
  }
}

void main() {
  group('StatisticsScreen Widget Tests', () {
    late StatisticsBloc testBloc;

    setUp(() {
      final sampleCategories = [
        StatisticCategoryItem(
          id: 'cat_housing',
          name: 'Housing & Houseware',
          icon: CategoryIconHelper.getIcon('200', categoryName: 'Housing'),
          color: const Color(0xFFC14660),
          amount: 2415.00,
          percentage: 43.51,
        ),
        StatisticCategoryItem(
          id: 'cat_transportation',
          name: 'Transportation',
          icon: CategoryIconHelper.getIcon(
            '300',
            categoryName: 'Transportation',
          ),
          color: const Color(0xFFE35444),
          amount: 1096.83,
          percentage: 19.76,
        ),
        StatisticCategoryItem(
          id: 'cat_food',
          name: 'Food & Drink',
          icon: CategoryIconHelper.getIcon('1', categoryName: 'Food & Drink'),
          color: const Color(0xFFF38426),
          amount: 852.88,
          percentage: 15.36,
        ),
        StatisticCategoryItem(
          id: 'cat_entertainment',
          name: 'Entertainment',
          icon: CategoryIconHelper.getIcon(
            '400',
            categoryName: 'Entertainment',
          ),
          color: const Color(0xFFF8BA3E),
          amount: 465.98,
          percentage: 8.39,
        ),
        StatisticCategoryItem(
          id: 'cat_clothing',
          name: 'Clothing & Appearance',
          icon: CategoryIconHelper.getIcon('100', categoryName: 'Clothing'),
          color: const Color(0xFF3AC79F),
          amount: 205.00,
          percentage: 3.69,
        ),
        StatisticCategoryItem(
          id: 'cat_communication',
          name: 'Communication',
          icon: CategoryIconHelper.getIcon(
            '500',
            categoryName: 'Communication',
          ),
          color: const Color(0xFF27C5C4),
          amount: 188.75,
          percentage: 3.40,
        ),
        StatisticCategoryItem(
          id: 'cat_finance',
          name: 'Finance & Insurance',
          icon: CategoryIconHelper.getIcon('600', categoryName: 'Finance'),
          color: const Color(0xFF34AEE2),
          amount: 120.00,
          percentage: 2.16,
        ),
        StatisticCategoryItem(
          id: 'cat_medical',
          name: 'Medical & Healthcare',
          icon: CategoryIconHelper.getIcon('700', categoryName: 'Medical'),
          color: const Color(0xFF1E5888),
          amount: 110.00,
          percentage: 1.90,
        ),
      ];

      final repo = _FakeStatsRepo(sampleCategories);
      testBloc = StatisticsBloc(getStatistics: GetStatisticsUseCase(repo));
    });

    tearDown(() {
      testBloc.close();
    });

    Widget buildTestScreen({StatisticsBloc? bloc}) {
      return MaterialApp(home: StatisticsScreen(bloc: bloc ?? testBloc));
    }

    Future<void> pumpAndFlush(WidgetTester tester) async {
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 30));
      });
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
    }

    testWidgets(
      'renders Pie Chart mode with Donut chart and default category details',
      (tester) async {
        await tester.pumpWidget(buildTestScreen());
        await pumpAndFlush(tester);

        // Top app bar elements
        expect(find.text('Expense By Primary Category'), findsOneWidget);
        expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
        expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);

        // Custom Paint Donut Chart
        expect(find.byType(CustomPaint), findsWidgets);

        // Default selected category details
        expect(find.text('43.51%'), findsOneWidget);
        expect(find.text('Housing & Houseware'), findsOneWidget);
        expect(find.text(r'$ 2,415.00'), findsOneWidget);

        // Bottom toolbar
        expect(find.text('This month'), findsOneWidget);
        expect(find.text('Pie Chart'), findsOneWidget);
        expect(find.text('Bar Chart'), findsOneWidget);

        await tester.pumpWidget(const SizedBox());
      },
    );

    testWidgets('navigates through categories in carousel on arrow tap', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestScreen());
      await pumpAndFlush(tester);

      expect(find.text('Housing & Houseware'), findsOneWidget);
      expect(find.text('43.51%'), findsOneWidget);

      // Tap next arrow
      final nextButton = find.byIcon(Icons.arrow_forward_rounded);
      expect(nextButton, findsOneWidget);
      await tester.tap(nextButton);
      await tester.pump();

      // Now should show Transportation
      expect(find.text('Transportation'), findsOneWidget);
      expect(find.text('19.76%'), findsOneWidget);

      // Tap previous arrow
      final prevButton = find.byIcon(Icons.arrow_back_rounded);
      await tester.tap(prevButton);
      await tester.pump();

      // Back to Housing & Houseware
      expect(find.text('Housing & Houseware'), findsOneWidget);
      expect(find.text('43.51%'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('switches between Pie Chart and Bar Chart view modes', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestScreen());
      await pumpAndFlush(tester);

      // Switch to Bar Chart
      await tester.tap(find.text('Bar Chart'));
      await tester.pump();

      // Verify category list in Bar Chart view
      expect(find.text('Housing & Houseware'), findsOneWidget);
      expect(find.text('Transportation'), findsOneWidget);
      expect(find.text('Food & Drink'), findsOneWidget);
      expect(find.text('Entertainment'), findsOneWidget);
      expect(find.text('Clothing & Appearance'), findsOneWidget);
      expect(find.text('Communication'), findsOneWidget);
      expect(find.text('Finance & Insurance'), findsOneWidget);
      expect(find.text('Medical & Healthcare'), findsOneWidget);

      // Switch back to Pie Chart
      await tester.tap(find.text('Pie Chart'));
      await tester.pump();

      expect(find.text('43.51%'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('opens SortActionSheet and updates sort ordering', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestScreen());
      await pumpAndFlush(tester);

      // Tap Sort by Amount
      await tester.tap(find.textContaining('Sort by'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(SortActionSheet), findsOneWidget);
      expect(find.text('Display Order'), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);

      // Select Name
      await tester.tap(find.text('Name'));
      await tester.pump(const Duration(milliseconds: 300));
      await pumpAndFlush(tester);

      expect(find.textContaining('Sort by Name'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('opens ChartScopeSheet and updates chart title', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestScreen());
      await pumpAndFlush(tester);

      // Tap dropdown title
      await tester.tap(find.text('Expense By Primary Category'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(ChartScopeSheet), findsOneWidget);
      expect(find.text('Income By Primary Category'), findsOneWidget);

      // Select Income By Primary Category
      await tester.tap(find.text('Income By Primary Category'));
      await tester.pump(const Duration(milliseconds: 300));
      await pumpAndFlush(tester);

      expect(find.text('Income By Primary Category'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('opens PeriodPopupMenu and steps periods using arrow buttons', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestScreen());
      await pumpAndFlush(tester);

      // Tap right step arrow button
      final rightStep = find.byIcon(Icons.arrow_forward);
      await tester.tap(rightStep);
      await pumpAndFlush(tester);

      expect(find.text('Last month'), findsOneWidget);

      // Tap left step arrow button
      final leftStep = find.byIcon(Icons.arrow_back);
      await tester.tap(leftStep);
      await pumpAndFlush(tester);

      expect(find.text('This month'), findsOneWidget);

      // Tap period text to open popup menu
      await tester.tap(find.text('This month'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(PeriodPopupMenu), findsOneWidget);
      expect(find.text('Recent 30 days'), findsOneWidget);
      expect(find.text('This week'), findsOneWidget);

      // Select This week
      await tester.tap(find.text('This week'));
      await tester.pump(const Duration(milliseconds: 300));
      await pumpAndFlush(tester);

      expect(find.text('This week'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('renders empty state placeholder when no transactions exist', (
      tester,
    ) async {
      testBloc.close();
      final emptyRepo = _FakeStatsRepo(const []);
      testBloc = StatisticsBloc(getStatistics: GetStatisticsUseCase(emptyRepo));

      await tester.pumpWidget(buildTestScreen());
      await pumpAndFlush(tester);

      // Pie chart view shows empty state text
      expect(find.text('No transaction data for this period'), findsOneWidget);

      // Switch to Bar Chart view
      await tester.tap(find.text('Bar Chart'));
      await tester.pump();

      expect(find.text('No transaction data for this period'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });
  });
}
