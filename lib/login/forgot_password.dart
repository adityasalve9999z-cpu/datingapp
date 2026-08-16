import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isSubmitting = false;
  bool _emailSent = false;

  // Entrance pop for the icon mark, same elasticOut language used on the
  // splash screen's heart, so this screen feels like part of the same app.
  late final AnimationController _entranceController;
  late final Animation<double> _entranceScale;
  late final Animation<double> _entranceFade;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..forward();
    _entranceScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.elasticOut),
    );
    _entranceFade =
        CurvedAnimation(parent: _entranceController, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    await AppApiService.forgotPassword(email: _emailController.text.trim());

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _emailSent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0x33FF2A6D), AppTheme.darkBackground],
            radius: 1.2,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white),
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(scale: animation, child: child),
                    ),
                    child:
                        _emailSent ? _buildSuccessState() : _buildFormState(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormState() {
    return SingleChildScrollView(
      key: const ValueKey('form'),
      physics: const BouncingScrollPhysics(),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            FadeTransition(
              opacity: _entranceFade,
              child: ScaleTransition(
                scale: _entranceScale,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.sunsetGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryRose.withOpacity(0.4),
                          blurRadius: 28,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.lock_reset_rounded,
                        size: 48, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Forgot your password?',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 10),
            const Text(
              'No worries — enter the email linked to your account and we\u2019ll send you a link to reset it.',
              style: TextStyle(
                  color: AppTheme.textSecondary, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            const Text('Email',
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                cursorColor: AppTheme.primaryRose,
                decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  icon: Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(Icons.alternate_email_rounded,
                        color: AppTheme.primaryRose),
                  ),
                  hintText: 'you@example.com',
                  hintStyle: TextStyle(color: AppTheme.textMuted),
                  border: InputBorder.none,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Enter your email';
                  if (!v.contains('@') || !v.contains('.')) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 32),
            _AnimatedGradientButton(
              label: 'Send Reset Link',
              loading: _isSubmitting,
              onPressed: _isSubmitting ? null : _submit,
            ),
            const SizedBox(height: 24),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Back to Log In',
                  style:
                      TextStyle(color: AppTheme.textSecondary, fontSize: 13.5),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState() {
    return Center(
      key: const ValueKey('success'),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        // FIX: AppTheme.glassContainer(...) is not defined on this project's
        // AppTheme class — replaced with a self-contained styled Container
        // (same fix applied to report_user_screen.dart earlier).
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.emeraldGreen.withOpacity(0.15),
                  border: Border.all(
                      color: AppTheme.emeraldGreen.withOpacity(0.4),
                      width: 1.5),
                ),
                child: const Icon(Icons.mark_email_read_rounded,
                    size: 48, color: AppTheme.emeraldGreen),
              ),
              const SizedBox(height: 24),
              const Text(
                'Check your inbox',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'We sent a password reset link to\n${_emailController.text.trim()}',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 14, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              _AnimatedGradientButton(
                label: 'Back to Log In',
                loading: false,
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => _emailSent = false),
                child: const Text(
                  'Didn\u2019t get it? Try again',
                  style: TextStyle(
                      color: AppTheme.primaryRose,
                      fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Primary gradient button with hover-lift (web/desktop), press-in scale
/// (all platforms), and a loading spinner swap — consistent with the button
/// language used across the rest of the app (filter sheet, onboarding,
/// action buttons).
class _AnimatedGradientButton extends StatefulWidget {
  final String label;
  final bool loading;
  final VoidCallback? onPressed;
  const _AnimatedGradientButton({
    required this.label,
    required this.loading,
    required this.onPressed,
  });

  @override
  State<_AnimatedGradientButton> createState() =>
      _AnimatedGradientButtonState();
}

class _AnimatedGradientButtonState extends State<_AnimatedGradientButton> {
  bool _pressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null;

    return MouseRegion(
      cursor: disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
        onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
        onTapCancel: disabled ? null : () => setState(() => _pressed = false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : (_isHovered && !disabled ? 1.015 : 1.0),
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: SizedBox(
            width: double.infinity,
            height: 54,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(18),
                boxShadow: disabled
                    ? []
                    : [
                        BoxShadow(
                          color: AppTheme.primaryRose
                              .withOpacity(_isHovered ? 0.5 : 0.35),
                          blurRadius: _isHovered ? 22 : 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: widget.loading
                      ? const SizedBox(
                          key: ValueKey('loading'),
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.4, color: Colors.white),
                        )
                      : Text(
                          widget.label,
                          key: const ValueKey('label'),
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
