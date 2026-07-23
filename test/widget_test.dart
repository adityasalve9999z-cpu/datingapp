import 'package:flutter_test/flutter_test.dart';
import 'package:datingapp/main.dart';

void main() {
  testWidgets('App shows onboarding welcome message', (tester) async {
    await tester.pumpWidget(const DatingApp());

    expect(find.text('Meet your match'), findsOneWidget);
  });
}
