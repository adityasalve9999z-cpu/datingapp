import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum DiscoveryCategory {
  all,
  verified,
  nearby,
  highSynergy,
  interests,
}

enum DiscoveryViewMode {
  swipeDeck,
  gridView,
}

class DiscoveryCategoryFilterBar extends StatelessWidget {
  final DiscoveryCategory selectedCategory;
  final ValueChanged<DiscoveryCategory> onCategoryChanged;
  final DiscoveryViewMode viewMode;
  final ValueChanged<DiscoveryViewMode> onViewModeChanged;
  final int totalCount;

  const DiscoveryCategoryFilterBar({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.viewMode,
    required this.onViewModeChanged,
    this.totalCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    const categories = [
      _CategoryItem(
        category: DiscoveryCategory.all,
        label: 'All Sparks',
        icon: Icons.local_fire_department_rounded,
        color: AppTheme.accentGold,
      ),
      _CategoryItem(
        category: DiscoveryCategory.verified,
        label: 'Verified',
        icon: Icons.verified_rounded,
        color: AppTheme.accentCyan,
      ),
      _CategoryItem(
        category: DiscoveryCategory.nearby,
        label: 'Nearby (<10km)',
        icon: Icons.near_me_rounded,
        color: AppTheme.primaryRose,
      ),
      _CategoryItem(
        category: DiscoveryCategory.highSynergy,
        label: '90%+ Synergy',
        icon: Icons.bolt_rounded,
        color: AppTheme.emeraldGreen,
      ),
      _CategoryItem(
        category: DiscoveryCategory.interests,
        label: 'Shared Vibes',
        icon: Icons.interests_rounded,
        color: AppTheme.primaryCoral,
      ),
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          // Filter Chips List
          Expanded(
            child: SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final item = categories[index];
                  final isSelected = selectedCategory == item.category;

                  return GestureDetector(
                    onTap: () => onCategoryChanged(item.category),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? item.color.withValues(alpha: 0.2)
                            : AppTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? item.color
                              : Colors.white.withValues(alpha: 0.08),
                          width: isSelected ? 1.5 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: item.color.withValues(alpha: 0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            size: 15,
                            color: isSelected
                                ? item.color
                                : AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            item.label,
                            style: TextStyle(
                              color: isSelected
                                  ? AppTheme.textPrimary
                                  : AppTheme.textSecondary,
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // View Mode Switcher Button (Deck vs Grid)
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildModeIcon(
                  icon: Icons.view_carousel_rounded,
                  isActive: viewMode == DiscoveryViewMode.swipeDeck,
                  tooltip: 'Swipe Deck',
                  onTap: () =>
                      onViewModeChanged(DiscoveryViewMode.swipeDeck),
                ),
                _buildModeIcon(
                  icon: Icons.grid_view_rounded,
                  isActive: viewMode == DiscoveryViewMode.gridView,
                  tooltip: 'Grid Explore',
                  onTap: () =>
                      onViewModeChanged(DiscoveryViewMode.gridView),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeIcon({
    required IconData icon,
    required bool isActive,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.accentGold.withValues(alpha: 0.25)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isActive ? AppTheme.accentGold : AppTheme.textMuted,
          ),
        ),
      ),
    );
  }
}

class _CategoryItem {
  final DiscoveryCategory category;
  final String label;
  final IconData icon;
  final Color color;

  const _CategoryItem({
    required this.category,
    required this.label,
    required this.icon,
    required this.color,
  });
}
