import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String? email;
  final String? phone;
  const OtpVerificationScreen({super.key, this.email, this.phone});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with TickerProviderStateMixin {
  static const int _otpLength = 6;
  static const int _resendSeconds = 30;

  final List<TextEditingController> _controllers =
      List.generate(_otpLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_otpLength, (_) => FocusNode());

  bool _isVerifying = false;
  bool _verified = false;
  bool _hasError = false;

  int _secondsLeft = _resendSeconds;
  Timer? _resendTimer;

  // Same elasticOut entrance pop used on Forgot/Reset Password icon marks.
  late final AnimationController _entranceController;
  late final Animation<double> _entranceScale;
  late final Animation<double> _entranceFade;

  // Shake animation played on the OTP row when verification fails — a
  // horizontal wiggle, not a generic error color flash, so an incorrect
  // code reads as an unmistakable "no" rather than something you might miss.
  late final AnimationController _shakeController;
  late final Animation<double> _shakeOffset;

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

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );
    _shakeOffset = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: 0.0), weight: 1),
    ]).animate(
        CurvedAnimation(parent: _shakeController, curve: Curves.easeOut));

    _startResendTimer();
  }

  void _startResendTimer() {
    _secondsLeft = _resendSeconds;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _shakeController.dispose();
    _resendTimer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _enteredCode => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (_hasError) setState(() => _hasError = false);

    if (value.isNotEmpty && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    if (_enteredCode.length == _otpLength) {
      FocusScope.of(context).unfocus();
      _verify();
    }
  }

  Future<void> _verify() async {
    if (_enteredCode.length != _otpLength || _isVerifying) return;
    setState(() => _isVerifying = true);

    final result = await AppApiService.verifyOtp(
      code: _enteredCode,
      email: widget.email,
      phone: widget.phone,
    );
    if (!mounted) return;

    final isCorrect = result['success'] as bool? ?? false;

    if (isCorrect) {
      setState(() {
        _isVerifying = false;
        _verified = true;
      });
    } else {
      setState(() {
        _isVerifying = false;
        _hasError = true;
      });
      _shakeController.forward(from: 0);
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes[0].requestFocus();
    }
  }

  void _resend() {
    if (_secondsLeft > 0) return;
    for (final c in _controllers) {
      c.clear();
    }
    setState(() => _hasError = false);
    _focusNodes[0].requestFocus();
    _startResendTimer();
    AppApiService.resendOtp(email: widget.email, phone: widget.phone);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('A new code has been sent'),
        backgroundColor: AppTheme.surfaceDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final destination = widget.email ?? widget.phone ?? 'your device';

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
                if (!_verified)
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
                    child: _verified
                        ? _buildSuccessState()
                        : _buildOtpState(destination),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpState(String destination) {
    return SingleChildScrollView(
      key: const ValueKey('otp'),
      physics: const BouncingScrollPhysics(),
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
                  child: const Icon(Icons.mark_email_read_rounded,
                      size: 48, color: Colors.white),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Verify your code',
            style: TextStyle(
                fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          Text(
            'Enter the $_otpLength-digit code we sent to\n$destination',
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 36),
          AnimatedBuilder(
            animation: _shakeOffset,
            builder: (context, child) => Transform.translate(
              offset: Offset(_shakeOffset.value, 0),
              child: child,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_otpLength, (i) => _buildOtpBox(i)),
            ),
          ),
          if (_hasError) ...[
            const SizedBox(height: 14),
            Row(
              children: const [
                Icon(Icons.error_outline_rounded,
                    size: 16, color: AppTheme.primaryCoral),
                SizedBox(width: 6),
                Text(
                  'Incorrect code. Please try again.',
                  style: TextStyle(
                      color: AppTheme.primaryCoral,
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
          const SizedBox(height: 32),
          _AnimatedGradientButton(
            label: 'Verify',
            loading: _isVerifying,
            onPressed: (_enteredCode.length == _otpLength && !_isVerifying)
                ? _verify
                : null,
          ),
          const SizedBox(height: 24),
          Center(
            child: _secondsLeft > 0
                ? Text(
                    'Resend code in 0:${_secondsLeft.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 13),
                  )
                : GestureDetector(
                    onTap: _resend,
                    child: const Text(
                      'Resend Code',
                      style: TextStyle(
                          color: AppTheme.primaryRose,
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildOtpBox(int index) {
    final hasFocus = _focusNodes[index].hasFocus;
    final filled = _controllers[index].text.isNotEmpty;

    return SizedBox(
      width: 46,
      height: 56,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _hasError
                ? AppTheme.primaryCoral
                : (hasFocus || filled)
                    ? AppTheme.primaryRose
                    : Colors.white12,
            width: (hasFocus || filled || _hasError) ? 1.6 : 1,
          ),
          boxShadow: hasFocus && !_hasError
              ? [
                  BoxShadow(
                    color: AppTheme.primaryRose.withOpacity(0.25),
                    blurRadius: 12,
                  ),
                ]
              : [],
        ),
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: const TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          cursorColor: AppTheme.primaryRose,
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (v) => _onDigitChanged(index, v),
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
                'Verified!',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Your identity has been confirmed. You\u2019re all set to continue.',
                style: TextStyle(
                    color: AppTheme.textSecondary, fontSize: 14, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              _AnimatedGradientButton(
                label: 'Continue',
                loading: false,
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Same primary gradient button used across Forgot/Reset Password: hover-lift
/// on web/desktop, press-in scale everywhere, spinner swap while loading.
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
            opacity: disabled && !widget.loading ? 0.5 : 1.0,
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
