import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../services/api_service.dart';
import '../widgets/shimmer_loading.dart';
import 'chat_room_screen.dart';

// ---------------------------------------------------------------------------
// Lume palette — kept local here so this file is drop-in runnable even before
// you sync it into your shared app_theme.dart. If you already have an
// AppTheme class, replace `LumeColors.x` below with `AppTheme.x` once you've
// added these same values there — see the note at the bottom of this file.
// ---------------------------------------------------------------------------
class LumeColors {
  static const bg = Color(0xFF160D1C);
  static const bgGradientEnd = Color(0xFF2A1830);
  static const surface = Color(0xFF221328);
  static const surfaceRaised = Color(0xFF2A1A32);
  static const surfaceBorder = Color(0xFF3A2740);
  static const gold = Color(0xFFD4A857);
  static const goldDim = Color(0xFF8A7245);
  static const blush = Color(0xFFE8A7A0);
  static const textPrimary = Color(0xFFF3EEE9);
  static const textSecondary = Color(0xFFA79AAE);
  static const textMuted = Color(0xFF6E6274);
  static const online = Color(0xFF8FBF9F); // muted sage, not a jarring bright green

  static const goldGradient = LinearGradient(
    colors: [gold, Color(0xFFC79340)],
  );
}

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _conversations = [];
  List<ProfileModel> _profiles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    final profiles = await AppApiService.fetchProfiles();
    final matches = await AppApiService.fetchMatches();
    if (!mounted) return;
    setState(() {
      _profiles = profiles;
      _conversations = matches;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredConversations = _conversations.where((conv) {
      final name = (conv['profile'] as ProfileModel).name.toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: LumeColors.bg,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [LumeColors.bg, LumeColors.bgGradientEnd],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const ChatListSkeleton()
              : CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Matches & Messages',
                        style: TextStyle(
                          color: LumeColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: LumeColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: LumeColors.surfaceBorder),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.tune_rounded, color: LumeColors.gold, size: 20),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Search bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: LumeColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: LumeColors.surfaceBorder),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      style: const TextStyle(color: LumeColors.textPrimary, fontSize: 14),
                      cursorColor: LumeColors.gold,
                      decoration: const InputDecoration(
                        icon: Icon(Icons.search_rounded, color: LumeColors.textMuted, size: 20),
                        hintText: 'Search matches...',
                        hintStyle: TextStyle(color: LumeColors.textMuted, fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
              ),

              // New Matches story row
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
                      child: Text(
                        'New Matches',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: LumeColors.textSecondary,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 106,
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator(color: LumeColors.gold))
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              physics: const BouncingScrollPhysics(),
                              itemCount: _profiles.length,
                              itemBuilder: (context, index) {
                                final profile = _profiles[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatRoomScreen(profile: profile),
                                ),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LumeColors.goldGradient,
                                    ),
                                    child: Container(
                                      width: 62,
                                      height: 62,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: LumeColors.bg, width: 2),
                                        image: DecorationImage(
                                          image: NetworkImage(profile.photos.first),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    profile.name.split(' ').first,
                                    style: const TextStyle(
                                      color: LumeColors.textPrimary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Divider(color: LumeColors.surfaceBorder, height: 24),
                    ),
                  ],
                ),
              ),

              // Conversation List Header
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: Text(
                    'Conversations',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: LumeColors.textSecondary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),

              // Conversation List Items
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (_isLoading) {
                      return const SizedBox.shrink();
                    }
                    final conv = filteredConversations[index];
                    final profile = conv['profile'] as ProfileModel;
                    final bool unread = (conv['unread'] as int) > 0;

                    return Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: Material(
                        color: unread ? LumeColors.surfaceRaised : LumeColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatRoomScreen(profile: profile),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: unread
                                    ? LumeColors.gold.withOpacity(0.35)
                                    : LumeColors.surfaceBorder,
                                width: unread ? 1.2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                // Avatar with online status
                                Stack(
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: NetworkImage(profile.photos.first),
                                          fit: BoxFit.cover,
                                        ),
                                        border: Border.all(
                                          color: unread ? LumeColors.gold.withOpacity(0.5) : Colors.transparent,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                    if (conv['isOnline'] as bool)
                                      Positioned(
                                        right: 0,
                                        bottom: 0,
                                        child: Container(
                                          width: 14,
                                          height: 14,
                                          decoration: BoxDecoration(
                                            color: LumeColors.online,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: LumeColors.surface,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 14),

                                // Message details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            profile.name,
                                            style: TextStyle(
                                              color: LumeColors.textPrimary,
                                              fontSize: 15.5,
                                              fontWeight: unread ? FontWeight.w700 : FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            conv['time'] as String,
                                            style: TextStyle(
                                              color: unread ? LumeColors.gold : LumeColors.textMuted,
                                              fontSize: 11.5,
                                              fontWeight: unread ? FontWeight.w700 : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              conv['lastMessage'] as String,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: unread ? LumeColors.textPrimary : LumeColors.textSecondary,
                                                fontSize: 13,
                                                fontWeight: unread ? FontWeight.w500 : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                          if (unread) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                              decoration: BoxDecoration(
                                                gradient: LumeColors.goldGradient,
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                '${conv['unread']}',
                                                style: const TextStyle(
                                                  color: LumeColors.bg,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: filteredConversations.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// To make this consistent app-wide: copy the `LumeColors` values above into
// your existing `theme/app_theme.dart` as fields on your `AppTheme` class
// (e.g. AppTheme.gold, AppTheme.surface, AppTheme.online), then swap every
// `LumeColors.x` reference in this file back to `AppTheme.x`. That keeps one
// single source of truth for color across every screen in the app.
// ---------------------------------------------------------------------------