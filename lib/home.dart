import 'package:flutter/material.dart';
import 'models/profile_model.dart';
import 'theme/app_theme.dart';
import 'widgets/tinder_swipe_deck.dart';
import 'widgets/modern_bottom_nav.dart';
import 'widgets/match_dialog.dart';
import 'screens/likes_screen.dart';
import 'screens/chat_list_screen.dart';
import 'screens/chat_room_screen.dart';
import 'profilescreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _currentTabIndex = 0;
  List<ProfileModel> _activeProfiles = List.from(mockProfiles);
  final List<ProfileModel> _swipedHistory = [];

  // Heartbeat pulse for the logo mark — two quick beats then a rest, like an
  // actual pulse, rather than a generic smooth breathing loop.
  late final AnimationController _heartbeatController;
  late final Animation<double> _heartbeatScale;

  // Cross-fade played whenever the bottom nav switches tabs. IndexedStack is
  // kept underneath so each tab's state (scroll position, form input, swipe
  // deck progress, etc.) is preserved — this only animates the visual swap.
  late final AnimationController _tabFadeController;

  // Rotates the filter (tune) icon open/closed when the discovery filter
  // sheet is shown, so it reads as a toggle rather than a static button.
  late final AnimationController _filterIconController;

  @override
  void initState() {
    super.initState();

    _heartbeatController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat();

    _heartbeatScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.22).chain(CurveTween(curve: Curves.easeOut)), weight: 12),
      TweenSequenceItem(tween: Tween(begin: 1.22, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.16).chain(CurveTween(curve: Curves.easeOut)), weight: 12),
      TweenSequenceItem(tween: Tween(begin: 1.16, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 10),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 56),
    ]).animate(_heartbeatController);

    _tabFadeController = AnimationController(
      duration: const Duration(milliseconds: 260),
      vsync: this,
    )..value = 1.0;

    _filterIconController = AnimationController(
      duration: const Duration(milliseconds: 260),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _heartbeatController.dispose();
    _tabFadeController.dispose();
    _filterIconController.dispose();
    super.dispose();
  }

  void _switchTab(int index) {
    if (index == _currentTabIndex) return;
    setState(() => _currentTabIndex = index);
    _tabFadeController.forward(from: 0);
  }

  void _handleSwipe(ProfileModel profile, SwipeDirection direction) {
    setState(() {
      _swipedHistory.add(profile);
      _activeProfiles.removeWhere((p) => p.id == profile.id);
    });
  }

  void _handleUndo() {
    if (_swipedHistory.isNotEmpty) {
      setState(() {
        final lastSwiped = _swipedHistory.removeLast();
        _activeProfiles.insert(0, lastSwiped);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Swiped profile restored!'),
          duration: Duration(seconds: 1),
          backgroundColor: AppTheme.surfaceCard,
        ),
      );
    }
  }

  void _triggerMatchPopup(ProfileModel profile) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MatchDialog(
        matchedProfile: profile,
        onSendChat: () {
          _switchTab(2); // Jump to Chat tab, animated
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatRoomScreen(profile: profile),
            ),
          );
        },
        onKeepSwiping: () {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildDiscoverTab(),
      const LikesScreen(),
      const ChatListScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          // Current Selected Tab View, cross-faded on switch, state preserved
          FadeTransition(
            opacity: CurvedAnimation(parent: _tabFadeController, curve: Curves.easeOut),
            child: IndexedStack(
              index: _currentTabIndex,
              children: screens,
            ),
          ),

          // Modern Glassmorphic Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ModernBottomNav(
              currentIndex: _currentTabIndex,
              onTap: _switchTab,
              unreadChatCount: 2,
              newMatchCount: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverTab() {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        centerTitle: false,
        title: Row(
          children: [
            AnimatedBuilder(
              animation: _heartbeatScale,
              builder: (context, child) => Transform.scale(
                scale: _heartbeatScale.value,
                child: child,
              ),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.primaryGradient,
                ),
                child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 10),
            ShaderMask(
              shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
              child: const Text(
                'GlowDate',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ],
        ),
        actions: [
          AnimatedBuilder(
            animation: _filterIconController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _filterIconController.value * 0.78, // ~45°
                child: child,
              );
            },
            child: IconButton(
              icon: const Icon(Icons.tune_rounded, color: AppTheme.textPrimary),
              onPressed: () => _showFilterSheet(context),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TinderSwipeDeck(
          profiles: _activeProfiles,
          onSwipe: _handleSwipe,
          onUndo: _handleUndo,
          onMatch: _triggerMatchPopup,
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    _filterIconController.forward();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => const _FilterSheet(),
    ).whenComplete(() => _filterIconController.reverse());
  }
}

// ── Stateful Filter Sheet ────────────────────────────────────────────────────
class _FilterSheet extends StatefulWidget {
  const _FilterSheet();
  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> with SingleTickerProviderStateMixin {
  RangeValues _ageRange = const RangeValues(20, 35);
  double _maxDistance = 25;
  String? _selectedGoal;
  bool _verifiedOnly = true;
  bool _hasAudio = false;
  bool _hasBio = true;

  // Entrance animation for the sheet content — a soft rise + fade rather than
  // relying only on the default modal-sheet slide, so it feels considered.
  late final AnimationController _entranceController;
  late final Animation<double> _entranceFade;
  late final Animation<Offset> _entranceSlide;

  final List<String> _goals = [
    'Long-term',
    'Short-term',
    'Open to explore',
    'New friends',
  ];

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 380),
      vsync: this,
    )..forward();
    _entranceFade = CurvedAnimation(parent: _entranceController, curve: Curves.easeOut);
    _entranceSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _entranceFade,
      child: SlideTransition(
        position: _entranceSlide,
        child: Container(
          decoration: const BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Discovery Filters',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () => setState(() {
                        _ageRange = const RangeValues(20, 35);
                        _maxDistance = 25;
                        _selectedGoal = null;
                        _verifiedOnly = true;
                        _hasAudio = false;
                        _hasBio = true;
                      }),
                      child: const Text('Reset', style: TextStyle(color: AppTheme.primaryRose)),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Age Range
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Age Range', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(scale: animation, child: child),
                      ),
                      child: Container(
                        key: ValueKey('${_ageRange.start}-${_ageRange.end}'),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_ageRange.start.toInt()} – ${_ageRange.end.toInt()} yrs',
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                RangeSlider(
                  values: _ageRange,
                  min: 18,
                  max: 60,
                  divisions: 42,
                  activeColor: AppTheme.primaryRose,
                  inactiveColor: Colors.white12,
                  onChanged: (v) => setState(() => _ageRange = v),
                ),
                const SizedBox(height: 16),

                // Max Distance
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Max Distance', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(scale: animation, child: child),
                      ),
                      child: Container(
                        key: ValueKey(_maxDistance),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceCard,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_maxDistance.toInt()} miles',
                          style: const TextStyle(color: AppTheme.accentCyan, fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _maxDistance,
                  min: 1,
                  max: 100,
                  divisions: 99,
                  activeColor: AppTheme.accentCyan,
                  inactiveColor: Colors.white12,
                  onChanged: (v) => setState(() => _maxDistance = v),
                ),
                const SizedBox(height: 20),

                // Relationship Goals
                const Text('Relationship Goal', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _goals.map((goal) {
                    final isSelected = _selectedGoal == goal;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedGoal = isSelected ? null : goal),
                      child: AnimatedScale(
                        scale: isSelected ? 1.05 : 1.0,
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutBack,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: isSelected ? AppTheme.primaryGradient : null,
                            color: isSelected ? null : AppTheme.surfaceCard,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? Colors.transparent : Colors.white12,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppTheme.primaryRose.withOpacity(0.35),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Text(
                            goal,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppTheme.textSecondary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Lifestyle Toggles
                const Text('Preferences', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                _buildToggleTile(
                  Icons.verified_rounded, 'Verified profiles only',
                  _verifiedOnly, (v) => setState(() => _verifiedOnly = v),
                  AppTheme.accentCyan,
                ),
                _buildToggleTile(
                  Icons.mic_rounded, 'Has audio prompt',
                  _hasAudio, (v) => setState(() => _hasAudio = v),
                  AppTheme.primaryPurple,
                ),
                _buildToggleTile(
                  Icons.short_text_rounded, 'Has bio',
                  _hasBio, (v) => setState(() => _hasBio = v),
                  AppTheme.emeraldGreen,
                ),
                const SizedBox(height: 28),

                // Apply Button
                _AnimatedApplyButton(onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleTile(IconData icon, String label, bool value, ValueChanged<bool> onChanged, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: value ? color.withOpacity(0.4) : Colors.transparent, width: 1.2),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(color: AppTheme.textPrimary))),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: color,
          ),
        ],
      ),
    );
  }
}

/// Apply button with a press-in scale for tactile feedback — a plain
/// ElevatedButton doesn't give this, so it's built on a GestureDetector.
class _AnimatedApplyButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _AnimatedApplyButton({required this.onPressed});

  @override
  State<_AnimatedApplyButton> createState() => _AnimatedApplyButtonState();
}

class _AnimatedApplyButtonState extends State<_AnimatedApplyButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(27),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryRose.withOpacity(_pressed ? 0.2 : 0.4),
                  blurRadius: _pressed ? 8 : 16,
                  offset: Offset(0, _pressed ? 3 : 6),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'Apply Filters',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}