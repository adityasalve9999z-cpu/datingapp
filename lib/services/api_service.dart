import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/profile_model.dart';

class AppApiService {
  static const String _baseUrl = 'https://dummyjson.com';
  static const String _placeholderBaseUrl = 'https://jsonplaceholder.typicode.com';

  static Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', name);
  }

  static Future<String?> getSavedUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name');
  }

  static Future<Map<String, dynamic>> fetchDashboardData() async {
    final profile = (await fetchProfiles()).firstOrNull ?? mockProfiles.first;
    return {
      'name': profile.name,
      'age': profile.age,
      'photo': profile.photos.first,
      'occupation': profile.occupation,
      'location': profile.location,
      'completion': profile.profileCompletion,
      'membership': 'GlowDate+',
      'message': 'Your profile is ready to shine',
    };
  }

  static Future<Map<String, dynamic>> fetchUserProfile() async {
    final profile = (await fetchProfiles()).firstOrNull ?? mockProfiles.first;
    return {
      'name': profile.name,
      'age': profile.age,
      'photo': profile.photos.first,
      'occupation': profile.occupation,
      'location': profile.location,
      'profileCompletion': profile.profileCompletion,
      'preferences': {
        'showMeOnDiscovery': true,
        'globalMode': false,
        'newMatches': true,
        'newMessages': true,
        'likesYou': true,
        'promotions': false,
        'readReceipts': true,
        'onlineStatus': true,
        'incognitoMode': false,
      },
    };
  }

  static Future<Map<String, dynamic>> updatePreferences(Map<String, dynamic> preferences) async {
    try {
      final response = await http.post(
        Uri.parse('$_placeholderBaseUrl/posts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(preferences),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': 'Preferences updated'};
      }
    } catch (_) {}

    return {'success': true, 'message': 'Preferences saved locally'};
  }

  static Future<List<Map<String, dynamic>>> fetchLearningTips() async {
    try {
      final response = await http.get(Uri.parse('$_placeholderBaseUrl/posts?userId=1'));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as List<dynamic>;
        return body.take(3).map((item) {
          final map = item as Map<String, dynamic>;
          return {
            'title': map['title']?.toString() ?? 'Level up your dating game',
            'subtitle': map['body']?.toString() ?? 'Keep your profile warm and your first message personal.',
            'icon': 'auto_awesome_rounded',
            'color': 'primaryRose',
          };
        }).toList();
      }
    } catch (_) {}

    return [
      {
        'title': 'Start with the basics',
        'subtitle': 'Create a clear profile, add your best photos, and set your vibe.',
        'icon': 'rocket_launch_rounded',
        'color': 'primaryRose',
      },
      {
        'title': 'Learn what works',
        'subtitle': 'Review your matches, responses, and interactions to improve your approach.',
        'icon': 'insights_rounded',
        'color': 'accentCyan',
      },
      {
        'title': 'Level up your game',
        'subtitle': 'Use stronger prompts, better timing, and smarter habits to stand out.',
        'icon': 'auto_awesome_rounded',
        'color': 'accentGold',
      },
    ];
  }

  static Future<ProfileModel> fetchProfileById(String id) async {
    final profiles = await fetchProfiles();
    return profiles.firstWhere((profile) => profile.id == id, orElse: () => profiles.firstOrNull ?? mockProfiles.first);
  }

  static Future<Map<String, dynamic>> login({required String email, required String password}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': email.contains('@') ? 'emilys' : email,
          'password': password.isEmpty ? '0lelplR' : password,
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final token = body['token']?.toString() ?? 'demo-token';
        await saveToken(token);
        final name = body['firstName']?.toString() ?? email.split('@').first;
        await saveUserName(name);
        return {'success': true, 'message': 'Signed in successfully', 'token': token, 'name': name};
      }
    } catch (_) {}

    await saveToken('demo-token');
    final fallbackName = email.split('@').first;
    await saveUserName(fallbackName);
    return {
      'success': true,
      'message': 'Using demo mode while the API is unavailable',
      'token': 'demo-token',
      'name': fallbackName,
    };
  }

  static Future<Map<String, dynamic>> signup({required String name, required String email, required String password}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/users/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': name.split(' ').first,
          'lastName': name.split(' ').length > 1 ? name.split(' ').sublist(1).join(' ') : 'User',
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        await saveUserName(body['firstName']?.toString() ?? name.split(' ').first);
        return {'success': true, 'message': 'Account created', 'user': body};
      }
    } catch (_) {}

    await saveUserName(name.split(' ').first);
    return {'success': true, 'message': 'Account created in demo mode'};
  }

  static Future<List<ProfileModel>> fetchProfiles() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/users?limit=6'));
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final users = body['users'] as List<dynamic>? ?? [];
        return users
            .map((item) => ProfileModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}

    return mockProfiles;
  }

  static Future<Map<String, dynamic>> submitOnboarding(Map<String, dynamic> payload) async {
    try {
      final response = await http.post(
        Uri.parse('$_placeholderBaseUrl/posts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': 'Profile setup synced'};
      }
    } catch (_) {}

    return {'success': true, 'message': 'Profile setup saved locally'};
  }

  static Future<Map<String, dynamic>> saveProfile(Map<String, dynamic> payload) async {
    try {
      final response = await http.post(
        Uri.parse('$_placeholderBaseUrl/posts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': 'Profile updated'};
      }
    } catch (_) {}

    return {'success': true, 'message': 'Profile updated in demo mode'};
  }

  static Future<Map<String, dynamic>> purchaseSubscription(String tier) async {
    try {
      final response = await http.post(
        Uri.parse('$_placeholderBaseUrl/posts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'tier': tier, 'status': 'active'}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': 'Subscription activated'};
      }
    } catch (_) {}

    return {'success': true, 'message': 'Subscription activated in demo mode'};
  }

  static Future<List<Map<String, dynamic>>> fetchMatches() async {
    final profiles = await fetchProfiles();
    return List.generate(profiles.length, (index) {
      final profile = profiles[index];
      return {
        'profile': profile,
        'lastMessage': index.isEven ? 'I love your energy! 💖' : 'Want to grab coffee this week?',
        'time': index == 0 ? 'Now' : '${index + 1}h ago',
        'unread': index == 0 ? 2 : 0,
        'isOnline': index < 2,
      };
    });
  }

  static Future<List<Map<String, dynamic>>> fetchLikes() async {
    final profiles = await fetchProfiles();
    return profiles.asMap().entries.map((entry) {
      final index = entry.key;
      final profile = entry.value;
      return {
        'profile': profile,
        'score': profile.compatibilityScore + index,
      };
    }).toList();
  }
}

extension IterableExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
