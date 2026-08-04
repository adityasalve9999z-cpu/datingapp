import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ResetPasswordScreen extends StatefulWidget {
  /// Typically passed in from the reset-link deep link / token flow.
  final String? email;
  const ResetPasswordScreen({super.key, this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;
  bool _resetComplete = false;
  double _passwordStrength = 0;

  // Same elasticOut entrance pop used on the icon marks across the app
  // (splash heart, forgot-password lock) so this screen reads as the same
  // continued flow rather than a new visual style.
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
    setState(() => _isSubmitting = true);

    // Simulated request — swap for your real "set new password" API call.
    await Future.delayed(const Duration(milliseconds: 1100));

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _resetComplete = true;
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
                if (!_resetComplete)
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
                    child: _resetComplete
                        ? _buildSuccessState()
                        : _buildFormState(),
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
                          color: AppTheme.primaryRose.withOpacity(0.4),
                          blurRadius: 28,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.password_rounded,
                        size: 48, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Set a new password',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              widget.email != null
                  ? 'Create a new password for ${widget.email}'
                  : 'Choose a strong password you haven\u2019t used before.',
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 32),
            const Text('New Password',
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
            const SizedBox(height: 10),
            _buildPasswordField(
              controller: _passwordController,
              hint: 'At least 8 characters',
              obscure: _obscurePassword,
              onToggleObscure: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              onChanged: _evaluateStrength,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Enter a new password';
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
                        valueColor: AlwaysStoppedAnimation(_strengthColor),
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
            _buildPasswordField(
              controller: _confirmController,
              hint: 'Re-enter your password',
              obscure: _obscureConfirm,
              onToggleObscure: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
              validator: (v) {
                if (v != _passwordController.text)
                  return 'Passwords do not match';
                return null;
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Icon(Icons.info_outline_rounded,
                    size: 14, color: AppTheme.textMuted),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Use 8+ characters with a mix of letters, numbers & symbols.',
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _AnimatedGradientButton(
              label: 'Reset Password',
              loading: _isSubmitting,
              onPressed: _isSubmitting ? null : _submit,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggleObscure,
    required String? Function(String?) validator,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        onChanged: onChanged,
        validator: validator,
        style: const TextStyle(color: Colors.white),
        cursorColor: AppTheme.primaryRose,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          icon: const Padding(
            padding: EdgeInsets.only(left: 4),
            child:
                Icon(Icons.lock_outline_rounded, color: AppTheme.primaryRose),
          ),
          hintText: hint,
          hintStyle: const TextStyle(color: AppTheme.textMuted),
          border: InputBorder.none,
          suffixIcon: IconButton(
            icon: Icon(
              obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: AppTheme.textSecondary,
              size: 20,
            ),
            onPressed: onToggleObscure,
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessState() {
    return Center(
      key: const ValueKey('success'),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: AppTheme.glassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
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
                child: const Icon(Icons.check_circle_rounded,
                    size: 48, color: AppTheme.emeraldGreen),
              ),
              const SizedBox(height: 24),
              const Text(
                'Password reset!',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Your password has been updated. Use your new password the next time you log in.',
                style: TextStyle(
                    color: AppTheme.textSecondary, fontSize: 14, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              _AnimatedGradientButton(
                label: 'Back to Log In',
                loading: false,
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Same primary gradient button as the Forgot Password screen: hover-lift on
/// web/desktop, press-in scale everywhere, and a spinner swap while loading.
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
