import 'package:ezbookkeeping/core/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CustomButton Tests', () {
    testWidgets(
      'renders primary button with label text and triggers onPressed',
      (tester) async {
        bool pressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomButton(
                text: 'Submit',
                onPressed: () => pressed = true,
              ),
            ),
          ),
        );

        expect(find.text('Submit'), findsOneWidget);
        await tester.tap(find.text('Submit'));
        await tester.pump();

        expect(pressed, isTrue);
      },
    );

    testWidgets(
      'displays loading spinner when isLoading is true and ignores taps',
      (tester) async {
        bool pressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomButton(
                text: 'Submit',
                isLoading: true,
                onPressed: () => pressed = true,
              ),
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Submit'), findsNothing);

        await tester.tap(find.byType(CircularProgressIndicator));
        await tester.pump();

        expect(pressed, isFalse);
      },
    );

    testWidgets(
      'renders disabled state when isDisabled is true or onPressed is null',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: CustomButton(
                text: 'Disabled Action',
                isDisabled: true,
                onPressed: null,
              ),
            ),
          ),
        );

        final button = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        expect(button.onPressed, isNull);
      },
    );

    testWidgets('renders outlined button variant correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton.outlined(text: 'Cancel', onPressed: () {}),
          ),
        ),
      );

      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('renders text button variant correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton.text(text: 'Skip', onPressed: () {}),
          ),
        ),
      );

      expect(find.byType(TextButton), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('renders custom icon alongside text label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Add Account',
              icon: const Icon(Icons.add),
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('Add Account'), findsOneWidget);
    });
  });

  group('CustomTextFormField Tests', () {
    testWidgets('renders labelText, hintText and updates text controller', (
      tester,
    ) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextFormField(
              controller: controller,
              labelText: 'Username',
              hintText: 'Enter username',
            ),
          ),
        ),
      );

      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Enter username'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'testuser');
      await tester.pump();

      expect(controller.text, equals('testuser'));
    });

    testWidgets('toggles password visibility when isPassword is true', (
      tester,
    ) async {
      final controller = TextEditingController(text: 'secret123');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextFormField(controller: controller, isPassword: true),
          ),
        ),
      );

      // Initially obscured
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      final editableTextInitial = tester.widget<EditableText>(
        find.byType(EditableText),
      );
      expect(editableTextInitial.obscureText, isTrue);

      // Tap to reveal
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      final editableTextRevealed = tester.widget<EditableText>(
        find.byType(EditableText),
      );
      expect(editableTextRevealed.obscureText, isFalse);
    });

    testWidgets('executes validation logic on form validate', (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: CustomTextFormField(
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Field cannot be empty';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      expect(find.text('Field cannot be empty'), findsNothing);

      formKey.currentState?.validate();
      await tester.pump();

      expect(find.text('Field cannot be empty'), findsOneWidget);
    });

    testWidgets(
      'supports underline and none variants without throwing errors',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  CustomTextFormField(
                    variant: CustomTextFieldVariant.underline,
                    hintText: 'Underline variant',
                  ),
                  CustomTextFormField(
                    variant: CustomTextFieldVariant.none,
                    hintText: 'None variant',
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.text('Underline variant'), findsOneWidget);
        expect(find.text('None variant'), findsOneWidget);
      },
    );
  });
}
