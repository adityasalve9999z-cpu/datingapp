import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../theme/app_theme.dart';

class SuperlikeNoteDialog extends StatefulWidget {
  final ProfileModel profile;
  final Function(String note)? onSendSuperlike;

  const SuperlikeNoteDialog({
    super.key,
    required this.profile,
    this.onSendSuperlike,
  });

  static Future<void> show(
    BuildContext context, {
    required ProfileModel profile,
    Function(String note)? onSendSuperlike,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (_) => SuperlikeNoteDialog(
        profile: profile,
        onSendSuperlike: onSendSuperlike,
      ),
    );
  }

  @override
  State<SuperlikeNoteDialog> createState() => _SuperlikeNoteDialogState();
}

class _SuperlikeNoteDialogState extends State<SuperlikeNoteDialog> {
  final TextEditingController _noteController = TextEditingController();
  bool _isGeneratingAi = false;

  final List<String> _quickCompliments = [
    'Your travel photos are incredible! Where was that sunset taken?',
    'You have amazing energy — couldn\'t pass without saying hi! ✨',
    'We both love coffee and good banter. What\'s your go-to spot?',
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _generateAiCompliment() {
    setState(() => _isGeneratingAi = true);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      final firstName = widget.profile.name.split(' ').first;
      final interest = widget.profile.interests.isNotEmpty
          ? widget.profile.interests.first
          : 'your vibe';

      setState(() {
        _noteController.text =
            'Hey $firstName, your passion for $interest really caught my eye! Would love to chat ✨';
        _isGeneratingAi = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final photoUrl = widget.profile.photos.isNotEmpty
        ? widget.profile.photos.first
        : 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppTheme.accentCyan.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.accentCyan.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header & Profile Avatar ───────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.accentCyan, width: 2),
                    ),
                    child: ClipOval(
                      child: Image.network(photoUrl, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Superlike ${widget.profile.name.split(' ').first}',
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.star_rounded,
                              color: AppTheme.accentCyan,
                              size: 20,
                            ),
                          ],
                        ),
                        const Text(
                          'Attach a direct note (3x match rate)',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: AppTheme.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ── Note Text Field ───────────────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white12),
                ),
                child: TextField(
                  controller: _noteController,
                  maxLines: 3,
                  maxLength: 140,
                  style: const TextStyle(
                      color: AppTheme.textPrimary, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Add an authentic compliment or icebreaker…',
                    hintStyle:
                        TextStyle(color: AppTheme.textMuted, fontSize: 13),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(14),
                    counterStyle:
                        TextStyle(color: AppTheme.textMuted, fontSize: 11),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // ── AI Generator & Quick Prompts ──────────────────────────────
              Row(
                children: [
                  GestureDetector(
                    onTap: _isGeneratingAi ? null : _generateAiCompliment,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.accentGold.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isGeneratingAi
                                ? Icons.sync_rounded
                                : Icons.auto_awesome_rounded,
                            size: 13,
                            color: AppTheme.accentGold,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isGeneratingAi ? 'Crafting…' : 'AI Opener',
                            style: const TextStyle(
                              color: AppTheme.accentGold,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: _quickCompliments.map((comp) {
                          return GestureDetector(
                            onTap: () => setState(() => _noteController.text = comp),
                            child: Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceCard,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white12),
                              ),
                              child: Text(
                                comp.length > 22
                                    ? '${comp.substring(0, 22)}…'
                                    : comp,
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ── Send Button ───────────────────────────────────────────────
              Container(
                width: double.infinity,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0072FF).withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    final note = _noteController.text.trim();
                    Navigator.pop(context);
                    widget.onSendSuperlike?.call(note);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '⭐ Superliked ${widget.profile.name.split(' ').first} with direct note!',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Send Superlike Note',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
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
      ),
    );
  }
}
