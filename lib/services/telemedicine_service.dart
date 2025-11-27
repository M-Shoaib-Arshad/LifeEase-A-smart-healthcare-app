import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import '../config/env_config.dart';

/// Service for managing telemedicine video calls using Agora RTC
/// Handles video call initialization, connection, and management
class TelemedicineService {
  RtcEngine? _engine;
  bool _isInitialized = false;
  bool _isInCall = false;
  
  // Agora configuration - loaded from environment variables
  static String get appId => EnvConfig.agoraAppId;
  
  // Call state
  int? _remoteUid;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  
  // Getters
  bool get isInitialized => _isInitialized;
  bool get isInCall => _isInCall;
  bool get isMuted => _isMuted;
  bool get isVideoEnabled => _isVideoEnabled;
  int? get remoteUid => _remoteUid;
  
  /// Initialize Agora RTC Engine
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Request necessary permissions
      await _requestPermissions();
      
      // Create RTC engine
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));
      
      // Set up event handlers
      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            debugPrint('Successfully joined channel: ${connection.channelId}');
            _isInCall = true;
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            debugPrint('Remote user joined: $remoteUid');
            _remoteUid = remoteUid;
          },
          onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
            debugPrint('Remote user offline: $remoteUid');
            _remoteUid = null;
          },
          onLeaveChannel: (RtcConnection connection, RtcStats stats) {
            debugPrint('Left channel');
            _isInCall = false;
            _remoteUid = null;
          },
          onError: (ErrorCodeType error, String msg) {
            debugPrint('Agora error: $error - $msg');
          },
        ),
      );
      
      // Enable video
      await _engine!.enableVideo();
      await _engine!.startPreview();
      
      _isInitialized = true;
      debugPrint('Agora RTC Engine initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize Agora RTC Engine: $e');
      rethrow;
    }
  }
  
  /// Request necessary permissions for video calls
  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.microphone,
    ].request();
  }
  
  /// Join a video call channel
  Future<void> joinCall({
    required String channelName,
    required String token,
    required int uid,
  }) async {
    if (!_isInitialized) {
      throw Exception('Agora RTC Engine not initialized');
    }
    
    try {
      await _engine!.joinChannel(
        token: token,
        channelId: channelName,
        uid: uid,
        options: const ChannelMediaOptions(
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );
      
      debugPrint('Joining channel: $channelName with uid: $uid');
    } catch (e) {
      debugPrint('Failed to join channel: $e');
      rethrow;
    }
  }
  
  /// Leave the current call
  Future<void> leaveCall() async {
    if (!_isInitialized || !_isInCall) return;
    
    try {
      await _engine!.leaveChannel();
      _isInCall = false;
      _remoteUid = null;
      debugPrint('Left call successfully');
    } catch (e) {
      debugPrint('Failed to leave call: $e');
      rethrow;
    }
  }
  
  /// Toggle microphone mute/unmute
  Future<void> toggleMute() async {
    if (!_isInitialized) return;
    
    try {
      _isMuted = !_isMuted;
      await _engine!.muteLocalAudioStream(_isMuted);
      debugPrint('Microphone ${_isMuted ? "muted" : "unmuted"}');
    } catch (e) {
      debugPrint('Failed to toggle mute: $e');
      rethrow;
    }
  }
  
  /// Toggle video on/off
  Future<void> toggleVideo() async {
    if (!_isInitialized) return;
    
    try {
      _isVideoEnabled = !_isVideoEnabled;
      await _engine!.muteLocalVideoStream(!_isVideoEnabled);
      debugPrint('Video ${_isVideoEnabled ? "enabled" : "disabled"}');
    } catch (e) {
      debugPrint('Failed to toggle video: $e');
      rethrow;
    }
  }
  
  /// Switch camera (front/back)
  Future<void> switchCamera() async {
    if (!_isInitialized) return;
    
    try {
      await _engine!.switchCamera();
      debugPrint('Camera switched');
    } catch (e) {
      debugPrint('Failed to switch camera: $e');
      rethrow;
    }
  }
  
  /// Set audio route to speaker
  Future<void> setSpeakerOn(bool enabled) async {
    if (!_isInitialized) return;
    
    try {
      await _engine!.setEnableSpeakerphone(enabled);
      debugPrint('Speaker ${enabled ? "on" : "off"}');
    } catch (e) {
      debugPrint('Failed to set speaker: $e');
      rethrow;
    }
  }
  
  /// Get the RTC engine instance for custom operations
  RtcEngine? get engine => _engine;
  
  /// Dispose and cleanup resources
  Future<void> dispose() async {
    if (_isInCall) {
      await leaveCall();
    }
    
    if (_isInitialized) {
      await _engine!.release();
      _isInitialized = false;
      _engine = null;
      debugPrint('Agora RTC Engine disposed');
    }
  }
  
  /// Generate a temporary token for testing
  /// Note: In production, tokens should be generated on the server
  static String generateTestToken() {
    // This is a placeholder. In production, implement proper token generation
    // on your backend server using Agora's token generation library
    return '';
  }
  
  /// Create a unique channel name for a consultation
  static String createChannelName(String appointmentId) {
    return 'consultation_$appointmentId';
  }
}
