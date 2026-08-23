import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_glow_button.dart';

class PaymentScreen extends StatefulWidget {
  final String? planTitle;
  final String? planPrice;
  final String? planPeriod;

  const PaymentScreen({
    super.key,
    this.planTitle,
    this.planPrice,
    this.planPeriod,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin {
  int _selectedMethodIndex = 0; // 0: Card, 1: Apple/Google Pay, 2: PayPal, 3: UPI
  int _selectedDurationIndex = 1; // 0: 1 Mo, 1: 6 Mo (30% off), 2: 12 Mo (50% off)
  int _activeTab = 0; // 0: Subscription, 1: Coin Packs / Boosts

  // Card form controllers
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _promoController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;
  bool _promoApplied = false;
  double _promoDiscount = 0.0;
  String _appliedPromoCode = '';

  late final AnimationController _cardGlowController;
  late final Animation<double> _cardGlowAnim;

  final List<Map<String, dynamic>> _durations = [
    {
      'months': 1,
      'label': '1 Month',
      'pricePerMonth': 19.99,
      'totalPrice': 19.99,
      'savings': null,
      'badge': null,
    },
    {
      'months': 6,
      'label': '6 Months',
      'pricePerMonth': 13.99,
      'totalPrice': 83.94,
      'savings': 'Save 30%',
      'badge': 'MOST POPULAR',
    },
    {
      'months': 12,
      'label': '12 Months',
      'pricePerMonth': 9.99,
      'totalPrice': 119.88,
      'savings': 'Save 50%',
      'badge': 'BEST VALUE',
    },
  ];

  final List<Map<String, dynamic>> _coinPacks = [
    {
      'id': 'boost_3',
      'title': '3 Super Boosts',
      'subtitle': '10x more profile views for 1 hour',
      'icon': Icons.bolt_rounded,
      'color': Color(0xFFFFB800),
      'price': '\$6.99',
      'badge': 'HOT',
    },
    {
      'id': 'superlikes_15',
      'title': '15 Super Likes',
      'subtitle': 'Stand out with 3x higher match rate',
      'icon': Icons.star_rounded,
      'color': Color(0xFF05D5E4),
      'price': '\$9.99',
      'badge': 'VALUE',
    },
    {
      'id': 'ai_unlimited',
      'title': 'AI Date Planner Pass',
      'subtitle': '1 Month unlimited custom date itineraries',
      'icon': Icons.auto_awesome_rounded,
      'color': Color(0xFFFF2A6D),
      'price': '\$4.99',
      'badge': 'NEW',
    },
    {
      'id': 'coins_500',
      'title': '500 Glow Coins',
      'subtitle': 'Spend on gifts, rewinds & mystery picks',
      'icon': Icons.monetization_on_rounded,
      'color': Color(0xFF10B981),
      'price': '\$14.99',
      'badge': 'POPULAR',
    },
  ];

  @override
  void initState() {
    super.initState();
    _cardGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _cardGlowAnim = CurvedAnimation(
      parent: _cardGlowController,
      curve: Curves.easeInOut,
    );

    _cardNumberController.addListener(() => setState(() {}));
    _cardHolderController.addListener(() => setState(() {}));
    _expiryController.addListener(() => setState(() {}));
    _cvvController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _cardGlowController.dispose();
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  void _applyPromo() {
    final code = _promoController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    if (code == 'GLOW20' || code == 'MATCH50' || code == 'VIPLOVE') {
      setState(() {
        _promoApplied = true;
        _appliedPromoCode = code;
        _promoDiscount = code == 'MATCH50' ? 0.50 : 0.20;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Promo code "$code" applied! ${(_promoDiscount * 100).toInt()}% discount added.'),
          backgroundColor: AppTheme.emeraldGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid promo code. Try "GLOW20" or "MATCH50"'),
          backgroundColor: AppTheme.primaryRose,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  double get _currentBaseTotal {
    if (_activeTab == 0) {
      return (_durations[_selectedDurationIndex]['totalPrice'] as num).toDouble();
    }
    return 9.99;
  }

  double get _finalTotal {
    final base = _currentBaseTotal;
    if (_promoApplied) {
      return base * (1.0 - _promoDiscount);
    }
    return base;
  }

  Future<void> _processPayment() async {
    if (_selectedMethodIndex == 0 && !_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isProcessing = true);

    // Simulate network processing
    await Future.delayed(const Duration(milliseconds: 2000));

    if (!mounted) return;
    setState(() => _isProcessing = false);

    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: AppTheme.surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
            side: BorderSide(color: AppTheme.emeraldGreen.withValues(alpha: 0.5), width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.emeraldGreen.withValues(alpha: 0.3),
                        AppTheme.emeraldGreen.withValues(alpha: 0.05),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.emeraldGreen.withValues(alpha: 0.4),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppTheme.emeraldGreen,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Payment Successful!',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _activeTab == 0
                      ? 'Welcome to GlowDate ${widget.planTitle ?? 'Gold'}! Your premium features are active.'
                      : 'Pack purchased successfully! Boost & credits added to your account.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Amount Charged:',
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                      ),
                      Text(
                        '\$${_finalTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppTheme.accentGold,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AnimatedGlowButton(
                  text: 'Start Exploring',
                  icon: Icons.favorite_rounded,
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/home');
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final planName = widget.planTitle ?? 'Gold Premium';

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Checkout & Upgrade'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            physics: const BouncingScrollPhysics(),
            children: [
              _buildTypeTabs(),
              const SizedBox(height: 20),
              if (_activeTab == 0) ...[
                _buildPlanHeader(planName),
                const SizedBox(height: 20),
                _buildDurationSelector(),
              ] else ...[
                _buildCoinPacksGrid(),
              ],
              const SizedBox(height: 24),
              _sectionTitle('Payment Method'),
              _buildPaymentMethodSelector(),
              const SizedBox(height: 20),
              if (_selectedMethodIndex == 0) _buildCardForm(),
              if (_selectedMethodIndex == 1) _buildInstantPayView('Apple Pay / Google Pay', Icons.phone_iphone_rounded),
              if (_selectedMethodIndex == 2) _buildInstantPayView('PayPal Instant Connect', Icons.account_balance_wallet_rounded),
              if (_selectedMethodIndex == 3) _buildInstantPayView('UPI & Net Banking', Icons.qr_code_scanner_rounded),
              const SizedBox(height: 24),
              _buildPromoSection(),
              const SizedBox(height: 24),
              _buildOrderSummary(),
              const SizedBox(height: 16),
              _buildSecurityAssurance(),
            ],
          ),
          _buildStickyBottomBar(),
        ],
      ),
    );
  }

  Widget _buildTypeTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeTab = 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: _activeTab == 0 ? AppTheme.primaryGradient : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Membership Plans',
                    style: TextStyle(
                      color: _activeTab == 0 ? Colors.white : AppTheme.textMuted,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _activeTab = 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: _activeTab == 1 ? AppTheme.goldGradient : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Boosts & Coins',
                    style: TextStyle(
                      color: _activeTab == 1 ? Colors.white : AppTheme.textMuted,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanHeader(String name) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.sunsetGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryRose.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'VIP',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Unlimited likes, see who likes you, 5 free Super Likes/wk',
                  style: TextStyle(color: Colors.white70, fontSize: 12.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Select Duration'),
        Row(
          children: List.generate(_durations.length, (index) {
            final item = _durations[index];
            final isSelected = _selectedDurationIndex == index;
            final isPopular = item['badge'] != null;

            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedDurationIndex = index),
                child: Container(
                  margin: EdgeInsets.only(
                    right: index == _durations.length - 1 ? 0 : 8,
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primaryRose.withValues(alpha: 0.12)
                              : AppTheme.surfaceCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? AppTheme.primaryRose : Colors.white12,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppTheme.primaryRose.withValues(alpha: 0.25),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: Column(
                          children: [
                            Text(
                              item['label'] as String,
                              style: TextStyle(
                                color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '\$${(item['pricePerMonth'] as num).toStringAsFixed(2)}',
                              style: TextStyle(
                                color: isSelected ? AppTheme.primaryRose : AppTheme.textPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            const Text(
                              '/mo',
                              style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                            ),
                            if (item['savings'] != null) ...[
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.emeraldGreen.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  item['savings'] as String,
                                  style: const TextStyle(
                                    color: AppTheme.emeraldGreen,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (isPopular)
                        Positioned(
                          top: -10,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                item['badge'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCoinPacksGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Choose Add-On Pack'),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _coinPacks.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final pack = _coinPacks[index];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (pack['color'] as Color).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      pack['icon'] as IconData,
                      color: pack['color'] as Color,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              pack['title'] as String,
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14.5,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: (pack['color'] as Color).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                pack['badge'] as String,
                                style: TextStyle(
                                  color: pack['color'] as Color,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          pack['subtitle'] as String,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    pack['price'] as String,
                    style: const TextStyle(
                      color: AppTheme.accentGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSelector() {
    final methods = [
      {'name': 'Credit Card', 'icon': Icons.credit_card_rounded},
      {'name': 'Apple/Google', 'icon': Icons.account_balance_wallet_rounded},
      {'name': 'PayPal', 'icon': Icons.payments_rounded},
      {'name': 'UPI / Net', 'icon': Icons.qr_code_rounded},
    ];

    return Row(
      children: List.generate(methods.length, (index) {
        final isSelected = _selectedMethodIndex == index;
        final m = methods[index];

        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedMethodIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: index == methods.length - 1 ? 0 : 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryPurple.withValues(alpha: 0.15)
                    : AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryPurple : Colors.white10,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    m['icon'] as IconData,
                    color: isSelected ? AppTheme.primaryPurple : AppTheme.textMuted,
                    size: 22,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    m['name'] as String,
                    style: TextStyle(
                      color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCardForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // 3D Card Simulation Preview
          AnimatedBuilder(
            animation: _cardGlowAnim,
            builder: (context, child) {
              return Container(
                height: 190,
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2C1947), Color(0xFF160E2A), Color(0xFF0F0B1E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: AppTheme.primaryPurple.withValues(alpha: 0.3 + 0.3 * _cardGlowAnim.value),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPurple.withValues(alpha: 0.2 * _cardGlowAnim.value),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.nfc_rounded, color: Colors.white70, size: 28),
                        Row(
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.red.withValues(alpha: 0.85),
                              ),
                            ),
                            Transform.translate(
                              offset: const Offset(-10, 0),
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.amber.withValues(alpha: 0.85),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text(
                      _cardNumberController.text.isEmpty
                          ? '•••• •••• •••• ••••'
                          : _cardNumberController.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 3,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'CARD HOLDER',
                              style: TextStyle(color: Colors.white54, fontSize: 9, letterSpacing: 1),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _cardHolderController.text.isEmpty
                                  ? 'YOUR NAME'
                                  : _cardHolderController.text.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'EXPIRES',
                              style: TextStyle(color: Colors.white54, fontSize: 9, letterSpacing: 1),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _expiryController.text.isEmpty ? 'MM/YY' : _expiryController.text,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 18),
          _buildInputField(
            controller: _cardNumberController,
            label: 'Card Number',
            hint: '4111 2222 3333 4444',
            icon: Icons.credit_card_rounded,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
              _CardNumberFormatter(),
            ],
            validator: (v) => (v == null || v.length < 19) ? 'Please enter a valid 16-digit card' : null,
          ),
          const SizedBox(height: 12),
          _buildInputField(
            controller: _cardHolderController,
            label: 'Cardholder Name',
            hint: 'Alex Morgan',
            icon: Icons.person_rounded,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter cardholder name' : null,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  controller: _expiryController,
                  label: 'Expiry Date',
                  hint: 'MM/YY',
                  icon: Icons.calendar_month_rounded,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                    _ExpiryFormatter(),
                  ],
                  validator: (v) => (v == null || v.length < 5) ? 'Invalid MM/YY' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInputField(
                  controller: _cvvController,
                  label: 'CVV / CVC',
                  hint: '123',
                  icon: Icons.lock_outline_rounded,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  validator: (v) => (v == null || v.length < 3) ? '3 or 4 digits' : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstantPayView(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: AppTheme.accentCyan),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Fast, 1-touch checkout with biometric verification.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 12.5),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12.5, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          inputFormatters: inputFormatters,
          validator: validator,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
            prefixIcon: Icon(icon, color: AppTheme.primaryPurple, size: 20),
            filled: true,
            fillColor: AppTheme.surfaceCard,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.white12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.white12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.primaryPurple, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPromoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.discount_rounded, color: AppTheme.accentGold, size: 18),
              SizedBox(width: 8),
              Text(
                'Have a Promo Code?',
                style: TextStyle(color: AppTheme.textPrimary, fontSize: 13.5, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _promoController,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Enter code (e.g. GLOW20)',
                    hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    filled: true,
                    fillColor: AppTheme.darkBackground,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _applyPromo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
                child: const Text('Apply', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          _summaryRow(
            'Subtotal',
            '\$${_currentBaseTotal.toStringAsFixed(2)}',
          ),
          if (_promoApplied) ...[
            const SizedBox(height: 8),
            _summaryRow(
              'Promo ($_appliedPromoCode)',
              '-\$${(_currentBaseTotal * _promoDiscount).toStringAsFixed(2)}',
              valueColor: AppTheme.emeraldGreen,
            ),
          ],
          const SizedBox(height: 8),
          _summaryRow('Estimated Taxes', '\$0.00'),
          const Divider(color: Colors.white12, height: 20),
          _summaryRow(
            'Total Due Today',
            '\$${_finalTotal.toStringAsFixed(2)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? valueColor, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? AppTheme.textPrimary : AppTheme.textSecondary,
            fontSize: isTotal ? 15 : 13,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? (isTotal ? AppTheme.accentGold : AppTheme.textPrimary),
            fontSize: isTotal ? 18 : 13.5,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityAssurance() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.lock_rounded, color: AppTheme.emeraldGreen, size: 16),
        const SizedBox(width: 6),
        Text(
          '256-Bit SSL Encrypted  •  Cancel Anytime in Settings',
          style: TextStyle(color: AppTheme.textMuted.withValues(alpha: 0.9), fontSize: 11.5),
        ),
      ],
    );
  }

  Widget _buildStickyBottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark.withValues(alpha: 0.96),
          border: const Border(top: BorderSide(color: Colors.white10)),
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TOTAL AMOUNT',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 10, letterSpacing: 1),
                ),
                Text(
                  '\$${_finalTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: AnimatedGlowButton(
                text: _isProcessing ? 'Processing...' : 'Pay & Unlock Now',
                icon: _isProcessing ? Icons.sync : Icons.lock_open_rounded,
                onPressed: _isProcessing ? () {} : _processPayment,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// Input Formatters
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(text[i]);
    }
    final str = buffer.toString();
    return TextEditingValue(
      text: str,
      selection: TextSelection.collapsed(offset: str.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(text[i]);
    }
    final str = buffer.toString();
    return TextEditingValue(
      text: str,
      selection: TextSelection.collapsed(offset: str.length),
    );
  }
}
