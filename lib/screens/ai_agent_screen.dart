import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/ai_service.dart';
import '../theme/app_theme.dart';
import '../widgets/animated_glow_button.dart';

class AiAgentScreen extends StatefulWidget {
  final String? initialMatchName;
  final String? initialTopic;

  const AiAgentScreen({
    super.key,
    this.initialMatchName,
    this.initialTopic,
  });

  @override
  State<AiAgentScreen> createState() => _AiAgentScreenState();
}

class _AiAgentScreenState extends State<AiAgentScreen> with SingleTickerProviderStateMixin {
  final List<AiMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  List<Map<String, String>> _quickPrompts = [];

  @override
  void initState() {
    super.initState();
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    // Initial welcome message from GlowAI
    _messages.add(
      AiMessage(
        role: 'assistant',
        content: widget.initialMatchName != null
            ? "Hey there! ✨ I'm your GlowDate AI Wingman. Let's make an incredible impression on **${widget.initialMatchName}**!\n\nWould you like custom openers, conversation starters, or a date plan?"
            : "Hey! ✨ I'm **GlowAI**, your personal dating wingman and conversation coach.\n\nAsk me anything: craft witty openers, optimize your bio, plan unforgettable dates, or get honest dating advice.",
        timestamp: DateTime.now(),
        suggestions: [
          widget.initialMatchName != null
              ? "Generate 3 openers for ${widget.initialMatchName}"
              : "Generate high-converting openers",
          "Polish and rate my bio",
          "Plan a 2-stage first date",
          "How to transition to a date",
        ],
      ),
    );

    final prompts = await AiService.getQuickPrompts();
    if (mounted) {
      setState(() {
        _quickPrompts = prompts;
      });
    }

    if (widget.initialTopic != null && widget.initialTopic!.isNotEmpty) {
      _handleSendMessage(widget.initialTopic!);
    }
  }

