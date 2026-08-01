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

class _HomeScreenState extends State<HomeScreen> {
  int _currentTabIndex = 0;
  List<ProfileModel> _activeProfiles = List.from(mockProfiles);
  final List<ProfileModel> _swipedHistory = [];

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
          setState(() {
            _currentTabIndex = 2; // Jump to Chat tab
          });
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
          // Current Selected Tab View
          IndexedStack(
            index: _currentTabIndex,
            children: screens,
          ),

          // Modern Glassmorphic Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ModernBottomNav(
              currentIndex: _currentTabIndex,
              onTap: (index) {
                setState(() {
                  _currentTabIndex = index;
                });
              },
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
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppTheme.primaryGradient,
              ),
              child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 20),
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
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: AppTheme.textPrimary),
            onPressed: () => _showFilterSheet(context),
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => const _FilterSheet(),
    );
  }
}

// ── Stateful Filter Sheet ────────────────────────────────────────────────────
class _FilterSheet extends StatefulWidget {
  const _FilterSheet();
  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  RangeValues _ageRange = const RangeValues(20, 35);
  double _maxDistance = 25;
  String? _selectedGoal;
  bool _verifiedOnly = true;
  bool _hasAudio = false;
  bool _hasBio = true;

  final List<String> _goals = [
    'Long-term',
    'Short-term',
    'Open to explore',
    'New friends',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
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
                Container(
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
                Container(
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
            SizedBox(
              width: double.infinity,
              height: 54,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(27),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryRose.withOpacity(0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(                  String _selectedHeight = "5'6\"";
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(27)),
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTile(IconData icon, String label, bool value, ValueChanged<bool> onChanged, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
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