import 'dart:ui';
import 'package:flutter/material.dart';

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

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  final ScrollController _scrollController = ScrollController();

  String? _selectedGenderId;
  bool _showOnProfile = true;

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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
            child: Text(
              'Step 3 of 6',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
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
                    const Text(
                      'How do you identify?',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Choose the option that best describes you. You can update this anytime in settings.',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Gender Option Cards
                    ..._options.map((opt) {
                      final bool isSelected = _selectedGenderId == opt.id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _GenderCardTile(
                          option: opt,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              _selectedGenderId = opt.id;
                            });
                          },
                        ),
                      );
                    }),

                    const SizedBox(height: 12),

                    // Privacy Switch Toggle
                    Container(
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
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom CTA Section
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              child: _ContinueButton(
                enabled: canContinue,
                onPressed: () {
                  if (canContinue) {
                    // Navigate to next onboarding step
                  }
                },
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
    final Color currentColor =
        widget.isSelected ? widget.option.accentColor : AppTheme.surfaceCard;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
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
              // Icon Container
              AnimatedContainer(
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

              // Check indicator
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
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
            ],
          ),
        ),
      ),
    );
  }
}

// ── Continue Button Widget ───────────────────────────────────────────────────
class _ContinueButton extends StatefulWidget {
  final bool enabled;
  final VoidCallback onPressed;

  const _ContinueButton({
    required this.enabled,
    required this.onPressed,
  });

  @override
  State<_ContinueButton> createState() => _ContinueButtonState();
}

class _ContinueButtonState extends State<_ContinueButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor:
          widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown:
            widget.enabled ? (_) => setState(() => _isPressed = true) : null,
        onTapUp:
            widget.enabled ? (_) => setState(() => _isPressed = false) : null,
        onTapCancel:
            widget.enabled ? () => setState(() => _isPressed = false) : null,
        onTap: widget.enabled ? widget.onPressed : null,
        child: AnimatedScale(
          scale:
              _isPressed ? 0.98 : (_isHovered && widget.enabled ? 1.01 : 1.0),
          duration: const Duration(milliseconds: 120),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 56,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: widget.enabled ? AppTheme.primaryGradient : null,
              color: widget.enabled ? null : AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(18),
              boxShadow: widget.enabled
                  ? [
                      BoxShadow(
                        color: AppTheme.primaryRose.withOpacity(0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: Text(
                'Continue',
                style: TextStyle(
                  color: widget.enabled ? Colors.white : AppTheme.textMuted,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
