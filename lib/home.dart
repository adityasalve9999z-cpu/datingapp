import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
i
/// Wraps a widget with a mouse-hover reaction: a slight scale-up plus a
/// softened/lifted shadow, using MouseRegion + AnimatedContainer exactly like
/// the pattern for `onEnter`/`onExit` hover detection. Only fires with an
/// actual pointer (web/desktop, or a mouse plugged into a tablet) — it's a
/// no-op on touch, which is fine since touch has no hover concept.
class _HoverLift extends StatefulWidget {
  final Widget child;
  final double scale;
  final Color glowColor;
  const _HoverLift({
    required this.child,
    this.scale = 1.02,
    this.glowColor = AppTheme.primaryRose,
  });

  @override
  State<_HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<_HoverLift> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        transform: _isHovered ? (Matrix4.identity()..scale(widget.scale)) : Matrix4.identity(),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.glowColor.withOpacity(0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [],
        ),
        child: widget.child,
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with TickerProviderStateMixin {
  // Toggles
  bool _showMeOnDiscovery = true;
  bool _globalMode = false;
  bool _newMatches = true;
  bool _newMessages = true;
  bool _likesYou = true;
  bool _promotions = false;
  bool _readReceipts = true;
  bool _onlineStatus = true;
  bool _incognitoMode = false;

  RangeValues _ageRange = const RangeValues(21, 34);
  double _maxDistance = 30;

  // Slow pulsing glow behind the Premium upsell card — draws the eye without
  // being distracting, using the same heartbeat-style rhythm as other
  // screens in the app rather than a generic sine breathing loop.
  late final AnimationController _premiumGlowController;
  late final Animation<double> _premiumGlow;

  @override
  void initState() {
    super.initState();
    _premiumGlowController = AnimationController(
      duration: const Duration(milliseconds: 2200),
      vsync: this,
    )..repeat(reverse: true);
    _premiumGlow = CurvedAnimation(parent: _premiumGlowController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _premiumGlowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        physics: const BouncingScrollPhysics(),
        children: [
          _HoverLift(child: _buildProfileCard()),
          const SizedBox(height: 20),
          _HoverLift(scale: 1.015, glowColor: AppTheme.primaryPurple, child: _buildPremiumCard()),
          const SizedBox(height: 24),

          _sectionLabel('Discovery'),
          _groupCard([
            _switchTile(
              icon: Icons.visibility_rounded,
              label: 'Show me on Discovery',
              color: AppTheme.primaryRose,
              value: _showMeOnDiscovery,
              onChanged: (v) => setState(() => _showMeOnDiscovery = v),
            ),
            _switchTile(
              icon: Icons.public_rounded,
              label: 'Global Mode',
              color: AppTheme.accentCyan,
              value: _globalMode,
              onChanged: (v) => setState(() => _globalMode = v),
            ),
            _rangeTile(
              icon: Icons.cake_rounded,
              label: 'Age Range',
              valueLabel: '${_ageRange.start.toInt()} – ${_ageRange.end.toInt()} yrs',
              color: AppTheme.primaryPurple,
              child: RangeSlider(
                values: _ageRange,
                min: 18,
                max: 60,
                divisions: 42,
                activeColor: AppTheme.primaryRose,
                inactiveColor: Colors.white12,
                onChanged: (v) => setState(() => _ageRange = v),
              ),
            ),
            _rangeTile(
              icon: Icons.location_on_rounded,
              label: 'Max Distance',
              valueLabel: '${_maxDistance.toInt()} miles',
              color: AppTheme.accentGold,
              child: Slider(
                value: _maxDistance,
                min: 1,
                max: 100,
                divisions: 99,
                activeColor: AppTheme.accentGold,
                inactiveColor: Colors.white12,
                onChanged: (v) => setState(() => _maxDistance = v),
              ),
            ),
          ]),

          const SizedBox(height: 20),
          _sectionLabel('Notifications'),
          _groupCard([
            _switchTile(
              icon: Icons.favorite_rounded,
              label: 'New Matches',
              color: AppTheme.primaryRose,
              value: _newMatches,
              onChanged: (v) => setState(() => _newMatches = v),
            ),
            _switchTile(
              icon: Icons.chat_bubble_rounded,
              label: 'New Messages',
              color: AppTheme.accentCyan,
              value: _newMessages,
              onChanged: (v) => setState(() => _newMessages = v),
            ),
            _switchTile(
              icon: Icons.emoji_emotions_rounded,
              label: 'Likes You',
              color: AppTheme.emeraldGreen,
              value: _likesYou,
              onChanged: (v) => setState(() => _likesYou = v),
            ),
            _switchTile(
              icon: Icons.local_offer_rounded,
              label: 'Promotions & Tips',
              color: AppTheme.primaryPurple,
              value: _promotions,
              onChanged: (v) => setState(() => _promotions = v),
            ),
          ]),

          const SizedBox(height: 20),
          _sectionLabel('Privacy & Safety'),
          _groupCard([
            _switchTile(
              icon: Icons.done_all_rounded,
              label: 'Read Receipts',
              color: AppTheme.accentCyan,
              value: _readReceipts,
              onChanged: (v) => setState(() => _readReceipts = v),
            ),
            _switchTile(
              icon: Icons.circle_rounded,
              label: 'Show Online Status',
              color: AppTheme.emeraldGreen,
              value: _onlineStatus,
              onChanged: (v) => setState(() => _onlineStatus = v),
            ),
            _switchTile(
              icon: Icons.visibility_off_rounded,
              label: 'Incognito Mode',
              color: AppTheme.primaryPurple,
              value: _incognitoMode,
              onChanged: (v) => setState(() => _incognitoMode = v),
            ),
            _actionTile(icon: Icons.block_rounded, label: 'Blocked Accounts', color: AppTheme.textMuted, onTap: () {}),
            _actionTile(icon: Icons.shield_rounded, label: 'Safety Center', color: AppTheme.accentGold, onTap: () {}),
          ]),

          const SizedBox(height: 20),
          _sectionLabel('Account'),
          _groupCard([
            _actionTile(icon: Icons.verified_user_rounded, label: 'Verify Your Profile', color: AppTheme.accentCyan, onTap: () {}),
            _actionTile(icon: Icons.lock_rounded, label: 'Change Password', color: AppTheme.primaryPurple, onTap: () {}),
            _actionTile(icon: Icons.link_rounded, label: 'Linked Accounts', color: AppTheme.emeraldGreen, onTap: () {}),
            _actionTile(icon: Icons.language_rounded, label: 'Language', value: 'English', color: AppTheme.accentGold, onTap: () {}),
          ]),

          const SizedBox(height: 20),
          _sectionLabel('Support'),
          _groupCard([
            _actionTile(icon: Icons.help_rounded, label: 'Help Center', color: AppTheme.accentCyan, onTap: () {}),
            _actionTile(icon: Icons.description_rounded, label: 'Community Guidelines', color: AppTheme.primaryPurple, onTap: () {}),
            _actionTile(icon: Icons.privacy_tip_rounded, label: 'Privacy Policy', color: AppTheme.textMuted, onTap: () {}),
            _actionTile(icon: Icons.info_rounded, label: 'About GlowDate', value: 'v2.4.0', color: AppTheme.textMuted, onTap: () {}),
          ]),

          const SizedBox(height: 28),
          _AnimatedDangerButton(
            label: 'Log Out',
            icon: Icons.logout_rounded,
            onPressed: () => _confirmLogout(context),
          ),
          const SizedBox(height: 14),
          Center(
            child: TextButton(
              onPressed: () => _confirmDelete(context),
              child: const Text(
                'Delete Account',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 12.5, decoration: TextDecoration.underline),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log out?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'You can always log back in to continue where you left off.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Log Out', style: TextStyle(color: AppTheme.primaryRose, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete your account?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This permanently removes your profile, matches, and messages. This can\u2019t be undone.',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ── Building blocks ────────────────────────────────────────────────────────

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.primaryGradient,
            ),
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.surfaceCard, width: 2),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Text('Maya, 27', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(width: 6),
                    Icon(Icons.verified_rounded, color: AppTheme.accentCyan, size: 16),
                  ],
                ),
                const SizedBox(height: 3),
                const Text('Edit your profile & preferences', style: TextStyle(color: AppTheme.textMuted, fontSize: 12.5)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumCard() {
    return AnimatedBuilder(
      animation: _premiumGlow,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryRose.withOpacity(0.18 + _premiumGlow.value * 0.22),
                blurRadius: 20 + _premiumGlow.value * 10,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Upgrade to GlowDate+', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                  SizedBox(height: 3),
                  Text('Unlimited likes, see who likes you & more', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppTheme.textMuted,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _groupCard(List<Widget> tiles) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: List.generate(tiles.length, (i) {
          return Column(
            children: [
              tiles[i],
              if (i != tiles.length - 1) const Divider(height: 1, indent: 56, color: Colors.white10),
            ],
          );
        }),
      ),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String label,
    required Color color,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: value ? color.withOpacity(0.05) : Colors.transparent,
      ),
      child: SwitchListTile(
        hoverColor: color.withOpacity(0.06),
        mouseCursor: SystemMouseCursors.click,
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        title: Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
        value: value,
        activeColor: color,
        onChanged: onChanged,
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String label,
    String? value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      hoverColor: color.withOpacity(0.06),
      mouseCursor: SystemMouseCursors.click,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
      trailing: value != null
          ? Text(value, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13))
          : const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted, size: 20),
      onTap: onTap,
    );
  }

  Widget _rangeTile({
    required IconData icon,
    required String label,
    required String valueLabel,
    required Color color,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14))),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                ),
                child: Container(
                  key: ValueKey(valueLabel),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    valueLabel,
                    style: TextStyle(color: color, fontSize: 12.5, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          child,
        ],
      ),
    );
  }
}

/// Log Out button with press-in feedback, styled as a subtle outlined
/// "danger" action rather than a filled button — it shouldn't visually
/// compete with the primary gradient CTAs used elsewhere in the app.
class _AnimatedDangerButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  const _AnimatedDangerButton({required this.label, required this.icon, required this.onPressed});

  @override
  State<_AnimatedDangerButton> createState() => _AnimatedDangerButtonState();
}

class _AnimatedDangerButtonState extends State<_AnimatedDangerButton> {
  bool _pressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : (_isHovered ? 1.015 : 1.0),
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              color: _isHovered ? AppTheme.primaryRose.withOpacity(0.08) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primaryRose.withOpacity(_pressed ? 0.4 : (_isHovered ? 1.0 : 0.7)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, color: AppTheme.primaryRose, size: 18),
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: const TextStyle(color: AppTheme.primaryRose, fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
