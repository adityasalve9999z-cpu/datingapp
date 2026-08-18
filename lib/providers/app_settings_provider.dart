import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AppSettingsProvider extends ChangeNotifier {
  bool _isDarkMode = true;
  bool _pushNotifications = true;
  bool _incognitoMode = false;
  bool _globalMode = false;
  double _maxDistance = 30.0;
  RangeValues _ageRange = const RangeValues(21, 34);
  bool _isLoading = true;

  bool get isDarkMode => _isDarkMode;
  bool get pushNotifications => _pushNotifications;
  bool get incognitoMode => _incognitoMode;
  bool get globalMode => _globalMode;
  double get maxDistance => _maxDistance;
  RangeValues get ageRange => _ageRange;
  bool get isLoading => _isLoading;

  AppSettingsProvider() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await AppApiService.fetchUserProfile();
      final prefs = data['preferences'] as Map<String, dynamic>? ?? {};

      _isDarkMode = true;
      _pushNotifications = prefs['newMessages'] as bool? ?? true;
      _incognitoMode = prefs['incognitoMode'] as bool? ?? false;
      _globalMode = prefs['globalMode'] as bool? ?? false;
      _maxDistance = (prefs['maxDistance'] as num?)?.toDouble() ?? 30.0;
      _isLoading = false;
      notifyListeners();
    } catch (_) {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setDistance(double distance) {
    _maxDistance = distance;
    notifyListeners();
    _saveToBackend();
  }

  void setAgeRange(RangeValues range) {
    _ageRange = range;
    notifyListeners();
    _saveToBackend();
  }

  void setIncognito(bool value) {
    _incognitoMode = value;
    notifyListeners();
    _saveToBackend();
  }

  void setGlobalMode(bool value) {
    _globalMode = value;
    notifyListeners();
    _saveToBackend();
  }

  void setNotifications(bool value) {
    _pushNotifications = value;
    notifyListeners();
    _saveToBackend();
  }

  void _saveToBackend() {
    AppApiService.saveSettings({
      'maxDistance': _maxDistance.toInt(),
      'ageRangeStart': _ageRange.start.toInt(),
      'ageRangeEnd': _ageRange.end.toInt(),
      'incognitoMode': _incognitoMode,
      'globalMode': _globalMode,
      'newMessages': _pushNotifications,
    });
  }
}
