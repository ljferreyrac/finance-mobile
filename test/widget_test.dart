import 'package:flutter_test/flutter_test.dart';

import 'package:finanzas_ia/main.dart';

void main() {
  testWidgets('App builds without throwing', (WidgetTester tester) async {
    await tester.pumpWidget(const FinanzasApp());
    expect(find.byType(FinanzasApp), findsOneWidget);
  });
}
