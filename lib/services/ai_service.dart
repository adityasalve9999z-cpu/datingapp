import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'api_service.dart';

/// Models for AI Dating Agent features
class AiMessage {
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime timestamp;
  final List<String> suggestions;

  AiMessage({
    required this.role,
    required this.content,
    required this.timestamp,
    this.suggestions = const [],
  });

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };
}

class AiIcebreaker {
  final String opener;
  final String style;
  final String explanation;

  AiIcebreaker({
    required this.opener,
    required this.style,
    required this.explanation,
  });

  factory AiIcebreaker.fromJson(Map<String, dynamic> json) {
    return AiIcebreaker(
      opener: json['opener']?.toString() ?? '',
      style: json['style']?.toString() ?? 'Playful',
      explanation: json['explanation']?.toString() ?? '',
    );
  }
}

class AiBioRewrite {
  final String style;
  final String bio;
  final String whyItWorks;

  AiBioRewrite({
    required this.style,
    required this.bio,
    required this.whyItWorks,
  });

  factory AiBioRewrite.fromJson(Map<String, dynamic> json) {
    return AiBioRewrite(
      style: json['style']?.toString() ?? 'Modern',
      bio: json['bio']?.toString() ?? '',
      whyItWorks: json['why_it_works']?.toString() ?? '',
    );
  }
}

class AiBioOptimizationResult {
  final int score;
  final List<String> strengths;
  final List<String> improvementAreas;
  final List<AiBioRewrite> rewrites;
  final List<String> photoAdvice;

  AiBioOptimizationResult({
    required this.score,
    required this.strengths,
    required this.improvementAreas,
    required this.rewrites,
    required this.photoAdvice,
  });

  factory AiBioOptimizationResult.fromJson(Map<String, dynamic> json) {
    return AiBioOptimizationResult(
      score: (json['score'] as num?)?.toInt() ?? 80,
      strengths: List<String>.from(json['strengths'] ?? []),
      improvementAreas: List<String>.from(json['improvement_areas'] ?? []),
      rewrites: (json['rewrites'] as List? ?? [])
          .map((e) => AiBioRewrite.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      photoAdvice: List<String>.from(json['photo_advice'] ?? []),
    );
  }
}

class AiReplyOption {
  final String label;
  final String flavor;
  final String text;

  AiReplyOption({
    required this.label,
    required this.flavor,
    required this.text,
  });

  factory AiReplyOption.fromJson(Map<String, dynamic> json) {
    return AiReplyOption(
      label: json['label']?.toString() ?? 'Reply',
      flavor: json['flavor']?.toString() ?? 'flirty',
      text: json['text']?.toString() ?? '',
    );
  }
}

/// Central AI Service for GlowDate AI Wingman & Dating Coach.
class AiService {
  /// Sends a conversation message to the backend AI agent
  static Future<AiMessage> sendMessage(
    String message, {
    List<AiMessage> history = const [],
  }) async {
    try {
      final token = await AppApiService.getStoredToken();
      final url = Uri.parse('${ApiConfig.baseUrl}/ai/chat');
      final response = await http
          .post(
            url,
            headers: ApiConfig.getHeaders(token: token),
            body: jsonEncode({
              'message': message,
              'history': history.map((m) => m.toJson()).toList(),
            }),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final data = body['data'];
        final replyText = data['reply']?.toString() ?? '';
        final suggestions = List<String>.from(data['suggestions'] ?? []);

        return AiMessage(
          role: 'assistant',
          content: replyText,
          timestamp: DateTime.now(),
          suggestions: suggestions,
        );
      }
    } catch (e) {
      debugPrint('AiService.sendMessage error: $e. Using local wingman heuristics.');
    }

    // Heuristic Fallback
    return _fallbackChatResponse(message);
  }

