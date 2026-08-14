import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AnimatedGlowButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Gradient? gradient;
  final Color foregroundColor;
  final double? width;
  final double? height;
  final BorderRadiusGeometry? borderRadius;
  final TextStyle? textStyle;
  final IconData? icon;

  const AnimatedGlowButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = AppTheme.accentGold,
    this.gradient,
    this.foregroundColor = AppTheme.darkBackground,
    this.width,
    this.height = 56,
    this.borderRadius,
    this.textStyle,
    this.icon,
  });

  @override
  State<AnimatedGlowButton> createState() => _AnimatedGlowButtonState();
}

class _AnimatedGlowButtonState extends State<AnimatedGlowButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;
  late final AnimationController _controller;
  late final Animation<double> _shineAnimation;
  late final Animation<double> _pulseAnimation;
  late final Animation<double> _gradientShiftAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    // Shine sweep across the button
    _shineAnimation = Tween<double>(begin: -1.2, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeInOutSine),
      ),
    );

    // Breathing glow aura expansion
    _pulseAnimation = Tween<double>(begin: 12.0, end: 26.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    // Subtle gradient alignment shift for a living color effect
    _gradientShiftAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(20);
    final baseColor = widget.backgroundColor;
    final shimmerColor = Colors.white.withOpacity(0.35);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: SizedBox(
          width: widget.width ?? double.infinity,
          height: widget.height,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              // Dynamic gradient alignment based on animation progress
              final shift = _gradientShiftAnimation.value;
              final effectiveGradient = widget.gradient ??
                  LinearGradient(
                    colors: [
                      baseColor,
                      Color.lerp(
                              baseColor, AppTheme.primaryRose, shift * 0.4) ??
                          baseColor.withOpacity(0.85),
                    ],
                    begin: Alignment(-1.0 + shift, -0.3),
                    end: Alignment(1.0 - shift, 0.3),
                  );

              final currentBlur = _pressed ? 6.0 : _pulseAnimation.value;
              final currentSpread =
                  _pressed ? 0.0 : _pulseAnimation.value * 0.25;

              return DecoratedBox(
                decoration: BoxDecoration(
                  gradient: effectiveGradient,
                  borderRadius: borderRadius,
                  boxShadow: [
                    // Primary pulsing glow shadow
                    BoxShadow(
                      color: baseColor.withOpacity(_pressed ? 0.2 : 0.4),
                      blurRadius: currentBlur,
                      spreadRadius: currentSpread,
                      offset: Offset(0, _pressed ? 2 : 6),
                    ),
                    // Secondary soft ambient aura
                    BoxShadow(
                      color: AppTheme.primaryRose
                          .withOpacity(_pressed ? 0.05 : 0.15),
                      blurRadius: currentBlur * 1.5,
                      spreadRadius: currentSpread * 1.5,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: borderRadius,
                  child: Stack(
                    children: [
                      // Moving light shine sweep effect
                      Positioned.fill(
                        child: Transform.translate(
                          offset: Offset(_shineAnimation.value * 240, 0),
                          child: FractionallySizedBox(
                            widthFactor: 0.4,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    shimmerColor,
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Button Label & Icon Content
                      Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (widget.icon != null) ...[
                              Icon(
                                widget.icon,
                                color: widget.foregroundColor,
                                size: 19,
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              widget.label,
                              style: widget.textStyle ??
                                  TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                    color: widget.foregroundColor,
                                  ),
                            ),
                          ],
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
