import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BoostSpotlightScreen extends StatefulWidget {
  const BoostSpotlightScreen({super.key});

  @override
  State<BoostSpotlightScreen> createState() => _BoostSpotlightScreenState();
}

class _BoostSpotlightScreenState extends State<BoostSpotlightScreen>
    with TickerProviderStateMixin {
  bool _isBoostActive = true;
  int _secondsRemaining = 28 * 60 + 45;
  Timer? _timer;
  int _viewsSurge = 42;
  int _likesSurge = 6;
  Timer? _surgeTimer;

  late AnimationController _pulseController;
  late Animation<double> _pulseScale;
  late AnimationController _rotateController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseScale = Tween<double>(begin: 0.95, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        setState(() => _isBoostActive = false);
      }
    });

    _surgeTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted && _isBoostActive) {
        setState(() {
          _viewsSurge += 1 + (_secondsRemaining % 2);
          if (_secondsRemaining % 7 == 0) _likesSurge += 1;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _surgeTimer?.cancel();
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  String get _timerString {
    final mins = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final secs = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  double get _progressPercent {
    return (_secondsRemaining / (30 * 60)).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.rocket_launch_rounded,
                color: Color(0xFFFF512F), size: 20),
            SizedBox(width: 8),
            Text(
              'Spotlight Boost',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // ── Hero Radar Pulse & Timer ──────────────────────────────────────
            Center(
              child: SizedBox(
                height: 280,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer rotating cosmic ring
                    RotationTransition(
                      turns: _rotateController,
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [
                              Colors.transparent,
                              AppTheme.primaryRose.withValues(alpha: 0.3),
                              const Color(0xFFFF512F).withValues(alpha: 0.5),
                              AppTheme.accentGold.withValues(alpha: 0.6),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Pulsing glow circle
                    AnimatedBuilder(
                      animation: _pulseScale,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseScale.value,
                          child: Container(
                            width: 210,
                            height: 210,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF5B247A)
                                  .withValues(alpha: 0.25),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFFF512F)
                                      .withValues(alpha: 0.3),
                                  blurRadius: 30,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    // Circular Progress Arc
                    SizedBox(
                      width: 190,
                      height: 190,
                      child: CircularProgressIndicator(
                        value: _progressPercent,
                        strokeWidth: 8,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFFFF512F),
                        ),
                      ),
                    ),

                    // Core timer display & rocket
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_fire_department_rounded,
                          size: 38,
                          color: Color(0xFFFF512F),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _timerString,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        Text(
                          _isBoostActive ? '10x Multiplier Live' : 'Boost Ended',
                          style: const TextStyle(
                            color: AppTheme.accentGold,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // ── Live Surge Traffic Ticker ─────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppTheme.accentGold.withValues(alpha: 0.35),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSurgeMetric(
                      icon: Icons.visibility_rounded,
                      color: AppTheme.accentCyan,
                      value: '+$_viewsSurge',
                      label: 'Profile Views',
                      sublabel: 'vs normal hour',
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 48,
                    color: Colors.white12,
                  ),
                  Expanded(
                    child: _buildSurgeMetric(
                      icon: Icons.favorite_rounded,
                      color: AppTheme.primaryRose,
                      value: '+$_likesSurge',
                      label: 'Secret Likes',
                      sublabel: 'incoming right now',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Perks & Features Breakdown ────────────────────────────────────
            _buildPerkRow(
              icon: Icons.flash_on_rounded,
              color: AppTheme.accentGold,
              title: 'Top of Everyone\'s Deck',
              description: 'Skip the line and be the 1st profile daters see nearby.',
            ),
            const SizedBox(height: 12),
            _buildPerkRow(
              icon: Icons.bolt_rounded,
              color: const Color(0xFFFF512F),
              title: '10x Higher Match Potential',
              description: 'Daters who boost get an average of 4x more instant matches.',
            ),
            const SizedBox(height: 12),
            _buildPerkRow(
              icon: Icons.auto_awesome_rounded,
              color: AppTheme.accentCyan,
              title: 'Golden Aura Badge',
              description: 'Subtle VIP glow on your photos highlighting your active spark.',
            ),

            const SizedBox(height: 28),

            // ── Action Buttons / Extend ───────────────────────────────────────
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF512F), Color(0xFFDD2476)],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFDD2476).withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _secondsRemaining += 30 * 60;
                    _isBoostActive = true;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('🚀 Spotlight Boost extended by 30 minutes!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle_outline_rounded,
                        color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Extend Boost (+30 Mins)',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSurgeMetric({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
    required String sublabel,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          sublabel,
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildPerkRow({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
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
