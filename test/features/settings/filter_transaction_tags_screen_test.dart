import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ezbookkeeping/core/di/service_locator.dart';
import 'package:ezbookkeeping/features/tags/models/tag_item.dart';
import 'package:ezbookkeeping/features/settings/presentation/filter_transaction_tags_screen.dart';

void main() {
  const sampleTags = [
    TagItem(
      id: 'tag_1',
      name: 'travel',
      groupId: '0',
    ),
    TagItem(
      id: 'tag_2',
      name: 'food',
      groupId: '0',
    ),
    TagItem(
      id: 'tag_hidden',
      name: 'secret',
      groupId: '0',
      hidden: true,
    ),
  ];

  group('FilterTransactionTagsScreen Widget Tests', () {
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

    testWidgets('renders top bar, search pill, tag group and tag items', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FilterTransactionTagsScreen(
            initialTags: sampleTags,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Top bar
      expect(find.text('Filter Transaction Tags'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
      expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      // Search pill
      expect(find.text('Find tag'), findsOneWidget);

      // Group header
      expect(find.text('Default Group'), findsOneWidget);

      // Tag items
      expect(find.text('travel'), findsOneWidget);
      expect(find.text('food'), findsOneWidget);
      expect(find.text('Default'), findsNWidgets(2));

      // Hidden tag should not be visible by default
      expect(find.text('secret'), findsNothing);
    });

    testWidgets('search filters tags in real time', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FilterTransactionTagsScreen(
            initialTags: sampleTags,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('travel'), findsOneWidget);
      expect(find.text('food'), findsOneWidget);

      // Search for 'travel'
      await tester.enterText(find.byType(TextField), 'travel');
      await tester.pumpAndSettle();

      expect(find.widgetWithText(InkWell, 'travel'), findsOneWidget);
      expect(find.widgetWithText(InkWell, 'food'), findsNothing);
    });

    testWidgets('selecting tag state from state picker bottom sheet', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FilterTransactionTagsScreen(
            initialTags: sampleTags,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on 'travel' tag row
      await tester.tap(find.text('travel'));
      await tester.pumpAndSettle();

      // State picker bottom sheet should be shown
      expect(find.text('# travel'), findsOneWidget);
      expect(find.text('Included'), findsOneWidget);
      expect(find.text('Excluded'), findsOneWidget);

      // Tap 'Included'
      await tester.tap(find.text('Included'));
      await tester.pumpAndSettle();

      // State should now be 'Included' for travel
      expect(find.text('Included'), findsOneWidget);

      // Save and verify
      await tester.tap(find.byIcon(Icons.check_rounded));
      await tester.pumpAndSettle();

      expect(controller.overviewTagFilter['tag_1'], 'Included');
      expect(controller.tagsInOverview, 'Selected Tags');
    });

    testWidgets('3-dots options menu modal actions matching media_1790832934076.png', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FilterTransactionTagsScreen(
            initialTags: sampleTags,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap 3-dots menu button
      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();

      // Verify bottom sheet action buttons
      expect(find.text('Set All to Included'), findsOneWidget);
      expect(find.text('Set All to Default'), findsOneWidget);
      expect(find.text('Set All to Excluded'), findsOneWidget);
      expect(find.text('Show Hidden Transaction Tags'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);

      // Tap 'Set All to Included'
      await tester.tap(find.text('Set All to Included'));
      await tester.pumpAndSettle();

      // Save and verify
      await tester.tap(find.byIcon(Icons.check_rounded));
      await tester.pumpAndSettle();

      expect(controller.overviewTagFilter['tag_1'], 'Included');
      expect(controller.overviewTagFilter['tag_2'], 'Included');
    });

    testWidgets('Show Hidden Transaction Tags reveals hidden tags', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FilterTransactionTagsScreen(
            initialTags: sampleTags,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('secret'), findsNothing);

      // Open 3-dots menu
      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();

      // Tap Show Hidden Transaction Tags
      await tester.tap(find.text('Show Hidden Transaction Tags'));
      await tester.pumpAndSettle();

      // Secret tag is now visible
      expect(find.text('secret'), findsOneWidget);

      // Re-open menu to verify title changes to 'Hide Hidden Transaction Tags'
      await tester.tap(find.byIcon(Icons.more_horiz_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Hide Hidden Transaction Tags'), findsOneWidget);
    });
  });
}
