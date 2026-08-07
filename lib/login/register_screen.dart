import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms = false;
  bool _isSubmitting = false;
  double _passwordStrength = 0;

  // Same elasticOut entrance pop used on Forgot/Reset/OTP screens' icon
  // marks, so this whole auth flow reads as one connected experience.
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
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _evaluateStrength(String value) {
    double score = 0;
    if (value.length >= 8) score += 0.34;
    if (RegExp(r'[A-Z]').hasMatch(value)) score += 0.33;
    if (RegExp(r'[0-9!@#\$%^&*]').hasMatch(value)) score += 0.33;
    setState(() => _passwordStrength = score.clamp(0, 1));
  }

  Color get _strengthColor {
    if (_passwordStrength < 0.34) return AppTheme.primaryCoral;
    if (_passwordStrength < 0.7) return AppTheme.accentGold;
    return AppTheme.emeraldGreen;
  }

  String get _strengthLabel {
    if (_passwordStrength == 0) return '';
    if (_passwordStrength < 0.34) return 'Weak';
    if (_passwordStrength < 0.7) return 'Getting there';
    return 'Strong';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please agree to the Terms to continue'),
          backgroundColor: AppTheme.surfaceDark,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final result = await AppApiService.signup(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message'] as String? ?? 'Welcome to GlowDate \u2014 let\u2019s find your person'),
        backgroundColor: AppTheme.surfaceDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
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
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
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
                                        color: AppTheme.primaryRose
                                            .withOpacity(0.4),
                                        blurRadius: 28,
                                        spreadRadius: 3,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.favorite_rounded,
                                      size: 44, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          const Text(
                            'Create your account',
                            style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'A few details, and you\u2019re one step from real connections that go somewhere.',
                            style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                                height: 1.5),
                          ),
                          const SizedBox(height: 32),
                          const Text('Full Name',
                              style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14)),
                          const SizedBox(height: 10),
                          _buildField(
                            controller: _nameController,
                            hint: 'How should matches see you?',
                            icon: Icons.person_outline_rounded,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Enter your name'
                                : null,
                          ),
                          const SizedBox(height: 20),
                          const Text('Email',
                              style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14)),
                          const SizedBox(height: 10),
                          _buildField(
                            controller: _emailController,
                            hint: 'you@example.com',
                            icon: Icons.alternate_email_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return 'Enter your email';
                              if (!v.contains('@') || !v.contains('.'))
                                return 'Enter a valid email';
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          const Text('Password',
                              style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14)),
                          const SizedBox(height: 10),
                          _buildField(
                            controller: _passwordController,
                            hint: 'At least 8 characters',
                            icon: Icons.lock_outline_rounded,
                            obscureText: _obscurePassword,
                            onChanged: _evaluateStrength,
                            suffix: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppTheme.textSecondary,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'Create a password';
                              if (v.length < 8) return 'At least 8 characters';
                              return null;
                            },
                          ),
                          if (_passwordController.text.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: _passwordStrength,
                                      minHeight: 4,
                                      backgroundColor: Colors.white12,
                                      valueColor: AlwaysStoppedAnimation(
                                          _strengthColor),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _strengthLabel,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: _strengthColor,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 20),
                          const Text('Confirm Password',
                              style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14)),
                          const SizedBox(height: 10),
                          _buildField(
                            controller: _confirmController,
                            hint: 'Re-enter your password',
                            icon: Icons.lock_outline_rounded,
                            obscureText: _obscureConfirm,
                            suffix: IconButton(
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppTheme.textSecondary,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm),
                            ),
                            validator: (v) {
                              if (v != _passwordController.text)
                                return 'Passwords do not match';
                              return null;
                            },
                          ),
                          const SizedBox(height: 22),
                          _buildTermsRow(),
                          const SizedBox(height: 28),
                          _AnimatedGradientButton(
                            label: 'Create Account',
                            loading: _isSubmitting,
                            onPressed: _isSubmitting ? null : _submit,
                          ),
                          const SizedBox(height: 24),
                          _buildDivider(),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                  child: _buildSocialButton(
                                      Icons.g_mobiledata_rounded, 'Google')),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: _buildSocialButton(
                                      Icons.apple_rounded, 'Apple')),
                            ],
                          ),
                          const SizedBox(height: 28),
                          Center(
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: RichText(
                                text: const TextSpan(
                                  style: TextStyle(
                                      fontSize: 13.5,
                                      color: AppTheme.textSecondary),
                                  children: [
                                    TextSpan(
                                        text: 'Already have an account?  '),
                                    TextSpan(
                                      text: 'Log in',
                                      style: TextStyle(
                                          color: AppTheme.primaryRose,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffix,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        validator: validator,
        style: const TextStyle(color: Colors.white),
        cursorColor: AppTheme.primaryRose,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          icon: Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Icon(icon, color: AppTheme.primaryRose),
          ),
          suffixIcon: suffix,
          hintText: hint,
          hintStyle: const TextStyle(color: AppTheme.textMuted),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildTermsRow() {
    return GestureDetector(
      onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            margin: const EdgeInsets.only(top: 1),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              gradient: _agreedToTerms ? AppTheme.primaryGradient : null,
              color: _agreedToTerms ? null : Colors.transparent,
              border: Border.all(
                color: _agreedToTerms ? Colors.transparent : Colors.white24,
                width: 1.4,
              ),
            ),
            child: _agreedToTerms
                ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 12.5, height: 1.4),
                children: [
                  const TextSpan(text: 'I agree to GlowDate\u2019s '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                        color: AppTheme.primaryRose.withOpacity(0.9),
                        fontWeight: FontWeight.w600),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                        color: AppTheme.primaryRose.withOpacity(0.9),
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: Colors.white12)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text('or sign up with',
              style: TextStyle(
                  color: AppTheme.textSecondary.withOpacity(0.8),
                  fontSize: 12)),
        ),
        Expanded(child: Container(height: 1, color: Colors.white12)),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, String label) {
    return SizedBox(
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(icon, color: Colors.white, size: 22),
        label: Text(label,
            style: const TextStyle(color: Colors.white, fontSize: 13.5)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

/// Same primary gradient button used across Forgot/Reset Password and OTP
/// Verification: hover-lift on web/desktop, press-in scale everywhere, and a
/// spinner swap while loading — kept identical so the whole auth flow reads
/// as one connected experience.
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
          child: AnimatedOpacity(
            opacity: disabled && !widget.loading ? 0.6 : 1.0,
            duration: const Duration(milliseconds: 200),
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
      ),
    );
  }
}
