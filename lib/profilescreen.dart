import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double _distanceRadius = 25.0;
  RangeValues _ageRange = const RangeValues(21, 32);
  bool _pushNotifications = true;
  bool _darkMode = true;

  @override
  Widget build(BuildContext context) {
    const userAvatar = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=600&q=80';

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: AppTheme.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header Info
            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.sunsetGradient,
                        ),
                      ),
                      Container(
                        width: 102,
                        height: 102,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.darkBackground, width: 3),
                          image: const DecorationImage(
                            image: NetworkImage(userAvatar),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppTheme.accentCyan,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: Colors.black,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Maya, 25',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(Icons.verified_rounded, color: AppTheme.accentCyan, size: 22),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'UX Designer @ TechStudio • San Francisco',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Profile Completion Gauge Card
            AppTheme.glassContainer(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: const [
                      SizedBox(
                        width: 54,
                        height: 54,
                        child: CircularProgressIndicator(
                          value: 0.85,
                          strokeWidth: 6,
                          valueColor: AlwaysStoppedAnimation(AppTheme.primaryRose),
                          backgroundColor: Colors.white10,
                        ),
                      ),
                      Text(
                        '85%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Complete your profile',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Add 1 more photo to boost your match rate by 2x!',
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // GlowDate Platinum Membership Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppTheme.goldGradient,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentGold.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'GlowDate Platinum',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Unlimited Swipes • See Who Likes You • Priority Boost',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('Upgrade'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Discovery Preferences Section
            const Text(
              'Discovery Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            // Maximum Distance Slider
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Maximum Distance', style: TextStyle(color: AppTheme.textPrimary)),
                      Text(
                        '${_distanceRadius.toInt()} miles',
                        style: const TextStyle(
                          color: AppTheme.primaryRose,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _distanceRadius,
                    min: 5,
                    max: 100,
                    onChanged: (val) => setState(() => _distanceRadius = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Age Preference Range Slider
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Age Range', style: TextStyle(color: AppTheme.textPrimary)),
                      Text(
                        '${_ageRange.start.toInt()} - ${_ageRange.end.toInt()}',
                        style: const TextStyle(
                          color: AppTheme.primaryRose,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: _ageRange,
                    min: 18,
                    max: 60,
                    onChanged: (val) => setState(() => _ageRange = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // App Settings Section
            const Text(
              'App Preferences',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Push Notifications', style: TextStyle(color: AppTheme.textPrimary)),
                    subtitle: const Text('Get updates on new matches and messages', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                    value: _pushNotifications,
                    activeColor: AppTheme.primaryRose,
                    onChanged: (val) => setState(() => _pushNotifications = val),
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  SwitchListTile(
                    title: const Text('Dark Mode Theme', style: TextStyle(color: AppTheme.textPrimary)),
                    subtitle: const Text('Always use dark obsidian layout', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                    value: _darkMode,
                    activeColor: AppTheme.primaryRose,
                    onChanged: (val) => setState(() => _darkMode = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Account Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.surfaceCard,
                      foregroundColor: AppTheme.textPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    icon: const Icon(Icons.logout_rounded, color: AppTheme.primaryRose),
                    label: const Text('Log Out', style: TextStyle(color: AppTheme.primaryRose)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.primaryRose),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
