import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../theme/app_theme.dart';
import 'profile_detail_screen.dart';

class LikesScreen extends StatefulWidget {
  const LikesScreen({super.key});

  @override
  State<LikesScreen> createState() => _LikesScreenState();
}

class _LikesScreenState extends State<LikesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isUnlocked = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Activity & Likes'),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryRose,
          labelColor: AppTheme.primaryRose,
          unselectedLabelColor: AppTheme.textMuted,
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: '14 Likes You'),
            Tab(text: 'Top Picks'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Likes Grid
          _buildLikesGrid(),

          // Top Picks Grid
          _buildLikesGrid(isTopPicks: true),
        ],
      ),
    );
  }

  Widget _buildLikesGrid({bool isTopPicks = false}) {
    final profiles = isTopPicks ? mockProfiles.reversed.toList() : mockProfiles;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Gold Upgrade Banner
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: AppTheme.glassContainer(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.goldGradient,
                    ),
                    child: const Icon(Icons.star_rounded,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'GlowDate Platinum',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isUnlocked
                              ? 'Preview unlocked!'
                              : 'Upgrade to see exactly who likes you instantly.',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isUnlocked = !_isUnlocked;
                      });
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.accentGold,
                    ),
                    child: Text(_isUnlocked ? 'Lock' : 'Unlock All'),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Grid of Likes
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.72,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final profile = profiles[index % profiles.length];
                final shouldBlur = !_isUnlocked && index > 0;

                return GestureDetector(
                  onTap: () {
                    if (!shouldBlur) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProfileDetailScreen(
                            profile: profile,
                            heroTag: 'likes_photo_${profile.id}_$index',
                          ),
                        ),
                      );
                    } else {
                      setState(() {
                        _isUnlocked = true;
                      });
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: shouldBlur
                            ? Colors.white10
                            : AppTheme.accentGold.withOpacity(0.5),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          // Profile Image
                          Positioned.fill(
                            child: Hero(
                              tag: 'likes_photo_${profile.id}_$index',
                              child: Image.network(
                                profile.photos.first,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          // Blur Filter for Non-Gold Users
                          if (shouldBlur)
                            Positioned.fill(
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                                child: Container(
                                  color: Colors.black.withOpacity(0.4),
                                  child: const Center(
                                    child: Icon(
                                      Icons.lock_rounded,
                                      color: AppTheme.accentGold,
                                      size: 36,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          // Gradient Overlay
                          Positioned.fill(
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: AppTheme.cardOverlayGradient,
                              ),
                            ),
                          ),

                          // Top Match Badge
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                '${profile.compatibilityScore}% Match',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          // Profile Info at Bottom
                          Positioned(
                            left: 14,
                            right: 14,
                            bottom: 14,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  shouldBlur
                                      ? 'Secret Admirer'
                                      : '${profile.name.split(' ').first}, ${profile.age}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  profile.occupation.split('@').first,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              childCount: profiles.length * 2,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}
