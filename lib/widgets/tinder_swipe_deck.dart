import 'dart:math';
import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../theme/app_theme.dart';
import '../screens/profile_detail_screen.dart';

class TinderSwipeDeck extends StatefulWidget {
  final List<ProfileModel> profiles;
  final Function(ProfileModel profile, SwipeDirection direction) onSwipe;
  final VoidCallback? onUndo;
  final Function(ProfileModel profile)? onMatch;

  const TinderSwipeDeck({
    super.key,
    required this.profiles,
    required this.onSwipe,
    this.onUndo,
    this.onMatch,
  });

  @override
  State<TinderSwipeDeck> createState() => _TinderSwipeDeckState();
}

enum SwipeDirection { left, right, up }

class _TinderSwipeDeckState extends State<TinderSwipeDeck>
    with SingleTickerProviderStateMixin {
  late List<ProfileModel> _deck;
  Offset _dragOffset = Offset.zero;
  double _dragAngle = 0.0;
  int _currentPhotoIndex = 0;

  late AnimationController _swipeAnimController;
  Animation<Offset>? _swipeOffsetAnimation;
  Animation<double>? _swipeAngleAnimation;

  @override
  void initState() {
    super.initState();
    _deck = List.from(widget.profiles);
    _swipeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _swipeAnimController.addListener(() {
      setState(() {
        if (_swipeOffsetAnimation != null) {
          _dragOffset = _swipeOffsetAnimation!.value;
        }
        if (_swipeAngleAnimation != null) {
          _dragAngle = _swipeAngleAnimation!.value;
        }
      });
    });
    _swipeAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _finalizeSwipe();
      }
    });
  }

  @override
  void didUpdateWidget(TinderSwipeDeck oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.profiles != oldWidget.profiles) {
      setState(() {
        _deck = List.from(widget.profiles);
      });
    }
  }

  @override
  void dispose() {
    _swipeAnimController.dispose();
    super.dispose();
  }

  SwipeDirection? get _currentDirection {
    if (_dragOffset.dx > 60) return SwipeDirection.right;
    if (_dragOffset.dx < -60) return SwipeDirection.left;
    if (_dragOffset.dy < -60) return SwipeDirection.up;
    return null;
  }

  double get _swipeProgress {
    if (_dragOffset.dx != 0) {
      return (_dragOffset.dx.abs() / 150).clamp(0.0, 1.0);
    }
    if (_dragOffset.dy < 0) {
      return (_dragOffset.dy.abs() / 150).clamp(0.0, 1.0);
    }
    return 0.0;
  }

  void _onPanStart(DragStartDetails details) {
    if (_deck.isEmpty || _swipeAnimController.isAnimating) return;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_deck.isEmpty || _swipeAnimController.isAnimating) return;
    setState(() {
      _dragOffset += details.delta;
      // Angle tilt proportional to X offset
      _dragAngle = (_dragOffset.dx / 300) * (pi / 12);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_deck.isEmpty || _swipeAnimController.isAnimating) return;
    final velocity = details.velocity.pixelsPerSecond;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    SwipeDirection? targetDirection;

    if (_dragOffset.dx > 120 || velocity.dx > 800) {
      targetDirection = SwipeDirection.right;
    } else if (_dragOffset.dx < -120 || velocity.dx < -800) {
      targetDirection = SwipeDirection.left;
    } else if (_dragOffset.dy < -120 || velocity.dy < -800) {
      targetDirection = SwipeDirection.up;
    }

    if (targetDirection != null) {
      _animateSwipe(targetDirection, screenWidth, screenHeight);
    } else {
      _resetCardPosition();
    }
  }

  void _animateSwipe(SwipeDirection direction, double width, double height) {
    Offset targetOffset;
    double targetAngle = _dragAngle;

    switch (direction) {
      case SwipeDirection.right:
        targetOffset = Offset(width * 1.5, _dragOffset.dy);
        targetAngle = pi / 8;
        break;
      case SwipeDirection.left:
        targetOffset = Offset(-width * 1.5, _dragOffset.dy);
        targetAngle = -pi / 8;
        break;
      case SwipeDirection.up:
        targetOffset = Offset(_dragOffset.dx, -height * 1.2);
        targetAngle = 0.0;
        break;
    }

    _swipeOffsetAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: targetOffset,
    ).animate(CurvedAnimation(
      parent: _swipeAnimController,
      curve: Curves.easeOutCubic,
    ));

    _swipeAngleAnimation = Tween<double>(
      begin: _dragAngle,
      end: targetAngle,
    ).animate(CurvedAnimation(
      parent: _swipeAnimController,
      curve: Curves.easeOut,
    ));

    _swipeAnimController.forward(from: 0.0);
  }

  void _resetCardPosition() {
    _swipeOffsetAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _swipeAnimController,
      curve: Curves.elasticOut,
    ));

    _swipeAngleAnimation = Tween<double>(
      begin: _dragAngle,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _swipeAnimController,
      curve: Curves.easeOut,
    ));

    _swipeAnimController.forward(from: 0.0);
  }

  void _finalizeSwipe() {
    if (_deck.isEmpty) return;
    final topProfile = _deck.first;
    final direction = _currentDirection ?? SwipeDirection.right;

    setState(() {
      _deck.removeAt(0);
      _dragOffset = Offset.zero;
      _dragAngle = 0.0;
      _currentPhotoIndex = 0;
    });

    widget.onSwipe(topProfile, direction);

    // Trigger match on right or up swipe
    if ((direction == SwipeDirection.right || direction == SwipeDirection.up) &&
        widget.onMatch != null) {
      widget.onMatch!(topProfile);
    }
  }

  void triggerProgrammaticSwipe(SwipeDirection direction) {
    if (_deck.isEmpty || _swipeAnimController.isAnimating) return;
    final size = MediaQuery.of(context).size;
    _animateSwipe(direction, size.width, size.height);
  }

  @override
  Widget build(BuildContext context) {
    if (_deck.isEmpty) {
      return Center(
        child: AppTheme.glassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.sunsetGradient,
                ),
                child: const Icon(Icons.favorite_rounded, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 24),
              const Text(
                'You\u2019ve seen everyone near you!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Expand your distance preferences or check back later for fresh matches.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Refresh Deck — hover brightens the button background using
              // MaterialStateProperty.resolveWith, same concept as a
              // MaterialState-driven ElevatedButton hover.
              _HoverElevatedButton(
                onPressed: () {
                  setState(() {
                    _deck = List.from(widget.profiles);
                  });
                },
                icon: Icons.refresh_rounded,
                label: 'Refresh Deck',
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Next Card Preview (Behind)
                  if (_deck.length > 1)
                    Transform.scale(
                      scale: 0.94 + (_swipeProgress * 0.06),
                      child: Opacity(
                        opacity: 0.7 + (_swipeProgress * 0.3),
                        child: _buildProfileCard(
                          context,
                          _deck[1],
                          isTopCard: false,
                        ),
                      ),
                    ),

                  // Top Interactive Card
                  GestureDetector(
                    onPanStart: _onPanStart,
                    onPanUpdate: _onPanUpdate,
                    onPanEnd: _onPanEnd,
                    child: Transform.translate(
                      offset: _dragOffset,
                      child: Transform.rotate(
                        angle: _dragAngle,
                        child: Stack(
                          children: [
                            _buildProfileCard(
                              context,
                              _deck.first,
                              isTopCard: true,
                            ),
                            // Stamp Overlays
                            _buildSwipeStamps(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),

        // Action Buttons Bar
        const SizedBox(height: 16),
        _buildActionButtons(),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    ProfileModel profile, {
    required bool isTopCard,
  }) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            // Photo View & Tap Navigator
            Positioned.fill(
              child: Hero(
                tag: isTopCard ? 'profile_photo_${profile.id}' : 'bg_photo_${profile.id}',
                child: Image.network(
                  profile.photos[_currentPhotoIndex % profile.photos.length],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppTheme.surfaceCard,
                    child: const Center(
                      child: Icon(Icons.person_rounded, size: 80, color: AppTheme.textMuted),
                    ),
                  ),
                ),
              ),
            ),

            // Gradient Overlay for readability
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.cardOverlayGradient,
                ),
              ),
            ),

            // Top Photo Progress Indicators
            if (profile.photos.length > 1)
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Row(
                  children: List.generate(
                    profile.photos.length,
                    (idx) => Expanded(
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        decoration: BoxDecoration(
                          color: idx == _currentPhotoIndex
                              ? Colors.white
                              : Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Photo Tap Left / Right Gesture Zones
            if (isTopCard && profile.photos.length > 1)
              Positioned.fill(
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          if (_currentPhotoIndex > 0) {
                            setState(() {
                              _currentPhotoIndex--;
                            });
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () {
                          if (_currentPhotoIndex < profile.photos.length - 1) {
                            setState(() {
                              _currentPhotoIndex++;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

            // Top Status Badges (Match % & Distance)
            Positioned(
              top: profile.photos.length > 1 ? 32 : 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: AppTheme.sunsetGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryRose.withOpacity(0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt_rounded, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${profile.compatibilityScore}% Match',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on_rounded, color: Colors.white70, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          profile.distance,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Card Bottom Content Overlay
            Positioned(
              left: 20,
              right: 20,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Flexible(
                              child: Text(
                                '${profile.name}, ${profile.age}',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (profile.isVerified) ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.verified_rounded,
                                color: AppTheme.accentCyan,
                                size: 24,
                              ),
                            ],
                          ],
                        ),
                      ),

                      // Info Button to open Profile Detail Screen — now with
                      // a hover reaction (scale + brighter border) for
                      // web/desktop pointers, on top of the existing tap.
                      _HoverCircleIconButton(
                        icon: Icons.arrow_upward_rounded,
                        onTap: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              transitionDuration: const Duration(milliseconds: 400),
                              reverseTransitionDuration: const Duration(milliseconds: 350),
                              pageBuilder: (_, __, ___) => ProfileDetailScreen(
                                profile: profile,
                                heroTag: 'profile_photo_${profile.id}',
                              ),
                              transitionsBuilder: (_, animation, __, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    profile.occupation,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profile.bio,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Interest Chips Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: profile.interests
                          .take(3)
                          .map(
                            (interest) => Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Text(
                                interest,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwipeStamps() {
    if (_dragOffset.dx == 0 && _dragOffset.dy == 0) return const SizedBox.shrink();

    final isRight = _dragOffset.dx > 30;
    final isLeft = _dragOffset.dx < -30;
    final isUp = _dragOffset.dy < -30 && _dragOffset.dx.abs() < 60;

    if (!isRight && !isLeft && !isUp) return const SizedBox.shrink();

    if (isRight) {
      return Positioned(
        top: 50,
        left: 40,
        child: Transform.rotate(
          angle: -pi / 12,
          child: Opacity(
            opacity: _swipeProgress,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.emeraldGreen, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.emeraldGreen.withOpacity(0.5),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: const Text(
                'LIKE',
                style: TextStyle(
                  color: AppTheme.emeraldGreen,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (isLeft) {
      return Positioned(
        top: 50,
        right: 40,
        child: Transform.rotate(
          angle: pi / 12,
          child: Opacity(
            opacity: _swipeProgress,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryRose, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryRose.withOpacity(0.5),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: const Text(
                'NOPE',
                style: TextStyle(
                  color: AppTheme.primaryRose,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (isUp) {
      return Positioned(
        bottom: 120,
        left: 0,
        right: 0,
        child: Align(
          alignment: Alignment.center,
          child: Opacity(
            opacity: _swipeProgress,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.accentCyan, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentCyan.withOpacity(0.6),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Text(
                'SUPER LIKE',
                style: TextStyle(
                  color: AppTheme.accentCyan,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Undo / Rewind Button
        _ActionButton(
          icon: Icons.replay_rounded,
          color: AppTheme.accentGold,
          size: 46,
          onTap: () {
            if (widget.onUndo != null) {
              widget.onUndo!();
            }
          },
        ),

        // Dislike (Pass) Button
        _ActionButton(
          icon: Icons.close_rounded,
          color: AppTheme.primaryRose,
          size: 58,
          onTap: () => triggerProgrammaticSwipe(SwipeDirection.left),
        ),

        // Super Like Button
        _ActionButton(
          icon: Icons.star_rounded,
          color: AppTheme.accentCyan,
          size: 50,
          onTap: () => triggerProgrammaticSwipe(SwipeDirection.up),
        ),

        // Like (Heart) Button
        _ActionButton(
          icon: Icons.favorite_rounded,
          color: AppTheme.emeraldGreen,
          size: 58,
          onTap: () => triggerProgrammaticSwipe(SwipeDirection.right),
        ),

        // Lightning / Boost Button
        _ActionButton(
          icon: Icons.bolt_rounded,
          color: AppTheme.primaryPurple,
          size: 46,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.bolt_rounded, color: AppTheme.accentGold),
                    SizedBox(width: 10),
                    Text('Boost activated! Your profile is prioritized for 30 mins.'),
                  ],
                ),
                backgroundColor: AppTheme.surfaceDark,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// The circular action buttons (undo, pass, super like, like, boost).
/// Now hover-aware: on web/desktop, hovering lifts the button slightly and
/// brightens its glow before the user even clicks — the existing tap-down
/// press animation (scale to 0.85) is untouched and still layers on top.
class _ActionButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.size,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedScale(
            scale: _isHovered ? 1.08 : 1.0,
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.surfaceCard,
                border: Border.all(
                  color: widget.color.withOpacity(_isHovered ? 0.9 : 0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withOpacity(_isHovered ? 0.45 : 0.25),
                    blurRadius: _isHovered ? 18 : 12,
                    spreadRadius: _isHovered ? 2 : 1,
                  ),
                ],
              ),
              child: Icon(
                widget.icon,
                color: widget.color,
                size: widget.size * 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The small circular "open profile detail" button overlaid on each card.
/// Adds a hover scale + brighter border, same MouseRegion pattern used
/// throughout the rest of the app.
class _HoverCircleIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HoverCircleIconButton({required this.icon, required this.onTap});

  @override
  State<_HoverCircleIconButton> createState() => _HoverCircleIconButtonState();
}

class _HoverCircleIconButtonState extends State<_HoverCircleIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(_isHovered ? 0.32 : 0.2),
              border: Border.all(color: Colors.white.withOpacity(_isHovered ? 0.7 : 0.38)),
            ),
            child: Icon(
              widget.icon,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

/// The "Refresh Deck" button shown once the user has swiped through
/// everyone. Uses MaterialStateProperty.resolveWith to change background
/// color on hover — the built-in Material hover-state pattern, rather than
/// a custom MouseRegion wrapper.
class _HoverElevatedButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  const _HoverElevatedButton({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ButtonStyle(
        foregroundColor: const MaterialStatePropertyAll(Colors.white),
        padding: const MaterialStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
        shape: MaterialStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        overlayColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.hovered)) {
            return Colors.white.withOpacity(0.12);
          }
          if (states.contains(MaterialState.pressed)) {
            return Colors.white.withOpacity(0.2);
          }
          return null;
        }),
        backgroundColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.hovered)) {
            // Slightly lighter rose on hover so the button visibly "wakes up"
            return const Color(0xFFFF4785);
          }
          return AppTheme.primaryRose;
        }),
        elevation: MaterialStateProperty.resolveWith((states) {
          return states.contains(MaterialState.hovered) ? 8 : 2;
        }),
      ),
    );
  }
}