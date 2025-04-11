import 'package:autocomplete_material_example/main.dart';
import 'package:autocomplete_material_example/widgets/single_select/single_select_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test suite for the SingleSelectPage.
void main() {
  Future navigateToSingleSelectPage(WidgetTester tester) async {
    await tester.pumpWidget(AutocompleteMaterialExample());

    /// Find the button by semantics adn navigate to the SingleSelectPage
    await tester.tap(find.bySemanticsLabel('SingleSelectButton'));

    await tester.pumpAndSettle();
  }

  group('Single Select Autocomplete', () {
    testWidgets('''
  Given a SingleSelectPage
  When the page is loaded
  Then the selected item should be None
  ''', (WidgetTester tester) async {
      await tester.pumpWidget(AutocompleteMaterialExample());

      /// Find the button by semantics adn navigate to the SingleSelectPage
      await tester.tap(find.bySemanticsLabel('SingleSelectButton'));

      await tester.pumpAndSettle();
      expect(find.byType(SingleSelectPage), findsOneWidget);
    });

    testWidgets('''
  Given a SingleSelectPage
  When the user selects an item
  Then the selected item should be updated
  ''', (WidgetTester tester) async {
      await navigateToSingleSelectPage(tester);

      await tester.tap(find.byKey(Key('SingleSelectAutocomplete')));
      // Simulate a tap on the first item in the list
      await tester.pumpAndSettle();

      await tester.tap(find.text('a').last);

      await tester.pumpAndSettle();

      // Verify that the selected item is updated
      expect(find.text('Selected Item: a'), findsOneWidget);
      expect(find.text('Selected Item: None'), findsNothing);
    });

    testWidgets('''
  Given a SingleSelectPage
  When the user cleans the field
  Then the selected item should be None
  ''', (WidgetTester tester) async {
      await navigateToSingleSelectPage(tester);

      await tester.tap(find.byKey(Key('SingleSelectAutocomplete')));
      // Simulate a tap on the first item in the list
      await tester.pumpAndSettle();

      await tester.tap(find.text('a').last);

      await tester.pumpAndSettle();

      // Verify that the selected item is updated
      expect(find.text('Selected Item: a'), findsOneWidget);
      expect(find.text('Selected Item: None'), findsNothing);

      // Clean the field
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      expect(find.text('Selected Item: None'), findsOneWidget);
      expect(find.text('Select an item'), findsOneWidget);
    });
  });
}