  /// Generates custom match icebreakers
  static Future<List<AiIcebreaker>> generateIcebreakers({
    String? matchName,
    List<String>? matchInterests,
    String? matchBio,
    String tone = 'playful',
  }) async {
    try {
      final token = await AppApiService.getStoredToken();
      final url = Uri.parse('${ApiConfig.baseUrl}/ai/icebreakers');
      final response = await http
          .post(
            url,
            headers: ApiConfig.getHeaders(token: token),
            body: jsonEncode({
              'match_name': matchName ?? 'Your Match',
              'match_interests': matchInterests ?? ['Coffee', 'Music'],
              'match_bio': matchBio,
              'tone': tone,
            }),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final openers = body['data']?['openers'] as List? ?? [];
        return openers
            .map((o) => AiIcebreaker.fromJson(Map<String, dynamic>.from(o)))
            .toList();
      }
    } catch (e) {
      debugPrint('AiService.generateIcebreakers error: $e');
    }

    final name = matchName ?? 'there';
    return [
      AiIcebreaker(
        opener: "Hey $name! Quick question to settle a debate: what's the ultimate coffee order?",
        style: "Playful & Curious",
        explanation: "Low friction question that immediately invites opinions.",
      ),
      AiIcebreaker(
        opener: "I have to ask $name—what's the story behind your favorite travel adventure?",
        style: "Charming & Storyteller",
        explanation: "Gets them talking about their favorite memories.",
      ),
      AiIcebreaker(
        opener: "If we were planning an impromptu weekend escape, where are we heading first?",
        style: "Spontaneous & Fun",
        explanation: "Creates shared hypothetical energy and playful banter.",
      ),
    ];
  }

  /// Optimizes and audits dating bio
  static Future<AiBioOptimizationResult> optimizeBio({
    required String bio,
    List<String>? interests,
  }) async {
    try {
      final token = await AppApiService.getStoredToken();
      final url = Uri.parse('${ApiConfig.baseUrl}/ai/optimize-bio');
      final response = await http
          .post(
            url,
            headers: ApiConfig.getHeaders(token: token),
            body: jsonEncode({
              'bio': bio,
              'interests': interests ?? [],
            }),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return AiBioOptimizationResult.fromJson(
            Map<String, dynamic>.from(body['data']));
      }
    } catch (e) {
      debugPrint('AiService.optimizeBio error: $e');
    }

    // Local heuristic fallback
    return AiBioOptimizationResult(
      score: 82,
      strengths: [
        "Expresses genuine passions and lifestyle tone",
        "Engaging and approachable voice",
      ],
      improvementAreas: [
        "Add a clear reply trigger to make it easy for matches to start talking",
        "Highlight 1 specific quirky detail or favorite city spot",
      ],
      rewrites: [
        AiBioRewrite(
          style: "Charismatic & Witty",
          bio: "$bio\n\n✨ Seeking someone who can appreciate great coffee & won't judge my playlist choices ☕",
          whyItWorks: "Adds playful stakes and a direct conversation hook.",
        ),
        AiBioRewrite(
          style: "Adventurous & Spontaneous",
          bio: "Always down for spontaneous road trips, weekend art markets, and great street food 🌮 Tell me your favorite hidden gem in town!",
          whyItWorks: "Shows vibrant lifestyle and invites immediate recommendations.",
        ),
        AiBioRewrite(
          style: "Short & Intriguing",
          bio: "Coffee addict • Vinyl explorer • Terrible at baking 🥐\nTwo truths and a lie waiting for you in chat.",
          whyItWorks: "Self-deprecating humor and an instant interactive game.",
        ),
      ],
      photoAdvice: [
        "Use natural daylight for your primary portrait (no sunglasses)",
        "Include an action photo of your favorite hobby",
      ],
    );
  }

