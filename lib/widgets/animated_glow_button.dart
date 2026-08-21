import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// 1. BouncingTapWrapper
/// Provides spring compression physics (0.94x scale) and haptic feedback
/// to any interactive widget (cards, chips, icons, custom buttons).
/// ─────────────────────────────────────────────────────────────────────────────
class BouncingTapWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;
  final Duration duration;
  final bool enableHaptics;

  const BouncingTapWrapper({
    super.key,
    required this.child,
    required this.onTap,
    this.scaleFactor = 0.93,
    this.duration = const Duration(milliseconds: 130),
    this.enableHaptics = true,
  });

  @override
  State<BouncingTapWrapper> createState() => _BouncingTapWrapperState();
}

class _BouncingTapWrapperState extends State<BouncingTapWrapper> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) {
    if (widget.onTap == null) return;
    setState(() => _isPressed = true);
    if (widget.enableHaptics) {
      HapticFeedback.lightImpact();
    }
  }

  void _handleTapUp(TapUpDetails _) {
    if (widget.onTap == null) return;
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    if (widget.onTap == null) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? widget.scaleFactor : 1.0,
        duration: widget.duration,
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// 2. AnimatedGlowButton
/// Primary CTA with dynamic gradient shift, continuous shimmer light sweep,
/// breathing ambient glow, and tactile bounce-down on press.
/// ─────────────────────────────────────────────────────────────────────────────
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
  final bool isLoading;

  const AnimatedGlowButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = AppTheme.primaryRose,
    this.gradient,
    this.foregroundColor = Colors.white,
    this.width,
    this.height = 56,
    this.borderRadius,
    this.textStyle,
    this.icon,
    this.isLoading = false,
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
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _shineAnimation = Tween<double>(begin: -1.4, end: 1.4).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.75, curve: Curves.easeInOutSine),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 10.0, end: 24.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

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
    final shimmerColor = Colors.white.withOpacity(0.32);

    return GestureDetector(
      onTapDown: (_) {
        if (!widget.isLoading && widget.onPressed != null) {
          setState(() => _pressed = true);
          HapticFeedback.lightImpact();
        }
      },
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: SizedBox(
          width: widget.width ?? double.infinity,
          height: widget.height,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final shift = _gradientShiftAnimation.value;
              final effectiveGradient = widget.gradient ??
                  LinearGradient(
                    colors: [
                      baseColor,
                      Color.lerp(
                              baseColor, AppTheme.primaryCoral, shift * 0.45) ??
                          baseColor.withOpacity(0.85),
                    ],
                    begin: Alignment(-1.0 + shift * 0.5, -0.3),
                    end: Alignment(1.0 - shift * 0.5, 0.3),
                  );

              final currentBlur = _pressed ? 5.0 : _pulseAnimation.value;
              final currentSpread =
                  _pressed ? 0.0 : _pulseAnimation.value * 0.2;

              return DecoratedBox(
                decoration: BoxDecoration(
                  gradient: effectiveGradient,
                  borderRadius: borderRadius,
                  boxShadow: [
                    BoxShadow(
                      color: baseColor.withOpacity(_pressed ? 0.25 : 0.45),
                      blurRadius: currentBlur,
                      spreadRadius: currentSpread,
                      offset: Offset(0, _pressed ? 2 : 6),
                    ),
                    BoxShadow(
                      color: AppTheme.primaryRose
                          .withOpacity(_pressed ? 0.05 : 0.18),
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
                      if (!widget.isLoading)
                        Positioned.fill(
                          child: Transform.translate(
                            offset: Offset(_shineAnimation.value * 280, 0),
                            child: FractionallySizedBox(
                              widthFactor: 0.35,
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
                      Center(
                        child: widget.isLoading
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      widget.foregroundColor),
                                ),
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (widget.icon != null) ...[
                                    Icon(
                                      widget.icon,
                                      color: widget.foregroundColor,
                                      size: 20,
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

/// ─────────────────────────────────────────────────────────────────────────────
/// 3. AnimatedCircleActionButton
/// Circular Action button designed for Swiping (Pass, Superlike, Like, Boost),
/// Floating Actions, and Call/Audio triggers with color-matched glowing halos.
/// ─────────────────────────────────────────────────────────────────────────────
class AnimatedCircleActionButton extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final Color glowColor;
  final double size;
  final double iconSize;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Gradient? gradient;

  const AnimatedCircleActionButton({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.glowColor,
    required this.onPressed,
    this.size = 56,
    this.iconSize = 26,
    this.backgroundColor,
    this.gradient,
  });

  @override
  State<AnimatedCircleActionButton> createState() =>
      _AnimatedCircleActionButtonState();
}

class _AnimatedCircleActionButtonState extends State<AnimatedCircleActionButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late final AnimationController _hoverPulseController;
  late final Animation<double> _haloAnimation;

  @override
  void initState() {
    super.initState();
    _hoverPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _haloAnimation = Tween<double>(begin: 4.0, end: 14.0).animate(
      CurvedAnimation(
        parent: _hoverPulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _hoverPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.onPressed != null) {
          setState(() => _isPressed = true);
          HapticFeedback.mediumImpact();
        }
      },
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _isPressed ? 0.86 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutBack,
        child: AnimatedBuilder(
          animation: _hoverPulseController,
          builder: (context, child) {
            final haloBlur = _isPressed ? 2.0 : _haloAnimation.value;

            return Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.backgroundColor ?? AppTheme.surfaceCard,
                gradient: widget.gradient,
                border: Border.all(
                  color: widget.glowColor.withOpacity(_isPressed ? 0.8 : 0.35),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.glowColor.withOpacity(_isPressed ? 0.5 : 0.25),
                    blurRadius: haloBlur,
                    spreadRadius: _isPressed ? 1.0 : 2.0,
                    offset: Offset(0, _isPressed ? 1 : 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  widget.icon,
                  color: widget.iconColor,
                  size: widget.iconSize,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// 4. AnimatedOutlinedGlowButton
/// Secondary button with frosted glass aesthetic, neon border, and press bounce.
/// ─────────────────────────────────────────────────────────────────────────────
class AnimatedOutlinedGlowButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color borderColor;
  final Color textColor;
  final IconData? icon;
  final double? width;
  final double height;

  const AnimatedOutlinedGlowButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.borderColor = Colors.white24,
    this.textColor = AppTheme.textPrimary,
    this.icon,
    this.width,
    this.height = 52,
  });

  @override
  State<AnimatedOutlinedGlowButton> createState() =>
      _AnimatedOutlinedGlowButtonState();
}

class _AnimatedOutlinedGlowButtonState
    extends State<AnimatedOutlinedGlowButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.onPressed != null) {
          setState(() => _isPressed = true);
          HapticFeedback.lightImpact();
        }
      },
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOutCubic,
        child: Container(
          width: widget.width ?? double.infinity,
          height: widget.height,
          decoration: BoxDecoration(
            color: _isPressed
                ? widget.borderColor.withOpacity(0.15)
                : AppTheme.surfaceGlass,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _isPressed
                  ? widget.borderColor.withOpacity(0.8)
                  : widget.borderColor,
              width: 1.5,
            ),
            boxShadow: _isPressed
                ? [
                    BoxShadow(
                      color: widget.borderColor.withOpacity(0.25),
                      blurRadius: 8,
                      spreadRadius: 1,
                    )
                  ]
                : [],
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, color: widget.textColor, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(
                  widget.label,
                  style: TextStyle(
                    color: widget.textColor,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
