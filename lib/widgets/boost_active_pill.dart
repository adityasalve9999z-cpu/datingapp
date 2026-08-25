import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/boost_spotlight_screen.dart';

class BoostActivePill extends StatefulWidget {
  final int initialMinutes;
  final VoidCallback? onExpired;

  const BoostActivePill({
    super.key,
    this.initialMinutes = 30,
    this.onExpired,
  });

  @override
  State<BoostActivePill> createState() => _BoostActivePillState();
}

class _BoostActivePillState extends State<BoostActivePill>
    with SingleTickerProviderStateMixin {
  late int _secondsRemaining;
  Timer? _timer;
  int _viewerSurge = 28;
  Timer? _surgeTimer;

  late AnimationController _glowController;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.initialMinutes * 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        widget.onExpired?.call();
      }
    });

    _surgeTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) {
        setState(() {
          _viewerSurge += (1 + (_secondsRemaining % 3));
        });
      }
    });

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.3, end: 0.9).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _surgeTimer?.cancel();
    _glowController.dispose();
    super.dispose();
  }

  String get _timeFormatted {
    final mins = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final secs = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const BoostSpotlightScreen(),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF5B247A),
                  Color(0xFF1B1464),
                  Color(0xFF662D8C),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFE07A6B)
                    .withValues(alpha: _glowAnim.value),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFED1E79)
                      .withValues(alpha: _glowAnim.value * 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF512F), Color(0xFFDD2476)],
                    ),
                  ),
                  child: const Icon(
                    Icons.rocket_launch_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'SPOTLIGHT 10X ACTIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _timeFormatted,
                            style: const TextStyle(
                              color: AppTheme.accentGold,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '⚡ +$_viewerSurge people viewing your profile now',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
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
    );
  }
}
