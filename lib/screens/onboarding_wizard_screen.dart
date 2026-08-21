import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/animated_glow_button.dart';

class OnboardingWizardScreen extends StatefulWidget {
  const OnboardingWizardScreen({super.key});

  @override
  State<OnboardingWizardScreen> createState() => _OnboardingWizardScreenState();
}

class _OnboardingWizardScreenState extends State<OnboardingWizardScreen> {
  int _currentStep = 0;
  final int _totalSteps = 6;
  bool _isCompleting = false;

  // +1 when moving forward, -1 when moving back — drives the direction of
  // the slide transition between steps so "next" and "back" feel distinct.
  int _direction = 1;

  final TextEditingController _nameController = TextEditingController(text: 'Maya');
  final TextEditingController _bioController = TextEditingController(text: 'Art gallery explorer & coffee fanatic ☕');
  final TextEditingController _educationController = TextEditingController(text: 'Stanford University');

  final List<String> _selectedInterests = ['Design', 'Vinyl Records', 'Coffee'];
  final List<String> _allInterests = [
    'Design', 'Vinyl Records', 'Coffee', 'Art Openings', 'Surfing',
    'Architecture', 'Photography', 'Natural Wine', 'Bouldering', 'Indie Rock',
    'Cooking', 'Yoga', 'Travel', 'Hiking', 'Gaming', 'Reading'
  ];

  String _selectedGoal = 'Long-term relationship';
  final List<String> _goals = [
    'Long-term relationship',
    'Short-term fun',
    'Open to explore',
    'New friends'
  ];

  // Step 4 — Lifestyle
  String _drinking = 'Socially';
  String _smoking = 'Never';
  String _exercise = 'Sometimes';
  String _pets = 'No pets';
  final List<String> _drinkingOptions = ['Never', 'Socially', 'Often'];
  final List<String> _smokingOptions = ['Never', 'Occasionally', 'Yes'];
  final List<String> _exerciseOptions = ['Rarely', 'Sometimes', 'Often', 'Daily'];
  final List<String> _petsOptions = ['Dog lover 🐶', 'Cat person 🐱', 'Has pets 🐇', 'Plant parent 🌿', 'No pets'];

  // Step 5 — Basic Details
  String _selectedMbti = 'INFP';
  String _selectedHeight = "5'6\""; // FIX: was missing an escape, terminated the string early and broke the file
  final List<String> _mbtiOptions = [
    'INTJ', 'INTP', 'ENTJ', 'ENTP',
    'INFJ', 'INFP', 'ENFJ', 'ENFP',
    'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ',
    'ISTP', 'ISFP', 'ESTP', 'ESFP',
  ];
  final List<String> _heightOptions = [
    "4'10\"", "4'11\"", "5'0\"", "5'1\"", "5'2\"", "5'3\"",
    "5'4\"", "5'5\"", "5'6\"", "5'7\"", "5'8\"", "5'9\"",
    "5'10\"", "5'11\"", "6'0\"", "6'1\"", "6'2\"", "6'3+\""
  ];

