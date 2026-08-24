import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../theme/app_theme.dart';
import '../screens/profile_detail_screen.dart';

class DiscoverGridExploreView extends StatelessWidget {
  final List<ProfileModel> profiles;
  final Function(ProfileModel profile)? onLike;
  final Function(ProfileModel profile)? onSuperLike;
  final Function(ProfileModel profile)? onSelectProfile;

  const DiscoverGridExploreView({
    super.key,
    required this.profiles,
    this.onLike,
    this.onSuperLike,
    this.onSelectProfile,
  });

  @override
  Widget build(BuildContext context) {
    if (profiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 56,
              color: AppTheme.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 14),
            const Text(
              'No sparks in this category yet',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 15,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.70,
      ),
      itemCount: profiles.length,
      itemBuilder: (context, index) {
        final profile = profiles[index];
        return _buildGridCard(context, profile);
      },
    );
  }

  Widget _buildGridCard(BuildContext context, ProfileModel profile) {
    final photoUrl = profile.photos.isNotEmpty
        ? profile.photos.first
        : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500';

    return GestureDetector(
      onTap: () {
        if (onSelectProfile != null) {
          onSelectProfile!(profile);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProfileDetailScreen(
                profile: profile,
                heroTag: 'grid_${profile.id}',
              ),
            ),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Photo
              Image.network(
                photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppTheme.surfaceDark,
                  child: const Center(
                    child: Icon(Icons.person, color: AppTheme.textMuted, size: 36),
                  ),
                ),
              ),

              // Gradient Overlay
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Color(0x33160D1C),
                      Color(0xEE160D1C),
                    ],
                    stops: [0.0, 0.45, 1.0],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),

              // Synergy Badge (Top Left)
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.darkBackground.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppTheme.accentGold.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.bolt_rounded,
                        color: AppTheme.accentGold,
                        size: 13,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${profile.compatibilityScore}%',
                        style: const TextStyle(
                          color: AppTheme.accentGold,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Verified Check / Distance (Top Right)
              if (profile.isVerified)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.darkBackground.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.verified_rounded,
                      color: AppTheme.accentCyan,
                      size: 15,
                    ),
                  ),
                ),

              // Profile Info & Quick Actions (Bottom)
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${profile.name}, ${profile.age}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${profile.distance} • ${profile.occupation}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Quick Like Button
                        Expanded(
                          child: GestureDetector(
                            onTap: () => onLike?.call(profile),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.favorite_rounded,
                                size: 16,
                                color: AppTheme.darkBackground,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Quick Superlike Button
                        GestureDetector(
                          onTap: () => onSuperLike?.call(profile),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceDark.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color:
                                    AppTheme.accentCyan.withValues(alpha: 0.4),
                              ),
                            ),
                            child: const Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: AppTheme.accentCyan,
                            ),
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
      ),
    );
  }
}
