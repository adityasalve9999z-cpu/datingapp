import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/profile_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String timeAgo;
  final String category; // 'matches', 'likes', 'messages', 'system', 'promos'
  final IconData icon;
  final Color iconColor;
  final String? avatarUrl;
  final String? actionRoute;
  final Object? routeExtra;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timeAgo,
    required this.category,
    required this.icon,
    required this.iconColor,
    this.avatarUrl,
    this.actionRoute,
    this.routeExtra,
    this.isRead = false,
  });
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _selectedCategory = 'all';

  List<NotificationItem> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    final data = await AppApiService.fetchNotifications();
    
    // Parse backend data
    final items = data.map((json) {
      Color color = AppTheme.primaryPurple;
      IconData icon = Icons.notifications;
      if (json['type'] == 'match') {
        color = AppTheme.primaryRose;
        icon = Icons.favorite_rounded;
      } else if (json['type'] == 'like') {
        color = AppTheme.accentCyan;
        icon = Icons.star_rounded;
      }
      
      return NotificationItem(
        id: json['id']?.toString() ?? '',
        title: json['title'] ?? 'Notification',
        message: json['message'] ?? '',
        timeAgo: 'Recently', // You'd format the timestamp here
        category: json['type'] == 'match' ? 'matches' : (json['type'] == 'like' ? 'likes' : 'system'),
        icon: icon,
        iconColor: color,
        isRead: json['is_read'] == true,
      );
    }).toList();

    if (mounted) {
      setState(() {
        _notifications = items;
        _isLoading = false;
      });
    }
  }

  final List<Map<String, String>> _categories = [
    {'id': 'all', 'label': 'All'},
    {'id': 'matches', 'label': 'Matches'},
    {'id': 'likes', 'label': 'Likes'},
    {'id': 'promos', 'label': 'Offers'},
    {'id': 'system', 'label': 'System'},
  ];

  List<NotificationItem> get _filteredNotifications {
    if (_selectedCategory == 'all') return _notifications;
    return _notifications.where((n) => n.category == _selectedCategory).toList();
  }

  void _markAllAsRead() async {
    await AppApiService.markAllNotificationsAsRead();
    setState(() {
      for (final n in _notifications) {
        n.isRead = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All notifications marked as read'),
        backgroundColor: AppTheme.primaryPurple,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearAll() {
    setState(() {
      _notifications.clear();
    });
  }

  void _handleNotificationTap(NotificationItem item) async {
    if (!item.isRead) {
      await AppApiService.markNotificationAsRead(item.id);
      setState(() {
        item.isRead = true;
      });
    }

    if (item.actionRoute != null) {
      context.push(item.actionRoute!, extra: item.routeExtra);
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Notifications'),
            if (unreadCount > 0) ...[
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$unreadCount new',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: AppTheme.textSecondary),
            color: AppTheme.surfaceDark,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onSelected: (value) {
              if (value == 'read_all') _markAllAsRead();
              if (value == 'clear_all') _clearAll();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'read_all',
                child: Row(
                  children: [
                    Icon(Icons.done_all_rounded, size: 18, color: AppTheme.accentCyan),
                    SizedBox(width: 10),
                    Text('Mark all as read', style: TextStyle(color: AppTheme.textPrimary, fontSize: 13)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, size: 18, color: AppTheme.primaryRose),
                    SizedBox(width: 10),
                    Text('Clear all', style: TextStyle(color: AppTheme.textPrimary, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryRose))
                : _filteredNotifications.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _filteredNotifications.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = _filteredNotifications[index];
                      return _buildNotificationCard(item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat['id'];

          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat['id']!),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected ? AppTheme.primaryGradient : null,
                color: isSelected ? null : AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.white10,
                ),
              ),
              child: Center(
                child: Text(
                  cat['label']!,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem item) {
    return GestureDetector(
      onTap: () => _handleNotificationTap(item),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: item.isRead ? AppTheme.surfaceCard : AppTheme.surfaceCard.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: item.isRead ? Colors.white10 : item.iconColor.withValues(alpha: 0.4),
            width: item.isRead ? 1 : 1.5,
          ),
          boxShadow: !item.isRead
              ? [
                  BoxShadow(
                    color: item.iconColor.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                if (item.avatarUrl != null)
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(item.avatarUrl!),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(color: item.iconColor, width: 1.5),
                    ),
                  )
                else
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: item.iconColor.withValues(alpha: 0.15),
                      border: Border.all(color: item.iconColor.withValues(alpha: 0.3)),
                    ),
                    child: Icon(item.icon, color: item.iconColor, size: 24),
                  ),
                if (item.avatarUrl != null)
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: item.iconColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.darkBackground, width: 2),
                      ),
                      child: Icon(item.icon, size: 10, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14.5,
                            fontWeight: item.isRead ? FontWeight.w600 : FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            item.timeAgo,
                            style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                          ),
                          if (!item.isRead) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.primaryRose,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.message,
                    style: TextStyle(
                      color: item.isRead ? AppTheme.textSecondary : AppTheme.textPrimary.withValues(alpha: 0.9),
                      fontSize: 12.5,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
                Icons.notifications_off_rounded,
                color: AppTheme.textMuted,
                size: 54,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Notifications Yet',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'When you get new matches, likes, or date suggestions, they\'ll show up here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
