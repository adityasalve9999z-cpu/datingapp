import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProfileProvider extends ChangeNotifier {
  Map<String, dynamic> _profileData = {};
  bool _isLoading = true;
  String? _errorMessage;

  Map<String, dynamic> get profileData => _profileData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get name => _profileData['name']?.toString() ?? 'Maya';
  String get age => _profileData['age']?.toString() ?? '25';
  String get occupation => _profileData['occupation']?.toString() ?? 'UX Designer';
  String get location => _profileData['location']?.toString() ?? 'San Francisco';
  String get bio => _profileData['bio']?.toString() ?? '';
  String get avatarUrl => _profileData['photo']?.toString() ?? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=600&q=80';
  List<String> get photos => List<String>.from(_profileData['photos'] ?? [avatarUrl]);
  List<String> get interests => List<String>.from(_profileData['interests'] ?? ['Design', 'Coffee', 'Travel', 'Art']);
  double get profileCompletion => (_profileData['profileCompletion'] as num?)?.toDouble() ?? 85.0;

  ProfileProvider() {
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await AppApiService.fetchUserProfile();
      _profileData = data;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await AppApiService.updateProfile(updates);
      if (result['success'] == true) {
        _profileData.addAll(updates);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _errorMessage = result['message']?.toString();
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<String?> uploadPhoto(String localFilePath) async {
    try {
      final result = await AppApiService.uploadProfilePhoto(localFilePath);
      if (result['success'] == true && result['url'] != null) {
        final newUrl = result['url'] as String;
        final updatedPhotos = List<String>.from(photos)..add(newUrl);
        await updateProfile({'photos': updatedPhotos, 'photo': newUrl});
        return newUrl;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
    return null;
  }
}
