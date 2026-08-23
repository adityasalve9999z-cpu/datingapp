import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_glow_button.dart';

class PhotoVerificationScreen extends StatefulWidget {
  const PhotoVerificationScreen({super.key});

  @override
  State<PhotoVerificationScreen> createState() =>
      _PhotoVerificationScreenState();
}

class _PhotoVerificationScreenState extends State<PhotoVerificationScreen>
    with TickerProviderStateMixin {
  int _step = 0; // 0: Intro, 1: Selfie Camera Pose 1, 2: Selfie Pose 2, 3: Verifying AI, 4: Success
  bool _isAnalyzing = false;
  double _scanProgress = 0.0;
  Timer? _scanTimer;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;
  late final AnimationController _scanLineController;
  late final Animation<double> _scanLineAnim;

  final List<String> _poses = [
    'Look straight into the camera & smile',
    'Turn your head slightly to the right 👉',
    'Tilt your head up slightly 👆',
  ];
  int _currentPoseIndex = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _pulseAnim = CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut);

    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
    _scanLineAnim = CurvedAnimation(parent: _scanLineController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scanLineController.dispose();
    _scanTimer?.cancel();
    super.dispose();
  }

  void _startVerificationFlow() {
    setState(() {
      _step = 1;
      _currentPoseIndex = 0;
    });
  }

  void _captureCurrentPose() {
    if (_currentPoseIndex < _poses.length - 1) {
      setState(() {
        _currentPoseIndex++;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pose ${_currentPoseIndex} captured! Now: ${_poses[_currentPoseIndex]}'),
          duration: const Duration(milliseconds: 1400),
          backgroundColor: AppTheme.primaryPurple,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      // Start AI Biometric verification
      setState(() {
        _step = 3;
        _isAnalyzing = true;
        _scanProgress = 0.0;
      });

      _scanTimer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
        if (!mounted) return;
        setState(() {
          _scanProgress += 0.025;
        });

        if (_scanProgress >= 1.0) {
          _scanTimer?.cancel();
          setState(() {
            _isAnalyzing = false;
            _step = 4;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Profile Verification'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: _buildCurrentStepView(),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStepView() {
    switch (_step) {
      case 0:
        return _buildIntroView();
      case 1:
      case 2:
        return _buildCameraPoseView();
      case 3:
        return _buildAnalyzingView();
      case 4:
        return _buildSuccessView();
      default:
        return _buildIntroView();
    }
  }

  Widget _buildIntroView() {
    return ListView(
      key: const ValueKey('intro'),
      physics: const BouncingScrollPhysics(),
      children: [
        const SizedBox(height: 20),
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseAnim,
                builder: (context, child) {
                  return Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.accentCyan.withValues(alpha: 0.15 * _pulseAnim.value),
                    ),
                  );
                },
              ),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppTheme.accentCyan, AppTheme.primaryPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentCyan.withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  color: Colors.white,
                  size: 54,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        const Text(
          'Get Your Verified Badge',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Stand out from the crowd! Verified profiles get up to 300% more matches and instant trust with other users.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        _buildBenefitCard(
          icon: Icons.shield_rounded,
          color: AppTheme.emeraldGreen,
          title: '100% Genuine Match Guarantee',
          desc: 'Prove you are real and unlock verified-only chat rooms & events.',
        ),
        const SizedBox(height: 14),
        _buildBenefitCard(
          icon: Icons.auto_awesome_rounded,
          color: AppTheme.accentGold,
          title: '3x More Profile Views',
          desc: 'Our algorithm prioritizes verified members in Discovery and Hot Picks.',
        ),
        const SizedBox(height: 14),
        _buildBenefitCard(
          icon: Icons.privacy_tip_rounded,
          color: AppTheme.accentCyan,
          title: 'Privacy Protected',
          desc: 'Your selfie video is only used for biometric check and never posted publicly.',
        ),
        const SizedBox(height: 40),
        AnimatedGlowButton(
          text: 'Start Verification',
          icon: Icons.camera_alt_rounded,
          onPressed: _startVerificationFlow,
        ),
      ],
    );
  }

  Widget _buildBenefitCard({
    required IconData icon,
    required Color color,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
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
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPoseView() {
    return Column(
      key: ValueKey('camera_pose_$_currentPoseIndex'),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.accentCyan.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.touch_app_rounded, color: AppTheme.accentCyan, size: 18),
              const SizedBox(width: 8),
              Text(
                'Step ${_currentPoseIndex + 1} of ${_poses.length}',
                style: const TextStyle(
                  color: AppTheme.accentCyan,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _poses[_currentPoseIndex],
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        // Camera Viewfinder Simulation
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF141220),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white12, width: 2),
                ),
                child: Center(
                  child: Icon(
                    Icons.face_retouching_natural_rounded,
                    size: 110,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
              ),
              // Oval Face Outline
              Container(
                width: 220,
                height: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(120),
                  border: Border.all(
                    color: AppTheme.accentCyan.withValues(alpha: 0.8),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accentCyan.withValues(alpha: 0.25),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              // Moving Laser Scan Line
              AnimatedBuilder(
                animation: _scanLineAnim,
                builder: (context, child) {
                  return Positioned(
                    top: 40 + (240 * _scanLineAnim.value),
                    child: Container(
                      width: 200,
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppTheme.accentCyan,
                            AppTheme.primaryRose,
                            Colors.transparent,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentCyan.withValues(alpha: 0.8),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        AnimatedGlowButton(
          text: 'Snap Pose',
          icon: Icons.camera_rounded,
          onPressed: _captureCurrentPose,
        ),
      ],
    );
  }

  Widget _buildAnalyzingView() {
    return Center(
      key: const ValueKey('analyzing'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: _scanProgress,
                  strokeWidth: 6,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentCyan),
                  backgroundColor: Colors.white10,
                ),
              ),
              const Icon(
                Icons.fingerprint_rounded,
                color: AppTheme.accentCyan,
                size: 64,
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'Analyzing Biometric Match...',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(_scanProgress * 100).toInt()}% Verified against AI safety model',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13.5),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.lock_rounded, color: AppTheme.emeraldGreen, size: 16),
                SizedBox(width: 8),
                Text(
                  'Encrypted & Secure Verification',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      key: const ValueKey('success'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AppTheme.emeraldGreen, Color(0xFF059669)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.emeraldGreen.withValues(alpha: 0.5),
                  blurRadius: 28,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: Colors.white,
              size: 68,
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'You Are Verified! 🎉',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Your profile now displays the official GlowDate Blue Verification Badge. Enjoy boosted matching and trusted dating!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 36),
          AnimatedGlowButton(
            text: 'Return to Profile',
            icon: Icons.check_rounded,
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
          ),
        ],
      ),
    );
  }
}
