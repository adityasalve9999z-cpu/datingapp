import 'package:flutter_test/flutter_test.dart';
import 'package:datingapp/main.dart';

void main() {
  testWidgets('App loads GlowDateApp successfully', (tester) async {
    await tester.pumpWidget(const GlowDateApp());
    expect(find.byType(GlowDateApp), findsOneWidget);
  });
}