  Future<void> _nextStep() async {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _direction = 1;
        _currentStep++;
      });
    } else {
      setState(() => _isCompleting = true);
      final result = await AppApiService.submitOnboarding({
        'name': _nameController.text.trim(),
        'bio': _bioController.text.trim(),
        'education': _educationController.text.trim(),
        'goals': _selectedGoal,
        'interests': _selectedInterests,
        'drinking': _drinking,
        'smoking': _smoking,
        'exercise': _exercise,
        'pets': _pets,
        'height': _selectedHeight,
        'mbti': _selectedMbti,
      });
      if (!mounted) return;
      setState(() => _isCompleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] as String)),
      );
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _direction = -1;
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: _previousStep,
              )
            : null,
        title: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(
            'Step ${_currentStep + 1} of $_totalSteps',
            key: ValueKey(_currentStep),
          ),
        ),
        centerTitle: true,
      ),
      body: GlowLoadingOverlay(
        isLoading: _isCompleting,
        message: 'Saving your preferences...',
        child: Column(
        children: [
          // Step Progress Bar — active segment gets a soft glow so the
          // current position reads clearly, not just a color change.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: List.generate(
                _totalSteps,
                (idx) => Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      gradient: idx <= _currentStep ? AppTheme.primaryGradient : null,
                      color: idx <= _currentStep ? null : Colors.white12,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: idx == _currentStep
                          ? [
                              BoxShadow(
                                color: AppTheme.primaryRose.withOpacity(0.6),
                                blurRadius: 6,
                                spreadRadius: 0.5,
                              ),
                            ]
                          : [],
                    ),
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              physics: const BouncingScrollPhysics(),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  final offsetAnimation = Tween<Offset>(
                    begin: Offset(_direction * 0.08, 0),
                    end: Offset.zero,
                  ).animate(animation);
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(position: offsetAnimation, child: child),
                  );
                },
                child: KeyedSubtree(
                  key: ValueKey(_currentStep),
                  child: _buildStepContent(),
                ),
              ),
            ),
          ),

          // Bottom Action Button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 20),
              child: AnimatedGlowButton(
                label: _currentStep == _totalSteps - 1 ? 'COMPLETE PROFILE' : 'CONTINUE',
                backgroundColor: AppTheme.primaryRose,
                gradient: AppTheme.primaryGradient,
                icon: _currentStep == _totalSteps - 1 ? Icons.check_circle_rounded : Icons.arrow_forward_rounded,
                onPressed: _nextStep,
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What\u2019s your name & bio?',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text('This is how you will appear to matches.', style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 32),
            _buildInputField('First Name', _nameController, Icons.person_rounded),
            const SizedBox(height: 20),
            _buildInputField('About You (Bio)', _bioController, Icons.short_text_rounded, maxLines: 3),
          ],
        );

      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add your best photos',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text('Upload at least 2 photos to get started.', style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 28),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: 6,
              itemBuilder: (context, idx) {
                final hasImage = idx < 2;
                final imageUrls = [
                  'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=400&q=80',
                  'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=400&q=80',
                ];

                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 280 + idx * 60),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) => Transform.scale(scale: value, child: child),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                      image: hasImage
                          ? DecorationImage(
                              image: NetworkImage(imageUrls[idx]),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: !hasImage
                        ? const Icon(Icons.add_a_photo_rounded, color: AppTheme.primaryRose, size: 28)
                        : Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              margin: const EdgeInsets.all(6),
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
                            ),
                          ),
                  ),
                );
              },
            ),
          ],
        );

      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select your interests',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text('Choose 3 to 5 passions that describe you.', style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 24),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _allInterests.map((interest) {
                final isSelected = _selectedInterests.contains(interest);

                return AnimatedScale(
                  scale: isSelected ? 1.05 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutBack,
                  child: FilterChip(
                    label: Text(interest),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedInterests.add(interest);
                        } else {
                          _selectedInterests.remove(interest);
                        }
                      });
                    },
                    selectedColor: AppTheme.primaryRose,
                    backgroundColor: AppTheme.surfaceCard,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? AppTheme.primaryRose : Colors.white12,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );

      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What are you looking for?',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text('Be open about your relationship goals.', style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 28),
            Column(
              children: _goals.map((goal) {
                final isSelected = _selectedGoal == goal;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedGoal = goal;
                    });
                  },
                  child: AnimatedScale(
                    scale: isSelected ? 1.02 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutBack,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppTheme.primaryRose : Colors.white12,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppTheme.primaryRose.withOpacity(0.25),
                                  blurRadius: 14,
                                  offset: const Offset(0, 5),
                                ),
                              ]
                            : [],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            goal,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (child, animation) =>
                                ScaleTransition(scale: animation, child: child),
                            child: Icon(
                              isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                              key: ValueKey(isSelected),
                              color: isSelected ? AppTheme.primaryRose : Colors.white24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );

      // ── Step 4: Lifestyle ─────────────────────────────────────────────────
      case 4:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your lifestyle 🌿',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text('Help matches understand how you live.', style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 28),
            _buildLifestyleSection('🍷 Drinking', _drinkingOptions, _drinking, (v) => setState(() => _drinking = v)),
            const SizedBox(height: 20),
            _buildLifestyleSection('🚬 Smoking', _smokingOptions, _smoking, (v) => setState(() => _smoking = v)),
            const SizedBox(height: 20),
            _buildLifestyleSection('🏃 Exercise', _exerciseOptions, _exercise, (v) => setState(() => _exercise = v)),
            const SizedBox(height: 20),
            _buildLifestyleSection('🐾 Pets', _petsOptions, _pets, (v) => setState(() => _pets = v)),
          ],
        );

      // ── Step 5: Basic Details ─────────────────────────────────────────────
      case 5:
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'A few more details ✨',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text('These help us find your best matches.', style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 28),
            _buildInputField('University / College', _educationController, Icons.school_rounded),
            const SizedBox(height: 24),
            const Text('Your Height', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _heightOptions.map((h) {
                final isSelected = _selectedHeight == h;
                return GestureDetector(
                  onTap: () => setState(() => _selectedHeight = h),
                  child: AnimatedScale(
                    scale: isSelected ? 1.06 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutBack,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: isSelected ? AppTheme.primaryGradient : null,
                        color: isSelected ? null : AppTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isSelected ? Colors.transparent : Colors.white12),
                      ),
                      child: Text(
                        h,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.textSecondary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text('Personality Type (MBTI)', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
            const SizedBox(height: 4),
            const Text('Optional — helps with compatibility', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _mbtiOptions.map((type) {
                final isSelected = _selectedMbti == type;
                final color = _mbtiColorForType(type);
                return GestureDetector(
                  onTap: () => setState(() => _selectedMbti = type),
                  child: AnimatedScale(
                    scale: isSelected ? 1.06 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutBack,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? color.withOpacity(0.25) : AppTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: isSelected ? color : Colors.white12, width: isSelected ? 2 : 1),
                      ),
                      child: Text(
                        type,
                        style: TextStyle(
                          color: isSelected ? color : AppTheme.textSecondary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
    }
  }

  Widget _buildInputField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          icon: Icon(icon, color: AppTheme.primaryRose),
          labelText: label,
          labelStyle: const TextStyle(color: AppTheme.textMuted),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildLifestyleSection(String label, List<String> options, String selected, ValueChanged<String> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options.map((opt) {
            final isSelected = selected == opt;
            return GestureDetector(
              onTap: () => onChanged(opt),
              child: AnimatedScale(
                scale: isSelected ? 1.05 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: isSelected ? AppTheme.primaryGradient : null,
                    color: isSelected ? null : AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSelected ? Colors.transparent : Colors.white12),
                  ),
                  child: Text(
                    opt,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _mbtiColorForType(String type) {
    const analysts = ['INTJ', 'INTP', 'ENTJ', 'ENTP'];
    const diplomats = ['INFJ', 'INFP', 'ENFJ', 'ENFP'];
    const sentinels = ['ISTJ', 'ISFJ', 'ESTJ', 'ESFJ'];
    if (analysts.contains(type)) return AppTheme.primaryPurple;
    if (diplomats.contains(type)) return AppTheme.emeraldGreen;
    if (sentinels.contains(type)) return AppTheme.accentCyan;
    return AppTheme.accentGold; // explorers
  }
}

/// Continue/Complete button with real press feedback — scales down and
/// softens on tap-down, springs back on release. Mirrors the button used on
/// the discovery filter sheet so the whole app feels like one product.
class _AnimatedContinueButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  const _AnimatedContinueButton({required this.label, required this.onPressed});

  @override
  State<_AnimatedContinueButton> createState() => _AnimatedContinueButtonState();
}

class _AnimatedContinueButtonState extends State<_AnimatedContinueButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppTheme.primaryRose,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryRose.withOpacity(_pressed ? 0.2 : 0.4),
                  blurRadius: _pressed ? 8 : 16,
                  offset: Offset(0, _pressed ? 3 : 6),
                ),
              ],
            ),
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  widget.label,
                  key: ValueKey(widget.label),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: Colors.white,
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