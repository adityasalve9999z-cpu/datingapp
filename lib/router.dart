import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'main.dart';
import 'models/profile_model.dart';
import 'providers/auth_provider.dart';
import 'splash.dart';
import 'home.dart' hide SettingsScreen;
import 'login/login.dart';
import 'login/signup.dart';
import 'login/forgot_password.dart';
import 'screens/otp_verification_screen.dart';
import 'screens/onboarding_wizard_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/profile_detail_screen.dart';
import 'screens/subscription_screen.dart';
import 'screens/basic_to_advanced_screen.dart';
import 'screens/discovery_filters_screen.dart';
import 'screens/safety_center_screen.dart';
import 'screens/ai_date_planner_screen.dart';
import 'screens/call_screen.dart';
import 'screens/match_celebration_screen.dart';
import 'screens/chat_room_screen.dart';
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
      final String loc = state.uri.toString();
      final bool isAuthRoute =
          loc == '/login' || loc == '/signup' || loc == '/forgot-password' || loc == '/otp' || loc == '/';

      // If user is not logged in and not on an auth route, redirect to login
      if (!loggedIn && !isAuthRoute) {
        return '/login';
      }

      // If user is logged in and trying to access login/signup/splash, redirect to home
      if (loggedIn && (loc == '/login' || loc == '/signup')) {
        return '/home';
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (BuildContext context, GoRouterState state) {
          return const SplashScreen();
        },
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreenAuth();
        },
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (BuildContext context, GoRouterState state) {
          return const SignupScreenAuth();
        },
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (BuildContext context, GoRouterState state) {
          return const ForgotPasswordScreen();
        },
      ),
      GoRoute(
        path: '/otp',
        name: 'otp',
        builder: (BuildContext context, GoRouterState state) {
          final destination = (state.extra as String?) ?? 'you@example.com';
          return OtpScreen(destination: destination);
        },
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (BuildContext context, GoRouterState state) {
          return const HomeScreen();
        },
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (BuildContext context, GoRouterState state) {
          return const OnboardingWizardScreen();
        },
      ),
      GoRoute(
        path: '/edit-profile',
        name: 'edit-profile',
        builder: (BuildContext context, GoRouterState state) {
          return const EditProfileScreen();
        },
      ),
      GoRoute(
        path: '/profile-detail',
        name: 'profile-detail',
        builder: (BuildContext context, GoRouterState state) {
          final profile = state.extra as ProfileModel;
          return ProfileDetailScreen(
            profile: profile,
            heroTag: 'detail_${profile.id}',
          );
        },
      ),
      GoRoute(
        path: '/filters',
        name: 'filters',
        builder: (BuildContext context, GoRouterState state) {
          return const DiscoveryFiltersScreen();
        },
      ),
      GoRoute(
        path: '/safety-center',
        name: 'safety-center',
        builder: (BuildContext context, GoRouterState state) {
          return const SafetyCenterScreen();
        },
      ),
      GoRoute(
        path: '/ai-date-planner',
        name: 'ai-date-planner',
        builder: (BuildContext context, GoRouterState state) {
          final matchName = state.extra as String?;
          return AiDatePlannerScreen(matchName: matchName);
        },
      ),
      GoRoute(
        path: '/match-celebration',
        name: 'match-celebration',
        builder: (BuildContext context, GoRouterState state) {
          final profile = state.extra as ProfileModel;
          return MatchCelebrationScreen(matchedProfile: profile);
        },
      ),
      GoRoute(
        path: '/chat-room',
        name: 'chat-room',
        builder: (BuildContext context, GoRouterState state) {
          final profile = state.extra as ProfileModel;
          return ChatRoomScreen(profile: profile);
        },
      ),
      GoRoute(
        path: '/call',
        name: 'call',
        builder: (BuildContext context, GoRouterState state) {
          final data = state.extra as Map<String, dynamic>;
          return CallScreen(
            profile: data['profile'] as ProfileModel,
            isVideoCall: data['isVideoCall'] as bool? ?? true,
          );
        },
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (BuildContext context, GoRouterState state) {
          return const SettingsScreen();
        },
      ),
      GoRoute(
        path: '/likes',
        name: 'likes',
        builder: (BuildContext context, GoRouterState state) {
          return const LikesScreen();
        },
      ),
      GoRoute(
        path: '/chats',
        name: 'chats',
        builder: (BuildContext context, GoRouterState state) {
          return const ChatListScreen();
        },
      ),
      GoRoute(
        path: '/subscription',
        name: 'subscription',
        builder: (BuildContext context, GoRouterState state) {
          return const SubscriptionScreen();
        },
      ),
      GoRoute(
        path: '/premium-plans',
        name: 'premium-plans',
        builder: (BuildContext context, GoRouterState state) {
          return const PremiumPlansScreen();
        },
      ),
      GoRoute(
        path: '/basic-to-advanced',
        name: 'basic-to-advanced',
        builder: (BuildContext context, GoRouterState state) {
          return const BasicToAdvancedScreen();
        },
      ),
    ],
  );
}
