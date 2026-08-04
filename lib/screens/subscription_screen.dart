import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_glow_button.dart';
import '../widgets/shimmer_loading.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  int _selectedTier = 1; // 0: 1 Week, 1: 1 Month, 2: 3 Months
  bool _isPlatinum = true;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('GlowDate VIP'),
        centerTitle: true,
      ),
      body: GlowLoadingOverlay(
        isLoading: _isProcessing,
        message: 'Upgrading your membership...',
        child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Floating Crown Badge
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _isPlatinum ? AppTheme.sunsetGradient : AppTheme.goldGradient,
                boxShadow: [
                  BoxShadow(
                    color: (_isPlatinum ? AppTheme.primaryRose : AppTheme.accentGold).withOpacity(0.5),
                    blurRadius: 30,
                  ),
                ],
              ),
              child: const Icon(Icons.workspace_premium_rounded, size: 54, color: Colors.white),
            ),
            const SizedBox(height: 20),

            // Subscription Title
            Text(
              _isPlatinum ? 'GLOWDATE PLATINUM' : 'GLOWDATE GOLD',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: _isPlatinum ? Colors.white : AppTheme.accentGold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Unlock 5x more matches with VIP privileges',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),

            const SizedBox(height: 24),

            // Tier Switcher Pill
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isPlatinum = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isPlatinum ? AppTheme.accentGold : Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          'Gold',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: !_isPlatinum ? Colors.black : AppTheme.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isPlatinum = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          gradient: _isPlatinum ? AppTheme.primaryGradient : null,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          'Platinum',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _isPlatinum ? Colors.white : AppTheme.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Features Breakdown List
            _buildFeatureRow('See Who Likes You Instantly', true),
            _buildFeatureRow('Unlimited Right Swipes & Likes', true),
            _buildFeatureRow('5 Free Super Likes Per Day', true),
            _buildFeatureRow('1 Monthly Profile Boost (10x Views)', true),
            _buildFeatureRow('Rewind / Undo Last Swipe', true),
            _buildFeatureRow('Passport Mode to Swipe Anywhere', _isPlatinum),

            const SizedBox(height: 32),

            // Duration & Price Options Grid
            Row(
              children: [
                _buildPriceCard(0, '1 Week', '\$6.99', '/wk'),
                const SizedBox(width: 10),
                _buildPriceCard(1, '1 Month', '\$14.99', '/mo', isBestValue: true),
                const SizedBox(width: 10),
                _buildPriceCard(2, '3 Months', '\$29.99', '\$9.99/mo'),
              ],
            ),

            const SizedBox(height: 32),

            // Primary Purchase Button
            AnimatedGlowButton(
              label: 'CONTINUE & UNLOCK',
              onPressed: _isProcessing
                  ? null
                  : () async {
                      setState(() => _isProcessing = true);
                      final tier = _selectedTier == 0 ? '1_week' : _selectedTier == 2 ? '3_months' : '1_month';
                      final result = await AppApiService.purchaseSubscription(tier);
                      if (!mounted) return;
                      setState(() => _isProcessing = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result['message'] as String),
                          backgroundColor: AppTheme.surfaceDark,
                        ),
                      );
                      Navigator.pop(context);
                    },
              backgroundColor: AppTheme.accentGold,
              foregroundColor: Colors.black,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Recurring billing. Cancel anytime in settings.',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildFeatureRow(String title, bool isIncluded) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isIncluded
                  ? (_isPlatinum ? AppTheme.primaryRose : AppTheme.accentGold)
                  : Colors.white10,
            ),
            child: Icon(
              isIncluded ? Icons.check_rounded : Icons.close_rounded,
              color: isIncluded ? Colors.black : Colors.white38,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: isIncluded ? AppTheme.textPrimary : AppTheme.textMuted,
              fontSize: 14,
              fontWeight: isIncluded ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(int index, String duration, String price, String subtext, {bool isBestValue = false}) {
    final isSelected = _selectedTier == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTier = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected
                  ? (_isPlatinum ? AppTheme.primaryRose : AppTheme.accentGold)
                  : Colors.white12,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: (_isPlatinum ? AppTheme.primaryRose : AppTheme.accentGold).withOpacity(0.3),
                      blurRadius: 12,
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              if (isBestValue)
                Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRose,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'BEST',
                    style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              Text(
                duration,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                price,
                style: TextStyle(
                  color: isSelected ? (_isPlatinum ? AppTheme.primaryRose : AppTheme.accentGold) : Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtext,
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
