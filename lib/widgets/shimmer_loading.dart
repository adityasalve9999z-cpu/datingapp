import 'dart:ui';

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Animated Shimmer gradient builder matching GlowDate's dark theme
class GlowShimmer extends StatefulWidget {
  final Widget child;
  final bool isShimmering;

  const GlowShimmer({
    super.key,
    required this.child,
    this.isShimmering = true,
  });

  @override
  State<GlowShimmer> createState() => _GlowShimmerState();
}

class _GlowShimmerState extends State<GlowShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isShimmering) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final dx = bounds.width * _controller.value * 2.5 - bounds.width;
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Color(0xFF221F30),
                Color(0xFF332D48),
                Color(0x88FF2A6D),
                Color(0xFF332D48),
                Color(0xFF221F30),
              ],
              stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
              transform:
                  _SlidingGradientTransform(slidePercent: _controller.value),
            ).createShader(Rect.fromLTWH(dx, 0, bounds.width, bounds.height));
          },
          child: widget.child,
        );
      },
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;
  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
        bounds.width * (slidePercent * 2 - 1), 0, 0);
  }
}

/// Basic Skeleton Primitive Elements
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 12.0,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class SkeletonAvatar extends StatelessWidget {
  final double size;

  const SkeletonAvatar({super.key, this.size = 56.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppTheme.surfaceCard,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// 1. Discover Card Swipe Skeleton (for Discover Screen)
class DiscoverCardSkeleton extends StatelessWidget {
  const DiscoverCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GlowShimmer(
      child: Center(
        child: Container(
          width: size.width * 0.9,
          height: size.height * 0.72,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo placeholder
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const SkeletonBox(width: 180, height: 24, borderRadius: 8),
              const SizedBox(height: 10),
              const SkeletonBox(width: 120, height: 16, borderRadius: 6),
              const SizedBox(height: 16),
              Row(
                children: const [
                  SkeletonBox(width: 70, height: 28, borderRadius: 14),
                  SizedBox(width: 8),
                  SkeletonBox(width: 90, height: 28, borderRadius: 14),
                  SizedBox(width: 8),
                  SkeletonBox(width: 80, height: 28, borderRadius: 14),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  SkeletonAvatar(size: 56),
                  SkeletonAvatar(size: 68),
                  SkeletonAvatar(size: 56),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 2. Likes Grid Skeleton (for Activity & Likes Screen)
class LikesGridSkeleton extends StatelessWidget {
  const LikesGridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GlowShimmer(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SkeletonBox(height: 70, borderRadius: 20),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemCount: 6,
                itemBuilder: (_, index) => Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceCard,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const SkeletonBox(
                            width: 100, height: 16, borderRadius: 6),
                        const SizedBox(height: 6),
                        const SkeletonBox(
                            width: 60, height: 12, borderRadius: 4),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 3. Chat List Skeleton (for Chat List Screen)
class ChatListSkeleton extends StatelessWidget {
  const ChatListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GlowShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            const SkeletonBox(height: 48, borderRadius: 24),
            const SizedBox(height: 24),
            // Matches Carousel
            const SkeletonBox(width: 140, height: 16, borderRadius: 6),
            const SizedBox(height: 14),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (_, __) => Column(
                  children: const [
                    SkeletonAvatar(size: 64),
                    SizedBox(height: 8),
                    SkeletonBox(width: 50, height: 10, borderRadius: 4),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            // Messages Header
            const SkeletonBox(width: 120, height: 16, borderRadius: 6),
            const SizedBox(height: 16),
            // List Tiles
            ...List.generate(
              6,
              (_) => Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Row(
                  children: [
                    const SkeletonAvatar(size: 58),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          SkeletonBox(width: 140, height: 16, borderRadius: 6),
                          SizedBox(height: 8),
                          SkeletonBox(width: 200, height: 12, borderRadius: 4),
                        ],
                      ),
                    ),
                    const SkeletonBox(width: 40, height: 10, borderRadius: 4),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 4. Profile Screen & Profile Detail Skeleton
class ProfileScreenSkeleton extends StatelessWidget {
  const ProfileScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GlowShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const SkeletonAvatar(size: 110),
            const SizedBox(height: 16),
            const SkeletonBox(width: 150, height: 22, borderRadius: 8),
            const SizedBox(height: 8),
            const SkeletonBox(width: 200, height: 14, borderRadius: 6),
            const SizedBox(height: 24),
            // Stat Cards
            Row(
              children: const [
                Expanded(child: SkeletonBox(height: 80, borderRadius: 20)),
                SizedBox(width: 12),
                Expanded(child: SkeletonBox(height: 80, borderRadius: 20)),
                SizedBox(width: 12),
                Expanded(child: SkeletonBox(height: 80, borderRadius: 20)),
              ],
            ),
            const SizedBox(height: 24),
            // Bio & Details Card
            const SkeletonBox(height: 140, borderRadius: 24),
            const SizedBox(height: 20),
            const SkeletonBox(height: 200, borderRadius: 24),
          ],
        ),
      ),
    );
  }
}

/// 5. Chat Room Skeleton
class ChatRoomSkeleton extends StatelessWidget {
  const ChatRoomSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GlowShimmer(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child:
                  const SkeletonBox(width: 240, height: 50, borderRadius: 20),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child:
                  const SkeletonBox(width: 200, height: 44, borderRadius: 20),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child:
                  const SkeletonBox(width: 260, height: 60, borderRadius: 20),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child:
                  const SkeletonBox(width: 180, height: 44, borderRadius: 20),
            ),
            const Spacer(),
            const SkeletonBox(height: 56, borderRadius: 28),
          ],
        ),
      ),
    );
  }
}

/// 6. Generic Form / Settings Skeleton
class FormScreenSkeleton extends StatelessWidget {
  const FormScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GlowShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonBox(width: 200, height: 26, borderRadius: 8),
            const SizedBox(height: 8),
            const SkeletonBox(width: 280, height: 14, borderRadius: 6),
            const SizedBox(height: 32),
            const SkeletonBox(height: 56, borderRadius: 20),
            const SizedBox(height: 16),
            const SkeletonBox(height: 56, borderRadius: 20),
            const SizedBox(height: 16),
            const SkeletonBox(height: 56, borderRadius: 20),
            const SizedBox(height: 32),
            const SkeletonBox(height: 120, borderRadius: 24),
            const SizedBox(height: 24),
            const SkeletonBox(height: 54, borderRadius: 27),
          ],
        ),
      ),
    );
  }
}

/// Frosted Glass Loading Overlay with Glowing Pulse Ring for Async Actions
class GlowLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final String message;
  final Widget child;

  const GlowLoadingOverlay({
    super.key,
    required this.isLoading,
    this.message = 'Loading...',
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          AnimatedOpacity(
            opacity: isLoading ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: Colors.black.withOpacity(0.55),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 24),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                          color: AppTheme.primaryRose.withOpacity(0.4)),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryRose.withOpacity(0.25),
                          blurRadius: 30,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 52,
                              height: 52,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppTheme.primaryRose),
                                backgroundColor:
                                    AppTheme.primaryRose.withOpacity(0.15),
                              ),
                            ),
                            const Icon(Icons.favorite_rounded,
                                size: 22, color: AppTheme.primaryRose),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
