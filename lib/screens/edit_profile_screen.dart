import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/shimmer_loading.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with TickerProviderStateMixin {
  final TextEditingController _bioController = TextEditingController(
    text:
        'Art gallery explorer & specialty coffee fanatic \u2615. Looking for someone to share late-night rooftop vinyl sessions and Sunday morning market runs.',
  );
  final TextEditingController _promptController = TextEditingController(
    text:
        'Freshly roasted espresso and spontaneous road trips up the coastline.',
  );

  static const int _bioMaxLength = 300;
  bool _isSaving = false;
  bool _isPlayingVoice = false;

  final List<String> _photos = const [
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=400&q=80',
  ];

  late final AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..forward();
    _bioController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _bioController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  /// Rough completeness score used to drive the meter at the top — counts
  /// photos, bio length, and whether the prompt has been answered.
  double get _completeness {
    double score = 0;
    score += (_photos.length / 6).clamp(0, 1) * 0.5;
    score += (_bioController.text.trim().length / 80).clamp(0, 1) * 0.3;
    score += _promptController.text.trim().isNotEmpty ? 0.2 : 0;
    return score.clamp(0, 1);
  }

  Animation<double> _staggerFor(int index, {int count = 5}) {
    final start = (index / count) * 0.5;
    final end = (start + 0.5).clamp(0.0, 1.0);
    return CurvedAnimation(
      parent: _entranceController,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    final result = await AppApiService.saveProfile({
      'bio': _bioController.text.trim(),
      'promptAnswer': _promptController.text.trim(),
    });
    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'] as String)),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _SaveButton(
                loading: _isSaving, onPressed: _isSaving ? null : _saveProfile),
          ),
        ],
      ),
      body: GlowLoadingOverlay(
        isLoading: _isSaving,
        message: 'Updating your profile...',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCompletenessMeter(),
              const SizedBox(height: 28),
              _sectionFade(0, _buildPhotosSection()),
              const SizedBox(height: 28),
              _sectionFade(1, _buildBioSection()),
              const SizedBox(height: 28),
              _sectionFade(2, _buildPromptSection()),
              const SizedBox(height: 28),
              _sectionFade(3, _buildVoiceSection()),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionFade(int index, Widget child) {
    final anim = _staggerFor(index, count: 4);
    return FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
            .animate(anim),
        child: child,
      ),
    );
  }

  Widget _buildCompletenessMeter() {
    final pct = (_completeness * 100).round();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppTheme.sunsetGradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: AppTheme.primaryRose.withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: _completeness),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOut,
                  builder: (context, value, _) => CircularProgressIndicator(
                    value: value,
                    strokeWidth: 4,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
                Text('$pct%',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Profile strength',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 3),
                Text('Complete profiles get up to 3x more matches',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Profile Photos',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(20)),
              child: Text('${_photos.length}/6',
                  style: const TextStyle(
                      color: AppTheme.accentGold,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text('Drag to reorder \u2014 your first photo is your cover.',
            style: TextStyle(color: AppTheme.textMuted, fontSize: 12.5)),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.75,
          ),
          itemCount: 6,
          itemBuilder: (context, index) => _PhotoTile(
            imageUrl: index < _photos.length ? _photos[index] : null,
            isCover: index == 0 && _photos.isNotEmpty,
          ),
        ),
      ],
    );
  }

  Widget _buildBioSection() {
    final length = _bioController.text.length;
    final nearLimit = length > _bioMaxLength * 0.9;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('About Me (Bio)',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _FocusGlowField(
          controller: _bioController,
          maxLines: 4,
          maxLength: _bioMaxLength,
          hint: 'Write a few words about yourself...',
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '$length / $_bioMaxLength',
            style: TextStyle(
              color: nearLimit ? AppTheme.primaryCoral : AppTheme.textMuted,
              fontSize: 11.5,
              fontWeight: nearLimit ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPromptSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Profile Prompt',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.primaryRose.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                  color: AppTheme.primaryRose.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('The key to my heart is...',
                      style: TextStyle(
                          color: AppTheme.primaryRose,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  Icon(Icons.edit_rounded,
                      color: AppTheme.primaryRose, size: 16),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _promptController,
                maxLines: 2,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                cursorColor: AppTheme.primaryRose,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Answer prompt...',
                  hintStyle: TextStyle(color: AppTheme.textMuted),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Voice Intro Prompt',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _FrostedGlassCard(
          child: Row(
            children: [
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _isPlayingVoice = !_isPlayingVoice),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.primaryGradient),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: Icon(
                        _isPlayingVoice
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        key: ValueKey(_isPlayingVoice),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('My ideal Sunday morning...',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    const SizedBox(height: 6),
                    _buildWaveform(),
                    const SizedBox(height: 4),
                    const Text('0:18 sec',
                        style: TextStyle(
                            color: AppTheme.textMuted, fontSize: 11.5)),
                  ],
                ),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Re-record',
                      style: TextStyle(
                          color: AppTheme.primaryRose,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWaveform() {
    final heights = [
      6.0,
      12.0,
      18.0,
      10.0,
      16.0,
      8.0,
      14.0,
      6.0,
      11.0,
      15.0,
      7.0,
      13.0
    ];
    return SizedBox(
      height: 20,
      child: Row(
        children: heights
            .map((h) => Container(
                  width: 3,
                  height: h,
                  margin: const EdgeInsets.only(right: 3),
                  decoration: BoxDecoration(
                    color: _isPlayingVoice
                        ? AppTheme.primaryRose
                        : AppTheme.textMuted.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

/// A real frosted-glass card (BackdropFilter blur) built locally so this file
/// doesn't depend on an AppTheme.glassContainer helper that may not exist.
class _FrostedGlassCard extends StatelessWidget {
  final Widget child;
  const _FrostedGlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.02)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Text field with a rose glow border on focus.
class _FocusGlowField extends StatefulWidget {
  final TextEditingController controller;
  final int maxLines;
  final int maxLength;
  final String hint;
  const _FocusGlowField({
    required this.controller,
    required this.maxLines,
    required this.maxLength,
    required this.hint,
  });

  @override
  State<_FocusGlowField> createState() => _FocusGlowFieldState();
}

class _FocusGlowFieldState extends State<_FocusGlowField> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasFocus = _focusNode.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: hasFocus ? AppTheme.primaryRose : Colors.white12,
            width: hasFocus ? 1.6 : 1),
        boxShadow: hasFocus
            ? [
                BoxShadow(
                    color: AppTheme.primaryRose.withOpacity(0.2),
                    blurRadius: 14)
              ]
            : [],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        maxLines: widget.maxLines,
        maxLength: widget.maxLength,
        style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
        cursorColor: AppTheme.primaryRose,
        decoration: InputDecoration(
          border: InputBorder.none,
          counterText: '',
          hintText: widget.hint,
          hintStyle: const TextStyle(color: AppTheme.textMuted),
        ),
      ),
    );
  }
}

/// Photo grid tile with hover lift, cover-photo badge, and a delete button
/// on filled tiles.
class _PhotoTile extends StatefulWidget {
  final String? imageUrl;
  final bool isCover;
  const _PhotoTile({required this.imageUrl, required this.isCover});

  @override
  State<_PhotoTile> createState() => _PhotoTileState();
}

class _PhotoTileState extends State<_PhotoTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.imageUrl != null;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 160),
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: _isHovered
                        ? AppTheme.primaryRose.withOpacity(0.5)
                        : Colors.white12),
                image: hasImage
                    ? DecorationImage(
                        image: NetworkImage(widget.imageUrl!),
                        fit: BoxFit.cover)
                    : null,
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                            color: AppTheme.primaryRose.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4))
                      ]
                    : [],
              ),
              child: !hasImage
                  ? const Center(
                      child: Icon(Icons.add_rounded,
                          color: AppTheme.primaryRose, size: 30))
                  : null,
            ),
            if (hasImage && widget.isCover)
              Positioned(
                left: 6,
                bottom: 6,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(8)),
                  child: const Text('COVER',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 8.5,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            if (hasImage)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                      color: Colors.black54, shape: BoxShape.circle),
                  child: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Save button with hover-lift, press-scale, and a loading spinner swap.
class _SaveButton extends StatefulWidget {
  final bool loading;
  final VoidCallback? onPressed;
  const _SaveButton({required this.loading, required this.onPressed});

  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton> {
  bool _pressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null;

    return MouseRegion(
      cursor: disabled ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: disabled ? null : (_) => setState(() => _pressed = true),
        onTapUp: disabled ? null : (_) => setState(() => _pressed = false),
        onTapCancel: disabled ? null : () => setState(() => _pressed = false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _pressed ? 0.94 : (_isHovered && !disabled ? 1.04 : 1.0),
          duration: const Duration(milliseconds: 120),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _isHovered && !disabled
                  ? AppTheme.primaryRose.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: widget.loading
                  ? const SizedBox(
                      key: ValueKey('loading'),
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2.2, color: AppTheme.primaryRose),
                    )
                  : const Text(
                      'Save',
                      key: ValueKey('label'),
                      style: TextStyle(
                          color: AppTheme.primaryRose,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
