import 'package:flutter_test/flutter_test.dart';
import 'package:datingapp/main.dart';

void main() {
  testWidgets('App shows match discovery screen', (tester) async {
    await tester.pumpWidget(const DatingApp());

    expect(find.text('Find your match'), findsOneWidget);
  });
}
