import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_glow_button.dart';
import 'chat_room_screen.dart';

class MatchCelebrationScreen extends StatefulWidget {
  final ProfileModel matchedProfile;
  final String userAvatarUrl;

  const MatchCelebrationScreen({
    super.key,
    required this.matchedProfile,
    this.userAvatarUrl = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=600&q=80',
  });

  @override
  State<MatchCelebrationScreen> createState() => _MatchCelebrationScreenState();
}

class _MatchCelebrationScreenState extends State<MatchCelebrationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  final TextEditingController _icebreakerController = TextEditingController();

  final List<String> _quickIcebreakers = [
    "Hey! That smile is contagious 😊",
    "Looks like our Spotify vibes match 🎵",
    "Coffee or rooftop cocktails first? ☕🍸",
    "Tell me your most spontaneous travel story ✈️",
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeInOut,
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _icebreakerController.dispose();
    super.dispose();
  }

  void _openChat([String? customInitialMessage]) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ChatRoomScreen(profile: widget.matchedProfile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.matchedProfile;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          // Background Gradient Glow
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.2),
                radius: 1.4,
                colors: [
                  Color(0x66FF2A6D),
                  Color(0x33D4A857),
                  AppTheme.darkBackground,
                ],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),

                  // Close button
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Animated Match Title
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              AppTheme.primaryGradient.createShader(bounds),
                          child: const Text(
                            "IT'S A MATCH!",
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "You and ${profile.name.split(' ').first} liked each other",
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Compatibility Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: AppTheme.goldGradient,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accentGold.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                "${profile.compatibilityScore}% Compatibility",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Dual Avatars with Heart Glow
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return SizedBox(
                        height: 160,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // User Avatar (Left)
                            Positioned(
                              left: 30,
                              child: Transform.scale(
                                scale: _pulseAnimation.value,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppTheme.accentGold, width: 3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.accentGold.withOpacity(0.3),
                                        blurRadius: 18,
                                      ),
                                    ],
                                    image: DecorationImage(
                                      image: NetworkImage(widget.userAvatarUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Matched Avatar (Right)
                            Positioned(
                              right: 30,
                              child: Transform.scale(
                                scale: _pulseAnimation.value,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppTheme.primaryRose, width: 3),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryRose.withOpacity(0.4),
                                        blurRadius: 18,
                                      ),
                                    ],
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        profile.photos.isNotEmpty
                                            ? profile.photos.first
                                            : 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=600&q=80',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Center Heart Badge
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: AppTheme.sunsetGradient,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryRose.withOpacity(0.6),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.favorite_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 36),

                  // Quick Icebreakers Section
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Break the ice with ${profile.name.split(' ').first}:",
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Icebreaker Suggestion Chips
                  Column(
                    children: _quickIcebreakers.map((starter) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () => _openChat(starter),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceCard,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withOpacity(0.08)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.chat_bubble_outline_rounded,
                                    size: 16, color: AppTheme.accentGold),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    starter,
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios_rounded,
                                    size: 12, color: Colors.white38),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // Action Buttons
                  AnimatedGlowButton(
                    label: "SEND A MESSAGE",
                    gradient: AppTheme.primaryGradient,
                    onPressed: () => _openChat(),
                  ),

                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "KEEP SWIPING",
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
