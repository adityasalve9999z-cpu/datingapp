import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/ai_service.dart';

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
      text: "Hi there! ✨ I'm your GlowDate AI wingman. Need an icebreaker or profile advice?",
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
        _scrollController.position.maxScrollExtent + 200, // extra padding
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
    
    // Allow UI to update and scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);

    // Call the mock AI service
    final response = await AiService.sendMessage(text);
    
    if (!mounted) return;

    setState(() {
      _isTyping = false;
      _messages.add(ChatMessage(text: response, isMe: false));
    });
    
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
    // Determine keyboard height so we can push the content up when keyboard is open
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.75 + keyboardHeight,
      decoration: const BoxDecoration(
        color: AppTheme.darkBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // ── Header ─────────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white12)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.primaryGradient,
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 24),
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
                      Text(
                        'Always here to help ✨',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppTheme.textSecondary),
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
            decoration: const BoxDecoration(
              color: AppTheme.surfaceCard,
              border: Border(top: BorderSide(color: Colors.white12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.darkBackground,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      decoration: const InputDecoration(
                        hintText: 'Ask for advice...',
                        hintStyle: TextStyle(color: AppTheme.textMuted),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.primaryGradient,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
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
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: message.isMe ? AppTheme.primaryRose : AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomRight: message.isMe ? const Radius.circular(4) : const Radius.circular(20),
            bottomLeft: !message.isMe ? const Radius.circular(4) : const Radius.circular(20),
          ),
        ),
        child: Text(
          message.text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(20).copyWith(
            bottomLeft: const Radius.circular(4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.circle, size: 8, color: AppTheme.textMuted),
            SizedBox(width: 4),
            Icon(Icons.circle, size: 8, color: AppTheme.textMuted),
            SizedBox(width: 4),
            Icon(Icons.circle, size: 8, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}
