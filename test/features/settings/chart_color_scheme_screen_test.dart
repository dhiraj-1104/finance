import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/features/settings/presentation/chart_color_scheme_screen.dart';

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
      home: ChartColorSchemeScreen(controller: controller),
    );
  }

  group('ChartColorSchemeScreen Widget Tests', () {
    testWidgets('renders header, title, and all 10 default chart colors with delete & drag handles',
        (tester) async {
      await tester.pumpWidget(createTestWidget(controller: preferencesController));
      await tester.pumpAndSettle();

      expect(find.text('Chart Color Scheme'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      // Verify all 10 default colors
      for (final color in PreferencesController.defaultChartColors) {
        expect(find.text(color), findsOneWidget);
      }

      // Verify 10 delete buttons and 10 drag listeners
      expect(find.byIcon(Icons.remove_rounded), findsNWidgets(10));
      expect(find.byType(ReorderableDragStartListener), findsNWidgets(10));
    });

    testWidgets('deleting a color removes it from the list', (tester) async {
      await tester.pumpWidget(createTestWidget(controller: preferencesController));
      await tester.pumpAndSettle();

      expect(find.text('#cc4a66'), findsOneWidget);

      // Tap delete on the first color (#cc4a66)
      await tester.tap(find.byIcon(Icons.remove_rounded).first);
      await tester.pumpAndSettle();

      expect(find.text('#cc4a66'), findsNothing);
      expect(find.byIcon(Icons.remove_rounded), findsNWidgets(9));
    });

    testWidgets('more actions sheet shows Add, Import, Export, Reset to Default, and Cancel',
        (tester) async {
      await tester.pumpWidget(createTestWidget(controller: preferencesController));
      await tester.pumpAndSettle();

      // Tap more actions (...)
      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Add'), findsOneWidget);
      expect(find.text('Import'), findsOneWidget);
      expect(find.text('Export'), findsOneWidget);
      expect(find.text('Reset to Default'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Tap Cancel to dismiss
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Add'), findsNothing);
    });

    testWidgets('Reset to Default restores all 10 default colors',
        (tester) async {
      final customController =
          PreferencesController(chartColors: ['#112233', '#445566']);

      await tester.pumpWidget(createTestWidget(controller: customController));
      await tester.pumpAndSettle();

      expect(find.text('#112233'), findsOneWidget);
      expect(find.text('#cc4a66'), findsNothing);

      // Open more actions
      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();

      // Tap Reset to Default
      await tester.tap(find.text('Reset to Default'));
      await tester.pumpAndSettle();

      for (final color in PreferencesController.defaultChartColors) {
        expect(find.text(color), findsOneWidget);
      }
    });

    testWidgets('Import sheet parses and updates color list', (tester) async {
      await tester.pumpWidget(createTestWidget(controller: preferencesController));
      await tester.pumpAndSettle();

      // Open more actions
      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();

      // Tap Import
      await tester.tap(find.text('Import'));
      await tester.pumpAndSettle();

      expect(find.text('Import'), findsWidgets);

      // Enter imported hex colors
      await tester.enterText(
        find.byType(TextField),
        '#aabbcc\n#ddeeff\n112233',
      );
      await tester.pumpAndSettle();

      // Tap Import button in modal
      await tester.tap(find.widgetWithText(ElevatedButton, 'Import'));
      await tester.pumpAndSettle();

      expect(find.text('#aabbcc'), findsOneWidget);
      expect(find.text('#ddeeff'), findsOneWidget);
      expect(find.text('#112233'), findsOneWidget);
    });

    testWidgets('Export sheet displays colors list and has copy button',
        (tester) async {
      final customController =
          PreferencesController(chartColors: ['#c67e48']);

      await tester.pumpWidget(createTestWidget(controller: customController));
      await tester.pumpAndSettle();

      // Open more actions
      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();

      // Tap Export
      await tester.tap(find.text('Export'));
      await tester.pumpAndSettle();

      expect(find.text('Export'), findsOneWidget);
      expect(find.text('#c67e48'), findsWidgets);
      expect(find.byIcon(Icons.copy_rounded), findsOneWidget);

      // Tap copy icon
      await tester.tap(find.byIcon(Icons.copy_rounded));
      await tester.pumpAndSettle();

      // Tap Close button
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.text('Export'), findsNothing);
    });

    testWidgets('Save button (✓) commits changes to PreferencesController',
        (tester) async {
      await tester.pumpWidget(createTestWidget(controller: preferencesController));
      await tester.pumpAndSettle();

      // Delete first color
      await tester.tap(find.byIcon(Icons.remove_rounded).first);
      await tester.pumpAndSettle();

      // Tap checkmark (✓)
      await tester.tap(find.byIcon(Icons.check_rounded));
      await tester.pumpAndSettle();

      expect(preferencesController.chartColors.length, 9);
      expect(preferencesController.chartColorScheme, 'Custom');
    });
  });
}
