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
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Discovery Filters',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Verified profiles only', style: TextStyle(color: Colors.white)),
              const SizedBox(height: 8),
              const Text('Has bio & audio prompt', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryRose,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text('Apply Filters', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
