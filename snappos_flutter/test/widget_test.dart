import 'package:flutter_test/flutter_test.dart';
import 'package:snappos_flutter/main.dart';

void main() {
  testWidgets('App can be built', (WidgetTester tester) async {
    // Build app
    await tester.pumpWidget(const SnapposApp());

    // Run initial frame
    await tester.pump();

    // Kalau tidak crash, test lulus
    expect(find.byType(SnapposApp), findsOneWidget);
  });
}
