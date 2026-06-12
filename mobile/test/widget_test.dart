import 'package:flutter_test/flutter_test.dart';
import 'package:eletrodescarte_mobile/main.dart';

void main() {
  testWidgets('Smoke test EletrodescarteApp', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const EletrodescarteApp());

    // Verify that the login screen displays the E-mail input field label.
    expect(find.text('E-mail'), findsOneWidget);
  });
}
