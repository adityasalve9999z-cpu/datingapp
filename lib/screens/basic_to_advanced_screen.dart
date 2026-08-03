import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class BasicToAdvancedScreen extends StatefulWidget {
  const BasicToAdvancedScreen({super.key});

  @override
  State<BasicToAdvancedScreen> createState() => _BasicToAdvancedScreenState();
}

class _BasicToAdvancedScreenState extends State<BasicToAdvancedScreen> {
  List<_SkillStep> _steps = const [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTips();
  }

  Future<void> _loadTips() async {
    final tips = await AppApiService.fetchLearningTips();
    if (!mounted) return;
    setState(() {
      _steps = tips.map((tip) {
        final icon = tip['icon'] as String?;
        final color = tip['color'] as String?;
        return _SkillStep(
          title: tip['title']?.toString() ?? 'Level up',
          subtitle: tip['subtitle']?.toString() ?? 'Keep it authentic.',
          icon: _iconForName(icon),
          color: _colorForName(color),
        );
      }).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Basic to Advanced'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppTheme.sunsetGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: const [
                  Icon(Icons.trending_up_rounded, color: Colors.white, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'A simple roadmap from first steps to confident connection-making.',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Your growth path',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: AppTheme.primaryRose))
            else
              ..._steps.map((step) => _buildStepCard(step)).toList(),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Quick tip', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 8),
                  Text(
                    'Keep your profile honest, your answers warm, and your first message short and personal.',
                    style: TextStyle(color: AppTheme.textSecondary, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepCard(_SkillStep step) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: step.color.withOpacity(0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(step.icon, color: step.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text(step.subtitle, style: const TextStyle(color: AppTheme.textSecondary, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

IconData _iconForName(String? name) {
  switch (name) {
    case 'rocket_launch_rounded':
      return Icons.rocket_launch_rounded;
    case 'insights_rounded':
      return Icons.insights_rounded;
    case 'auto_awesome_rounded':
    default:
      return Icons.auto_awesome_rounded;
  }
}

Color _colorForName(String? name) {
  switch (name) {
    case 'accentCyan':
      return AppTheme.accentCyan;
    case 'accentGold':
      return AppTheme.accentGold;
    case 'primaryRose':
    default:
      return AppTheme.primaryRose;
  }
}

class _SkillStep {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _SkillStep({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}
