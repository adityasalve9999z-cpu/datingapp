import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class PremiumPlansScreen extends StatefulWidget {
  const PremiumPlansScreen({super.key});

  @override
  State<PremiumPlansScreen> createState() => _PremiumPlansScreenState();
}

class _Plan {
  final String id;        // 'free' | 'gold' | 'platinum'
  final String name;
  final String price;
  final String period;
  final Color accentColor;
  final LinearGradient gradient;
  final IconData badgeIcon;
  final List<_Feature> features;
  final bool isPopular;

  const _Plan({
    required this.id,
    required this.name,
    required this.price,
    required this.period,
    required this.accentColor,
    required this.gradient,
    required this.badgeIcon,
    required this.features,
    this.isPopular = false,
  });
}

class _Feature {
  final String label;
  final bool included;
  const _Feature(this.label, {this.included = true});
}

class _PremiumPlansScreenState extends State<PremiumPlansScreen>
    with SingleTickerProviderStateMixin {
  String _selectedPlanId = 'gold';
  bool _isSubmitting = false;
  String? _currentTier;

  late final AnimationController _glowController;
  late final Animation<double> _glowAnim;

  static final List<_Plan> _plans = [
    _Plan(
      id: 'free',
      name: 'Free',
      price: '\$0',
      period: 'forever',
      accentColor: const Color(0xFF8C8C8C),
      gradient: const LinearGradient(
          colors: [Color(0xFF3A3A3A), Color(0xFF2A2A2A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
      badgeIcon: Icons.person_rounded,
      features: const [
        _Feature('Limited daily swipes (20/day)'),
        _Feature('Basic matching'),
        _Feature('Text chat with matches'),
        _Feature('See who liked you', included: false),
        _Feature('Unlimited swipes', included: false),
        _Feature('Rewind last swipe', included: false),
        _Feature('Incognito mode', included: false),
        _Feature('Priority in discovery', included: false),
      ],
    ),
    _Plan(
      id: 'gold',
      name: 'Gold',
      price: '\$19.99',
      period: 'per month',
      accentColor: const Color(0xFFD4A857),
      gradient: const LinearGradient(
          colors: [Color(0xFFD4A857), Color(0xFFB8882E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
      badgeIcon: Icons.star_rounded,
      isPopular: true,
      features: const [
        _Feature('Unlimited swipes'),
        _Feature('See who liked you'),
        _Feature('Rewind last swipe'),
        _Feature('1 free Boost per month'),
        _Feature('Advanced filters'),
        _Feature('Text & voice chat'),
        _Feature('Incognito mode', included: false),
        _Feature('Priority in discovery', included: false),
      ],
    ),
    _Plan(
      id: 'platinum',
      name: 'Platinum',
      price: '\$34.99',
      period: 'per month',
      accentColor: const Color(0xFF7EC8E3),
      gradient: const LinearGradient(
          colors: [Color(0xFF7EC8E3), Color(0xFF4FA8C9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight),
      badgeIcon: Icons.diamond_rounded,
      features: const [
        _Feature('Everything in Gold'),
        _Feature('Unlimited Boosts'),
        _Feature('Incognito mode'),
        _Feature('Priority in discovery'),
        _Feature('Profile verification badge'),
        _Feature('AI-powered match suggestions'),
        _Feature('Super Likes (unlimited)'),
        _Feature('Dedicated support'),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnim =
        CurvedAnimation(parent: _glowController, curve: Curves.easeInOut);
    _loadCurrentTier();
  }

  Future<void> _loadCurrentTier() async {
    final sub = await AppApiService.fetchSubscription();
    if (!mounted) return;
    setState(() {
      _currentTier = sub['tier']?.toString() ?? 'free';
      _selectedPlanId = _currentTier!;
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _subscribe() async {
    if (_selectedPlanId == _currentTier) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You\'re already on the ${_selectedPlanId.toUpperCase()} plan.'),
          backgroundColor: AppTheme.surfaceDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final result = await AppApiService.updateSubscription(_selectedPlanId);
    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      if (result['success'] == true) _currentTier = _selectedPlanId;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message'] as String? ?? 'Done'),
        backgroundColor: result['success'] == true
            ? AppTheme.emeraldGreen
            : AppTheme.primaryCoral,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedPlan =
        _plans.firstWhere((p) => p.id == _selectedPlanId, orElse: () => _plans[1]);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('Choose Your Plan',
            style: TextStyle(fontSize: 17)),
        centerTitle: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              physics: const BouncingScrollPhysics(),
              children: [
                // Hero header
                _buildHeroHeader(),
                const SizedBox(height: 24),

                // Plan cards
                ..._plans.map((plan) => _buildPlanCard(plan)),
                const SizedBox(height: 24),

                // Feature comparison for selected plan
                _buildFeatureList(selectedPlan),
                const SizedBox(height: 24),

                // Legal
                const Text(
                  'Subscriptions auto-renew monthly. Cancel any time in your account settings. '
                  'Prices are in USD and may vary by region.',
                  style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 11,
                      height: 1.5),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 100), // space for bottom CTA
              ],
            ),
          ),

          // Sticky bottom CTA
          _buildBottomCta(selectedPlan),
        ],
      ),
    );
  }

  Widget _buildHeroHeader() {
    return AnimatedBuilder(
      animation: _glowAnim,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: AppTheme.sunsetGradient,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryRose
                    .withOpacity(0.2 + _glowAnim.value * 0.15),
                blurRadius: 20 + _glowAnim.value * 10,
                spreadRadius: 1,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        );
      },
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.bolt_rounded,
                color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Upgrade to Premium',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'See who likes you, swipe without limits, and get discovered faster.',
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12.5,
                      height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(_Plan plan) {
    final isSelected = _selectedPlanId == plan.id;
    final isCurrent = _currentTier == plan.id;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlanId = plan.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected
              ? plan.accentColor.withOpacity(0.08)
              : AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? plan.accentColor : Colors.white12,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: plan.accentColor.withOpacity(0.22),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            // Badge icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: isSelected ? plan.gradient : null,
                color:
                    isSelected ? null : Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(plan.badgeIcon,
                  color: isSelected ? Colors.white : plan.accentColor,
                  size: 22),
            ),
            const SizedBox(width: 14),

            // Plan name + price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        plan.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w600,
                        ),
                      ),
                      if (plan.isPopular) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: plan.gradient,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'POPULAR',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5),
                          ),
                        ),
                      ],
                      if (isCurrent) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.emeraldGreen.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AppTheme.emeraldGreen.withOpacity(0.5)),
                          ),
                          child: const Text(
                            'ACTIVE',
                            style: TextStyle(
                                color: AppTheme.emeraldGreen,
                                fontSize: 9,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${plan.price} ${plan.period}',
                    style: const TextStyle(
                        color: AppTheme.textMuted, fontSize: 12),
                  ),
                ],
              ),
            ),

            // Radio selector
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                key: ValueKey(isSelected),
                color: isSelected ? plan.accentColor : AppTheme.textMuted,
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureList(_Plan plan) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) =>
                    plan.gradient.createShader(bounds),
                child: Text(
                  '${plan.name} includes',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...plan.features.map((f) => _buildFeatureRow(f, plan.accentColor)),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(_Feature feature, Color accent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: feature.included
                  ? accent.withOpacity(0.15)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              feature.included
                  ? Icons.check_rounded
                  : Icons.close_rounded,
              size: 14,
              color: feature.included ? accent : AppTheme.textMuted,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              feature.label,
              style: TextStyle(
                color: feature.included ? Colors.white : AppTheme.textMuted,
                fontSize: 13.5,
                decoration:
                    feature.included ? null : TextDecoration.lineThrough,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCta(_Plan plan) {
    final isCurrentPlan = _selectedPlanId == _currentTier;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          border: const Border(top: BorderSide(color: Colors.white10)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isCurrentPlan) ...[
              Text(
                '${plan.name} Plan · ${plan.price} ${plan.period}',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 10),
            ],
            SizedBox(
              width: double.infinity,
              height: 52,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: isCurrentPlan
                      ? const LinearGradient(
                          colors: [Color(0xFF444444), Color(0xFF333333)])
                      : plan.gradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isCurrentPlan
                      ? []
                      : [
                          BoxShadow(
                            color: plan.accentColor.withOpacity(0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _isSubmitting ? null : _subscribe,
                    child: Center(
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5),
                            )
                          : Text(
                              isCurrentPlan
                                  ? 'Current Plan'
                                  : (plan.id == 'free'
                                      ? 'Downgrade to Free'
                                      : 'Upgrade to ${plan.name}'),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