  Future<void> _handleSendMessage(String text) async {
    final query = text.trim();
    if (query.isEmpty) return;

    _textController.clear();
    setState(() {
      _messages.add(
        AiMessage(
          role: 'user',
          content: query,
          timestamp: DateTime.now(),
        ),
      );
      _isTyping = true;
    });
    _scrollToBottom();

    final response = await AiService.sendMessage(query, history: _messages);

    if (!mounted) return;
    setState(() {
      _isTyping = false;
      _messages.add(response);
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showIcebreakerModal() {
    final matchNameCtrl = TextEditingController(text: widget.initialMatchName ?? 'Maya');
    final interestsCtrl = TextEditingController(text: 'Coffee, Photography, Travel');
    String selectedTone = 'playful';
    bool isLoading = false;
    List<AiIcebreaker>? generated;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: AppTheme.sunsetGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.flash_on_rounded, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Instant Icebreaker Synthesizer',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                'Custom tailored opening lines that spark genuine replies',
                                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: matchNameCtrl,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Match Name',
                        labelStyle: const TextStyle(color: AppTheme.textSecondary),
                        filled: true,
                        fillColor: AppTheme.surfaceCard,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: interestsCtrl,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Match Interests (comma separated)',
                        labelStyle: const TextStyle(color: AppTheme.textSecondary),
                        filled: true,
                        fillColor: AppTheme.surfaceCard,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text('Select Tone:', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ['playful', 'charming', 'bold', 'intellectual'].map((tone) {
                        final isSel = selectedTone == tone;
                        return ChoiceChip(
                          label: Text(tone.toUpperCase()),
                          selected: isSel,
                          selectedColor: AppTheme.accentGold,
                          backgroundColor: AppTheme.surfaceCard,
                          labelStyle: TextStyle(
                            color: isSel ? Colors.black : AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                          onSelected: (val) {
                            if (val) setModalState(() => selectedTone = tone);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    AnimatedGlowButton(
                      label: isLoading ? 'Crafting Openers...' : 'Generate 3 Openers ✨',
                      isLoading: isLoading,
                      onPressed: () async {
                        setModalState(() => isLoading = true);
                        final ints = interestsCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                        final res = await AiService.generateIcebreakers(
                          matchName: matchNameCtrl.text.trim(),
                          matchInterests: ints,
                          tone: selectedTone,
                        );
                        setModalState(() {
                          isLoading = false;
                          generated = res;
                        });
                      },
                    ),
                    if (generated != null && generated!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Text(
                        '✨ Tailored Openers (Tap to Copy):',
                        style: TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      ...generated!.map((item) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceCard,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.accentGold.withOpacity(0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentGold.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        item.style,
                                        style: const TextStyle(
                                          color: AppTheme.accentGold,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.copy_rounded, color: AppTheme.textSecondary, size: 18),
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(text: item.opener));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Opener copied to clipboard! 📋')),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item.opener,
                                  style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '💡 ${item.explanation}',
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showBioOptimizerModal() {
    final bioCtrl = TextEditingController(text: 'Love coffee, music, travel, and weekend adventures.');
    bool isLoading = false;
    AiBioOptimizationResult? result;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.auto_fix_high_rounded, color: Colors.black, size: 22),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Bio Doctor & Optimizer',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                'Audit charisma score & rewrite with high attraction',
                                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: bioCtrl,
                      maxLines: 3,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Your Current Bio',
                        labelStyle: const TextStyle(color: AppTheme.textSecondary),
                        filled: true,
                        fillColor: AppTheme.surfaceCard,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedGlowButton(
                      label: isLoading ? 'Analyzing Charisma...' : 'Audit & Optimize Bio ✨',
                      isLoading: isLoading,
                      onPressed: () async {
                        if (bioCtrl.text.trim().isEmpty) return;
                        setModalState(() => isLoading = true);
                        final res = await AiService.optimizeBio(bio: bioCtrl.text.trim());
                        setModalState(() {
                          isLoading = false;
                          result = res;
                        });
                      },
                    ),
                    if (result != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceCard,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.accentGold.withOpacity(0.4)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Charisma Score:',
                              style: TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${result!.score} / 100 🔥',
                              style: const TextStyle(
                                color: AppTheme.accentGold,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('✨ 3 High-Converting Rewrites:', style: TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      ...result!.rewrites.map((rw) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceCard,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      rw.style,
                                      style: const TextStyle(
                                        color: AppTheme.primaryRose,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.copy_rounded, color: AppTheme.textSecondary, size: 18),
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(text: rw.bio));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Bio copied to clipboard! 📋')),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                Text(
                                  rw.bio,
                                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, height: 1.4),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '💡 ${rw.whyItWorks}',
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppTheme.sunsetGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accentGold.withOpacity(0.4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GlowAI Wingman',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    CircleAvatar(radius: 3.5, backgroundColor: AppTheme.emeraldGreen),
                    SizedBox(width: 5),
                    Text(
                      'Online • AI Dating Coach',
                      style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline_rounded, color: AppTheme.accentGold),
            tooltip: 'Quick Prompts',
            onPressed: () {
              if (_quickPrompts.isNotEmpty) {
                _handleSendMessage(_quickPrompts.first['prompt'] ?? 'Give me top dating tips');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick Action Cards Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: AppTheme.surfaceDark.withOpacity(0.6),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildToolPill(
                    icon: Icons.flash_on_rounded,
                    label: 'Instant Openers',
                    gradient: AppTheme.sunsetGradient,
                    onTap: _showIcebreakerModal,
                  ),
                  const SizedBox(width: 8),
                  _buildToolPill(
                    icon: Icons.auto_fix_high_rounded,
                    label: 'Bio Doctor',
                    gradient: AppTheme.primaryGradient,
                    onTap: _showBioOptimizerModal,
                  ),
                  const SizedBox(width: 8),
                  _buildToolPill(
                    icon: Icons.celebration_rounded,
                    label: 'Date Concierge',
                    gradient: AppTheme.goldGradient,
                    onTap: () {
                      Navigator.pushNamed(context, '/ai-date-planner');
                    },
                  ),
                ],
              ),
            ),
          ),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),

          // Message Composer
          _buildComposer(),
        ],
      ),
    );
  }

  Widget _buildToolPill({
    required IconData icon,
    required String label,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.accentGold.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => gradient.createShader(bounds),
              child: Icon(icon, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(AiMessage msg) {
    final isUser = msg.role == 'user';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: AppTheme.sunsetGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 14),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? AppTheme.accentGold : AppTheme.surfaceCard,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: isUser ? const Radius.circular(18) : const Radius.circular(4),
                      bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(18),
                    ),
                    border: isUser
                        ? null
                        : Border.all(color: AppTheme.accentGold.withOpacity(0.15)),
                  ),
                  child: SelectableText(
                    msg.content,
                    style: TextStyle(
                      color: isUser ? Colors.black : AppTheme.textPrimary,
                      fontSize: 14.5,
                      height: 1.45,
                      fontWeight: isUser ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
                if (!isUser && msg.suggestions.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: msg.suggestions.map((suggestion) {
                      return GestureDetector(
                        onTap: () => _handleSendMessage(suggestion),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceDark,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppTheme.accentGold.withOpacity(0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.auto_awesome_rounded, color: AppTheme.accentGold, size: 12),
                              const SizedBox(width: 4),
                              Text(
                                suggestion,
                                style: const TextStyle(
                                  color: AppTheme.accentGold,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              gradient: AppTheme.sunsetGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentGold),
                ),
                SizedBox(width: 10),
                Text(
                  'GlowAI is thinking...',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComposer() {
    return Container(
      padding: EdgeInsets.only(
        left: 14,
        right: 14,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        border: Border(top: BorderSide(color: AppTheme.surfaceCard)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.accentGold.withOpacity(0.2)),
              ),
              child: TextField(
                controller: _textController,
                style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Ask GlowAI for openers, bio audit, or advice...',
                  hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  border: InputBorder.none,
                ),
                onSubmitted: _handleSendMessage,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              gradient: AppTheme.sunsetGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentGold.withOpacity(0.3),
                  blurRadius: 8,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              onPressed: () => _handleSendMessage(_textController.text),
            ),
          ),
        ],
      ),
    );
  }
}
