import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:datingapp/main.dart';
import 'package:datingapp/home.dart';
import 'package:datingapp/screens/basic_to_advanced_screen.dart';
import 'package:datingapp/providers/auth_provider.dart';
import 'package:datingapp/providers/profile_provider.dart';
import 'package:datingapp/providers/discovery_feed_provider.dart';
import 'package:datingapp/providers/matches_and_chat_provider.dart';
import 'package:datingapp/providers/app_settings_provider.dart';

void main() {
  testWidgets('App loads GlowDateApp successfully', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => ProfileProvider()),
          ChangeNotifierProvider(create: (_) => DiscoveryFeedProvider()),
          ChangeNotifierProvider(create: (_) => MatchesAndChatProvider()),
          ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
        ],
        child: const GlowDateApp(),
      ),
    );
    await tester.pump(const Duration(seconds: 3));
    expect(find.byType(GlowDateApp), findsOneWidget);
  });

  testWidgets('Basic to Advanced screen renders its title', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: BasicToAdvancedScreen()));
    expect(find.text('Basic to Advanced'), findsOneWidget);
  });

  testWidgets('Home screen shows the discovery shell', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    expect(find.text('Discover'), findsWidgets);
    expect(find.text('Likes'), findsOneWidget);
  });
}

