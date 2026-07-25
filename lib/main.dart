import 'package:flutter/material.dart';
import 'home.dart';
import 'profilescreen.dart';

void main() => runApp(const GlowDateApp());

class GlowDateApp extends StatelessWidget {
  const GlowDateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GlowDate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pinkAccent,
        ),
      ),
      home: const SplashScreenAuth(),
      routes: {
        '/login': (context) => const LoginScreenAuth(),
        '/signup': (context) => const SignupScreenAuth(),
        '/home': (context) => const MainNavigationScreen(),
      },
    );
  }
}

// Splash Screen
class SplashScreenAuth extends StatefulWidget {
  const SplashScreenAuth({super.key});

  @override
  State<SplashScreenAuth> createState() => _SplashScreenAuthState();
}

class _SplashScreenAuthState extends State<SplashScreenAuth> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: AlwaysStoppedAnimation(1.0),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.pinkAccent, Colors.orangeAccent],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '💝',
                    style: TextStyle(fontSize: 60),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'GlowDate',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.pinkAccent,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Find your perfect match',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Login Screen
class LoginScreenAuth extends StatefulWidget {
  const LoginScreenAuth({super.key});

  @override
  State<LoginScreenAuth> createState() => _LoginScreenAuthState();
}

class _LoginScreenAuthState extends State<LoginScreenAuth> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Login',
          style: TextStyle(color: Colors.pinkAccent),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Welcome Back',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Login to find your perfect match',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.email, color: Colors.pinkAccent),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.lock, color: Colors.pinkAccent),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
                child: const Text(
                  "Don't have an account? Sign up",
                  style: TextStyle(color: Colors.pinkAccent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Signup Screen
class SignupScreenAuth extends StatefulWidget {
  const SignupScreenAuth({super.key});

  @override
  State<SignupScreenAuth> createState() => _SignupScreenAuthState();
}

class _SignupScreenAuthState extends State<SignupScreenAuth> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Sign Up',
          style: TextStyle(color: Colors.pinkAccent),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Create Account',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Join our community and find love',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.person, color: Colors.pinkAccent),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.email, color: Colors.pinkAccent),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.lock, color: Colors.pinkAccent),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Already have an account? Login',
                  style: TextStyle(color: Colors.pinkAccent),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Main Navigation Screen with Bottom Navigation
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeScreen(),
      const DiscoverScreen(),
      const MessagesScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.pinkAccent.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: Colors.pinkAccent,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: 'Discover',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// Discover Screen
class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Discover',
          style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search profiles...',
                prefixIcon: const Icon(Icons.search, color: Colors.pinkAccent),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Explore Profiles',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: 8,
              itemBuilder: (context, index) {
                return _buildProfilePreview(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePreview(int index) {
    final names = ['Emma', 'Sarah', 'Jessica', 'Anna', 'Maria', 'Laura', 'Sophie', 'Rachel'];
    final ages = [24, 26, 25, 23, 27, 25, 24, 26];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.pinkAccent.withOpacity(0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.4),
                ],
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                'https://images.unsplash.com/photo-${1494790108377 + index * 10}?auto=format&fit=crop&w=300&q=80',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.person),
                    ),
                  );
                },
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${names[index]}, ${ages[index]}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Messages Screen
class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF2F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Messages',
          style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          final names = ['Maya', 'Sophie', 'Emma', 'Sarah', 'Jessica'];
          final messages = ['Hey! How are you?', 'That sounds fun!', 'Haha, yes!', 'When are you free?', 'Talk soon!'];
          final times = ['2m ago', '5m ago', '1h ago', '2h ago', '3h ago'];

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(
                'https://images.unsplash.com/photo-${1494790108377 + index * 10}?auto=format&fit=crop&w=200&q=80',
              ),
            ),
            title: Text(
              names[index],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              messages[index],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              times[index],
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          );
        },
      ),
    );
  }
}
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _agreedToTerms = false;
  double _passwordStrength = 0;

  // Heartbeat pulse for the signature spark icon — two quick beats then rest,
  // like an actual pulse, not a generic sine "breathing" loop.
  late final AnimationController _heartbeatController;
  late final Animation<double> _heartbeatScale;

  // Ambient floating hearts drifting up behind the content — a single
  // orchestrated love-themed moment, kept subtle so it doesn't fight the form.
  late final AnimationController _driftController;
  final List<_FloatingHeart> _hearts = List.generate(7, (i) => _FloatingHeart(seed: i));

  @override
  void initState() {
    super.initState();

    _heartbeatController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat();

    _heartbeatScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.22).chain(CurveTween(curve: Curves.easeOut)), weight: 12),
      TweenSequenceItem(tween: Tween(begin: 1.22, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.16).chain(CurveTween(curve: Curves.easeOut)), weight: 12),
      TweenSequenceItem(tween: Tween(begin: 1.16, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 10),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 56),
    ]).animate(_heartbeatController);

    _driftController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _heartbeatController.dispose();
    _driftController.dispose();
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
        child: Stack(
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _driftController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _FloatingHeartsPainter(
                      hearts: _hearts,
                      progress: _driftController.value,
                    ),
                  );
                },
              ),
            ),
            SafeArea(
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
          ],
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
            child: AnimatedBuilder(
              animation: _heartbeatScale,
              builder: (context, child) => Transform.scale(
                scale: _heartbeatScale.value,
                child: child,
              ),
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
                child: const Icon(Icons.favorite_rounded, size: 12, color: LumeColors.bg),
              ),
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

