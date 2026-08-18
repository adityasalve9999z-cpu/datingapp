import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../services/api_service.dart';

class DiscoveryFeedProvider extends ChangeNotifier {
  List<ProfileModel> _profiles = [];
  bool _isLoading = true;
  String? _errorMessage;
  ProfileModel? _lastMatch;
  final List<ProfileModel> _swipeHistory = [];
  Map<String, dynamic> _filters = {
    'maxDistance': 30.0,
    'ageRange': const RangeValues(20, 32),
    'interestedIn': 'Everyone',
  };

  List<ProfileModel> get profiles => _profiles;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ProfileModel? get lastMatch => _lastMatch;
  bool get hasProfiles => _profiles.isNotEmpty;
  Map<String, dynamic> get filters => _filters;

  DiscoveryFeedProvider() {
    loadProfiles();
  }

  Future<void> loadProfiles() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetched = await AppApiService.fetchProfiles();
      _profiles = fetched;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> swipeRight(ProfileModel profile) async {
    return await swipe(profile, 'like');
  }

  Future<bool> swipeLeft(ProfileModel profile) async {
    return await swipe(profile, 'pass');
  }

  Future<bool> superLike(ProfileModel profile) async {
    return await swipe(profile, 'super_like');
  }

  Future<bool> swipe(ProfileModel profile, String action) async {
    _profiles.removeWhere((p) => p.id == profile.id);
    _swipeHistory.add(profile);
    notifyListeners();

    try {
      final result = await AppApiService.recordSwipe(
        targetUserId: profile.id,
        action: action,
      );

      final isMatch = result['is_match'] == true || profile.compatibilityScore >= 92;
      if (isMatch) {
        _lastMatch = profile;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error recording swipe: $e');
    }
    return false;
  }

  void clearLastMatch() {
    _lastMatch = null;
    notifyListeners();
  }

  void undoLastSwipe() {
    if (_swipeHistory.isNotEmpty) {
      final last = _swipeHistory.removeLast();
      _profiles.insert(0, last);
      notifyListeners();
    }
  }

  void applyFilters(Map<String, dynamic> newFilters) {
    _filters = newFilters;
    notifyListeners();
    loadProfiles();
  }
}
