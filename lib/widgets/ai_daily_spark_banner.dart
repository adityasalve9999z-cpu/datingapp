import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../theme/app_theme.dart';
import 'ai_agent_sheet.dart';

class AiDailySparkBanner extends StatelessWidget {
  final ProfileModel? profile;
  final VoidCallback? onDismiss;
  final Function(ProfileModel profile)? onSparkAction;

  const AiDailySparkBanner({
    super.key,
    required this.profile,
    this.onDismiss,
    this.onSparkAction,
  });

  @override
  Widget build(BuildContext context) {
    if (profile == null) return const SizedBox.shrink();

    final targetProfile = profile!;
    final photoUrl = targetProfile.photos.isNotEmpty
        ? targetProfile.photos.first
        : 'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=500';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [
            AppTheme.accentGold.withValues(alpha: 0.18),
            AppTheme.surfaceCard,
            AppTheme.surfaceDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppTheme.accentGold.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentGold.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background ambient subtle glow
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.accentGold.withValues(alpha: 0.12),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Profile Avatar with Score Ring
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.primaryGradient,
                      ),
                      padding: const EdgeInsets.all(2),
                      child: ClipOval(
                        child: Image.network(
                          photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppTheme.surfaceDark,
                            child: const Icon(
                              Icons.person,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGold,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${targetProfile.compatibilityScore}%',
                          style: const TextStyle(
                            color: AppTheme.darkBackground,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),

                // Info & Highlights
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  AppTheme.accentGold.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  color: AppTheme.accentGold,
                                  size: 11,
                                ),
                                SizedBox(width: 3),
                                Text(
                                  'DAILY AI SPARK',
                                  style: TextStyle(
                                    color: AppTheme.accentGold,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          if (onDismiss != null)
                            GestureDetector(
                              onTap: onDismiss,
                              child: const Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: AppTheme.textMuted,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${targetProfile.name}, ${targetProfile.age}',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        targetProfile.interests.isNotEmpty
                            ? 'Matches: ${targetProfile.interests.take(2).join(', ')} • ${targetProfile.distance}'
                            : '${targetProfile.occupation} • ${targetProfile.distance}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Action Button
                GestureDetector(
                  onTap: () {
                    if (onSparkAction != null) {
                      onSparkAction!(targetProfile);
                    } else {
                      AiAgentSheet.show(context);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentGold.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 16,
                          color: AppTheme.darkBackground,
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Wingman',
                          style: TextStyle(
                            color: AppTheme.darkBackground,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
