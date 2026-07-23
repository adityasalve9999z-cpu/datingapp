import 'package:flutter_test/flutter_test.dart';
import 'package:datingapp/main.dart';

void main() {
  testWidgets('App shows welcome text', (tester) async {
    await tester.pumpWidget(const DatingApp());

    expect(find.text('Welcome to your new Flutter app'), findsOneWidget);
  });
}
