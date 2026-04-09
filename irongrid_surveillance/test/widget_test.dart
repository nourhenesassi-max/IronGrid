import 'package:flutter_test/flutter_test.dart';

import 'package:irongrid_surveillance/main.dart';

void main() {
  testWidgets('surveillance app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const IronGridSurveillanceApp());

    expect(find.byType(IronGridSurveillanceApp), findsOneWidget);
  });
}