/// A single ambient heart with a randomized horizontal lane, size, speed
/// offset, and drift — so the loop never feels mechanical or synced.
class _FloatingHeart {
  final double lane;       // 0..1 horizontal position
  final double size;
  final double speed;      // relative speed multiplier
  final double phaseOffset; // 0..1 stagger so hearts don't move in lockstep
  final double swayAmount;
  final double opacity;
  final bool isGold;

  _FloatingHeart({required int seed})
      : lane = _rand(seed, 1),
        size = 10 + _rand(seed, 2) * 14,
        speed = 0.6 + _rand(seed, 3) * 0.8,
        phaseOffset = _rand(seed, 4),
        swayAmount = 10 + _rand(seed, 5) * 18,
        opacity = 0.10 + _rand(seed, 6) * 0.16,
        isGold = _rand(seed, 7) > 0.5;

  static double _rand(int seed, int salt) {
    final r = Random(seed * 97 + salt * 131);
    return r.nextDouble();
  }
}

class _FloatingHeartsPainter extends CustomPainter {
  final List<_FloatingHeart> hearts;
  final double progress; // 0..1 looping

  _FloatingHeartsPainter({required this.hearts, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final heart in hearts) {
      final t = (progress * heart.speed + heart.phaseOffset) % 1.0;
      // Drift from bottom to top, fading in and out at the ends.
      final dy = size.height * (1.0 - t) - size.height * 0.15;
      final sway = sin((t + heart.phaseOffset) * 2 * pi) * heart.swayAmount;
      final dx = heart.lane * size.width + sway;

      double fade = 1.0;
      if (t < 0.12) fade = t / 0.12;
      if (t > 0.85) fade = (1.0 - t) / 0.15;
      fade = fade.clamp(0.0, 1.0);

      final paint = Paint()
        ..color = (heart.isGold ? LumeColors.gold : LumeColors.blush)
            .withOpacity(heart.opacity * fade)
        ..style = PaintingStyle.fill;

      _drawHeart(canvas, Offset(dx, dy), heart.size, paint);
    }
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    final w = size;
    final h = size;
    path.moveTo(center.dx, center.dy + h * 0.32);
    path.cubicTo(
      center.dx - w * 0.7, center.dy - h * 0.25,
      center.dx - w * 0.3, center.dy - h * 0.75,
      center.dx, center.dy - h * 0.28,
    );
    path.cubicTo(
      center.dx + w * 0.3, center.dy - h * 0.75,
      center.dx + w * 0.7, center.dy - h * 0.25,
      center.dx, center.dy + h * 0.32,
    );
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _FloatingHeartsPainter oldDelegate) => true;
}