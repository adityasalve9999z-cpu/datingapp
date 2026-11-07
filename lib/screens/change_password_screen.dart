import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_glow_button.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// ChangePasswordScreen
/// ─────────────────────────────────────────────────────────────────────────────
/// HeroUI-styled screen for changing the authenticated user's password.
/// Validates locally (min 8 chars, new ≠ old) then calls the backend.
/// ─────────────────────────────────────────────────────────────────────────────
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;
  bool _isSubmitting = false;

  // Password strength
  int _strengthLevel = 0; // 0-4
  String _strengthLabel = '';

  late AnimationController _checkAnim;
  bool _success = false;

  @override
  void initState() {
    super.initState();
    _checkAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _newCtrl.addListener(_updateStrength);
  }

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    _checkAnim.dispose();
    super.dispose();
  }

  void _updateStrength() {
    final pwd = _newCtrl.text;
    int score = 0;
    if (pwd.length >= 8) score++;
    if (pwd.contains(RegExp(r'[A-Z]'))) score++;
    if (pwd.contains(RegExp(r'[0-9]'))) score++;
    if (pwd.contains(RegExp(r'[!@#\$&*~^%]'))) score++;

    final labels = ['', 'Weak', 'Fair', 'Good', 'Strong'];
    setState(() {
      _strengthLevel = score;
      _strengthLabel = pwd.isEmpty ? '' : labels[score.clamp(0, 4)];
    });
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    HapticFeedback.mediumImpact();
    setState(() => _isSubmitting = true);

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final result = await auth.changePassword(
      currentPassword: _currentCtrl.text,
      newPassword: _newCtrl.text,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result['success'] == true) {
      HapticFeedback.heavyImpact();
      setState(() => _success = true);
      _checkAnim.forward();

      await Future.delayed(const Duration(milliseconds: 1800));
      if (mounted) Navigator.of(context).pop();
    } else {
      _showError(result['message']?.toString() ?? 'Failed to change password');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppTheme.dangerRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
                child: Text(msg, style: const TextStyle(color: Colors.white))),
          ],
        ),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Change Password',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0x20006FEE), AppTheme.darkBackground],
            radius: 1.4,
            center: Alignment(0, -0.9),
          ),
        ),
        child: SafeArea(
          child: _success ? _buildSuccess() : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            builder: (_, v, child) => Transform.scale(scale: v, child: child),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.successGreen.withOpacity(0.15),
                border: Border.all(color: AppTheme.successGreen, width: 2),
              ),
              child: const Icon(Icons.check_rounded,
                  color: AppTheme.successGreen, size: 40),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Password Changed!',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your password has been updated successfully.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Update your password to keep your account secure.',
              style: TextStyle(
                  color: AppTheme.textSecondary.withOpacity(0.8), fontSize: 14),
            ),
            const SizedBox(height: 28),

            // ── Card ──────────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.borderDefault),
              ),
              child: Column(
                children: [
                  // Current password
                  _PasswordField(
                    controller: _currentCtrl,
                    label: 'Current Password',
                    hint: 'Enter your current password',
                    icon: Icons.lock_outline_rounded,
                    showPassword: _showCurrent,
                    onToggle: () =>
                        setState(() => _showCurrent = !_showCurrent),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Please enter your current password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // New password + strength meter
                  _PasswordField(
                    controller: _newCtrl,
                    label: 'New Password',
                    hint: 'Minimum 8 characters',
                    icon: Icons.lock_reset_rounded,
                    showPassword: _showNew,
                    onToggle: () => setState(() => _showNew = !_showNew),
                    validator: (v) {
                      if (v == null || v.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      if (v == _currentCtrl.text) {
                        return 'New password must differ from the current one';
                      }
                      return null;
                    },
                  ),

                  if (_strengthLabel.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    _StrengthMeter(level: _strengthLevel, label: _strengthLabel),
                  ],

                  const SizedBox(height: 14),

                  // Confirm new password
                  _PasswordField(
                    controller: _confirmCtrl,
                    label: 'Confirm New Password',
                    hint: 'Re-enter your new password',
                    icon: Icons.lock_rounded,
                    showPassword: _showConfirm,
                    onToggle: () =>
                        setState(() => _showConfirm = !_showConfirm),
                    validator: (v) {
                      if (v != _newCtrl.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Submit ────────────────────────────────────────────────────────
            AnimatedGlowButton(
              label: _isSubmitting ? 'UPDATING...' : 'UPDATE PASSWORD',
              onPressed: _isSubmitting ? null : _handleSubmit,
              gradient: AppTheme.primaryGradient,
              height: 52,
            ),

            const SizedBox(height: 20),

            // ── Security Tips ─────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryRose.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppTheme.primaryRose.withOpacity(0.20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.security_rounded,
                          color: AppTheme.primaryRose, size: 16),
                      const SizedBox(width: 8),
                      const Text(
                        'Security Tips',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  for (final tip in [
                    'Use 8+ characters with a mix of letters, numbers and symbols',
                    'Avoid using the same password on multiple sites',
                    'Never share your password with anyone',
                  ])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle_outline_rounded,
                              size: 14,
                              color: AppTheme.successGreen.withOpacity(0.8)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              tip,
                              style: const TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 12.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Supporting Widgets ────────────────────────────────────────────────────────

class _PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool showPassword;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.showPassword,
    required this.onToggle,
    this.validator,
  });

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  final _focus = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _isFocused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isFocused
                  ? AppTheme.primaryRose.withOpacity(0.75)
                  : AppTheme.borderDefault,
              width: _isFocused ? 1.5 : 1.0,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: AppTheme.primaryRose.withOpacity(0.12),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focus,
            obscureText: !widget.showPassword,
            validator: widget.validator,
            style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              prefixIcon: Icon(
                widget.icon,
                color: _isFocused ? AppTheme.primaryRose : AppTheme.textMuted,
                size: 18,
              ),
              suffixIcon: GestureDetector(
                onTap: widget.onToggle,
                child: Icon(
                  widget.showPassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppTheme.textMuted,
                  size: 18,
                ),
              ),
              hintText: widget.hint,
              hintStyle:
                  const TextStyle(color: AppTheme.textMuted, fontSize: 14),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              errorStyle:
                  const TextStyle(color: AppTheme.dangerRed, fontSize: 11.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _StrengthMeter extends StatelessWidget {
  final int level; // 0-4
  final String label;

  const _StrengthMeter({required this.level, required this.label});

  Color get _color {
    switch (level) {
      case 1:
        return const Color(0xFFF31260); // Danger
      case 2:
        return const Color(0xFFF5A524); // Warning
      case 3:
        return const Color(0xFF006FEE); // Primary
      case 4:
        return const Color(0xFF17C964); // Success
      default:
        return AppTheme.borderDefault;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) {
            final filled = i < level;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < 3 ? 4 : 0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 4,
                  decoration: BoxDecoration(
                    color: filled ? _color : AppTheme.borderDefault,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: _color,
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
