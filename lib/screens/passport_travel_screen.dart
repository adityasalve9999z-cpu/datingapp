import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PassportTravelScreen extends StatefulWidget {
  final String currentCity;
  final Function(String city, String country)? onLocationSelected;

  const PassportTravelScreen({
    super.key,
    this.currentCity = 'Current Location (GPS)',
    this.onLocationSelected,
  });

  @override
  State<PassportTravelScreen> createState() => _PassportTravelScreenState();
}

class _PassportTravelScreenState extends State<PassportTravelScreen> {
  final TextEditingController _searchController = TextEditingController();
  late String _selectedCity;
  String _selectedCountry = '';

  final List<_PassportDestination> _destinations = const [
    _PassportDestination(
      city: 'Paris',
      country: 'France',
      flag: '🇫🇷',
      tagline: 'The City of Romance',
      activeDaters: '14.2k active sparks',
      imageUrl:
          'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=600',
    ),
    _PassportDestination(
      city: 'Tokyo',
      country: 'Japan',
      flag: '🇯🇵',
      tagline: 'Neon Nights & Izakaya Dates',
      activeDaters: '22.8k active sparks',
      imageUrl:
          'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?w=600',
    ),
    _PassportDestination(
      city: 'New York',
      country: 'United States',
      flag: '🇺🇸',
      tagline: 'Rooftops, Jazz & Fast Connections',
      activeDaters: '35.4k active sparks',
      imageUrl:
          'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?w=600',
    ),
    _PassportDestination(
      city: 'London',
      country: 'United Kingdom',
      flag: '🇬🇧',
      tagline: 'Soho Pubs & River Thames Walks',
      activeDaters: '19.1k active sparks',
      imageUrl:
          'https://images.unsplash.com/photo-1513635269975-59663e0ac1ad?w=600',
    ),
    _PassportDestination(
      city: 'Bali',
      country: 'Indonesia',
      flag: '🇮🇩',
      tagline: 'Sunset Surf & Beachfront Chill',
      activeDaters: '8.7k active sparks',
      imageUrl:
          'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=600',
    ),
    _PassportDestination(
      city: 'Sydney',
      country: 'Australia',
      flag: '🇦🇺',
      tagline: 'Bondi Vibes & Harbour Brunches',
      activeDaters: '11.5k active sparks',
      imageUrl:
          'https://images.unsplash.com/photo-1506973035872-a4ec16b8e8d9?w=600',
    ),
    _PassportDestination(
      city: 'Milan',
      country: 'Italy',
      flag: '🇮🇹',
      tagline: 'Aperitivo & High Fashion',
      activeDaters: '9.3k active sparks',
      imageUrl:
          'https://images.unsplash.com/photo-1513581166391-887a96ddeafd?w=600',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedCity = widget.currentCity;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_PassportDestination> get _filteredDestinations {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _destinations;
    return _destinations
        .where((d) =>
            d.city.toLowerCase().contains(query) ||
            d.country.toLowerCase().contains(query))
        .toList();
  }

  void _applyTeleport(String city, String country) {
    setState(() {
      _selectedCity = city;
      _selectedCountry = country;
    });
    widget.onLocationSelected?.call(city, country);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.flight_takeoff_rounded,
                color: AppTheme.accentGold, size: 20),
            const SizedBox(width: 8),
            Text('✈️ Teleported to $city, $country!'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.surfaceCard,
      ),
    );

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) Navigator.pop(context, {'city': city, 'country': country});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.public_rounded, color: AppTheme.accentCyan, size: 20),
            SizedBox(width: 8),
            Text(
              'GlowDate Passport',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── Search & Teleport Input ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search any world city or country…',
                  hintStyle:
                      const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppTheme.accentCyan, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: AppTheme.textMuted, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
          ),

          // ── Current Active Location Card ──────────────────────────────────
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.accentCyan.withValues(alpha: 0.15),
                  AppTheme.surfaceDark,
                ],
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppTheme.accentCyan.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.my_location_rounded,
                    color: AppTheme.accentCyan, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CURRENT PASSPORT LOCATION',
                        style: TextStyle(
                          color: AppTheme.accentCyan,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _selectedCity.contains(',')
                            ? _selectedCity
                            : '$_selectedCity ${_selectedCountry.isNotEmpty ? ', $_selectedCountry' : ''}',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      _applyTeleport('Current Location (GPS)', ''),
                  child: const Text(
                    'Reset GPS',
                    style: TextStyle(
                      color: AppTheme.accentGold,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ── Curated Global Destinations Grid ──────────────────────────────
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: _filteredDestinations.length,
              itemBuilder: (context, index) {
                final dest = _filteredDestinations[index];
                final isCurrent = _selectedCity.contains(dest.city);

                return GestureDetector(
                  onTap: () => _applyTeleport(dest.city, dest.country),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    height: 110,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: NetworkImage(dest.imageUrl),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(
                        color: isCurrent
                            ? AppTheme.accentGold
                            : Colors.white.withValues(alpha: 0.12),
                        width: isCurrent ? 2 : 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0x33160D1C),
                                Color(0xD9160D1C),
                              ],
                              stops: [0.0, 0.75],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: [
                                        Text(dest.flag,
                                            style: const TextStyle(fontSize: 18)),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${dest.city}, ${dest.country}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${dest.tagline} • ${dest.activeDaters}',
                                      style: TextStyle(
                                        color: Colors.white
                                            .withValues(alpha: 0.85),
                                        fontSize: 11.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: isCurrent
                                      ? AppTheme.primaryGradient
                                      : null,
                                  color: isCurrent
                                      ? null
                                      : AppTheme.darkBackground
                                          .withValues(alpha: 0.75),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isCurrent
                                        ? Colors.transparent
                                        : Colors.white30,
                                  ),
                                ),
                                child: Text(
                                  isCurrent ? 'Active 📍' : 'Teleport ✈️',
                                  style: TextStyle(
                                    color: isCurrent
                                        ? AppTheme.darkBackground
                                        : Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PassportDestination {
  final String city;
  final String country;
  final String flag;
  final String tagline;
  final String activeDaters;
  final String imageUrl;

  const _PassportDestination({
    required this.city,
    required this.country,
    required this.flag,
    required this.tagline,
    required this.activeDaters,
    required this.imageUrl,
  });
}
