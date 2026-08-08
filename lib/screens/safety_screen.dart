import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ReportUserScreen extends StatefulWidget {
  final String? userName;
  const ReportUserScreen({super.key, this.userName});

  @override
  State<ReportUserScreen> createState() => _ReportUserScreenState();
}

class _ReasonOption {
  final String label;
  final IconData icon;
  const _ReasonOption(this.label, this.icon);
}

class _ReportUserScreenState extends State<ReportUserScreen> {
  final List<_ReasonOption> _reasons = const [
    _ReasonOption('Inappropriate photos', Icons.no_photography_rounded),
    _ReasonOption('Harassment or abuse', Icons.report_rounded),
    _ReasonOption('Fake profile', Icons.person_off_rounded),
    _ReasonOption('Spam or scam', Icons.warning_amber_rounded),
    _ReasonOption('Underage user', Icons.child_care_rounded),
    _ReasonOption('Something else', Icons.more_horiz_rounded),
  ];

  String? _selectedReason;
  bool _blockUser = true;
  bool _isSubmitting = false;
  bool _submitted = false;

  final _detailsController = TextEditingController();

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a reason to continue'),
          backgroundColor: AppTheme.surfaceDark,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _submitted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Report User'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: animation, child: child),
          ),
          child: _submitted ? _buildSuccessState() : _buildFormState(),
        ),
      ),
    );
  }

  Widget _buildFormState() {
    return SingleChildScrollView(
      key: const ValueKey('form'),
      padding: const EdgeInsets.all(24),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.userName != null)
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  const CircleAvatar(radius: 18, backgroundColor: AppTheme.surfaceDark, child: Icon(Icons.person, color: AppTheme.textSecondary, size: 18)),
                  const SizedBox(width: 12),
                  Text('Reporting ${widget.userName}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          const Text(
            'Why are you reporting this user?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your report is confidential. The user won\u2019t be notified who reported them.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 24),

          ..._reasons.map((r) => _buildReasonTile(r)),

          const SizedBox(height: 20),
          const Text('Additional details (optional)', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: TextField(
              controller: _detailsController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              cursorColor: AppTheme.primaryRose,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(16),
                hintText: 'Tell us more about what happened...',
                hintStyle: TextStyle(color: AppTheme.textMuted),
                border: InputBorder.none,
              ),
            ),
          ),

          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _blockUser,
              activeColor: AppTheme.primaryRose,
              onChanged: (v) => setState(() => _blockUser = v),
              title: const Text('Also block this user', style: TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: const Text('They won\u2019t be able to see or message you', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            ),
          ),

          const SizedBox(height: 24),
          _AnimatedGradientButton(
            label: 'Submit Report',
            loading: _isSubmitting,
            color: AppTheme.primaryCoral,
            onPressed: _isSubmitting ? null : _submit,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildReasonTile(_ReasonOption reason) {
    final isSelected = _selectedReason == reason.label;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => setState(() => _selectedReason = reason.label),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? AppTheme.primaryCoral : Colors.white12,
                width: isSelected ? 1.6 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(reason.icon, size: 18, color: isSelected ? AppTheme.primaryCoral : AppTheme.textSecondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    reason.label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                      fontSize: 13.5,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                  child: Icon(
                    isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                    key: ValueKey(isSelected),
                    color: isSelected ? AppTheme.primaryCoral : Colors.white24,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessState() {
    return Center(
      key: const ValueKey('success'),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.emeraldGreen.withOpacity(0.15),
                  border: Border.all(color: AppTheme.emeraldGreen.withOpacity(0.4), width: 1.5),
                ),
                child: const Icon(Icons.check_circle_rounded, size: 48, color: AppTheme.emeraldGreen),
              ),
              const SizedBox(height: 24),
              const Text(
                'Report submitted',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _blockUser
                    ? 'Thank you. We\u2019ll review this report and the user has been blocked.'
                    : 'Thank you. Our safety team will review this within 24 hours.',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              _AnimatedGradientButton(
                label: 'Done',
                loading: false,
                color: AppTheme.primaryRose,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedGradientButton extends StatefulWidget {
  final String label;
  final bool loading;
  final Color color;
  final VoidCallback? onPressed;
  const _AnimatedGradientButton({
    required this.label,
    required this.loading,
    required this.color,
    required this.onPressed,
  });

  @override
  State<_AnimatedGradientButton> createState() => _AnimatedGradientButtonState();
}

class _AnimatedGradientButtonState extends State<_AnimatedGradientButton> {
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
          scale: _pressed ? 0.97 : (_isHovered && !disabled ? 1.015 : 1.0),
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: AnimatedOpacity(
            opacity: disabled && !widget.loading ? 0.6 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: disabled
                      ? []
                      : [
                          BoxShadow(
                            color: widget.color.withOpacity(_isHovered ? 0.5 : 0.35),
                            blurRadius: _isHovered ? 22 : 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: widget.loading
                        ? const SizedBox(
                            key: ValueKey('loading'),
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                          )
                        : Text(
                            widget.label,
                            key: const ValueKey('label'),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
