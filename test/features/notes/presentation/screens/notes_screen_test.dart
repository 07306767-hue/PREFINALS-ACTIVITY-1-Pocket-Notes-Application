import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_notes/features/notes/presentation/screens/notes_screen.dart';

void main() {
  testWidgets('shows an empty state when there are no notes', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: NotesScreen()));

    expect(find.text('No notes yet'), findsOneWidget);
    expect(find.text('Pocket Notes'), findsOneWidget);
  });

  testWidgets('creates and deletes a note', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: NotesScreen()));

    await tester.tap(find.byTooltip('Create note'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('note-title')), 'Shopping list');
    await tester.enterText(find.byKey(const Key('note-body')), 'Apples and tea');
    await tester.tap(find.text('Save note'));
    await tester.pumpAndSettle();

    expect(find.text('Shopping list'), findsOneWidget);
    expect(find.text('Apples and tea'), findsOneWidget);

    await tester.tap(find.byTooltip('Delete note'));
    await tester.pumpAndSettle();

    expect(find.text('Shopping list'), findsNothing);
    expect(find.text('No notes yet'), findsOneWidget);
  });
}
