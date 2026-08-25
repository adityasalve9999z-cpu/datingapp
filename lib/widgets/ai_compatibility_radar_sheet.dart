import 'dart:math';
import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../theme/app_theme.dart';

class AiCompatibilityRadarSheet extends StatelessWidget {
  final ProfileModel profile;

  const AiCompatibilityRadarSheet({
    super.key,
    required this.profile,
  });

  static void show(BuildContext context, {required ProfileModel profile}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AiCompatibilityRadarSheet(profile: profile),
    );
  }

  @override
  Widget build(BuildContext context) {
    const pillars = [
      _PillarScore(name: 'Core Values', score: 0.94, icon: Icons.favorite_rounded),
      _PillarScore(name: 'Banter & Chat', score: 0.91, icon: Icons.chat_rounded),
      _PillarScore(name: 'Lifestyle', score: 0.88, icon: Icons.explore_rounded),
      _PillarScore(name: 'MBTI Synergy', score: 0.95, icon: Icons.psychology_rounded),
      _PillarScore(name: 'Love Language', score: 0.96, icon: Icons.auto_awesome_rounded),
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(
          color: AppTheme.accentGold.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),

          // ── Title & Match Score ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.bolt_rounded,
                              color: AppTheme.accentGold, size: 22),
                          const SizedBox(width: 6),
                          Text(
                            'AI Chemistry Radar',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Synergy dynamics with ${profile.name.split(' ').first}',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    '${profile.compatibilityScore}% Synergy',
                    style: const TextStyle(
                      color: AppTheme.darkBackground,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // ── Visual Radar Chart ──────────────────────────────────────
                  Container(
                    height: 220,
                    width: double.infinity,
                    alignment: Alignment.center,
                    child: CustomPaint(
                      size: const Size(220, 220),
                      painter: _RadarChartPainter(
                        scores: pillars.map((p) => p.score).toList(),
                        labels: pillars.map((p) => p.name).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ── 5 Pillars List ──────────────────────────────────────────
                  ...pillars.map((pillar) {
                    final percentInt = (pillar.score * 100).toInt();
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.07),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(pillar.icon,
                              color: AppTheme.accentGold, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      pillar.name,
                                      style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      '$percentInt%',
                                      style: const TextStyle(
                                        color: AppTheme.accentGold,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: pillar.score,
                                    backgroundColor: Colors.white12,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                      AppTheme.accentGold,
                                    ),
                                    minHeight: 6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 12),

                  // ── AI Wingman Analysis Summary ─────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.accentGold.withValues(alpha: 0.15),
                          AppTheme.surfaceCard,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppTheme.accentGold.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.psychology_rounded,
                                color: AppTheme.accentGold, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'AI WINGMAN INSIGHT',
                              style: TextStyle(
                                color: AppTheme.accentGold,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'You and ${profile.name.split(' ').first} share high MBTI complementarity and spontaneous travel interest. Start the conversation with music or favorite travel memories for maximum reply probability!',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PillarScore {
  final String name;
  final double score;
  final IconData icon;

  const _PillarScore({
    required this.name,
    required this.score,
    required this.icon,
  });
}

class _RadarChartPainter extends CustomPainter {
  final List<double> scores;
  final List<String> labels;

  _RadarChartPainter({required this.scores, required this.labels});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 24;
    final count = scores.length;

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw concentric polygons
    for (int step = 1; step <= 4; step++) {
      final r = radius * (step / 4);
      final path = Path();
      for (int i = 0; i < count; i++) {
        final angle = (i * 2 * pi / count) - (pi / 2);
        final x = center.dx + r * cos(angle);
        final y = center.dy + r * sin(angle);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    // Draw spokes
    for (int i = 0; i < count; i++) {
      final angle = (i * 2 * pi / count) - (pi / 2);
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      canvas.drawLine(center, Offset(x, y), gridPaint);
    }

    // Draw data polygon
    final dataPath = Path();
    for (int i = 0; i < count; i++) {
      final r = radius * scores[i];
      final angle = (i * 2 * pi / count) - (pi / 2);
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      if (i == 0) {
        dataPath.moveTo(x, y);
      } else {
        dataPath.lineTo(x, y);
      }
    }
    dataPath.close();

    final fillPaint = Paint()
      ..color = AppTheme.accentGold.withValues(alpha: 0.28)
      ..style = PaintingStyle.fill;
    canvas.drawPath(dataPath, fillPaint);

    final borderPaint = Paint()
      ..color = AppTheme.accentGold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawPath(dataPath, borderPaint);

    // Draw vertex dots
    final dotPaint = Paint()..color = Colors.white;
    for (int i = 0; i < count; i++) {
      final r = radius * scores[i];
      final angle = (i * 2 * pi / count) - (pi / 2);
      final x = center.dx + r * cos(angle);
      final y = center.dy + r * sin(angle);
      canvas.drawCircle(Offset(x, y), 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
