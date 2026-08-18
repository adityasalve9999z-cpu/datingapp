import 'package:datingapp/screens/edit_profile_screen.dart';
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'splash.dart';
import 'home.dart';
import 'screens/onboarding_wizard_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/subscription_screen.dart';
import 'widgets/animated_glow_button.dart';
import 'widgets/shimmer_loading.dart';
import 'services/api_service.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';

import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/discovery_feed_provider.dart';
import 'providers/matches_and_chat_provider.dart';
import 'providers/app_settings_provider.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(
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
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return Scrollbar(
      thumbVisibility: true,
      thickness: 8,
      radius: const Radius.circular(8),
      child: child,
    );
  }
}

class GlowDateApp extends StatelessWidget {
  const GlowDateApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the AuthProvider from the context
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    // Create the router
    final appRouter = createRouter(authProvider);

    return MaterialApp.router(
      title: 'GlowDate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      scrollBehavior: AppScrollBehavior(),
      routerConfig: appRouter,
    );
  }
}

class LoginScreenAuth extends StatefulWidget {
  const LoginScreenAuth({super.key});

  @override
  State<LoginScreenAuth> createState() => _LoginScreenAuthState();
}

class _LoginScreenAuthState extends State<LoginScreenAuth> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _handleLogin() async {
    setState(() => _isSubmitting = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'] as String)),
    );
    if (result['success'] == true) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: GlowLoadingOverlay(
        isLoading: _isSubmitting,
        message: 'Authenticating...',
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Color(0x2BFF2A6D),
                AppTheme.darkBackground,
              ],
              radius: 1.2,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.sunsetGradient,
                      ),
                      child: const Icon(Icons.favorite_rounded,
                          size: 50, color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppTheme.primaryGradient.createShader(bounds),
                      child: const Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Sign in to discover your next spark',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 36),

                    // Input Box Email
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: TextField(
                        controller: _emailController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          icon: Icon(Icons.email_rounded,
                              color: AppTheme.primaryRose),
                          hintText: 'Email address',
                          hintStyle: TextStyle(color: AppTheme.textMuted),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Input Box Password
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          icon: Icon(Icons.lock_rounded,
                              color: AppTheme.primaryRose),
                          hintText: 'Password',
                          hintStyle: TextStyle(color: AppTheme.textMuted),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Login Button
                    AnimatedGlowButton(
                      label: _isSubmitting ? 'SIGNING IN...' : 'SIGN IN',
                      onPressed: _isSubmitting ? null : _handleLogin,
                      gradient: AppTheme.primaryGradient,
                    ),

                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/signup'),
                          child: const Text(
                            'Create One',
                            style: TextStyle(
                              color: AppTheme.primaryRose,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SignupScreenAuth extends StatefulWidget {
  const SignupScreenAuth({super.key});

  @override
  State<SignupScreenAuth> createState() => _SignupScreenAuthState();
}

class _SignupScreenAuthState extends State<SignupScreenAuth> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _handleSignup() async {
    setState(() => _isSubmitting = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.signup(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'] as String)),
    );
    if (result['success'] == true) {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: GlowLoadingOverlay(
        isLoading: _isSubmitting,
        message: 'Creating account...',
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Join GlowDate Today',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Connect with extraordinary people nearby',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 32),
                _buildInputTile(Icons.person_rounded, 'Full Name',
                    controller: _nameController),
                const SizedBox(height: 16),
                _buildInputTile(Icons.email_rounded, 'Email Address',
                    controller: _emailController),
                const SizedBox(height: 16),
                _buildInputTile(Icons.lock_rounded, 'Password',
                    isObscure: true, controller: _passwordController),
                const SizedBox(height: 32),
                AnimatedGlowButton(
                  label: _isSubmitting ? 'CREATING ACCOUNT...' : 'GET STARTED',
                  onPressed: _isSubmitting ? null : _handleSignup,
                  backgroundColor: AppTheme.primaryRose,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputTile(IconData icon, String hint,
      {bool isObscure = false, TextEditingController? controller}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          icon: Icon(icon, color: AppTheme.primaryRose),
          hintText: hint,
          hintStyle: const TextStyle(color: AppTheme.textMuted),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
