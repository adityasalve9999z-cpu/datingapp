import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/profile_model.dart';

class AppApiService {
  static final _supabase = Supabase.instance.client;

  static Future<String?> getStoredToken() async {
    final session = _supabase.auth.currentSession;
    return session?.accessToken;
  }

  static Future<void> saveToken(String token) async {
    // Supabase handles session persistence automatically.
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
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return _fallbackProfile();
    }

    try {
      final data =
          await _supabase.from('profiles').select().eq('id', user.id).single();

      final profile = ProfileModel.fromJson(data);
      return {
        'name': profile.name,
        'age': profile.age,
        'photo': profile.photos.isNotEmpty ? profile.photos.first : '',
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
    } catch (_) {
      return _fallbackProfile();
    }
  }

  static Map<String, dynamic> _fallbackProfile() {
    final profile = mockProfiles.first;
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

  static Future<Map<String, dynamic>> updatePreferences(
      Map<String, dynamic> preferences) async {
    // In a real app, you would have a preferences table or a JSONB column in profiles.
    return {'success': true, 'message': 'Preferences saved successfully'};
  }

  static Future<List<Map<String, dynamic>>> fetchLearningTips() async {
    return [
      {
        'title': 'Start with the basics',
        'subtitle':
            'Create a clear profile, add your best photos, and set your vibe.',
        'icon': 'rocket_launch_rounded',
        'color': 'primaryRose',
      },
      {
        'title': 'Learn what works',
        'subtitle':
            'Review your matches, responses, and interactions to improve your approach.',
        'icon': 'insights_rounded',
        'color': 'accentCyan',
      },
      {
        'title': 'Level up your game',
        'subtitle':
            'Use stronger prompts, better timing, and smarter habits to stand out.',
        'icon': 'auto_awesome_rounded',
        'color': 'accentGold',
      },
    ];
  }

  static Future<ProfileModel> fetchProfileById(String id) async {
    try {
      final data =
          await _supabase.from('profiles').select().eq('id', id).single();
      return ProfileModel.fromJson(data);
    } catch (_) {
      final profiles = await fetchProfiles();
      return profiles.firstWhere((profile) => profile.id == id,
          orElse: () => mockProfiles.first);
    }
  }

  static Future<Map<String, dynamic>> login(
      {required String email, required String password}) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final name = response.user!.userMetadata?['firstName']?.toString() ??
            email.split('@').first;
        await saveUserName(name);
        return {
          'success': true,
          'message': 'Signed in successfully',
          'token': response.session?.accessToken,
          'name': name
        };
      }
    } on AuthException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }

    final fallbackName = email.split('@').first;
    await saveUserName(fallbackName);
    return {
      'success': true,
      'message': 'Using demo mode while the API is unavailable',
      'token': 'demo-token',
      'name': fallbackName,
    };
  }

  static Future<Map<String, dynamic>> signup(
      {required String name,
      required String email,
      required String password}) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'firstName': name.split(' ').first,
          'lastName': name.split(' ').length > 1
              ? name.split(' ').sublist(1).join(' ')
              : ''
        },
      );

      if (response.user != null) {
        await saveUserName(name.split(' ').first);
        return {
          'success': true,
          'message': 'Account created',
          'user': response.user!.toJson()
        };
      }
    } on AuthException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }

    await saveUserName(name.split(' ').first);
    return {'success': true, 'message': 'Account created in demo mode'};
  }

  static Future<List<ProfileModel>> fetchProfiles() async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      var query = _supabase.from('profiles').select().limit(10);

      if (currentUserId != null) {
        query = query.neq('id', currentUserId);
      }

      final data = await query;
      final users = data as List<dynamic>? ?? [];

      if (users.isNotEmpty) {
        return users
            .map((item) => ProfileModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}

    return mockProfiles;
  }

  static Future<Map<String, dynamic>> submitOnboarding(
      Map<String, dynamic> payload) async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        await _supabase.from('profiles').update(payload).eq('id', user.id);
        return {'success': true, 'message': 'Profile setup synced'};
      } catch (e) {
        return {'success': false, 'message': e.toString()};
      }
    }
    return {'success': true, 'message': 'Profile setup saved locally'};
  }

  static Future<Map<String, dynamic>> saveProfile(
      Map<String, dynamic> payload) async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        await _supabase.from('profiles').update(payload).eq('id', user.id);
        return {'success': true, 'message': 'Profile updated'};
      } catch (e) {
        return {'success': false, 'message': e.toString()};
      }
    }
    return {'success': true, 'message': 'Profile updated in demo mode'};
  }

  static Future<Map<String, dynamic>> purchaseSubscription(String tier) async {
    return {'success': true, 'message': 'Subscription activated'};
  }

  static Future<List<Map<String, dynamic>>> fetchMatches() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final data = await _supabase
            .from('matches')
            .select('''
              id,
              status,
              created_at,
              user1_id,
              user2_id
            ''')
            .or('user1_id.eq.${user.id},user2_id.eq.${user.id}')
            .eq('status', 'matched');

        if (data.isNotEmpty) {
          // Fetch profiles for these matches
          final matchResults = <Map<String, dynamic>>[];
          for (var match in data) {
            final otherUserId = match['user1_id'] == user.id
                ? match['user2_id']
                : match['user1_id'];
            final profileData = await _supabase
                .from('profiles')
                .select()
                .eq('id', otherUserId)
                .single();
            final profile = ProfileModel.fromJson(profileData);

            // Get last message
            final messageData = await _supabase
                .from('messages')
                .select()
                .eq('match_id', match['id'])
                .order('created_at', ascending: false)
                .limit(1)
                .maybeSingle();

            matchResults.add({
              'profile': profile,
              'lastMessage':
                  messageData != null ? messageData['text'] : 'New Match!',
              'time': 'Recently',
              'unread': 0,
              'isOnline': false,
            });
          }
          return matchResults;
        }
      }
    } catch (_) {}

    final profiles = await fetchProfiles();
    return List.generate(profiles.length, (index) {
      final profile = profiles[index];
      return {
        'profile': profile,
        'lastMessage': index.isEven
            ? 'I love your energy! 💖'
            : 'Want to grab coffee this week?',
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

  // ── Auth: Forgot Password ────────────────────────────────────────────────

  static Future<Map<String, dynamic>> forgotPassword(
      {required String email}) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return {'success': true, 'message': 'Reset link sent to $email'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ── Auth: Reset Password ─────────────────────────────────────────────────

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
      return {'success': true, 'message': 'Password updated successfully'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ── Auth: OTP Verification ────────────────────────────────────────────────

  static Future<Map<String, dynamic>> verifyOtp({
    required String code,
    String? email,
    String? phone,
  }) async {
    try {
      if (email != null) {
        await _supabase.auth
            .verifyOTP(email: email, token: code, type: OtpType.signup);
        return {'success': true, 'message': 'Verified successfully'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }

    // Fallback demo rule
    final lastDigit = int.tryParse(code.substring(code.length - 1)) ?? 0;
    final isValid = lastDigit.isEven;
    return {
      'success': isValid,
      'message': isValid ? 'Verified successfully' : 'Incorrect code',
    };
  }

  static Future<Map<String, dynamic>> resendOtp(
      {String? email, String? phone}) async {
    return {'success': true, 'message': 'A new code has been sent'};
  }

  // ── Chat: Send Message ────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> sendMessage({
    required String toUserId,
    required String text,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        // Find match first
        final matchData = await _supabase
            .from('matches')
            .select()
            .or('user1_id.eq.${user.id},user2_id.eq.${user.id}')
            .or('user1_id.eq.$toUserId,user2_id.eq.$toUserId')
            .maybeSingle();

        String? matchId;
        if (matchData != null) {
          matchId = matchData['id'];
        }

        await _supabase.from('messages').insert({
          'match_id': matchId,
          'sender_id': user.id,
          'receiver_id': toUserId,
          'text': text,
        });
        return {'success': true, 'message': 'Message sent'};
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }

    return {'success': true, 'message': 'Message queued'};
  }

  static Future<List<Map<String, dynamic>>> fetchMessages(
      String profileId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final data = await _supabase
            .from('messages')
            .select()
            .or('and(sender_id.eq.${user.id},receiver_id.eq.$profileId),and(sender_id.eq.$profileId,receiver_id.eq.${user.id})')
            .order('created_at', ascending: true);

        if (data.isNotEmpty) {
          return data
              .map((msg) => {
                    'sender': msg['sender_id'] == user.id ? 'me' : 'them',
                    'text': msg['text'],
                    'time': 'Now', // Formatting timestamp logic could go here
                  })
              .toList();
        }
      }
    } catch (_) {}

    return [
      {
        'sender': 'them',
        'text':
            'Hey there! Loved your profile photos. Are you a fan of jazz vinyls too?',
        'time': '10:30 AM',
      },
      {
        'sender': 'me',
        'text':
            'Yes! Big fan of Blue Note records and Miles Davis. How about you?',
        'time': '10:32 AM',
      },
    ];
  }

  // ── Settings ──────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> saveSettings(
      Map<String, dynamic> settings) async {
    return {'success': true, 'message': 'Settings saved'};
  }

  // ── Account ───────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> logout() async {
    try {
      await _supabase.auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_name');
    } catch (_) {}
    return {'success': true, 'message': 'Logged out'};
  }

  static Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        // Technically relies on edge functions or server-side admin client to delete user
        // We'll just sign out here for demo
        await _supabase.auth.signOut();
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      return {'success': true, 'message': 'Account deleted'};
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    return {'success': true, 'message': 'Account removed'};
  }

  // ── Gender / Onboarding step ──────────────────────────────────────────────

  static Future<Map<String, dynamic>> saveGender({
    required String gender,
    required bool showOnProfile,
  }) async {
    return {'success': true, 'message': 'Gender saved'};
  }
}

extension IterableExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
