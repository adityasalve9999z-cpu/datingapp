import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../theme/app_theme.dart';
import 'chat_room_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _conversations = [
    {
      'profile': mockProfiles[0],
      'lastMessage': 'I’d love to visit that espresso bar on 4th street! ☕',
      'time': '10:42 AM',
      'unread': 2,
      'isOnline': true,
    },
    {
      'profile': mockProfiles[1],
      'lastMessage': 'Check out this film photo I took yesterday 🎞️',
      'time': 'Yesterday',
      'unread': 0,
      'isOnline': true,
    },
    {
      'profile': mockProfiles[2],
      'lastMessage': 'Have you heard the new vinyl release by L’Impératrice?',
      'time': 'Mon',
      'unread': 1,
      'isOnline': false,
    },
    {
      'profile': mockProfiles[3],
      'lastMessage': 'That beat snippet sounded incredible!',
      'time': 'Sun',
      'unread': 0,
      'isOnline': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredConversations = _conversations.where((conv) {
      final name = (conv['profile'] as ProfileModel).name.toLowerCase();
      return name.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Matches & Messages'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: AppTheme.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Search Input Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                  decoration: const InputDecoration(
                    icon: Icon(Icons.search_rounded, color: AppTheme.textMuted),
                    hintText: 'Search matches...',
                    hintStyle: TextStyle(color: AppTheme.textMuted),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),

          // New Matches Story Row
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Text(
                    'New Matches',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: mockProfiles.length,
                    itemBuilder: (context, index) {
                      final profile = mockProfiles[index];
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
                                  gradient: AppTheme.sunsetGradient,
                                ),
                                child: Container(
                                  width: 62,
                                  height: 62,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppTheme.darkBackground, width: 2),
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
                                  color: AppTheme.textPrimary,
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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(color: Colors.white10),
                ),
              ],
            ),
          ),

          // Conversation List Header
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Text(
                'Conversations',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ),

          // Conversation List Items
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final conv = filteredConversations[index];
                final profile = conv['profile'] as ProfileModel;
                final bool unread = (conv['unread'] as int) > 0;

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatRoomScreen(profile: profile),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      children: [
                        // Avatar with online status
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundImage: NetworkImage(profile.photos.first),
                            ),
                            if (conv['isOnline'] as bool)
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: AppTheme.emeraldGreen,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppTheme.darkBackground,
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
                                      color: AppTheme.textPrimary,
                                      fontSize: 16,
                                      fontWeight: unread ? FontWeight.bold : FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    conv['time'] as String,
                                    style: TextStyle(
                                      color: unread ? AppTheme.primaryRose : AppTheme.textMuted,
                                      fontSize: 12,
                                      fontWeight: unread ? FontWeight.bold : FontWeight.normal,
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
                                        color: unread ? AppTheme.textPrimary : AppTheme.textSecondary,
                                        fontSize: 14,
                                        fontWeight: unread ? FontWeight.w600 : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  if (unread) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: const BoxDecoration(
                                        color: AppTheme.primaryRose,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '${conv['unread']}',
                                        style: const TextStyle(
                                          color: Colors.white,
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
                );
              },
              childCount: filteredConversations.length,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
