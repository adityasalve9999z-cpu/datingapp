import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_glow_button.dart';

class DiscoveryFiltersScreen extends StatefulWidget {
  final double initialDistance;
  final RangeValues initialAgeRange;
  final String initialInterestedIn;
  final Function(Map<String, dynamic>)? onApply;

  const DiscoveryFiltersScreen({
    super.key,
    this.initialDistance = 25.0,
    this.initialAgeRange = const RangeValues(20, 32),
    this.initialInterestedIn = 'Everyone',
    this.onApply,
  });

  @override
  State<DiscoveryFiltersScreen> createState() => _DiscoveryFiltersScreenState();
}

class _DiscoveryFiltersScreenState extends State<DiscoveryFiltersScreen> {
  late double _maxDistance;
  late RangeValues _ageRange;
  late String _interestedIn;
  bool _verifiedOnly = false;
  bool _hasBioOnly = true;
  bool _globalMode = false;
  
  final List<String> _selectedIntentions = ['Long-term partner', 'Open to anything'];
  final List<String> _selectedLifestyles = ['Non-smoker', 'Active gym', 'Pet lover'];

  final List<String> _intentionOptions = [
    'Long-term partner',
    'Short-term fun',
    'Open to anything',
    'New friends',
    'Marriage minded',
  ];

  final List<String> _lifestyleOptions = [
    'Non-smoker',
    'Social drinker',
    'Active gym',
    'Pet lover',
    'Vegetarian',
    'Night owl',
    'Early bird',
  ];

  @override
  void initState() {
    super.initState();
    _maxDistance = widget.initialDistance;
    _ageRange = widget.initialAgeRange;
    _interestedIn = widget.initialInterestedIn;
  }

  void _resetFilters() {
    setState(() {
      _maxDistance = 30.0;
      _ageRange = const RangeValues(18, 35);
      _interestedIn = 'Everyone';
      _verifiedOnly = false;
      _hasBioOnly = false;
      _globalMode = false;
      _selectedIntentions.clear();
      _selectedLifestyles.clear();
    });
  }

