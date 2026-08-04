import 'dart:ui';
import 'package:flutter/material.dart';

// ── AppTheme ─────────────────────────────────────────────────────────────────
class AppTheme {
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

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF2A6D), Color(0xFFFF6464)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [Color(0x26FFFFFF), Color(0x05FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// ── Profile Details Screen ──────────────────────────────────────────────────
class ProfileDetailsScreen extends StatefulWidget {
  const ProfileDetailsScreen({super.key});

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  final ScrollController _scrollController = ScrollController();

  // Selected values
  String? _selectedEducation;
  final TextEditingController _professionController = TextEditingController();
  final Set<String> _selectedLifestyle = {};
  String? _selectedLookingFor;

  // Options Data
  final List<String> _educationOptions = [
    "High School",
    "Undergraduate",
    "Postgraduate",
    "Doctorate",
    "Trade / Tech School",
  ];

  final List<Map<String, dynamic>> _lifestyleOptions = [
    {"label": "Non-smoker", "icon": Icons.smoke_free_rounded},
    {"label": "Social Drinker", "icon": Icons.local_bar_rounded},
    {"label": "Active / Gym", "icon": Icons.fitness_center_rounded},
    {"label": "Night Owl", "icon": Icons.bedtime_rounded},
    {"label": "Early Bird", "icon": Icons.wb_sunny_rounded},
    {"label": "Pet Owner", "icon": Icons.pets_rounded},
    {"label": "Vegetarian / Vegan", "icon": Icons.eco_rounded},
  ];

  final List<Map<String, dynamic>> _lookingForOptions = [
    {
      "id": "long_term",
      "title": "Long-term relationship",
      "icon": Icons.favorite_rounded,
      "color": AppTheme.primaryRose
    },
    {
      "id": "short_term",
      "title": "Short-term fun",
      "icon": Icons.local_fire_department_rounded,
      "color": AppTheme.accentGold
    },
    {
      "id": "friends",
      "title": "New friends",
      "icon": Icons.people_alt_rounded,
      "color": AppTheme.accentCyan
    },
    {
      "id": "unsure",
      "title": "Still figuring it out",
      "icon": Icons.explore_rounded,
      "color": AppTheme.primaryPurple
    },
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    _professionController.dispose();
    super.dispose();
  }

  bool get _canSave =>
      _selectedEducation != null &&
      _professionController.text.trim().isNotEmpty &&
      _selectedLifestyle.isNotEmpty &&
      _selectedLookingFor != null;

  @override
  Widget build(BuildContext context) {
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
              'Step 4 of 6',
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
                      'More about you',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Share a few more details to help us find matches that share your vibe.',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 1. EDUCATION
                    _buildSectionHeader(
                        'Education', Icons.school_rounded, AppTheme.accentCyan),
                    const SizedBox(height: 12),
                    _buildDropdownField(
                      hint: 'Select your highest level',
                      value: _selectedEducation,
                      items: _educationOptions,
                      onChanged: (val) =>
                          setState(() => _selectedEducation = val),
                    ),
                    const SizedBox(height: 28),

                    // 2. PROFESSION
                    _buildSectionHeader(
                        'Profession', Icons.work_rounded, AppTheme.accentGold),
                    const SizedBox(height: 12),
                    _buildInputField(
                      controller: _professionController,
                      hint: 'e.g. Software Engineer, Designer, Student',
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 28),

                    // 3. LIFESTYLE
                    _buildSectionHeader('Lifestyle', Icons.style_rounded,
                        AppTheme.emeraldGreen),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _lifestyleOptions.map((item) {
                        final String label = item["label"];
                        final IconData icon = item["icon"];
                        final bool isSelected =
                            _selectedLifestyle.contains(label);

                        return _LifestyleChip(
                          label: label,
                          icon: icon,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedLifestyle.remove(label);
                              } else {
                                _selectedLifestyle.add(label);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),

                    // 4. LOOKING FOR
                    _buildSectionHeader('Looking For', Icons.search_rounded,
                        AppTheme.primaryRose),
                    const SizedBox(height: 12),
                    Column(
                      children: _lookingForOptions.map((opt) {
                        final bool isSelected =
                            _selectedLookingFor == opt["id"];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _LookingForTile(
                            id: opt["id"],
                            title: opt["title"],
                            icon: opt["icon"],
                            accentColor: opt["color"],
                            isSelected: isSelected,
                            onTap: () {
                              setState(() {
                                _selectedLookingFor = opt["id"];
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom CTA
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              child: _ContinueButton(
                enabled: _canSave,
                onPressed: () {
                  if (_canSave) {
                    // Navigate to next screen
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 14)),
          dropdownColor: AppTheme.surfaceDark,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppTheme.textMuted),
          isExpanded: true,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
        onChanged: onChanged,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
        ),
      ),
    );
  }
}

// ── Lifestyle Choice Chip ────────────────────────────────────────────────────
class _LifestyleChip extends StatefulWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _LifestyleChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_LifestyleChip> createState() => _LifestyleChipState();
}

class _LifestyleChipState extends State<_LifestyleChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppTheme.emeraldGreen.withOpacity(0.18)
                : (_isHovered ? AppTheme.surfaceDark : AppTheme.surfaceCard),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.isSelected
                  ? AppTheme.emeraldGreen
                  : (_isHovered ? Colors.white24 : Colors.white12),
              width: widget.isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 16,
                color: widget.isSelected
                    ? AppTheme.emeraldGreen
                    : AppTheme.textMuted,
              ),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  color:
                      widget.isSelected ? Colors.white : AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight:
                      widget.isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Looking For Card Tile ────────────────────────────────────────────────────
class _LookingForTile extends StatefulWidget {
  final String id;
  final String title;
  final IconData icon;
  final Color accentColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _LookingForTile({
    required this.id,
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_LookingForTile> createState() => _LookingForTileState();
}

class _LookingForTileState extends State<_LookingForTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? widget.accentColor.withOpacity(0.12)
                : (_isHovered ? AppTheme.surfaceDark : AppTheme.surfaceCard),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isSelected
                  ? widget.accentColor
                  : (_isHovered ? Colors.white24 : Colors.white12),
              width: widget.isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 20,
                color:
                    widget.isSelected ? widget.accentColor : AppTheme.textMuted,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    color:
                        widget.isSelected ? Colors.white : AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight:
                        widget.isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isSelected
                      ? widget.accentColor
                      : Colors.transparent,
                  border: Border.all(
                    color: widget.isSelected
                        ? widget.accentColor
                        : AppTheme.textMuted,
                    width: 2,
                  ),
                ),
                child: widget.isSelected
                    ? const Icon(Icons.check_rounded,
                        color: Colors.white, size: 14)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Continue Button ──────────────────────────────────────────────────────────
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
