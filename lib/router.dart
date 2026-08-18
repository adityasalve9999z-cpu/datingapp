import 'package:datingapp/main.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'splash.dart';
import 'home.dart' hide SettingsScreen;
import 'login/login.dart';
import 'login/signup.dart';
import 'screens/onboarding_wizard_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/subscription_screen.dart';
import 'screens/basic_to_advanced_screen.dart';
import 'screens/discovery_filters_screen.dart';
import 'screens/safety_center_screen.dart';
import 'screens/ai_date_planner_screen.dart';
import 'screens/setting_screen.dart';
import 'screens/likes_screen.dart';
import 'screens/chat_list_screen.dart';
import 'screens/premium_plans_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: authProvider,
    redirect: (BuildContext context, GoRouterState state) {
      final bool loggedIn = authProvider.isAuthenticated;
      final bool loggingIn =
          state.uri.toString() == '/login' || state.uri.toString() == '/signup';

      if (!loggedIn && !loggingIn) return '/login';
      if (loggedIn && loggingIn) return '/home';

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const SplashScreen();
        },
      ),
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreenAuth();
        },
      ),
      GoRoute(
        path: '/signup',
        builder: (BuildContext context, GoRouterState state) {
          return const SignupScreenAuth();
        },
      ),
      GoRoute(
        path: '/home',
        builder: (BuildContext context, GoRouterState state) {
          return const HomeScreen();
        },
      ),
      GoRoute(
        path: '/onboarding',
        builder: (BuildContext context, GoRouterState state) {
          return const OnboardingWizardScreen();
        },
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (BuildContext context, GoRouterState state) {
          return const EditProfileScreen();
        },
      ),
      GoRoute(
        path: '/filters',
        builder: (BuildContext context, GoRouterState state) {
          return const DiscoveryFiltersScreen();
        },
      ),
      GoRoute(
        path: '/safety-center',
        builder: (BuildContext context, GoRouterState state) {
          return const SafetyCenterScreen();
        },
      ),
      GoRoute(
        path: '/ai-date-planner',
        builder: (BuildContext context, GoRouterState state) {
          return const AiDatePlannerScreen();
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (BuildContext context, GoRouterState state) {
          return const SettingsScreen();
        },
      ),
      GoRoute(
        path: '/likes',
        builder: (BuildContext context, GoRouterState state) {
          return const LikesScreen();
        },
      ),
      GoRoute(
        path: '/chats',
        builder: (BuildContext context, GoRouterState state) {
          return const ChatListScreen();
        },
      ),
      GoRoute(
        path: '/subscription',
        builder: (BuildContext context, GoRouterState state) {
          return const SubscriptionScreen();
        },
      ),
      GoRoute(
        path: '/premium-plans',
        builder: (BuildContext context, GoRouterState state) {
          return const PremiumPlansScreen();
        },
      ),
      GoRoute(
        path: '/basic-to-advanced',
        builder: (BuildContext context, GoRouterState state) {
          return const BasicToAdvancedScreen();
        },
      ),
    ],
  );
}
