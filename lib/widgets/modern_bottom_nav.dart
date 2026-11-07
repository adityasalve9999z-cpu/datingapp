import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// HeroUI-styled floating bottom navigation bar.
/// Glass-frosted pill shape with electric-blue active indicator.
class ModernBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int unreadChatCount;
  final int newMatchCount;

  const ModernBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.unreadChatCount = 3,
    this.newMatchCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            height: 68,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark.withOpacity(0.80),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppTheme.borderDefault,
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.local_fire_department_rounded,
                  label: 'Discover',
                  isSelected: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
                _NavItem(
                  icon: Icons.favorite_rounded,
                  label: 'Likes',
                  isSelected: currentIndex == 1,
                  badgeCount: newMatchCount,
                  badgeColor: AppTheme.dangerRose,
                  onTap: () => onTap(1),
                ),
                _NavItem(
                  icon: Icons.chat_bubble_rounded,
                  label: 'Matches',
                  isSelected: currentIndex == 2,
                  badgeCount: unreadChatCount,
                  badgeColor: AppTheme.emeraldGreen,
                  onTap: () => onTap(2),
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  isSelected: currentIndex == 3,
                  onTap: () => onTap(3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final int badgeCount;
  final Color badgeColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.badgeCount = 0,
    this.badgeColor = AppTheme.primaryRose,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 180),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.88)
        .animate(CurvedAnimation(parent: _pressController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) {
        _pressController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressController.reverse(),
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (_, child) => Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 230),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            horizontal: widget.isSelected ? 18 : 14,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppTheme.primaryRose.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: widget.isSelected
                ? Border.all(
                    color: AppTheme.primaryRose.withOpacity(0.35),
                    width: 1.0,
                  )
                : null,
          ),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    widget.icon,
                    size: 22,
                    color: widget.isSelected
                        ? AppTheme.primaryRose
                        : AppTheme.textSecondary,
                  ),
                  if (!widget.isSelected && widget.badgeCount > 0)
                    Positioned(
                      top: -4,
                      right: -6,
                      child: Container(
                        padding: const EdgeInsets.all(3.5),
                        decoration: BoxDecoration(
                          color: widget.badgeColor,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 15,
                          minHeight: 15,
                        ),
                        child: Text(
                          '${widget.badgeCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              if (widget.isSelected) ...[
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: AppTheme.primaryRose,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
