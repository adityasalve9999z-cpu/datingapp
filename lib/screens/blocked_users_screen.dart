import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class BlockedUserItem {
  final String id;
  final String name;
  final int age;
  final String avatarUrl;
  final String blockedDate;
  final String reason;

  BlockedUserItem({
    required this.id,
    required this.name,
    required this.age,
    required this.avatarUrl,
    required this.blockedDate,
    required this.reason,
  });
}

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  final List<BlockedUserItem> _blockedUsers = [
    BlockedUserItem(
      id: 'b1',
      name: 'Marcus Vance',
      age: 29,
      avatarUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=500',
      blockedDate: 'Aug 14, 2026',
      reason: 'Inappropriate messages',
    ),
    BlockedUserItem(
      id: 'b2',
      name: 'Taylor Reed',
      age: 26,
      avatarUrl: 'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?w=500',
      blockedDate: 'Jul 28, 2026',
      reason: 'Fake profile suspicion',
    ),
    BlockedUserItem(
      id: 'b3',
      name: 'Jordan Bell',
      age: 31,
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=500',
      blockedDate: 'Jun 19, 2026',
      reason: 'Unsolicited spam',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<BlockedUserItem> get _filteredList {
    if (_query.isEmpty) return _blockedUsers;
    return _blockedUsers
        .where((u) => u.name.toLowerCase().contains(_query))
        .toList();
  }

  void _unblockUser(BlockedUserItem user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.white12),
        ),
        title: Text(
          'Unblock ${user.name}?',
          style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'They will be able to see your profile in Discovery and send you likes again.',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13.5, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                _blockedUsers.removeWhere((u) => u.id == user.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${user.name} has been unblocked'),
                  backgroundColor: AppTheme.emeraldGreen,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Unblock', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Blocked Accounts'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          _buildInfoBanner(),
          _buildSearchBar(),
          Expanded(
            child: _filteredList.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _filteredList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final user = _filteredList[index];
                      return _buildUserTile(user);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 4, 20, 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryRose.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.shield_rounded, color: AppTheme.primaryRose, size: 22),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Privacy Protection',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Blocked contacts cannot view your profile, message you, or match with you.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search blocked accounts...',
          hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
          prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textMuted, size: 20),
          filled: true,
          fillColor: AppTheme.surfaceCard,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.white12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.white12),
          ),
        ),
      ),
    );
  }

  Widget _buildUserTile(BlockedUserItem user) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundImage: NetworkImage(user.avatarUrl),
            backgroundColor: AppTheme.surfaceDark,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user.name}, ${user.age}',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Blocked: ${user.blockedDate}',
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 11.5),
                ),
                const SizedBox(height: 2),
                Text(
                  user.reason,
                  style: const TextStyle(color: AppTheme.primaryRose, fontSize: 11.5, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () => _unblockUser(user),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            child: const Text(
              'Unblock',
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.surfaceCard,
                border: Border.all(color: Colors.white10),
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: AppTheme.emeraldGreen,
                size: 54,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No Blocked Users',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'You haven\'t blocked anyone yet. When you block a profile, they\'ll be listed here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
