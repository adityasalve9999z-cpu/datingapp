import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../theme/app_theme.dart';

class ProfileDetailScreen extends StatefulWidget {
  final ProfileModel profile;
  final String heroTag;

  const ProfileDetailScreen({
    super.key,
    required this.profile,
    required this.heroTag,
  });

  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  final PageController _pageController = PageController();
  int _currentPhotoIndex = 0;
  bool _isPlayingAudio = false;

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          // Scrollable Detail View
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Hero Photo Header View
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.height * 0.55,
                pinned: true,
                backgroundColor: AppTheme.darkBackground,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
                      onPressed: () => _showReportBottomSheet(context),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      // Photo PageView with Hero animation
                      PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPhotoIndex = index;
                          });
                        },
                        itemCount: profile.photos.length,
                        itemBuilder: (context, index) {
                          return Hero(
                            tag: index == 0 ? widget.heroTag : 'photo_$index',
                            child: Image.network(
                              profile.photos[index],
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      ),

                      // Gradient Bottom Overlay
                      Positioned.fill(
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: AppTheme.cardOverlayGradient,
                          ),
                        ),
                      ),

                      // Page Indicators
                      if (profile.photos.length > 1)
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 60,
                          left: 20,
                          right: 20,
                          child: Row(
                            children: List.generate(
                              profile.photos.length,
                              (idx) => Expanded(
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  height: 4,
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  decoration: BoxDecoration(
                                    color: idx == _currentPhotoIndex
                                        ? Colors.white
                                        : Colors.white30,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Name & Age Header on Image
                      Positioned(
                        bottom: 24,
                        left: 20,
                        right: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${profile.name}, ${profile.age}',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                if (profile.isVerified) ...[
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.verified_rounded,
                                    color: AppTheme.accentCyan,
                                    size: 26,
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profile.occupation,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Detailed Profile Info Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Match Compatibility & Distance Row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: AppTheme.sunsetGradient,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.bolt_rounded, color: Colors.white, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  '${profile.compatibilityScore}% Compatibility',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceCard,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.near_me_rounded, color: AppTheme.primaryRose, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  profile.distance,
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Bio Section
                      const Text(
                        'About Me',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        profile.bio,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppTheme.textSecondary,
                          height: 1.6,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Audio Voice Prompt Player
                      if (profile.audioPromptTitle != null) ...[
                        AppTheme.glassContainer(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isPlayingAudio = !_isPlayingAudio;
                                  });
                                },
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: AppTheme.primaryGradient,
                                  ),
                                  child: Icon(
                                    _isPlayingAudio ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      profile.audioPromptTitle!,
                                      style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            height: 4,
                                            decoration: BoxDecoration(
                                              color: Colors.white12,
                                              borderRadius: BorderRadius.circular(2),
                                            ),
                                            child: FractionallySizedBox(
                                              alignment: Alignment.centerLeft,
                                              widthFactor: _isPlayingAudio ? 0.65 : 0.0,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  gradient: AppTheme.primaryGradient,
                                                  borderRadius: BorderRadius.circular(2),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          profile.audioPromptDuration ?? '0:20',
                                          style: const TextStyle(
                                            color: AppTheme.textMuted,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Prompt Answer Card
                      if (profile.promptQuestion != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceCard,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withOpacity(0.08)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.promptQuestion!,
                                style: const TextStyle(
                                  color: AppTheme.primaryRose,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                profile.promptAnswer!,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Basics & Attributes Grid
                      const Text(
                        'Basics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _buildDetailTile(Icons.height_rounded, profile.height),
                          _buildDetailTile(Icons.auto_awesome_rounded, profile.zodiac),
                          _buildDetailTile(Icons.favorite_outline_rounded, profile.relationshipGoal),
                          _buildDetailTile(Icons.location_city_rounded, profile.location),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Interests Chips
                      const Text(
                        'Interests',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: profile.interests
                            .map(
                              (interest) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceCard,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppTheme.primaryRose.withOpacity(0.3)),
                                ),
                                child: Text(
                                  interest,
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),

                      // Bottom spacing for sticky floating bar
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Floating Action Bar at Bottom
          Positioned(
            bottom: 24,
            left: 30,
            right: 30,
            child: AppTheme.glassContainer(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppTheme.primaryRose, size: 30),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.star_rounded, color: AppTheme.accentCyan, size: 30),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Super Liked ${profile.name}!'),
                          backgroundColor: AppTheme.surfaceCard,
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite_rounded, color: AppTheme.emeraldGreen, size: 30),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Liked ${profile.name}!'),
                          backgroundColor: AppTheme.surfaceCard,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailTile(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primaryRose),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showReportBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Material(
            color: AppTheme.surfaceDark,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.flag_rounded, color: AppTheme.primaryRose),
                  title: const Text('Report Profile', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile reported. Thank you for keeping GlowDate safe.')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.block_rounded, color: Colors.white70),
                  title: const Text('Block User', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
