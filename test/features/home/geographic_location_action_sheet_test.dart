import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ezbookkeeping/features/home/widgets/geographic_location_action_sheet.dart';
import 'package:ezbookkeeping/features/home/presentation/add_transaction_screen.dart';

void main() {
  group('GeographicLocationActionSheet Widget Tests', () {
    Widget buildTestWidget({
      String? currentLocation,
      ValueChanged<String>? onUpdateLocation,
      VoidCallback? onClearLocation,
      VoidCallback? onShowMap,
      Brightness brightness = Brightness.light,
    }) {
      return MaterialApp(
        theme: ThemeData(brightness: brightness, useMaterial3: true),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  GeographicLocationActionSheet.show(
                    context,
                    currentLocation: currentLocation,
                    onUpdateLocation: onUpdateLocation,
                    onClearLocation: onClearLocation,
                    onShowMap: onShowMap,
                  );
                },
                child: const Text('Open Location Action Sheet'),
              );
            },
          ),
        ),
      );
    }

    testWidgets('Renders 3 stacked blocks with all action options', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget(currentLocation: 'No Location'));
      await tester.tap(find.text('Open Location Action Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Update Geographic Location'), findsOneWidget);
      expect(find.text('Clear Geographic Location'), findsOneWidget);
      expect(find.text('Show on the map'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets(
      'Tapping Update Geographic Location triggers callback and pops sheet',
      (tester) async {
        String? updated;
        await tester.pumpWidget(
          buildTestWidget(onUpdateLocation: (loc) => updated = loc),
        );
        await tester.tap(find.text('Open Location Action Sheet'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Update Geographic Location'));
        await tester.pumpAndSettle();

        expect(updated, isNotNull);
        expect(updated, contains('Current Location'));
        // Sheet should be popped
        expect(find.text('Update Geographic Location'), findsNothing);
      },
    );

    testWidgets(
      'Tapping Clear Geographic Location triggers callback and pops sheet',
      (tester) async {
        bool cleared = false;
        await tester.pumpWidget(
          buildTestWidget(onClearLocation: () => cleared = true),
        );
        await tester.tap(find.text('Open Location Action Sheet'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Clear Geographic Location'));
        await tester.pumpAndSettle();

        expect(cleared, isTrue);
        // Sheet should be popped
        expect(find.text('Clear Geographic Location'), findsNothing);
      },
    );

    testWidgets('Tapping Show on the map triggers callback and pops sheet', (
      tester,
    ) async {
      bool mapShown = false;
      await tester.pumpWidget(
        buildTestWidget(
          currentLocation: 'San Francisco, CA',
          onShowMap: () => mapShown = true,
        ),
      );
      await tester.tap(find.text('Open Location Action Sheet'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Show on the map'));
      await tester.pumpAndSettle();

      expect(mapShown, isTrue);
      expect(find.text('Show on the map'), findsNothing);
    });

    testWidgets('Tapping Cancel dismisses the action sheet', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.tap(find.text('Open Location Action Sheet'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Update Geographic Location'), findsNothing);
    });

    testWidgets('Renders properly in Dark Theme', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          brightness: Brightness.dark,
          currentLocation: 'New York, NY',
        ),
      );
      await tester.tap(find.text('Open Location Action Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Update Geographic Location'), findsOneWidget);
      expect(find.text('Clear Geographic Location'), findsOneWidget);
      expect(find.text('Show on the map'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets(
      'AddTransactionScreen opens GeographicLocationActionSheet on location tile tap',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: AddTransactionScreen()),
        );
        await tester.pumpAndSettle();

        // Scroll down to Geographic Location tile
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -300),
        );
        await tester.pumpAndSettle();

        final locationTile = find.text('Geographic Location');
        expect(locationTile, findsOneWidget);

        await tester.tap(locationTile);
        await tester.pumpAndSettle();

        // Action sheet is displayed
        expect(find.text('Update Geographic Location'), findsOneWidget);
        expect(find.text('Clear Geographic Location'), findsOneWidget);
        expect(find.text('Show on the map'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);

        // Update location
        await tester.tap(find.text('Update Geographic Location'));
        await tester.pumpAndSettle();

        // Verify location changed in AddTransactionScreen
        expect(find.textContaining('Current Location'), findsOneWidget);
      },
    );
  });
}
