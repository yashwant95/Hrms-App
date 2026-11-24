import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('HRMSApp launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: HRMSApp()));
    expect(find.byType(HRMSApp), findsOneWidget);
  });
}
