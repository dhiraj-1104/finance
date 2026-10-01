import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ezbookkeeping/features/home/presentation/add_transaction_screen.dart';
import 'package:ezbookkeeping/features/home/widgets/amount_keypad_sheet.dart';

void main() {
  group('AmountKeypadSheet Widget Tests', () {
    testWidgets('renders all keypad grid keys matching mockup layout', (
      tester,
    ) async {
      double? confirmedAmount;
      double? liveAmount;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    AmountKeypadSheet.show(
                      context,
                      initialAmount: 0.0,
                      onAmountChanged: (val) => liveAmount = val,
                      onConfirm: (val) => confirmedAmount = val,
                    );
                  },
                  child: const Text('Open Keypad'),
                );
              },
            ),
          ),
        ),
      );

      // Open bottom sheet
      await tester.tap(find.text('Open Keypad'));
      await tester.pumpAndSettle();

      // Check numbers 0-9
      for (int i = 0; i <= 9; i++) {
        expect(find.text('$i'), findsOneWidget);
      }

      // Check operators and symbols
      expect(find.text('\u00D7'), findsOneWidget); // ×
      expect(find.text('\u2212'), findsOneWidget); // −
      expect(find.text('+'), findsOneWidget); // +
      expect(find.text('.'), findsOneWidget); // .
      expect(find.text('OK'), findsOneWidget); // OK button
      expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);

      // Enter 4, 5, ., 5
      await tester.tap(find.text('4'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('5'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('.'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('5'));
      await tester.pumpAndSettle();

      expect(liveAmount, 45.5);

      // Tap OK
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Verify bottom sheet closed and onConfirm called
      expect(find.text('OK'), findsNothing);
      expect(confirmedAmount, 45.5);
    });

    testWidgets('calculates arithmetic expressions properly (10 + 5 = 15)', (
      tester,
    ) async {
      double? confirmedAmount;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    AmountKeypadSheet.show(
                      context,
                      initialAmount: 0.0,
                      onConfirm: (val) => confirmedAmount = val,
                    );
                  },
                  child: const Text('Open Keypad'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Keypad'));
      await tester.pumpAndSettle();

      // 1 0 + 5 OK
      await tester.tap(find.text('1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('0'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('+'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('5'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(confirmedAmount, 15.0);
    });

    testWidgets('AddTransactionScreen opens AmountKeypadSheet on amount tap', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: AddTransactionScreen()));
      await tester.pumpAndSettle();

      // Verify initial amount display
      expect(find.text('\$ 0.00'), findsOneWidget);

      // Tap on the amount display
      await tester.tap(find.text('\$ 0.00'));
      await tester.pumpAndSettle();

      // Verify keypad sheet is shown
      expect(find.text('OK'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);
      expect(find.text('8'), findsOneWidget);
      expect(find.text('9'), findsOneWidget);

      // Tap 3, 5, 0, 0
      await tester.tap(find.text('3'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('5'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('0'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('0'));
      await tester.pumpAndSettle();

      // Verify live amount in AddTransactionScreen behind sheet updated
      expect(find.text('\$ 3500.00'), findsOneWidget);

      // Confirm with OK
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Verify sheet dismissed and amount preserved
      expect(find.text('OK'), findsNothing);
      expect(find.text('\$ 3500.00'), findsOneWidget);
    });
  });
}
