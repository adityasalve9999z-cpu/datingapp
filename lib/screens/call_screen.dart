import 'dart:async';
import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../theme/app_theme.dart';

class CallScreen extends StatefulWidget {
  final ProfileModel profile;
  final bool isVideoCall;

  const CallScreen({
    super.key,
    required this.profile,
    this.isVideoCall = true,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  bool _isMuted = false;
  bool _isVideoOff = false;
  bool _isSpeakerOn = true;
  bool _isFrontCamera = true;
  bool _glowFilterActive = true;
  int _callDurationSeconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _isVideoOff = !widget.isVideoCall;
    _startCallTimer();
  }

  void _startCallTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _callDurationSeconds++);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _endCall() {
    _timer?.cancel();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Call with ${widget.profile.name.split(' ').first} ended (${_formatDuration(_callDurationSeconds)})')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final photoUrl = profile.photos.isNotEmpty
        ? profile.photos.first
        : 'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=600&q=80';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main Video / Background Area
          if (!_isVideoOff)
            Positioned.fill(
              child: Image.network(
                photoUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: AppTheme.surfaceDark),
              ),
            )
          else
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, -0.2),
                    radius: 1.2,
                    colors: [Color(0x554A2E55), AppTheme.darkBackground],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.accentGold, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.accentGold.withOpacity(0.3),
                              blurRadius: 24,
                            ),
                          ],
                          image: DecorationImage(
                            image: NetworkImage(photoUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        profile.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Voice Call Connected • ${_formatDuration(_callDurationSeconds)}',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Vignette Overlay for video call
          if (!_isVideoOff)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0x99000000),
                      Colors.transparent,
                      Color(0xCC000000),
                    ],
                    stops: [0.0, 0.4, 1.0],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

          // Top Info Bar (Caller Name, Duration & Badges)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black45,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.emeraldGreen,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatDuration(_callDurationSeconds),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Filter toggle
                  if (!_isVideoOff)
                    IconButton(
                      icon: Icon(
                        _glowFilterActive ? Icons.auto_awesome_rounded : Icons.auto_awesome_outlined,
                        color: _glowFilterActive ? AppTheme.accentGold : Colors.white70,
                      ),
                      onPressed: () {
                        setState(() => _glowFilterActive = !_glowFilterActive);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_glowFilterActive ? 'Glow beauty filter enabled' : 'Filter disabled'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  IconButton(
                    icon: Icon(
                      _isSpeakerOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
                  ),
                ],
              ),
            ),
          ),

          // PIP Self Preview (for Video Calls)
          if (!_isVideoOff)
            Positioned(
              top: 80,
              right: 20,
              child: Container(
                width: 100,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.accentGold, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                    ),
                  ],
                  image: const DecorationImage(
                    image: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=600&q=80'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

          // Bottom Call Dock Controls
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark.withOpacity(0.85),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Mute / Unmute
                  _buildCallActionBtn(
                    icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                    isActive: !_isMuted,
                    activeColor: Colors.white24,
                    inactiveColor: Colors.redAccent,
                    onTap: () => setState(() => _isMuted = !_isMuted),
                  ),

                  // Video Toggle
                  _buildCallActionBtn(
                    icon: _isVideoOff ? Icons.videocam_off_rounded : Icons.videocam_rounded,
                    isActive: !_isVideoOff,
                    activeColor: Colors.white24,
                    inactiveColor: Colors.redAccent,
                    onTap: () => setState(() => _isVideoOff = !_isVideoOff),
                  ),

                  // Camera Flip
                  if (!_isVideoOff)
                    _buildCallActionBtn(
                      icon: Icons.flip_camera_ios_rounded,
                      isActive: true,
                      activeColor: Colors.white24,
                      onTap: () => setState(() => _isFrontCamera = !_isFrontCamera),
                    ),

                  // End Call Button
                  GestureDetector(
                    onTap: _endCall,
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFE02B48),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x66E02B48),
                            blurRadius: 14,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.call_end_rounded, color: Colors.white, size: 28),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallActionBtn({
    required IconData icon,
    required bool isActive,
    required Color activeColor,
    Color? inactiveColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? activeColor : (inactiveColor ?? Colors.redAccent),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}
