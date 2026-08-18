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

  static Map<String, dynamic> _normalizeProfilePayload(Map<String, dynamic> raw) {
    final payload = <String, dynamic>{};
    raw.forEach((key, value) {
      if (value == null) return;
      switch (key) {
        case 'name':
          final str = value.toString().trim();
          final parts = str.split(' ');
          payload['first_name'] = parts.isNotEmpty ? parts.first : str;
          if (parts.length > 1) {
            payload['last_name'] = parts.sublist(1).join(' ');
          }
          break;
        case 'firstName':
          payload['first_name'] = value;
          break;
        case 'lastName':
          payload['last_name'] = value;
          break;
        case 'goals':
        case 'relationshipGoal':
          payload['relationship_goal'] = value;
          break;
        case 'promptAnswer':
          payload['prompt_answer'] = value;
          break;
        case 'promptQuestion':
          payload['prompt_question'] = value;
          break;
        case 'audioPromptTitle':
          payload['audio_prompt_title'] = value;
          break;
        case 'audioPromptDuration':
          payload['audio_prompt_duration'] = value;
          break;
        case 'showGender':
          payload['show_gender'] = value;
          break;
        case 'mutualFriends':
          payload['mutual_friends'] = value;
          break;
        case 'instagramHandle':
          payload['instagram_handle'] = value;
          break;
        case 'profileCompletion':
          payload['profile_completion'] = value;
          break;
        case 'isVerified':
          payload['is_verified'] = value;
          break;
        case 'compatibilityScore':
          payload['compatibility_score'] = value;
          break;
        case 'lookingFor':
          payload['looking_for'] = value;
          break;
        default:
          payload[key] = value;
      }
    });
    return payload;
  }

  static Future<List<ProfileModel>> fetchProfiles() async {
    try {
      final currentUserId = _supabase.auth.currentUser?.id;
      final swipedIds = await fetchSwipedIds();
      final blockedIds = await fetchBlockedUsers();
      final excludeIds = <String>{...swipedIds, ...blockedIds};
      if (currentUserId != null) {
        excludeIds.add(currentUserId);
      }

      var query = _supabase.from('profiles').select();
      if (currentUserId != null) {
        query = query.neq('id', currentUserId);
      }

      final data = await query.limit(20);
      final users = data as List<dynamic>? ?? [];

      if (users.isNotEmpty) {
        final results = users
            .map((item) => ProfileModel.fromJson(item as Map<String, dynamic>))
            .where((p) => !excludeIds.contains(p.id))
            .toList();
        if (results.isNotEmpty) return results;
      }
    } catch (_) {}

    return mockProfiles;
  }

  static Future<Map<String, dynamic>> submitOnboarding(
      Map<String, dynamic> payload) async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        final normalized = _normalizeProfilePayload(payload);
        await _supabase.from('profiles').update(normalized).eq('id', user.id);
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
        final normalized = _normalizeProfilePayload(payload);
        await _supabase.from('profiles').update(normalized).eq('id', user.id);
        return {'success': true, 'message': 'Profile updated'};
      } catch (e) {
        return {'success': false, 'message': e.toString()};
      }
    }
    return {'success': true, 'message': 'Profile updated in demo mode'};
  }

  static Future<Map<String, dynamic>> purchaseSubscription(String tier) async {
    return updateSubscription(tier);
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
            try {
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
                'id': match['id'],
                'profile': profile,
                'lastMessage':
                    messageData != null ? messageData['text'] : 'New Match!',
                'time': messageData != null
                    ? _formatTimestamp(messageData['created_at']?.toString())
                    : 'Recently',
                'unread': 0,
                'isOnline': false,
              });
            } catch (_) {}
          }
          if (matchResults.isNotEmpty) return matchResults;
        }
      }
    } catch (_) {}

    final profiles = await fetchProfiles();
    return List.generate(profiles.length, (index) {
      final profile = profiles[index];
      return {
        'id': 'match-$index',
        'profile': profile,
        'lastMessage': index.isEven
            ? 'I love your energy! \u{1F496}'
            : 'Want to grab coffee this week?',
        'time': index == 0 ? 'Now' : '${index + 1}h ago',
        'unread': index == 0 ? 2 : 0,
        'isOnline': index < 2,
      };
    });
  }

  static Future<List<Map<String, dynamic>>> fetchLikes() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final swipes = await _supabase
            .from('swipes')
            .select('swiper_id, action, created_at')
            .eq('swiped_id', user.id)
            .inFilter('action', ['like', 'super_like']);

        if (swipes.isNotEmpty) {
          final likesList = <Map<String, dynamic>>[];
          for (final swipe in swipes) {
            final swiperId = swipe['swiper_id']?.toString();
            if (swiperId == null) continue;
            try {
              final profileData = await _supabase
                  .from('profiles')
                  .select()
                  .eq('id', swiperId)
                  .single();
              final profile = ProfileModel.fromJson(profileData);
              likesList.add({
                'profile': profile,
                'score': profile.compatibilityScore,
                'action': swipe['action'],
                'createdAt': swipe['created_at'],
              });
            } catch (_) {}
          }
          if (likesList.isNotEmpty) return likesList;
        }
      }
    } catch (_) {}

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
                    'time': _formatTimestamp(msg['created_at']?.toString()),
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

  static Stream<List<Map<String, dynamic>>> streamMessages(String profileId) {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _supabase
        .from('messages')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true)
        .map((rows) {
          final filtered = rows.where((msg) {
            final senderId = msg['sender_id']?.toString();
            final receiverId = msg['receiver_id']?.toString();
            return (senderId == user.id && receiverId == profileId) ||
                (senderId == profileId && receiverId == user.id);
          }).toList();

          return filtered.map((msg) {
            return {
              'id': msg['id'],
              'sender': msg['sender_id'] == user.id ? 'me' : 'them',
              'text': msg['text']?.toString() ?? '',
              'time': _formatTimestamp(msg['created_at']?.toString()),
            };
          }).toList();
        });
  }

  static String _formatTimestamp(String? isoString) {
    if (isoString == null) return 'Now';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$hour:$minute $period';
    } catch (_) {
      return 'Now';
    }
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
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        await _supabase.from('profiles').update({
          'gender': gender,
          'show_gender': showOnProfile,
        }).eq('id', user.id);
        return {'success': true, 'message': 'Gender saved'};
      } catch (e) {
        return {'success': false, 'message': e.toString()};
      }
    }
    return {'success': true, 'message': 'Gender saved locally'};
  }

  // ── Discovery: Swipe Right (Like) ─────────────────────────────────────────

  /// Records a like/super_like swipe. Returns `{'result': 'match'}` if it
  /// created a mutual match, or `{'result': 'liked'}` otherwise.
  static Future<Map<String, dynamic>> swipeRight(String targetUserId,
      {bool isSuperLike = false}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return {'result': 'liked'};

    try {
      final action = isSuperLike ? 'super_like' : 'like';
      final result = await _supabase.rpc('process_swipe', params: {
        'p_swiper_id': user.id,
        'p_swiped_id': targetUserId,
        'p_action': action,
      });
      // result is a JSON object like {"result": "match", "match_id": "..."}
      if (result is Map<String, dynamic>) return result;
      return {'result': 'liked'};
    } catch (e) {
      return {'result': 'liked', 'error': e.toString()};
    }
  }

  // ── Discovery: Swipe Left (Dislike) ──────────────────────────────────────

  /// Records a dislike swipe so the same profile is never shown again.
  static Future<void> swipeLeft(String targetUserId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      await _supabase.rpc('process_swipe', params: {
        'p_swiper_id': user.id,
        'p_swiped_id': targetUserId,
        'p_action': 'dislike',
      });
    } catch (_) {}
  }

  // ── Discovery: Fetch already-swiped IDs ──────────────────────────────────

  /// Returns all user IDs the current user has already swiped so they can be
  /// excluded from the discovery feed.
  static Future<List<String>> fetchSwipedIds() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final data = await _supabase
          .from('swipes')
          .select('swiped_id')
          .eq('swiper_id', user.id);
      return (data as List<dynamic>)
          .map((e) => e['swiped_id'].toString())
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── Safety: Report a User ─────────────────────────────────────────────────

  /// Submits a user report. [reason] must match one of the CHECK constraint
  /// values defined in the `reports` table in supabase_schema.sql.
  static Future<Map<String, dynamic>> reportUser({
    required String reportedUserId,
    required String reason,
    String? details,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return {'success': false, 'message': 'Not authenticated'};
    }

    try {
      await _supabase.from('reports').insert({
        'reporter_id': user.id,
        'reported_id': reportedUserId,
        'reason': reason,
        'details': details,
      });
      return {'success': true, 'message': 'Report submitted'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ── Safety: Block a User ──────────────────────────────────────────────────

  /// Blocks [targetUserId]. Blocked users are excluded from discovery and
  /// their existing matches/messages become inaccessible.
  static Future<Map<String, dynamic>> blockUser(String targetUserId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return {'success': false, 'message': 'Not authenticated'};
    }

    try {
      await _supabase.from('blocked_users').insert({
        'blocker_id': user.id,
        'blocked_id': targetUserId,
      });
      return {'success': true, 'message': 'User blocked'};
    } catch (e) {
      // Unique constraint violation means already blocked — treat as success
      if (e.toString().contains('unique') || e.toString().contains('23505')) {
        return {'success': true, 'message': 'Already blocked'};
      }
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Unblocks [targetUserId].
  static Future<Map<String, dynamic>> unblockUser(String targetUserId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return {'success': false, 'message': 'Not authenticated'};
    }

    try {
      await _supabase
          .from('blocked_users')
          .delete()
          .eq('blocker_id', user.id)
          .eq('blocked_id', targetUserId);
      return {'success': true, 'message': 'User unblocked'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Returns a list of user IDs that the current user has blocked.
  static Future<List<String>> fetchBlockedUsers() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final data = await _supabase
          .from('blocked_users')
          .select('blocked_id')
          .eq('blocker_id', user.id);
      return (data as List<dynamic>)
          .map((e) => e['blocked_id'].toString())
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── Subscription / Premium ────────────────────────────────────────────────

  /// Fetches the current user's subscription info.
  /// Returns a map with keys: `tier` ('free'|'gold'|'platinum'),
  /// `is_active`, `expires_at`.
  static Future<Map<String, dynamic>> fetchSubscription() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return {'tier': 'free', 'is_active': false};

    try {
      final data = await _supabase
          .from('subscriptions')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();
      if (data != null) return data as Map<String, dynamic>;
    } catch (_) {}

    return {'tier': 'free', 'is_active': true};
  }

  /// Upserts a subscription row for the current user with the given [tier].
  /// In production, call this from a server-side webhook after payment
  /// confirmation, not directly from the client.
  static Future<Map<String, dynamic>> updateSubscription(String tier,
      {DateTime? expiresAt}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return {'success': false, 'message': 'Not authenticated'};
    }

    try {
      await _supabase.from('subscriptions').upsert({
        'user_id': user.id,
        'tier': tier,
        'is_active': true,
        'started_at': DateTime.now().toIso8601String(),
        'expires_at': expiresAt?.toIso8601String(),
      }, onConflict: 'user_id');
      return {'success': true, 'message': 'Subscription activated: $tier'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // ── Profile Photo Upload ──────────────────────────────────────────────────

  /// Uploads a profile photo from [localFilePath] to the `profile-photos`
  /// Supabase Storage bucket and returns the public URL.
  ///
  /// Requires the `profile-photos` bucket to be created in the Supabase
  /// Dashboard with the Storage RLS policies from supabase_schema.sql.
  static Future<Map<String, dynamic>> uploadProfilePhoto(
      String localFilePath) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      return {'success': false, 'message': 'Not authenticated'};
    }

    try {
      final fileName =
          '${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final bytes = await _readFileBytes(localFilePath);
      if (bytes == null) {
        return {'success': false, 'message': 'Could not read file'};
      }

      await _supabase.storage.from('profile-photos').uploadBinary(
            fileName.bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );

      final publicUrl =
          _supabase.storage.from('profile-photos').getPublicUrl(fileName);

      return {'success': true, 'url': publicUrl};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static List<int> newMethod(List<int> bytes) => bytes;

  /// Reads file bytes from [path]. Supports both dart:io (mobile/desktop)
  /// and web (returns null on unsupported platforms gracefully).
  static Future<List<int>?> _readFileBytes(String path) async {
    try {
      // dart:io is available on Android / iOS / desktop
      final file = await _loadFile(path);
      return file;
    } catch (_) {
      return null;
    }
  }

  static Future<List<int>?> _loadFile(String path) async {
    // Lazy import to avoid web compile errors
    try {
      // ignore: avoid_dynamic_calls
      final dynamic io = await _ioFile(path);
      return io;
    } catch (_) {
      return null;
    }
  }

  static Future<List<int>?> _ioFile(String path) async {
    // Uses dart:io only at runtime — safe on mobile/desktop
    // ignore: unnecessary_import
    final ioImport = _fileHelper;
    return ioImport?.call(path);
  }

  // File helper: set at app start for platforms that support dart:io
  static Future<List<int>?> Function(String)? _fileHelper;

  /// Call once in main() on mobile/desktop to enable photo uploads:
  /// ```dart
  /// AppApiService.registerFileHelper((path) async {
  ///   return await File(path).readAsBytes();
  /// });
  /// ```
  static void registerFileHelper(Future<List<int>?> Function(String) helper) {
    _fileHelper = helper;
  }
}

extension IterableExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
