import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/profile_model.dart';
import '../providers/call_provider.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CallProvider>().startCall(isVideoCall: widget.isVideoCall);
    });
  }

  void _endCall() {
    context.read<CallProvider>().endCall();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer<CallProvider>(
        builder: (context, callState, child) {
          final isVideoActive = widget.isVideoCall && callState.isCameraOn;

          return Stack(
            fit: StackFit.expand,
            children: [
              // Background (Remote Video or Blurred Image)
              if (isVideoActive)
                _buildRemoteVideoPlaceholder()
              else
                _buildAudioBackground(),

              // Gradient Overlay for visibility of top/bottom elements
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black87,
                      Colors.transparent,
                      Colors.black87
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
              ),

              // Top Bar (Name, Time, Back button)
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Colors.white,
                                  size: 32),
                              onPressed: _endCall,
                            ),
                            const Icon(newMethod,
                                color: AppTheme.emeraldGreen, size: 16),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.profile.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          callState.formattedDuration,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // PIP Local Video
              if (isVideoActive)
                Positioned(
                  top: 120,
                  right: 20,
                  child: _buildLocalVideoPIP(),
                ),

              // Bottom Control Bar
              Align(
                alignment: Alignment.bottomCenter,
                child: _buildControlBar(callState),
              ),
            ],
          );
        },
      ),
    );
  }

  dynamic get newMethod => Icons.encrypted_rounded;

  Widget _buildAudioBackground() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          widget.profile.photos.isNotEmpty ? widget.profile.photos.first : '',
          fit: BoxFit.cover,
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            color: Colors.black.withOpacity(0.4),
          ),
        ),
        Center(
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primaryRose, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryRose.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
              image: DecorationImage(
                image: NetworkImage(
                  widget.profile.photos.isNotEmpty
                      ? widget.profile.photos.first
                      : '',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRemoteVideoPlaceholder() {
    return Image.network(
      widget.profile.photos.isNotEmpty ? widget.profile.photos.first : '',
      fit: BoxFit.cover,
    );
  }

  Widget _buildLocalVideoPIP() {
    return Container(
      width: 110,
      height: 160,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.person, color: Colors.white54, size: 40),
      ),
    );
  }

  Widget _buildControlBar(CallProvider callState) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 32.0, left: 32.0, right: 32.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildControlButton(
              icon:
                  callState.isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
              isActive: !callState.isMuted,
              onTap: () => callState.toggleMute(),
            ),
            if (widget.isVideoCall)
              _buildControlButton(
                icon: callState.isCameraOn
                    ? Icons.videocam_rounded
                    : Icons.videocam_off_rounded,
                isActive: callState.isCameraOn,
                onTap: () => callState.toggleCamera(),
              ),
            _buildControlButton(
              icon: callState.isSpeakerOn
                  ? Icons.volume_up_rounded
                  : Icons.volume_down_rounded,
              isActive: callState.isSpeakerOn,
              onTap: () => callState.toggleSpeaker(),
            ),
            _buildControlButton(
              icon: Icons.call_end_rounded,
              isActive: true,
              activeColor: AppTheme.primaryCoral,
              iconColor: Colors.white,
              onTap: _endCall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
    Color activeColor = Colors.white,
    Color iconColor = Colors.black,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.white24,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isActive ? iconColor : Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