  /// Generates 3 in-chat smart reply suggestions
  static Future<List<AiReplyOption>> getReplySuggestions({
    required String lastMessage,
    String? matchName,
  }) async {
    try {
      final token = await AppApiService.getStoredToken();
      final url = Uri.parse('${ApiConfig.baseUrl}/ai/reply-suggestions');
      final response = await http
          .post(
            url,
            headers: ApiConfig.getHeaders(token: token),
            body: jsonEncode({
              'last_received_message': lastMessage,
              'match_name': matchName ?? 'Match',
            }),
          )
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final list = body['data']?['suggestions'] as List? ?? [];
        return list
            .map((s) => AiReplyOption.fromJson(Map<String, dynamic>.from(s)))
            .toList();
      }
    } catch (e) {
      debugPrint('AiService.getReplySuggestions error: $e');
    }

    return [
      AiReplyOption(
        label: 'Flirty & Witty 🔥',
        flavor: 'flirty',
        text: 'Haha you definitely have great taste! Are you this charming in person too? 😉',
      ),
      AiReplyOption(
        label: 'Authentic & Curious ✨',
        flavor: 'deep',
        text: "That's so interesting! What inspired you to get into that?",
      ),
      AiReplyOption(
        label: 'Playful Tease ⚡',
        flavor: 'playful',
        text: 'I was almost going to agree with you, but now I think we need a coffee debate to settle this ☕',
      ),
    ];
  }

  /// Generates quick prompts for the AI dashboard
  static Future<List<Map<String, String>>> getQuickPrompts() async {
    try {
      final token = await AppApiService.getStoredToken();
      final url = Uri.parse('${ApiConfig.baseUrl}/ai/quick-prompts');
      final response = await http
          .get(url, headers: ApiConfig.getHeaders(token: token))
          .timeout(ApiConfig.timeout);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final list = body['data'] as List? ?? [];
        return list.map((item) => Map<String, String>.from(item)).toList();
      }
    } catch (e) {
      debugPrint('AiService.getQuickPrompts error: $e');
    }

    return [
      {
        'title': '✨ High-Converting Openers',
        'prompt': 'Give me 3 creative, high-converting openers for someone who loves photography and coffee.',
      },
      {
        'title': '📝 Bio Polish & Audit',
        'prompt': 'How do I rewrite my bio to sound witty, confident, and approachable?',
      },
      {
        'title': '🍷 3-Stage Date Itinerary',
        'prompt': 'Plan a perfect first date that isn\'t just an awkward formal dinner.',
      },
      {
        'title': '💬 Revive a Dying Conversation',
        'prompt': 'What\'s the best text to send when a match gives short replies?',
      },
    ];
  }

  static AiMessage _fallbackChatResponse(String message) {
    final lower = message.toLowerCase();

    if (lower.contains('opener') || lower.contains('icebreaker')) {
      return AiMessage(
        role: 'assistant',
        content:
            "Here's a golden rule: Curiosity + Light Playfulness beats 'Hey' every single time! 🔥\n\n"
            "Try this:\n"
            "'I have to ask—what's the story behind your second photo? It looks like an adventure!'",
        timestamp: DateTime.now(),
        suggestions: [
          "Generate opener for coffee lover",
          "How to ask them out smoothly?",
          "Give me a flirty tease line",
        ],
      );
    } else if (lower.contains('bio') || lower.contains('profile')) {
      return AiMessage(
        role: 'assistant',
        content:
            "To make your bio stand out instantly:\n\n"
            "1. Cut clichés like 'love to laugh'\n"
            "2. Add 1 specific favorite local spot\n"
            "3. End with a fun question or 'Two truths and a lie' prompt to trigger easy replies! ✨",
        timestamp: DateTime.now(),
        suggestions: [
          "Optimize my bio now",
          "What makes photos attractive?",
          "How to sound charismatic",
        ],
      );
    } else {
      return AiMessage(
        role: 'assistant',
        content:
            "Hi there! ✨ I'm your GlowDate AI Wingman. I can help you craft irresistible openers, review your bio, plan unforgettable dates, and coach you through any conversation.",
        timestamp: DateTime.now(),
        suggestions: [
          "Write an opener for my match",
          "Rate and polish my bio",
          "Plan a fun first date",
          "Give me top dating advice",
        ],
      );
    }
  }
}
