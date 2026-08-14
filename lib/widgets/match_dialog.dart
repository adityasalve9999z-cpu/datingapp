import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../theme/app_theme.dart';
import 'animated_glow_button.dart'; // Assuming your AnimatedGlowButton is imported here

class MatchDialog extends StatefulWidget {
  final ProfileModel matchedProfile;
  final VoidCallback onSendChat;
  final VoidCallback onKeepSwiping;

  const MatchDialog({
    super.key,
    required this.matchedProfile,
    required this.onSendChat,
    required this.onKeepSwiping,
  });

  @override
  State<MatchDialog> createState() => _MatchDialogState();
}

class _MatchDialogState extends State<MatchDialog> {
  // A list of dynamic icebreakers tailored for the match
  late final List<String> _icebreakers;
  int _currentIcebreakerIndex = 0;

  @override
  void initState() {
    super.initState();
    final firstName = widget.matchedProfile.name.split(' ').first;
    _icebreakers = [
      "Hey $firstName! What's your go-to weekend adventure? 🌲",
      "If we had to cook dinner together tonight, what are we making? 🍝",
      "Two truths and a lie: go! Or just tell me your favorite coffee spot ☕",
      "Hey $firstName! Spot on taste in profiles ✨ What song is on repeat for you lately?",
    ];
  }

  void _shuffleIcebreaker() {
    setState(() {
      _currentIcebreakerIndex =
          (_currentIcebreakerIndex + 1) % _icebreakers.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    const userAvatar =
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80';
    final firstName = widget.matchedProfile.name.split(' ').first;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xF0181424), Color(0xF00D0B14)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(36),
              border: Border.all(
                  color: AppTheme.primaryRose.withOpacity(0.4), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryRose.withOpacity(0.3),
                  blurRadius: 40,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Floating Sparkle Badge
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.sunsetGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryRose.withOpacity(0.5),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.favorite_rounded,
                        color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 16),

                  // Match Headline
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppTheme.primaryGradient.createShader(bounds),
                    child: const Text(
                      "IT'S A MATCH!",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'You and ${widget.matchedProfile.name} have liked each other!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Dual Overlapping Avatars
                  SizedBox(
                    height: 105,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // User Avatar (Left)
                        Positioned(
                          left: MediaQuery.of(context).size.width * 0.12,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 15,
                                ),
                              ],
                              image: const DecorationImage(
                                image: NetworkImage(userAvatar),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        // Matched User Avatar (Right)
                        Positioned(
                          right: MediaQuery.of(context).size.width * 0.12,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppTheme.primaryRose, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryRose.withOpacity(0.5),
                                  blurRadius: 15,
                                ),
                              ],
                              image: DecorationImage(
                                image: NetworkImage(
                                    widget.matchedProfile.photos.first),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ✨ NEW FEATURE: Interactive AI Icebreaker Suggestion Box
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.auto_awesome,
                                    color: AppTheme.accentGold, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  "Suggested Icebreaker",
                                  style: TextStyle(
                                    color: AppTheme.accentGold,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: _shuffleIcebreaker,
                              child: Row(
                                children: const [
                                  Icon(Icons.refresh_rounded,
                                      color: AppTheme.textSecondary, size: 14),
                                  SizedBox(width: 4),
                                  Text(
                                    "Shuffle",
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            _icebreakers[_currentIcebreakerIndex],
                            key: ValueKey<int>(_currentIcebreakerIndex),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Primary Action Button (Using AnimatedGlowButton)
                  AnimatedGlowButton(
                    label: 'SAY HELLO TO ${firstName.toUpperCase()}',
                    icon: Icons.send_rounded,
                    gradient: AppTheme.primaryGradient,
                    foregroundColor: Colors.white,
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onSendChat();
                    },
                  ),
                  const SizedBox(height: 12),

                  // Secondary Action Button (Keep Swiping)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onKeepSwiping();
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.white.withOpacity(0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'KEEP SWIPING',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
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
}
