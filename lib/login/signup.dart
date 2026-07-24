import 'package:flutter/material.dart';

void main() => runApp(const LumeApp());

// ---------------------------------------------------------------------------
// Design tokens — "Lume" dating app
// Palette: deep midnight plum background, warm champagne-gold accent,
// soft blush for secondary highlights. Built for a premium, intimate feel —
// not the generic purple-gradient SaaS look.
// ---------------------------------------------------------------------------
class LumeColors {
  static const bg = Color(0xFF160D1C);         // near-black plum
  static const bgGradientEnd = Color(0xFF2A1830); // lighter plum
  static const surface = Color(0xFF221328);     // card/field surface
  static const surfaceBorder = Color(0xFF3A2740);
  static const gold = Color(0xFFD4A857);        // champagne gold accent
  static const goldDim = Color(0xFF8A7245);
  static const blush = Color(0xFFE8A7A0);       // secondary warm accent
  static const textPrimary = Color(0xFFF3EEE9);
  static const textSecondary = Color(0xFFA79AAE);
  static const error = Color(0xFFE07A6B);
}

class LumeApp extends StatelessWidget {
  const LumeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lume',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: LumeColors.bg,
        colorScheme: const ColorScheme.dark(
          primary: LumeColors.gold,
          surface: LumeColors.surface,
        ),
      ),
      home: const SignupScreen(),
    );
  }
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _agreedToTerms = false;
  double _passwordStrength = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
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
    if (_passwordStrength < 0.34) return LumeColors.error;
    if (_passwordStrength < 0.7) return LumeColors.blush;
    return LumeColors.gold;
  }

  String get _strengthLabel {
    if (_passwordStrength == 0) return '';
    if (_passwordStrength < 0.34) return 'Weak';
    if (_passwordStrength < 0.7) return 'Getting there';
    return 'Strong';
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms to continue'),
          backgroundColor: LumeColors.surface,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Welcome to Lume — let\'s find your person'),
        backgroundColor: LumeColors.surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [LumeColors.bg, LumeColors.bgGradientEnd],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 12, 28, 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  _buildSignatureMotif(),
                  const SizedBox(height: 28),
                  const Text(
                    'Create your space',
                    style: TextStyle(
                      color: LumeColors.textPrimary,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'A few details, and you\'re one step from\nreal conversations that go somewhere.',
                    style: TextStyle(
                      color: LumeColors.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  _buildLabel('Your name'),
                  _buildField(
                    controller: _nameController,
                    hint: 'How should matches see you?',
                    icon: Icons.person_outline_rounded,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
                  ),
                  const SizedBox(height: 18),

                  _buildLabel('Email'),
                  _buildField(
                    controller: _emailController,
                    hint: 'you@example.com',
                    icon: Icons.alternate_email_rounded,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Enter your email';
                      if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),

                  _buildLabel('Password'),
                  _buildField(
                    controller: _passwordController,
                    hint: 'At least 8 characters',
                    icon: Icons.lock_outline_rounded,
                    obscureText: _obscurePassword,
                    onChanged: _evaluateStrength,
                    suffix: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: LumeColors.textSecondary,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Create a password';
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
                              backgroundColor: LumeColors.surfaceBorder,
                              valueColor: AlwaysStoppedAnimation(_strengthColor),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _strengthLabel,
                          style: TextStyle(fontSize: 11, color: _strengthColor, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 22),
                  _buildTermsRow(),

                  const SizedBox(height: 28),
                  _buildPrimaryButton(),

                  const SizedBox(height: 24),
                  _buildDivider(),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(child: _buildSocialButton(Icons.g_mobiledata_rounded, 'Google')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildSocialButton(Icons.apple_rounded, 'Apple')),
                    ],
                  ),

                  const SizedBox(height: 32),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 13.5, color: LumeColors.textSecondary),
                        children: [
                          const TextSpan(text: 'Already have an account?  '),
                          TextSpan(
                            text: 'Log in',
                            style: const TextStyle(color: LumeColors.gold, fontWeight: FontWeight.w700),
                            recognizer: null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Signature element: an overlapping trio of avatar rings converging on a
  /// small warm spark — a quiet visual metaphor for "your circle is about to
  /// widen," instead of a generic logo mark.
  Widget _buildSignatureMotif() {
    return SizedBox(
      height: 84,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            child: _avatarRing(color: LumeColors.blush, opacity: 0.55),
          ),
          Positioned(
            left: 34,
            child: _avatarRing(color: LumeColors.gold, opacity: 0.85),
          ),
          Positioned(
            left: 68,
            top: 4,
            child: _avatarRing(color: LumeColors.blush, opacity: 0.4, size: 56),
          ),
          Positioned(
            left: 96,
            top: 22,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: LumeColors.gold,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: LumeColors.gold.withOpacity(0.55), blurRadius: 14, spreadRadius: 1),
                ],
              ),
              child: const Icon(Icons.auto_awesome_rounded, size: 13, color: LumeColors.bg),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarRing({required Color color, required double opacity, double size = 64}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(opacity), width: 1.6),
        color: LumeColors.surface,
      ),
      child: Icon(Icons.person_rounded, color: color.withOpacity(opacity + 0.15), size: size * 0.42),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(
        text,
        style: const TextStyle(
          color: LumeColors.textSecondary,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
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
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(color: LumeColors.textPrimary, fontSize: 14.5),
      cursorColor: LumeColors.gold,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF6E6274), fontSize: 14),
        prefixIcon: Icon(icon, color: LumeColors.textSecondary, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: LumeColors.surface,
        errorStyle: const TextStyle(color: LumeColors.error, fontSize: 11.5),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: LumeColors.surfaceBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: LumeColors.surfaceBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: LumeColors.gold, width: 1.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: LumeColors.error, width: 1.2),
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
          Container(
            margin: const EdgeInsets.only(top: 1),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: _agreedToTerms ? LumeColors.gold : Colors.transparent,
              border: Border.all(
                color: _agreedToTerms ? LumeColors.gold : LumeColors.surfaceBorder,
                width: 1.4,
              ),
            ),
            child: _agreedToTerms
                ? const Icon(Icons.check_rounded, size: 14, color: LumeColors.bg)
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: const TextStyle(color: LumeColors.textSecondary, fontSize: 12.5, height: 1.4),
                children: [
                  const TextSpan(text: 'I agree to Lume\'s '),
                  TextSpan(text: 'Terms of Service', style: TextStyle(color: LumeColors.gold.withOpacity(0.9), fontWeight: FontWeight.w600)),
                  const TextSpan(text: ' and '),
                  TextSpan(text: 'Privacy Policy', style: TextStyle(color: LumeColors.gold.withOpacity(0.9), fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(colors: [LumeColors.gold, Color(0xFFC79340)]),
          boxShadow: [
            BoxShadow(color: LumeColors.gold.withOpacity(0.28), blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _submit,
            child: const Center(
              child: Text(
                'Create Account',
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
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: LumeColors.surfaceBorder)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text('or sign up with', style: TextStyle(color: LumeColors.textSecondary.withOpacity(0.8), fontSize: 12)),
        ),
        Expanded(child: Container(height: 1, color: LumeColors.surfaceBorder)),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, String label) {
    return SizedBox(
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(icon, color: LumeColors.textPrimary, size: 22),
        label: Text(label, style: const TextStyle(color: LumeColors.textPrimary, fontSize: 13.5)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: LumeColors.surfaceBorder),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
