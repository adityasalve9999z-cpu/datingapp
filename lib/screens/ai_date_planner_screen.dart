import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_glow_button.dart';

class AiDatePlannerScreen extends StatefulWidget {
  final String? matchName;

  const AiDatePlannerScreen({super.key, this.matchName});

  @override
  State<AiDatePlannerScreen> createState() => _AiDatePlannerScreenState();
}

class _AiDatePlannerScreenState extends State<AiDatePlannerScreen> {
  String _selectedVibe = 'Cozy Coffee & Books';
  String _selectedBudget = '\$\$ (Moderate)';
  String _selectedTime = 'Evening (6 PM - 9 PM)';
  bool _isGenerating = false;
  Map<String, dynamic>? _generatedPlan;

  final List<Map<String, dynamic>> _vibes = [
    {
      'name': 'Cozy Coffee & Books',
      'icon': Icons.coffee_rounded,
      'color': AppTheme.accentGold,
      'description': 'Low pressure, intimate conversations & relaxed ambiance.',
    },
    {
      'name': 'Rooftop & Sunset Cocktails',
      'icon': Icons.local_bar_rounded,
      'color': AppTheme.primaryRose,
      'description': 'Elevated atmosphere with golden hour views.',
    },
    {
      'name': 'Arcade, Bowling & Games',
      'icon': Icons.sports_esports_rounded,
      'color': AppTheme.accentCyan,
      'description': 'Playful competition that breaks the ice instantly.',
    },
    {
      'name': 'Art Gallery & Street Tacos',
      'icon': Icons.palette_rounded,
      'color': AppTheme.emeraldGreen,
      'description': 'Creative spark followed by casual foodie delights.',
    },
    {
      'name': 'Scenic Sunset Walk & Gelato',
      'icon': Icons.park_rounded,
      'color': AppTheme.primaryCoral,
      'description': 'Casual stroll along waterfront with sweet treats.',
    },
  ];

  final List<String> _budgets = [
    '\$ (Budget Friendly)',
    '\$\$ (Moderate)',
    '\$\$\$ (Fine Dining)',
  ];

  final List<String> _times = [
    'Afternoon (1 PM - 4 PM)',
    'Sunset (5 PM - 7 PM)',
    'Evening (7 PM - 10 PM)',
  ];

  void _generateItinerary() {
    setState(() => _isGenerating = true);

    Future.delayed(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      setState(() {
        _isGenerating = false;
        _generatedPlan = {
          'title': 'The Perfect ${_selectedVibe.split('&').first.trim()} Date',
          'matchName': widget.matchName ?? 'Your Match',
          'vibe': _selectedVibe,
          'timeline': [
            {
              'step': 'Stage 1 • The Meetup',
              'action': 'Meet at an artisanal café or lounge with warm ambient lighting.',
              'duration': '45 mins',
            },
            {
              'step': 'Stage 2 • The Activity',
              'action': 'Transition to a scenic walk or interactive exhibit to discover shared interests naturally.',
              'duration': '1 hour',
            },
            {
              'step': 'Stage 3 • Sweet Wrap-up',
              'action': 'Finish with artisan gelato or signature mocktails while exchanging music playlists.',
              'duration': '30 mins',
            },
          ],
          'icebreakers': [
            'What is the most memorable hidden gem café you have ever discovered?',
            'If we were to curate a road trip playlist right now, what is your #1 track?',
            'What is one passion project you could talk about for 2 hours straight?',
          ],
          'proTip': 'Dating AI Tip: Ask open-ended questions about passions rather than job titles to foster emotional connection.',
        };
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('AI Date Planner'),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header AI Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0x33D4A857), Color(0x11160D1C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.accentGold.withOpacity(0.35)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color(0x33D4A857),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: AppTheme.accentGold, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.matchName != null
                              ? 'Planning a Date with ${widget.matchName}'
                              : 'AI Wingman Date Architect',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Generate zero-awkwardness date ideas and custom conversation starters.',
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Step 1: Vibe Selector
            const Text(
              '1. CHOOSE DATE VIBE',
              style: TextStyle(
                color: AppTheme.accentGold,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 10),

            Column(
              children: _vibes.map((vibe) {
                final isSelected = _selectedVibe == vibe['name'];
                final color = vibe['color'] as Color;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => setState(() => _selectedVibe = vibe['name'] as String),
                    borderRadius: BorderRadius.circular(20),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? color.withOpacity(0.15) : AppTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? color : Colors.white.withOpacity(0.08),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(vibe['icon'] as IconData, color: color, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vibe['name'] as String,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  vibe['description'] as String,
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Radio<String>(
                            value: vibe['name'] as String,
                            groupValue: _selectedVibe,
                            activeColor: color,
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedVibe = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Step 2: Budget & Time Picker
            const Text(
              '2. BUDGET & TIME WINDOW',
              style: TextStyle(
                color: AppTheme.accentGold,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedBudget,
                    decoration: const InputDecoration(
                      labelText: 'Target Budget',
                      labelStyle: TextStyle(color: AppTheme.textSecondary),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.attach_money_rounded, color: AppTheme.accentGold),
                    ),
                    dropdownColor: AppTheme.surfaceDark,
                    items: _budgets
                        .map((b) => DropdownMenuItem(value: b, child: Text(b, style: const TextStyle(color: Colors.white))))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedBudget = val);
                    },
                  ),
                  const Divider(color: Colors.white12),
                  DropdownButtonFormField<String>(
                    value: _selectedTime,
                    decoration: const InputDecoration(
                      labelText: 'Preferred Time',
                      labelStyle: TextStyle(color: AppTheme.textSecondary),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.access_time_rounded, color: AppTheme.primaryRose),
                    ),
                    dropdownColor: AppTheme.surfaceDark,
                    items: _times
                        .map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(color: Colors.white))))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedTime = val);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Generate Button
            AnimatedGlowButton(
              label: _isGenerating ? 'ARCHITECTING DATE...' : 'GENERATE AI ITINERARY',
              gradient: AppTheme.primaryGradient,
              onPressed: _isGenerating ? null : _generateItinerary,
            ),

            // Generated Result Display
            if (_generatedPlan != null) ...[
              const SizedBox(height: 32),
              const Divider(color: Colors.white24),
              const SizedBox(height: 16),

              Row(
                children: const [
                  Icon(Icons.auto_awesome, color: AppTheme.accentGold, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'CURATED ITINERARY',
                    style: TextStyle(
                      color: AppTheme.accentGold,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppTheme.accentGold.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _generatedPlan!['title'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    ...(_generatedPlan!['timeline'] as List).map((step) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AppTheme.surfaceDark,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.circle, size: 8, color: AppTheme.accentGold),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        step['step'] as String,
                                        style: const TextStyle(
                                          color: AppTheme.primaryRose,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        step['duration'] as String,
                                        style: const TextStyle(
                                          color: AppTheme.textMuted,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    step['action'] as String,
                                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const Divider(color: Colors.white12, height: 24),

                    const Text(
                      'Suggested Icebreakers to Ask:',
                      style: TextStyle(
                        color: AppTheme.accentGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),

                    ...(_generatedPlan!['icebreakers'] as List).map((icebreaker) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceDark,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.format_quote_rounded, color: AppTheme.primaryRose, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                icebreaker as String,
                                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy_rounded, size: 16, color: Colors.white54),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: icebreaker));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Copied icebreaker to clipboard!')),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
