import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/ai_service.dart';
import '../screens/ai_agent_screen.dart';


class AiAgentSheet extends StatefulWidget {
  const AiAgentSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AiAgentSheet(),
    );
  }

  @override
  State<AiAgentSheet> createState() => _AiAgentSheetState();
}

class ChatMessage {
  final String text;
  final bool isMe;

  ChatMessage({required this.text, required this.isMe});
}

class _AiAgentSheetState extends State<AiAgentSheet> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // Welcome message
    _messages.add(ChatMessage(
      text:
          "Hi there! ✨ I'm your Lume AI wingman. Need an icebreaker, bio polish, or profile advice?",
      isMe: false,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 200,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isMe: true));
      _isTyping = true;
    });

    _controller.clear();
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);

    // Call AI service
    final response = await AiService.sendMessage(text);


    if (!mounted) return;

    setState(() {
      _isTyping = false;
      _messages.add(ChatMessage(text: response.content, isMe: false));
    });

    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75 + keyboardHeight,
      decoration: BoxDecoration(
        color: AppTheme.darkBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: const Color(0xFF3A2740), width: 1.2),
      ),
      child: Column(
        children: [
          // ── Header ─────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF3A2740))),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.goldGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentGold.withOpacity(0.3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.auto_awesome_rounded,
                      color: AppTheme.darkBackground, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Wingman',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Your intelligent dating advisor ✨',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.open_in_full_rounded,
                      color: AppTheme.accentGold, size: 20),
                  tooltip: 'Full Screen Wingman',
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AiAgentScreen()),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      color: AppTheme.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // ── Message List ───────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return const _TypingIndicator();
                }

                final msg = _messages[index];
                return _MessageBubble(message: msg);
              },
            ),
          ),

          // ── Input Area ─────────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + keyboardHeight),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              border: const Border(top: BorderSide(color: Color(0xFF3A2740))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF3A2740)),
                    ),
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(
                          color: AppTheme.textPrimary, fontSize: 15),
                      decoration: const InputDecoration(
                        hintText: 'Ask for advice or openers...',
                        hintStyle: TextStyle(color: AppTheme.textMuted),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.goldGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentGold.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded,
                        color: AppTheme.darkBackground, size: 20),
                    onPressed: _handleSend,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: message.isMe ? null : AppTheme.surfaceCard,
          gradient: message.isMe ? AppTheme.goldGradient : null,
          border:
              message.isMe ? null : Border.all(color: const Color(0xFF3A2740)),
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight: message.isMe
                ? const Radius.circular(4)
                : const Radius.circular(20),
            bottomLeft: !message.isMe
                ? const Radius.circular(4)
                : const Radius.circular(20),
          ),
          boxShadow: message.isMe
              ? [
                  BoxShadow(
                    color: AppTheme.accentGold.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color:
                message.isMe ? AppTheme.darkBackground : AppTheme.textPrimary,
            fontSize: 14.5,
            fontWeight: message.isMe ? FontWeight.w600 : FontWeight.normal,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          border: Border.all(color: const Color(0xFF3A2740)),
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomLeft: const Radius.circular(4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.circle, size: 7, color: AppTheme.accentGold),
            SizedBox(width: 5),
            Icon(Icons.circle, size: 7, color: AppTheme.accentGold),
            SizedBox(width: 5),
            Icon(Icons.circle, size: 7, color: AppTheme.accentGold),
          ],
        ),
      ),
    );
  }
}
