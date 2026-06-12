import 'package:flutter_test/flutter_test.dart';
import 'package:eletrodescarte_mobile/main.dart';

void main() {
  testWidgets('Smoke test EletrodescarteApp', (WidgetTester tester) async {
    await tester.pumpWidget(const EletrodescarteApp());

    expect(find.text('E-mail'), findsOneWidget);
  });
}
