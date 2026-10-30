import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notice_period/main.dart';

void main() {
  testWidgets('NoticePeriod App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: NoticePeriodApp(),
      ),
    );

    expect(find.byType(NoticePeriodApp), findsOneWidget);
  });
}
