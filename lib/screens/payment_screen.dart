import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class GenderSelectionScreen extends StatefulWidget {
  const GenderSelectionScreen({super.key});

  @override
  State<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderOption {
  final String label;
  final IconData icon;
  const _GenderOption(this.label, this.icon);
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen>
    with TickerProviderStateMixin {
  final List<_GenderOption> _options = const [
    _GenderOption('Woman', Icons.female_rounded),
    _GenderOption('Man', Icons.male_rounded),
    _GenderOption('Non-binary', Icons.transgender_rounded),
    _GenderOption('More options', Icons.expand_more_rounded),
  ];

  String? _selected;
  bool _showOnProfile = true;

  // Same elasticOut entrance pop used on Registration/Forgot/Reset/OTP
  // screens' icon marks, so this keeps reading as one connected flow.
  late final AnimationController _entranceController;
  late final Animation<double> _entranceScale;
  late final Animation<double> _entranceFade;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..forward();
    _entranceScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.elasticOut),
    );
    _entranceFade =
        CurvedAnimation(parent: _entranceController, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  void _continue() {
    if (_selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select an option to continue'),
          backgroundColor: AppTheme.surfaceDark,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      return;
    }
    // Fire-and-forget: persist gender to API in background
    AppApiService.saveGender(
      gender: _selected!,
      showOnProfile: _showOnProfile,
    );
    Navigator.pop(
        context, {'gender': _selected, 'showOnProfile': _showOnProfile});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0x33FF2A6D), AppTheme.darkBackground],
            radius: 1.2,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: Colors.white),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        FadeTransition(
                          opacity: _entranceFade,
                          child: ScaleTransition(
                            scale: _entranceScale,
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: AppTheme.sunsetGradient,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          AppTheme.primaryRose.withOpacity(0.4),
                                      blurRadius: 28,
                                      spreadRadius: 3,
                                    ),
                                  ],
                                ),
                                child: const Icon(Icons.person_outline_rounded,
                                    size: 44, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'What\u2019s your gender?',
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'This helps us personalize your matches. You can adjust who sees this later.',
                          style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                              height: 1.5),
                        ),
                        const SizedBox(height: 32),
                        ..._options.map((option) => _buildOptionCard(option)),
                        const SizedBox(height: 12),
                        _buildVisibilityToggle(),
                        const SizedBox(height: 32),
                        _AnimatedGradientButton(
                          label: 'Continue',
                          enabled: _selected != null,
                          onPressed: _continue,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(_GenderOption option) {
    final isSelected = _selected == option.label;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => setState(() => _selected = option.label),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedScale(
            scale: isSelected ? 1.015 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryRose : Colors.white12,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryRose.withOpacity(0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: isSelected ? AppTheme.primaryGradient : null,
                      color: isSelected ? null : Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      option.icon,
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      option.label,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      key: ValueKey(isSelected),
                      color: isSelected ? AppTheme.primaryRose : Colors.white24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVisibilityToggle() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _showOnProfile
              ? AppTheme.accentCyan.withOpacity(0.4)
              : Colors.transparent,
          width: 1.2,
        ),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        secondary: const Icon(Icons.visibility_rounded,
            color: AppTheme.accentCyan, size: 20),
        title: const Text(
          'Show my gender on my profile',
          style: TextStyle(color: AppTheme.textPrimary, fontSize: 13.5),
        ),
        value: _showOnProfile,
        activeColor: AppTheme.accentCyan,
        onChanged: (v) => setState(() => _showOnProfile = v),
      ),
    );
  }
}

/// Same primary gradient button used across the whole auth/onboarding flow:
/// hover-lift on web/desktop, press-in scale everywhere, and a dimmed/
/// disabled state until a selection is made.
class _AnimatedGradientButton extends StatefulWidget {
  final String label;
  final bool enabled;
  final VoidCallback onPressed;
  const _AnimatedGradientButton({
    required this.label,
    required this.enabled,
    required this.onPressed,
  });

  @override
  State<_AnimatedGradientButton> createState() =>
      _AnimatedGradientButtonState();
}

class _AnimatedGradientButtonState extends State<_AnimatedGradientButton> {
  bool _pressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : (_isHovered && widget.enabled ? 1.015 : 1.0),
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: AnimatedOpacity(
            opacity: widget.enabled ? 1.0 : 0.55,
            duration: const Duration(milliseconds: 200),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: widget.enabled
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryRose
                                .withOpacity(_isHovered ? 0.5 : 0.35),
                            blurRadius: _isHovered ? 22 : 16,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    widget.label,
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
      ),
    );
  }
}
