import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_glow_button.dart';

class SafetyCenterScreen extends StatefulWidget {
  const SafetyCenterScreen({super.key});

  @override
  State<SafetyCenterScreen> createState() => _SafetyCenterScreenState();
}

class _SafetyCenterScreenState extends State<SafetyCenterScreen> {
  bool _shareDateActive = false;
  bool _incognitoMode = false;

  final List<Map<String, dynamic>> _safetyTips = [
    {
      'title': 'Meet in Public Places',
      'desc': 'Always have your first few dates in crowded, well-lit public venues like cafes or restaurants.',
      'icon': Icons.storefront_rounded,
      'color': AppTheme.accentGold,
    },
    {
      'title': 'Tell a Friend (Share My Date)',
      'desc': 'Share your date location, time, and match profile with a trusted friend or family member.',
      'icon': Icons.share_location_rounded,
      'color': AppTheme.accentCyan,
    },
    {
      'title': 'Arrange Your Own Transport',
      'desc': 'Keep control of your ride so you can leave whenever you feel uncomfortable.',
      'icon': Icons.directions_car_rounded,
      'color': AppTheme.emeraldGreen,
    },
    {
      'title': 'Never Send Money or Crypto',
      'desc': 'Beware of financial requests or romance scams. Real matches will never ask for wire transfers.',
      'icon': Icons.gavel_rounded,
      'color': AppTheme.primaryRose,
    },
  ];

  void _showShareDateDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.share_location_rounded, color: AppTheme.accentCyan, size: 28),
                SizedBox(width: 12),
                Text(
                  'Share My Date',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Select a trusted contact who will receive a secure SMS link with your match details, date venue, and live GPS location during your date.',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.person_pin_rounded, color: AppTheme.accentGold),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Emergency Contact: Alex (Sister)',
                      style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Icon(Icons.check_circle_rounded, color: AppTheme.emeraldGreen, size: 20),
                ],
              ),
            ),
            const SizedBox(height: 24),
            AnimatedGlowButton(
              label: 'ACTIVATE LIVE DATE SHARING',
              gradient: AppTheme.primaryGradient,
              onPressed: () {
                setState(() => _shareDateActive = true);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Date sharing activated with Alex!')),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showVerificationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.verified_rounded, color: AppTheme.accentCyan),
            SizedBox(width: 10),
            Text('Photo Verification', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18)),
          ],
        ),
        content: const Text(
          'Take a quick live selfie matching a dynamic pose to earn the verified blue badge on your profile.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Later', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentCyan,
              foregroundColor: AppTheme.darkBackground,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Starting selfie camera verification...')),
              );
            },
            child: const Text('Start Selfie Scan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Safety & Privacy Center'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        physics: const BouncingScrollPhysics(),
        children: [
          // Safety Status Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0x3372A6A6), Color(0x11160D1C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppTheme.accentCyan.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    color: Color(0x3372A6A6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shield_rounded, color: AppTheme.accentCyan, size: 32),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Safety is #1',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '24/7 AI moderation, verified badges, and discrete tools to protect your dates.',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Safety Tools Section
          const Text(
            'SAFETY TOOLKIT',
            style: TextStyle(
              color: AppTheme.accentGold,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),

          // Tool 1: Share My Date
          _buildToolCard(
            title: 'Share My Date',
            subtitle: _shareDateActive
                ? 'Active: Sharing location with Alex'
                : 'Send your itinerary & location to trusted friends',
            icon: Icons.share_location_rounded,
            iconColor: AppTheme.accentCyan,
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _shareDateActive ? AppTheme.emeraldGreen : AppTheme.accentCyan,
                foregroundColor: AppTheme.darkBackground,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _showShareDateDialog,
              child: Text(_shareDateActive ? 'Configured' : 'Setup'),
            ),
          ),

          const SizedBox(height: 12),

          // Tool 2: Photo Verification
          _buildToolCard(
            title: 'Photo Verification',
            subtitle: 'Verify your photos to get the blue checkmark',
            icon: Icons.verified_rounded,
            iconColor: AppTheme.accentGold,
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGold,
                foregroundColor: AppTheme.darkBackground,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _showVerificationDialog,
              child: const Text('Verify Now'),
            ),
          ),

          const SizedBox(height: 12),

          // Tool 3: Incognito Mode
          _buildToolCard(
            title: 'Incognito Browsing',
            subtitle: 'Only profiles you like will be able to see you',
            icon: Icons.visibility_off_rounded,
            iconColor: AppTheme.primaryRose,
            trailing: Switch.adaptive(
              value: _incognitoMode,
              activeColor: AppTheme.primaryRose,
              onChanged: (val) => setState(() => _incognitoMode = val),
            ),
          ),

          const SizedBox(height: 28),

          // Dating Safety Rules
          const Text(
            'ESSENTIAL DATING GUIDELINES',
            style: TextStyle(
              color: AppTheme.accentGold,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),

          ..._safetyTips.map((tip) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.07)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (tip['color'] as Color).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(tip['icon'] as IconData, color: tip['color'] as Color, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tip['title'] as String,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tip['desc'] as String,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 20),

          // Emergency Assistance Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0x22E07A6B),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primaryCoral.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.emergency_rounded, color: AppTheme.primaryCoral, size: 28),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Need Immediate Help?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Access national crisis and emergency helplines directly.',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryCoral,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Dialing Emergency Assistance (911 / Local Emergency)...')),
                    );
                  },
                  child: const Text('Call 911'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }
}
