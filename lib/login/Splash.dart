import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_glow_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.6),
            radius: 1.3,
            colors: [
              Color(0x33D4A857),
              AppTheme.darkBackground,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              children: [
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.sunsetGradient,
                  ),
                  child: const Icon(Icons.favorite_rounded, size: 60, color: Colors.white),
                ),
                const SizedBox(height: 32),
                ShaderMask(
                  shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(bounds),
                  child: const Text(
                    'GlowDate',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Where meaningful connections and sparks ignite.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
                const Spacer(),
                AnimatedGlowButton(
                  label: 'CREATE ACCOUNT',
                  gradient: AppTheme.primaryGradient,
                  onPressed: () => context.go('/signup'),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textPrimary,
                    side: const BorderSide(color: Colors.white24),
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  onPressed: () => context.go('/login'),
                  child: const Text(
                    'SIGN IN',
                    style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
