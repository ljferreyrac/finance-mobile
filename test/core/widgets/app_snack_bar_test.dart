import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:finanzas_ia/core/widgets/app_snack_bar.dart';

Widget _harness(WidgetTester tester, void Function(BuildContext) onPressed) {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => onPressed(context),
          child: const Text('trigger'),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets(
    'error snack bar with an action auto-dismisses after its duration',
    (tester) async {
      await tester.pumpWidget(_harness(tester, (context) {
        AppSnackBar.showError(
          context,
          'boom',
          actionLabel: 'Retry',
          onAction: () {},
        );
      }));

      await tester.tap(find.text('trigger'));
      await tester.pump();
      // Let the entrance animation complete before jumping further, so the
      // dismiss Timer is actually scheduled (mirrors Flutter's own SnackBar
      // tests, which step through pumps rather than jumping in one leap).
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(seconds: 4));

      // Still visible before the 5s duration elapses.
      expect(find.text('boom'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      expect(find.text('boom'), findsNothing);
    },
  );

  testWidgets(
    'a second call replaces the previous snack bar instead of queueing it',
    (tester) async {
      await tester.pumpWidget(_harness(tester, (context) {
        AppSnackBar.showError(context, 'first error');
        AppSnackBar.showError(context, 'second error');
      }));

      await tester.tap(find.text('trigger'));
      await tester.pump();

      expect(find.text('first error'), findsNothing);
      expect(find.text('second error'), findsOneWidget);
    },
  );
}
