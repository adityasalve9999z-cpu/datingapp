import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/animated_glow_button.dart';

// ── AppTheme ─────────────────────────────────────────────────────────────────
class AppTheme {
  // Brand Color Palette
  static const Color darkBackground = Color(0xFF0D0C13);
  static const Color surfaceDark = Color(0xFF181622);
  static const Color surfaceCard = Color(0xFF221F30);
  static const Color surfaceGlass = Color(0x33262335);

  static const Color primaryRose = Color(0xFFFF2A6D);
  static const Color primaryCoral = Color(0xFFFF6464);
  static const Color primaryPurple = Color(0xFF8B5CF6);
  static const Color accentCyan = Color(0xFF05D5E4);
  static const Color accentGold = Color(0xFFFFB800);
  static const Color emeraldGreen = Color(0xFF10B981);

  static const Color textPrimary = Color(0xFFF9FAFB);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);

  // Gradient Presets
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF2A6D), Color(0xFFFF6464)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFFF2A6D), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardOverlayGradient = LinearGradient(
    colors: [
      Colors.transparent,
      Color(0x66000000),
      Color(0xF10B0914),
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0x26FFFFFF),
      Color(0x05FFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// ── Gender Model ─────────────────────────────────────────────────────────────
class _GenderOption {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;

  const _GenderOption({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });
}

// ── Main Screen Widget ───────────────────────────────────────────────────────
class GenderSelectionScreen extends StatefulWidget {
  const GenderSelectionScreen({super.key});

  @override
  State<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  String? _selectedGenderId;
  bool _showOnProfile = true;
  bool _isSubmitting = false;

  Future<void> _handleSave() async {
    if (_selectedGenderId == null || _isSubmitting) return;
    setState(() => _isSubmitting = true);

    final selected = _options.firstWhere(
      (opt) => opt.id == _selectedGenderId,
      orElse: () => _options.first,
    );

    final result = await AppApiService.saveGender(
      gender: selected.title,
      showOnProfile: _showOnProfile,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message'] as String? ?? 'Gender saved!'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  static const int _currentStep = 3;
  static const int _totalSteps = 6;

  // Staggered entrance for header + cards — each item fades/slides in with
  // an increasing delay so the list feels like it's arriving in sequence,
  // not popping in all at once.
  late final AnimationController _entranceController;

  // Nudge shake on the Continue button when tapped while disabled, so
  // "nothing happened" reads as a deliberate "not yet" rather than a
  // silently broken button.
  late final AnimationController _shakeController;
  late final Animation<double> _shakeOffset;

  final List<_GenderOption> _options = const [
    _GenderOption(
      id: 'woman',
      title: 'Woman',
      subtitle: 'Identify as female',
      icon: Icons.female_rounded,
      accentColor: AppTheme.primaryRose,
    ),
    _GenderOption(
      id: 'man',
      title: 'Man',
      subtitle: 'Identify as male',
      icon: Icons.male_rounded,
      accentColor: AppTheme.accentCyan,
    ),
    _GenderOption(
      id: 'nonbinary',
      title: 'Non-Binary',
      subtitle: 'Identify outside the binary',
      icon: Icons.transgender_rounded,
      accentColor: AppTheme.primaryPurple,
    ),
    _GenderOption(
      id: 'other',
      title: 'More Options',
      subtitle: 'Specify custom identity',
      icon: Icons.more_horiz_rounded,
      accentColor: AppTheme.accentGold,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..forward();

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _shakeOffset = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -5.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -5.0, end: 0.0), weight: 1),
    ]).animate(
        CurvedAnimation(parent: _shakeController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _entranceController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  /// Returns a 0..1 delayed interval for the [index]-th staggered item, so
  /// each item's fade/slide starts a little after the previous one.
  Animation<double> _staggerFor(int index,
      {int count = 6, double spread = 0.5}) {
    final start = (index / count) * spread;
    final end = (start + (1 - spread)).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _entranceController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
  }

  void _handleDisabledTap() {
    _shakeController.forward(from: 0);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Select an option to continue'),
        backgroundColor: AppTheme.surfaceDark,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1400),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canContinue = _selectedGenderId != null;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textPrimary, size: 20),
          onPressed: () => Navigator.maybePop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20, top: 16),
            child: FadeTransition(
              opacity: CurvedAnimation(
                  parent: _entranceController, curve: const Interval(0, 0.4)),
              child: const Text(
                'Step $_currentStep of $_totalSteps',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Step Progress Bar — glowing active segment, matches the visual
            // language used on the rest of the onboarding flow.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              child: Row(
                children: List.generate(_totalSteps, (idx) {
                  final isActive = idx < _currentStep;
                  final isCurrent = idx == _currentStep - 1;
                  return Expanded(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: isActive ? 1 : 0),
                      duration: Duration(milliseconds: 400 + idx * 80),
                      curve: Curves.easeOut,
                      builder: (context, value, _) {
                        return Container(
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            gradient:
                                value > 0 ? AppTheme.primaryGradient : null,
                            color: value > 0 ? null : Colors.white12,
                            borderRadius: BorderRadius.circular(2),
                            boxShadow: isCurrent
                                ? [
                                    BoxShadow(
                                      color: AppTheme.primaryRose
                                          .withOpacity(0.6 * value),
                                      blurRadius: 6,
                                      spreadRadius: 0.5,
                                    ),
                                  ]
                                : [],
                          ),
                        );
                      },
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                thickness: 6.0,
                radius: const Radius.circular(10),
                child: ListView(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    FadeTransition(
                      opacity: _staggerFor(0, count: _options.length + 2),
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.15),
                          end: Offset.zero,
                        ).animate(_staggerFor(0, count: _options.length + 2)),
                        child: const Text(
                          'How do you identify?',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FadeTransition(
                      opacity: _staggerFor(1, count: _options.length + 2),
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.15),
                          end: Offset.zero,
                        ).animate(_staggerFor(1, count: _options.length + 2)),
                        child: const Text(
                          'Choose the option that best describes you. You can update this anytime in settings.',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Gender Option Cards — staggered entrance, each starting
                    // a little later than the one before it.
                    ..._options.asMap().entries.map((entry) {
                      final i = entry.key;
                      final opt = entry.value;
                      final isSelected = _selectedGenderId == opt.id;
                      final stagger =
                          _staggerFor(i + 2, count: _options.length + 2);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: FadeTransition(
                          opacity: stagger,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.2),
                              end: Offset.zero,
                            ).animate(stagger),
                            child: _GenderCardTile(
                              option: opt,
                              isSelected: isSelected,
                              onTap: () {
                                setState(() {
                                  _selectedGenderId = opt.id;
                                });
                              },
                            ),
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 12),

                    // Privacy Switch Toggle
                    FadeTransition(
                      opacity: _staggerFor(_options.length + 1,
                          count: _options.length + 2),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceCard,
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: SwitchListTile(
                          value: _showOnProfile,
                          activeColor: AppTheme.primaryRose,
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Show gender on my profile',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: const Text(
                            'Visible to potential matches',
                            style: TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 12,
                            ),
                          ),
                          onChanged: (val) {
                            setState(() {
                              _showOnProfile = val;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom CTA Section
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              child: AnimatedBuilder(
                animation: _shakeOffset,
                builder: (context, child) => Transform.translate(
                  offset: Offset(_shakeOffset.value, 0),
                  child: child,
                ),
                child: _ContinueButton(
                  enabled: canContinue && !_isSubmitting,
                  onPressed: canContinue && !_isSubmitting ? _handleSave : () {},
                  onDisabledTap: _handleDisabledTap,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Gender Card Tile Widget ──────────────────────────────────────────────────
class _GenderCardTile extends StatefulWidget {
  final _GenderOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderCardTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_GenderCardTile> createState() => _GenderCardTileState();
}

class _GenderCardTileState extends State<_GenderCardTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          // Selection gets a slightly bouncier feel than hover, so the two
          // states read as different in weight, not just in color.
          scale: widget.isSelected ? 1.02 : (_isHovered ? 1.01 : 1.0),
          duration: const Duration(milliseconds: 220),
          curve: widget.isSelected ? Curves.elasticOut : Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? widget.option.accentColor.withOpacity(0.12)
                  : (_isHovered ? AppTheme.surfaceDark : AppTheme.surfaceCard),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: widget.isSelected
                    ? widget.option.accentColor
                    : (_isHovered ? Colors.white24 : Colors.white12),
                width: widget.isSelected ? 2.0 : 1.0,
              ),
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: widget.option.accentColor.withOpacity(0.25),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              children: [
                // Icon Container — pops with an elasticOut bounce on select
                // instead of just cross-fading color.
                AnimatedScale(
                  scale: widget.isSelected ? 1.12 : 1.0,
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.elasticOut,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? widget.option.accentColor
                          : widget.option.accentColor.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.option.icon,
                      color: widget.isSelected
                          ? Colors.white
                          : widget.option.accentColor,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Title and Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.option.title,
                        style: TextStyle(
                          color: widget.isSelected
                              ? Colors.white
                              : AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.option.subtitle,
                        style: TextStyle(
                          color: widget.isSelected
                              ? Colors.white.withOpacity(0.8)
                              : AppTheme.textMuted,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Check indicator — scale + rotate swap instead of an
                // instant appear, so the confirmation reads as a deliberate
                // "yes" rather than a snap.
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) => ScaleTransition(
                    scale: animation,
                    child: RotationTransition(
                      turns: Tween<double>(begin: 0.75, end: 1.0)
                          .animate(animation),
                      child: child,
                    ),
                  ),
                  child: Container(
                    key: ValueKey(widget.isSelected),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isSelected
                          ? widget.option.accentColor
                          : Colors.transparent,
                      border: Border.all(
                        color: widget.isSelected
                            ? widget.option.accentColor
                            : AppTheme.textMuted,
                        width: 2,
                      ),
                    ),
                    child: widget.isSelected
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 16)
                        : null,
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

class _ContinueButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onPressed;
  final VoidCallback? onDisabledTap;

  const _ContinueButton({
    required this.enabled,
    required this.onPressed,
    this.onDisabledTap,
  });

  @override
  Widget build(BuildContext context) {
    if (enabled) {
      return AnimatedGlowButton(
        label: 'Continue',
        backgroundColor: AppTheme.primaryRose,
        gradient: AppTheme.primaryGradient,
        icon: Icons.arrow_forward_rounded,
        onPressed: onPressed,
      );
    }

    return GestureDetector(
      onTap: onDisabledTap,
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: const Center(
          child: Text(
            'Continue',
            style: TextStyle(
              color: AppTheme.textMuted,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
