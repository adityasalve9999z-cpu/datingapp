import 'dart:async';
import 'package:flutter/material.dart';

class CallProvider extends ChangeNotifier {
  bool _isMuted = false;
  bool _isCameraOn = true;
  bool _isSpeakerOn = false;
  bool _isCallActive = false;
  int _callDurationSeconds = 0;
  Timer? _timer;

  bool get isMuted => _isMuted;
  bool get isCameraOn => _isCameraOn;
  bool get isSpeakerOn => _isSpeakerOn;
  bool get isCallActive => _isCallActive;
  int get callDurationSeconds => _callDurationSeconds;

  String get formattedDuration {
    final minutes = (_callDurationSeconds / 60).floor().toString().padLeft(2, '0');
    final seconds = (_callDurationSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    notifyListeners();
  }

  void toggleCamera() {
    _isCameraOn = !_isCameraOn;
    notifyListeners();
  }

  void toggleSpeaker() {
    _isSpeakerOn = !_isSpeakerOn;
    notifyListeners();
  }

  void startCall({bool isVideoCall = true}) {
    _isCallActive = true;
    _callDurationSeconds = 0;
    _isCameraOn = isVideoCall;
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _callDurationSeconds++;
      notifyListeners();
    });
    
    notifyListeners();
  }

  void endCall() {
    _isCallActive = false;
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
