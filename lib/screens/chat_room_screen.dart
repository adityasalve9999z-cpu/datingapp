import 'dart:async';
import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/animated_glow_button.dart';
import 'profile_detail_screen.dart';
import 'call_screen.dart';
import 'ai_date_planner_screen.dart';

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
  StreamSubscription? _msgSubscription;

  @override
  void initState() {
    super.initState();
    _messages = [];
    _loadMessages();
    _subscribeToRealtime();
  }

  void _subscribeToRealtime() {
    _msgSubscription =
        AppApiService.streamMessages(widget.profile.id).listen((liveMessages) {
      if (liveMessages.isNotEmpty && mounted) {
        setState(() {
          _messages = liveMessages;
          _isLoading = false;
        });
        _scrollToBottom();
      }
    });
  }

  @override
  void dispose() {
    _msgSubscription?.cancel();
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    final fetched = await AppApiService.fetchMessages(widget.profile.id);
    if (!mounted) return;
    setState(() {
      _messages = fetched;
      _isLoading = false;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
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
    // Send to Supabase in background
    AppApiService.sendMessage(toUserId: widget.profile.id, text: text.trim());
    _scrollToBottom();
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
            tooltip: 'AI Date Planner',
            icon: const Icon(Icons.auto_awesome_rounded, color: AppTheme.accentGold),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AiDatePlannerScreen(
                    matchName: profile.name.split(' ').first,
                  ),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Video Call',
            icon: const Icon(Icons.videocam_rounded, color: AppTheme.textPrimary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CallScreen(
                    profile: profile,
                    isVideoCall: true,
                  ),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Voice Call',
            icon: const Icon(Icons.call_rounded, color: AppTheme.textPrimary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CallScreen(
                    profile: profile,
                    isVideoCall: false,
                  ),
                ),
              );
            },
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
                  BouncingTapWrapper(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white10,
                      ),
                      child: const Icon(Icons.add_rounded, color: AppTheme.primaryRose, size: 22),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white10),
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
                  AnimatedCircleActionButton(
                    icon: Icons.send_rounded,
                    iconColor: Colors.white,
                    glowColor: AppTheme.primaryRose,
                    size: 46,
                    iconSize: 20,
                    gradient: AppTheme.primaryGradient,
                    onPressed: () => _sendMessage(_msgController.text),
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
    return BouncingTapWrapper(
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
