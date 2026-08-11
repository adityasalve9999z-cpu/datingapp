import 'dart:async';

class AiService {
  /// Sends a message to the AI agent and returns a stream of responses
  /// (simulating typing/network latency).
  static Future<String> sendMessage(String message) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    final lower = message.toLowerCase();
    
    if (lower.contains('hello') || lower.contains('hi')) {
      return "Hi there! ✨ I'm your GlowDate AI wingman. I can help you write the perfect opening line, review your profile, or give you dating advice. What's on your mind?";
    } else if (lower.contains('opener') || lower.contains('icebreaker')) {
      return "Here's a fun icebreaker you can use:\n\n'If we went out for coffee, what's your go-to order, and what does it say about you?'\n\nIt's low-pressure and gives them a chance to talk about themselves!";
    } else if (lower.contains('profile')) {
      return "Your profile is looking great! To make it stand out even more, try adding a prompt that shows off your sense of humor, or a photo of you doing one of your favorite hobbies.";
    } else {
      return "That's an interesting point! Since I'm still learning, I might not have the perfect answer for that yet. Try asking me for an icebreaker or some profile advice! ✨";
    }
  }
}
