import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'widgets/shimmer_loading.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';

import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/discovery_feed_provider.dart';
import 'providers/matches_and_chat_provider.dart';
import 'providers/app_settings_provider.dart';
import 'providers/app_loading_provider.dart';
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
        ChangeNotifierProvider(create: (_) => AppLoadingProvider()),
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
      controller: details.controller,
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
      builder: (context, child) {
        return Consumer<AppLoadingProvider>(
          builder: (context, loadingProvider, _) {
            return GlowLoadingOverlay(
              isLoading: loadingProvider.isLoading,
              message: loadingProvider.message,
              child: child!,
            );
          },
        );
      },
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
                Color(0x28006FEE), // electric blue subtle glow
                AppTheme.darkBackground,
              ],
              radius: 1.4,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    // ── Logo ───────────────────────────────────────────────
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.sunsetGradient,
                      ),
                      child: const Icon(Icons.favorite_rounded,
                          size: 36, color: Colors.white),
                    ),
                    const SizedBox(height: 28),
                    // ── Heading ─────────────────────────────────────────────
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppTheme.primaryGradient.createShader(bounds),
                      child: const Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.8,
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

                    // ── Card Container ──────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceDark,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.borderDefault),
                      ),
                      child: Column(
                        children: [
                          // Email Field
                          _HeroInputField(
                            controller: _emailController,
                            hint: 'Email address',
                            icon: Icons.email_outlined,
                          ),
                          const SizedBox(height: 12),

                          // Password Field
                          _HeroInputField(
                            controller: _passwordController,
                            hint: 'Password',
                            icon: Icons.lock_outline_rounded,
                            isObscure: true,
                          ),
                          const SizedBox(height: 24),

                          // Sign In Button
                          AnimatedGlowButton(
                            label: _isSubmitting ? 'SIGNING IN...' : 'SIGN IN',
                            onPressed: _isSubmitting ? null : _handleLogin,
                            gradient: AppTheme.primaryGradient,
                            height: 52,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(color: AppTheme.textSecondary,
                              fontSize: 14),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/signup'),
                          child: const Text(
                            'Create One',
                            style: TextStyle(
                              color: AppTheme.primaryRose,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textPrimary, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: GlowLoadingOverlay(
        isLoading: _isSubmitting,
        message: 'Creating account...',
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Color(0x20006FEE),
                AppTheme.darkBackground,
              ],
              radius: 1.4,
              center: Alignment(0, -0.8),
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  ShaderMask(
                    shaderCallback: (b) =>
                        AppTheme.primaryGradient.createShader(b),
                    child: const Text(
                      'Join GlowDate Today',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Connect with extraordinary people nearby',
                    style: TextStyle(color: AppTheme.textSecondary,
                        fontSize: 14),
                  ),
                  const SizedBox(height: 32),

                  // ── Card ──────────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.borderDefault),
                    ),
                    child: Column(
                      children: [
                        _HeroInputField(
                          controller: _nameController,
                          hint: 'Full Name',
                          icon: Icons.person_outline_rounded,
                        ),
                        const SizedBox(height: 12),
                        _HeroInputField(
                          controller: _emailController,
                          hint: 'Email Address',
                          icon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 12),
                        _HeroInputField(
                          controller: _passwordController,
                          hint: 'Password',
                          icon: Icons.lock_outline_rounded,
                          isObscure: true,
                        ),
                        const SizedBox(height: 24),
                        AnimatedGlowButton(
                          label: _isSubmitting
                              ? 'CREATING ACCOUNT...'
                              : 'GET STARTED',
                          onPressed: _isSubmitting ? null : _handleSignup,
                          gradient: AppTheme.primaryGradient,
                          height: 52,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// HeroUI-style text input field with focus ring
/// ─────────────────────────────────────────────────────────────────────────────
class _HeroInputField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isObscure;

  const _HeroInputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.isObscure = false,
  });

  @override
  State<_HeroInputField> createState() => _HeroInputFieldState();
}

class _HeroInputFieldState extends State<_HeroInputField> {
  final FocusNode _focus = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      setState(() => _isFocused = _focus.hasFocus);
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isFocused
              ? AppTheme.primaryRose.withOpacity(0.80)
              : AppTheme.borderDefault,
          width: _isFocused ? 1.5 : 1.0,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: AppTheme.primaryRose.withOpacity(0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focus,
        obscureText: widget.isObscure,
        style: const TextStyle(
            color: AppTheme.textPrimary, fontSize: 15),
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          prefixIcon: Icon(
            widget.icon,
            color: _isFocused ? AppTheme.primaryRose : AppTheme.textMuted,
            size: 18,
          ),
          hintText: widget.hint,
          hintStyle: const TextStyle(
              color: AppTheme.textMuted, fontSize: 14),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}
