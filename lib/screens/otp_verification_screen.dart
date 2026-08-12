import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ---------------------------------------------------------------------------
// Design tokens — "Lume" dating app theme consistency
// ---------------------------------------------------------------------------
class LumeColors {
  static const bg = Color(0xFF160D1C); // near-black plum
  static const bgGradientEnd = Color(0xFF2A1830); // lighter plum
  static const surface = Color(0xFF221328); // card/field surface
  static const surfaceBorder = Color(0xFF3A2740);
  static const gold = Color(0xFFD4A857); // champagne gold accent
  static const goldDim = Color(0xFF8A7245);
  static const blush = Color(0xFFE8A7A0); // secondary warm accent
  static const textPrimary = Color(0xFFF3EEE9);
  static const textSecondary = Color(0xFFA79AAE);
  static const error = Color(0xFFE07A6B);
}

class OtpScreen extends StatefulWidget {
  final String destination; // e.g. user's email or phone
  const OtpScreen({super.key, this.destination = 'you@example.com'});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with TickerProviderStateMixin {
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  bool _isSubmitting = false;
  bool _isResending = false;

  // Animation Controllers
  late final AnimationController _entryController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
    ));

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onFieldChanged(String value, int index) {
    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Auto-submit when all 4 digits are filled
    if (_controllers.every((c) => c.text.isNotEmpty)) {
      _verifyOtp();
    }
  }

  Future<void> _verifyOtp() async {
    String otpCode = _controllers.map((c) => c.text).join();
    if (otpCode.length < 4) return;

    setState(() => _isSubmitting = true);

    // Simulate backend verification delay
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Code verified successfully! Welcome to Lume.'),
        backgroundColor: LumeColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _resendCode() async {
    setState(() => _isResending = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() => _isResending = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('A new verification code has been sent.'),
        backgroundColor: LumeColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: LumeColors.textPrimary, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [LumeColors.bg, LumeColors.bgGradientEnd],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 12, 28, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    // Spark icon indicator
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: LumeColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: LumeColors.gold.withOpacity(0.5),
                            width: 1.5),
                        boxShadow: [
                          BoxShadow(
                              color: LumeColors.gold.withOpacity(0.2),
                              blurRadius: 12,
                              spreadRadius: 1),
                        ],
                      ),
                      child: const Icon(Icons.lock_reset_rounded,
                          color: LumeColors.gold, size: 24),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Verify your identity',
                      style: TextStyle(
                        color: LumeColors.textPrimary,
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter the 4-digit code we just sent to\n${widget.destination}',
                      style: const TextStyle(
                        color: LumeColors.textSecondary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // 4-Digit OTP Input Boxes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(4, (index) {
                        return SizedBox(
                          width: 68,
                          height: 68,
                          child: TextFormField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            onChanged: (value) => _onFieldChanged(value, index),
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            style: const TextStyle(
                              color: LumeColors.textPrimary,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                            cursorColor: LumeColors.gold,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: LumeColors.surface,
                              contentPadding: EdgeInsets.zero,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                    color: LumeColors.surfaceBorder),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                    color: LumeColors.surfaceBorder),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                    color: LumeColors.gold, width: 1.6),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),

                    const SizedBox(height: 40),

                    // Verify Button
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                              colors: [LumeColors.gold, Color(0xFFC79340)]),
                          boxShadow: [
                            BoxShadow(
                                color: LumeColors.gold.withOpacity(0.28),
                                blurRadius: 20,
                                offset: const Offset(0, 8)),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: _isSubmitting ? null : _verifyOtp,
                            child: Center(
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                LumeColors.bg),
                                      ),
                                    )
                                  : const Text(
                                      'Verify Code',
                                      style: TextStyle(
                                        color: LumeColors.bg,
                                        fontSize: 15.5,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Resend Code Prompt
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Didn't receive a code? ",
                            style: TextStyle(
                                color: LumeColors.textSecondary,
                                fontSize: 13.5),
                          ),
                          GestureDetector(
                            onTap: _isResending ? null : _resendCode,
                            child: Text(
                              _isResending ? 'Sending...' : 'Resend',
                              style: const TextStyle(
                                color: LumeColors.gold,
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                              ),
                            ),
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
      ),
    );
  }
}
