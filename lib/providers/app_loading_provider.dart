import 'package:flutter/material.dart';

class AppLoadingProvider extends ChangeNotifier {
  bool _isLoading = false;
  String _message = 'Loading...';

  bool get isLoading => _isLoading;
  String get message => _message;

  void show({String message = 'Loading...'}) {
    _isLoading = true;
    _message = message;
    notifyListeners();
  }

  void hide() {
    _isLoading = false;
    notifyListeners();
  }
}
