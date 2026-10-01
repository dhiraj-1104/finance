import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/features/settings/presentation/preferences_screen.dart';
import 'package:ezbookkeeping/features/settings/widgets/statistics_timezone_picker_sheet.dart';

void main() {
  group('StatisticsTimezonePickerSheet Widget Tests', () {
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

    testWidgets(
      'renders header with close button, title, search button, and primary options',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatisticsTimezonePickerSheet(
                currentTimezone:
                    PreferencesController.formattedApplicationTimezone,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify title
        expect(find.text('Timezone Used for Statistics'), findsOneWidget);

        // Verify circular action icons
        expect(find.byIcon(Icons.close_rounded), findsOneWidget);
        expect(find.byIcon(Icons.search_rounded), findsOneWidget);

        // Verify primary options
        expect(
          find.text(PreferencesController.formattedApplicationTimezone),
          findsOneWidget,
        );
        expect(find.text('Transaction Timezone'), findsOneWidget);

        // Verify left checkmark on selected item
        expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      },
    );

    testWidgets('toggles search and filters timezone list', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatisticsTimezonePickerSheet(
              currentTimezone:
                  PreferencesController.formattedApplicationTimezone,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap search icon
      await tester.tap(find.byIcon(Icons.search_rounded));
      await tester.pumpAndSettle();

      // Search field is visible
      expect(find.byType(TextField), findsOneWidget);

      // Enter search query
      await tester.enterText(find.byType(TextField), 'Kolkata');
      await tester.pumpAndSettle();

      expect(
        find.text('(UTC+05:30) Chennai, Kolkata, Mumbai, New Delhi'),
        findsOneWidget,
      );
    });

    testWidgets('selects option and triggers callback', (
      WidgetTester tester,
    ) async {
      String? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  selected = await StatisticsTimezonePickerSheet.show(
                    context,
                    currentTimezone:
                        PreferencesController.formattedApplicationTimezone,
                  );
                },
                child: const Text('Open Sheet'),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open sheet
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Select 'Transaction Timezone'
      await tester.tap(find.text('Transaction Timezone'));
      await tester.pumpAndSettle();

      expect(selected, 'Transaction Timezone');
    });

    testWidgets(
      'PreferencesScreen opens StatisticsTimezonePickerSheet and updates preference',
      (WidgetTester tester) async {
        final controller = getIt<PreferencesController>();

        await tester.pumpWidget(
          const MaterialApp(
            home: PreferencesScreen(),
          ),
        );
        await tester.pumpAndSettle();

        // Scroll to 'Timezone Used for Statistics'
        await tester.scrollUntilVisible(
          find.text('Timezone Used for Statistics'),
          50,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();

        // Tap on 'Timezone Used for Statistics'
        await tester.tap(find.text('Timezone Used for Statistics'));
        await tester.pumpAndSettle();

        // Sheet is shown
        expect(find.byType(StatisticsTimezonePickerSheet), findsOneWidget);
        expect(find.text('Transaction Timezone'), findsOneWidget);

        // Tap 'Transaction Timezone'
        await tester.tap(find.text('Transaction Timezone'));
        await tester.pumpAndSettle();

        // Sheet is dismissed and controller is updated
        expect(find.byType(StatisticsTimezonePickerSheet), findsNothing);
        expect(controller.timezoneForStatistics, 'Transaction Timezone');
        expect(controller.useTransactionTimezone, isTrue);
      },
    );
  });
}
