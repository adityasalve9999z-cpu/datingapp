import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'theme/app_theme.dart';

/// Hover-scale wrapper (web/desktop hover; no-op on touch)
class _HoverGlow extends StatefulWidget {
  final Widget child;
  const _HoverGlow({required this.child});

  @override
  State<_HoverGlow> createState() => _HoverGlowState();
}

class _HoverGlowState extends State<_HoverGlow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit:  (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: _isHovered
            ? (Matrix4.identity()..scale(1.06))
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryRose.withOpacity(_isHovered ? 0.70 : 0.40),
              blurRadius: _isHovered ? 50 : 32,
              spreadRadius: _isHovered ? 10 : 6,
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;
  late final Animation<double> _glowRadius;

  Timer? _navTimer;

  @override
  void initState() {
    super.initState();

    // Entry pop animation
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scaleAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeIn),
    );

    // Subtle heartbeat pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    _pulseScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.10).chain(CurveTween(curve: Curves.easeOut)), weight: 14),
      TweenSequenceItem(tween: Tween(begin: 1.10, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 12),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.06).chain(CurveTween(curve: Curves.easeOut)), weight: 12),
      TweenSequenceItem(tween: Tween(begin: 1.06, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 10),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 52),
    ]).animate(_pulseController);

    _glowRadius = Tween<double>(begin: 1.1, end: 1.6).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    _entryController.forward().whenComplete(() {
      if (mounted) _pulseController.repeat();
    });

    _navTimer = Timer(const Duration(milliseconds: 2400), () {
      if (!mounted) return;
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.isAuthenticated) {
        context.go('/home');
      } else {
        context.go('/login');
      }
    });
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _entryController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: AnimatedBuilder(
        animation: Listenable.merge([_entryController, _pulseController]),
        builder: (context, _) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: const [
                  Color(0x40006FEE), // HeroUI primary blue glow
                  AppTheme.darkBackground,
                ],
                radius: _glowRadius.value,
              ),
            ),
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ── Logo Mark ─────────────────────────────────────────
                      Transform.scale(
                        scale: _pulseScale.value,
                        child: _HoverGlow(
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppTheme.sunsetGradient,
                            ),
                            child: const Icon(
                              Icons.favorite_rounded,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── App Name ──────────────────────────────────────────
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            AppTheme.primaryGradient.createShader(bounds),
                        child: const Text(
                          'GlowDate',
                          style: TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Where Meaningful Connections Spark',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // ── Progress Indicator ────────────────────────────────
                      SizedBox(
                        width: 120,
                        height: 3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: const LinearProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryRose),
                            backgroundColor: Color(0x20006FEE),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Loading your experience...',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}