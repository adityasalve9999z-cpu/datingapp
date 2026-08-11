import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'splash.dart';
import 'home.dart';
import 'login/login.dart';
import 'login/signup.dart';
import 'screens/onboarding_wizard_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/subscription_screen.dart';
import 'screens/basic_to_advanced_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  refreshListenable: _AuthProviderListenable(),
  redirect: (BuildContext context, GoRouterState state) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // AuthProvider's isLoading might be true while initializing.
    // If we want a splash screen to wait, we can handle it here or in a wrapper.
    
    final bool loggedIn = authProvider.isAuthenticated;
    final bool loggingIn = state.uri.toString() == '/login' || state.uri.toString() == '/signup';

    if (!loggedIn && !loggingIn) return '/login';
    if (loggedIn && loggingIn) return '/home';

    return null; // no redirect needed
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
        // Adjust this if your actual login screen widget has a different name
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
      path: '/subscription',
      builder: (BuildContext context, GoRouterState state) {
        return const SubscriptionScreen();
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

/// A wrapper to convert AuthProvider (ChangeNotifier) to a Listenable for GoRouter.
class _AuthProviderListenable extends ChangeNotifier {
  late final AuthProvider _authProvider;
  
  _AuthProviderListenable() {
    // This assumes the AuthProvider instance is accessed via some locator or passed in.
    // However, GoRouter's refreshListenable typically just takes a Listenable.
    // Since we need to access AuthProvider before GoRouter builds, we might need a better pattern.
  }
}
