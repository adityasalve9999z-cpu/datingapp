import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'home.dart';

/// Wraps the logo mark with a mouse-hover reaction (scale + brighter glow),
/// same MouseRegion + AnimatedContainer pattern used across the app's other
/// screens. Only fires with an actual pointer (web/desktop) — harmless no-op
/// on touch devices, which have no hover concept.
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
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: _isHovered ? (Matrix4.identity()..scale(1.06)) : Matrix4.identity(),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryRose.withOpacity(_isHovered ? 0.75 : 0.5),
              blurRadius: _isHovered ? 46 : 35,
              spreadRadius: _isHovered ? 8 : 5,
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
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  // Heartbeat pulse for the logo mark once the entrance animation settles —
  // two quick beats then a rest, matching the rhythm used on the home and
  // settings screens, rather than a generic smooth breathing loop.
  late final AnimationController _heartbeatController;
  late final Animation<double> _heartbeatScale;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.elasticOut),
    );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _heartbeatController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    _heartbeatScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.14).chain(CurveTween(curve: Curves.easeOut)), weight: 12),
      TweenSequenceItem(tween: Tween(begin: 1.14, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.08).chain(CurveTween(curve: Curves.easeOut)), weight: 12),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 10),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 56),
    ]).animate(_heartbeatController);

    _animController.forward().whenComplete(() {
      // Start the ambient heartbeat only after the entrance pop finishes,
      // so the two animations don't fight each other on the same scale value.
      if (mounted) _heartbeatController.repeat();
    });

    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _heartbeatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Color(0x33FF2A6D),
              AppTheme.darkBackground,
            ],
            radius: 1.2,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([_animController, _heartbeatController]),
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnim,
                child: ScaleTransition(
                  scale: _scaleAnim,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.scale(
                        scale: _heartbeatScale.value,
                        child: _HoverGlow(
                          child: Container(
                            padding: const EdgeInsets.all(28),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppTheme.sunsetGradient,
                            ),
                            child: const Icon(
                              Icons.favorite_rounded,
                              size: 70,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      ShaderMask(
                        shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                        child: const Text(
                          'GlowDate',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Where Meaningful Connections Spark',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppTheme.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Animated Glow Loading Line
                      SizedBox(
                        width: 140,
                        height: 4,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: const LinearProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryRose),
                            backgroundColor: Color(0x33FF2A6D),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Loading your experience...',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}