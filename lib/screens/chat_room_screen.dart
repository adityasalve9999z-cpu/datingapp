import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/shimmer_loading.dart';
import 'profile_detail_screen.dart';

class ChatRoomScreen extends StatefulWidget {
  final ProfileModel profile;

  const ChatRoomScreen({super.key, required this.profile});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late List<Map<String, dynamic>> _messages;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _messages = [];
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final fetched = await AppApiService.fetchMessages(widget.profile.id);
    final extra = [
      {
        'sender': 'them',
        'text': widget.profile.promptAnswer ?? 'I’d love to visit that espresso bar on 4th street! ☕',
        'time': '10:42 AM',
      },
    ];
    if (!mounted) return;
    setState(() {
      _messages = [...fetched, ...extra];
      _isLoading = false;
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    final msg = {
      'sender': 'me',
      'text': text.trim(),
      'time': 'Just now',
    };
    setState(() {
      _messages.add(msg);
      _msgController.clear();
    });
    // Fire-and-forget: send to API in background
    AppApiService.sendMessage(toUserId: widget.profile.id, text: text.trim());
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceDark,
        elevation: 1,
        titleSpacing: 0,
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileDetailScreen(
                  profile: profile,
                  heroTag: 'chat_header_${profile.id}',
                ),
              ),
            );
          },
          child: Row(
            children: [
              Hero(
                tag: 'chat_header_${profile.id}',
                child: CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(profile.photos.first),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        profile.name.split(' ').first,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (profile.isVerified) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified_rounded, color: AppTheme.accentCyan, size: 16),
                      ],
                    ],
                  ),
                  const Text(
                    'Active now',
                    style: TextStyle(fontSize: 12, color: AppTheme.emeraldGreen),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_rounded, color: AppTheme.textPrimary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.call_rounded, color: AppTheme.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const ChatRoomSkeleton()
          : Column(
        children: [
          // Chat Messages Scroll Area
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isMe = msg['sender'] == 'me';

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      gradient: isMe ? AppTheme.primaryGradient : null,
                      color: isMe ? null : AppTheme.surfaceCard,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(20),
                        topRight: const Radius.circular(20),
                        bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
                        bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          msg['text'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          msg['time'] as String,
                          style: TextStyle(
                            color: isMe ? Colors.white70 : AppTheme.textMuted,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Icebreaker Chips Quick Suggestions
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                _buildQuickChip('☕ Best coffee spot?'),
                _buildQuickChip('🎞️ Show me a photo'),
                _buildQuickChip('✨ What’s your weekend plan?'),
              ],
            ),
          ),

          // Message Input Field
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppTheme.surfaceDark,
                border: Border(top: BorderSide(color: Colors.white10)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.primaryRose),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _msgController,
                        style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(color: AppTheme.textMuted),
                          border: InputBorder.none,
                        ),
                        onSubmitted: _sendMessage,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _sendMessage(_msgController.text),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.primaryGradient,
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip(String text) {
    return GestureDetector(
      onTap: () => _sendMessage(text),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white12),
        ),
        child: Text(
          text,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        ),
      ),
    );
  }
}
