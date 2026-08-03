import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:datingapp/main.dart';
import 'package:datingapp/home.dart';
import 'package:datingapp/screens/basic_to_advanced_screen.dart';

void main() {
  testWidgets('App loads GlowDateApp successfully', (tester) async {
    await tester.pumpWidget(const GlowDateApp());
    expect(find.byType(GlowDateApp), findsOneWidget);
  });

  testWidgets('Basic to Advanced screen renders its title', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: BasicToAdvancedScreen()));
    expect(find.text('Basic to Advanced'), findsOneWidget);
  });

  testWidgets('Home screen shows the discovery shell', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    expect(find.text('Discover'), findsOneWidget);
    expect(find.text('Matches'), findsOneWidget);
  });
}