  void _applyFilters() {
    final filters = {
      'maxDistance': _maxDistance,
      'ageRange': _ageRange,
      'interestedIn': _interestedIn,
      'verifiedOnly': _verifiedOnly,
      'hasBioOnly': _hasBioOnly,
      'globalMode': _globalMode,
      'intentions': _selectedIntentions,
      'lifestyles': _selectedLifestyles,
    };
    if (widget.onApply != null) {
      widget.onApply!(filters);
    }
    Navigator.pop(context, filters);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Discovery Preferences'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _resetFilters,
            child: const Text(
              'Reset',
              style: TextStyle(
                color: AppTheme.primaryRose,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location / Global Mode Card
            _buildSectionHeader('LOCATION & PASSPORT', Icons.public_rounded),
            const SizedBox(height: 10),
            _buildCard(
              child: Column(
                children: [
                  _buildSwitchTile(
                    title: 'Global Passport Mode',
                    subtitle: 'Match with singles anywhere in the world',
                    value: _globalMode,
                    icon: Icons.flight_takeoff_rounded,
                    onChanged: (val) => setState(() => _globalMode = val),
                  ),
                  if (!_globalMode) ...[
                    const Divider(color: Colors.white12, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Maximum Distance',
                          style: TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${_maxDistance.toInt()} km',
                          style: const TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                    Slider(
                      value: _maxDistance,
                      min: 2,
                      max: 150,
                      divisions: 74,
                      activeColor: AppTheme.accentGold,
                      inactiveColor: Colors.white12,
                      onChanged: (val) => setState(() => _maxDistance = val),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Age Range
            _buildSectionHeader('AGE BRACKET', Icons.cake_rounded),
            const SizedBox(height: 10),
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Target Age Range',
                        style: TextStyle(color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${_ageRange.start.round()} - ${_ageRange.end.round()}',
                        style: const TextStyle(color: AppTheme.primaryRose, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ],
                  ),
                  RangeSlider(
                    values: _ageRange,
                    min: 18,
                    max: 65,
                    divisions: 47,
                    activeColor: AppTheme.primaryRose,
                    inactiveColor: Colors.white12,
                    onChanged: (values) => setState(() => _ageRange = values),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Interested In
            _buildSectionHeader('SHOW ME', Icons.people_alt_rounded),
            const SizedBox(height: 10),
            _buildCard(
              child: Row(
                children: ['Women', 'Men', 'Everyone'].map((gender) {
                  final isSelected = _interestedIn == gender;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () => setState(() => _interestedIn = gender),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            gradient: isSelected ? AppTheme.primaryGradient : null,
                            color: isSelected ? null : AppTheme.surfaceDark,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? Colors.transparent : Colors.white12,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              gender,
                              style: TextStyle(
                                color: isSelected ? AppTheme.darkBackground : AppTheme.textSecondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // Relationship Intent
            _buildSectionHeader('RELATIONSHIP GOAL', Icons.favorite_rounded),
            const SizedBox(height: 10),
            _buildCard(
              child: Wrap(
                spacing: 8,
                runSpacing: 10,
                children: _intentionOptions.map((intent) {
                  final isSelected = _selectedIntentions.contains(intent);
                  return ChoiceChip(
                    label: Text(intent),
                    selected: isSelected,
                    selectedColor: AppTheme.accentGold.withOpacity(0.25),
                    backgroundColor: AppTheme.surfaceDark,
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.accentGold : AppTheme.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppTheme.accentGold : Colors.white10,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedIntentions.add(intent);
                        } else {
                          _selectedIntentions.remove(intent);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // Verification & Profile Quality
            _buildSectionHeader('SAFETY & QUALITY FILTERS', Icons.verified_user_rounded),
            const SizedBox(height: 10),
            _buildCard(
              child: Column(
                children: [
                  _buildSwitchTile(
                    title: 'Verified Profiles Only',
                    subtitle: 'Show only members with photo verification badge',
                    value: _verifiedOnly,
                    icon: Icons.verified_rounded,
                    iconColor: AppTheme.accentCyan,
                    onChanged: (val) => setState(() => _verifiedOnly = val),
                  ),
                  const Divider(color: Colors.white12, height: 20),
                  _buildSwitchTile(
                    title: 'Must Have Bio & Photos',
                    subtitle: 'Hide incomplete profiles',
                    value: _hasBioOnly,
                    icon: Icons.notes_rounded,
                    iconColor: AppTheme.emeraldGreen,
                    onChanged: (val) => setState(() => _hasBioOnly = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Lifestyle / Habits
            _buildSectionHeader('LIFESTYLE & HABITS', Icons.local_activity_rounded),
            const SizedBox(height: 10),
            _buildCard(
              child: Wrap(
                spacing: 8,
                runSpacing: 10,
                children: _lifestyleOptions.map((habit) {
                  final isSelected = _selectedLifestyles.contains(habit);
                  return FilterChip(
                    label: Text(habit),
                    selected: isSelected,
                    selectedColor: AppTheme.primaryRose.withOpacity(0.25),
                    backgroundColor: AppTheme.surfaceDark,
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.primaryRose : AppTheme.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppTheme.primaryRose : Colors.white10,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedLifestyles.add(habit);
                        } else {
                          _selectedLifestyles.remove(habit);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 36),

            // Apply Button
            AnimatedGlowButton(
              label: 'APPLY PREFERENCES',
              gradient: AppTheme.primaryGradient,
              onPressed: _applyFilters,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.accentGold),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.accentGold,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: child,
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    Color iconColor = AppTheme.accentGold,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
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
                  fontWeight: FontWeight.w600,
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
        Switch.adaptive(
          value: value,
          activeColor: AppTheme.accentGold,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
