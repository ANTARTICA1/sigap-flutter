import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:vibration/vibration.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../models/security_event_model.dart';
import '../services/camera_evidence_service.dart';
import '../services/emergency_location_service.dart';
import '../services/security_storage_service.dart';
import '../utils/constants.dart';

enum SecurityState { disarmed, countdown, armed, alert }

class SecurityProvider extends ChangeNotifier {
  SecurityState _currentState = SecurityState.disarmed;
  int _countdownValue = AppConstants.countdownSeconds;
  
  SecurityStorageService? _storageService;
  String _currentPin = AppConstants.defaultSecurityPin;
  int _failedAttemptsCount = 0;
  
  SecurityEvent? _lastSecurityEvent;
  String _lastTriggerReason = '';
  double? _lastLatitude;
  double? _lastLongitude;
  String? _lastMapsUrl;
  bool _isLocationSharingInProgress = false;

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<BatteryState>? _batterySubscription;
  AccelerometerEvent? _initialEvent;
  final Battery _battery = Battery();
  BatteryState? _lastBatteryState;

  Timer? _countdownTimer;
  Timer? _volumeWatchdogTimer;
  Timer? _vibrationLoopTimer;

  SecurityProvider() {
    _initStorage();
  }

  SecurityState get currentState => _currentState;
  int get countdownValue => _countdownValue;
  String get currentPin => _currentPin;
  int get failedAttemptsCount => _failedAttemptsCount;
  SecurityEvent? get lastSecurityEvent => _lastSecurityEvent;
  String get lastTriggerReason => _lastTriggerReason;
  double? get lastLatitude => _lastLatitude;
  double? get lastLongitude => _lastLongitude;
  String? get lastMapsUrl => _lastMapsUrl;
  bool get isLocationSharingInProgress => _isLocationSharingInProgress;
  SecurityStorageService? get storageService => _storageService;

  Future<void> _initStorage() async {
    _storageService = await SecurityStorageService.init();
    _currentPin = _storageService!.getPin();
    notifyListeners();
  }

  Future<bool> changePin({
    required String currentPin,
    required String newPin,
  }) async {
    if (currentPin.trim() != _currentPin) {
      return false;
    }
    _currentPin = newPin.trim();
    if (_storageService != null) {
      await _storageService!.setPin(_currentPin);
    }
    notifyListeners();
    return true;
  }

  void startSecurity() {
    if (_currentState != SecurityState.disarmed) return;

    _currentState = SecurityState.countdown;
    _countdownValue = AppConstants.countdownSeconds;
    _failedAttemptsCount = 0;
    notifyListeners();

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_currentState != SecurityState.countdown) {
        timer.cancel();
        return;
      }

      if (_countdownValue > 1) {
        _countdownValue--;
        notifyListeners();
      } else {
        timer.cancel();
        _armSystem();
      }
    });
  }

  void _armSystem() {
    _currentState = SecurityState.armed;
    _initialEvent = null;
    WakelockPlus.enable();
    notifyListeners();

    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = accelerometerEventStream().listen((AccelerometerEvent event) {
      if (_currentState != SecurityState.armed) return;

      if (_initialEvent == null) {
        _initialEvent = event;
        return;
      }

      double diffX = (event.x - _initialEvent!.x).abs();
      double diffY = (event.y - _initialEvent!.y).abs();
      double diffZ = (event.z - _initialEvent!.z).abs();

      if (diffX > AppConstants.motionThreshold || 
          diffY > AppConstants.motionThreshold || 
          diffZ > AppConstants.motionThreshold) {
        _triggerAlert(reason: 'Gerakan Mencurigakan Terdeteksi');
      }
    });

    _battery.batteryState.then((state) {
      _lastBatteryState = state;
    });

    _batterySubscription?.cancel();
    _batterySubscription = _battery.onBatteryStateChanged.listen((BatteryState state) {
      if (_currentState != SecurityState.armed) return;
      
      if ((_lastBatteryState == BatteryState.charging || _lastBatteryState == BatteryState.full) && 
          (state != BatteryState.charging && state != BatteryState.full)) {
        _triggerAlert(reason: 'Kabel Charger Dicabut Paksa');
      }
      _lastBatteryState = state;
    });
  }

  void _triggerAlert({String reason = 'Alarm Keamanan Terpicu'}) {
    if (_currentState == SecurityState.alert) return;
    
    _currentState = SecurityState.alert;
    _lastTriggerReason = reason;
    notifyListeners();

    WakelockPlus.enable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _startVolumeLock();
    _startVibration();

    _processEvidenceAndEmergency(reason);
  }

  Future<void> _processEvidenceAndEmergency(String reason) async {
    _isLocationSharingInProgress = true;
    notifyListeners();

    double? lat;
    double? lng;
    String? mapsUrl;
    String? photoPath;

    try {
      final position = await EmergencyLocationService.getCurrentLocation();
      if (position != null) {
        lat = position.latitude;
        lng = position.longitude;
        mapsUrl = EmergencyLocationService.buildMapsUrl(lat, lng);
        _lastLatitude = lat;
        _lastLongitude = lng;
        _lastMapsUrl = mapsUrl;
      }
    } catch (_) {}

    if (_storageService != null && _storageService!.isIntruderPhotoEnabled()) {
      try {
        photoPath = await CameraEvidenceService.captureIntruderPhoto();
      } catch (_) {}
    }

    final event = SecurityEvent(
      id: 'SEC_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      triggerType: reason,
      latitude: lat,
      longitude: lng,
      mapsUrl: mapsUrl,
      photoPath: photoPath,
      failedAttempts: _failedAttemptsCount,
    );

    _lastSecurityEvent = event;
    if (_storageService != null) {
      await _storageService!.addSecurityEvent(event);
    }

    _isLocationSharingInProgress = false;
    notifyListeners();
  }

  void _startVolumeLock() {
    try {
      VolumeController.instance.showSystemUI = false;
      VolumeController.instance.setVolume(1.0);

      VolumeController.instance.addListener((volume) {
        if (_currentState == SecurityState.alert && volume < 0.98) {
          VolumeController.instance.setVolume(1.0);
        }
      });
    } catch (_) {}

    FlutterRingtonePlayer().playAlarm(
      looping: true,
      volume: 1.0,
    );

    _volumeWatchdogTimer?.cancel();
    _volumeWatchdogTimer = Timer.periodic(const Duration(milliseconds: 800), (_) {
      if (_currentState != SecurityState.alert) {
        _stopVolumeLock();
        return;
      }
      try {
        VolumeController.instance.setVolume(1.0);
      } catch (_) {}
    });
  }

  void _stopVolumeLock() {
    _volumeWatchdogTimer?.cancel();
    _volumeWatchdogTimer = null;
    try {
      VolumeController.instance.removeListener();
      VolumeController.instance.showSystemUI = true;
    } catch (_) {}
  }

  void _startVibration() async {
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(
        pattern: [500, 1000, 500, 1000, 500, 1000], 
        intensities: [128, 255, 128, 255, 128, 255],
      );
      
      _vibrationLoopTimer?.cancel();
      _vibrationLoopTimer = Timer.periodic(const Duration(milliseconds: 4500), (timer) {
        if (_currentState != SecurityState.alert) {
          timer.cancel();
          Vibration.cancel();
        } else {
          Vibration.vibrate(
            pattern: [500, 1000, 500, 1000, 500, 1000], 
            intensities: [128, 255, 128, 255, 128, 255],
          );
        }
      });
    }
  }

  bool verifyAndDisarm(String password) {
    if (password.trim() == _currentPin) {
      _failedAttemptsCount = 0;
      _disarmSystem();
      return true;
    }

    _failedAttemptsCount++;
    notifyListeners();

    if (_failedAttemptsCount >= AppConstants.maxFailedAttemptsBeforeAlert) {
      if (_currentState != SecurityState.alert) {
        _triggerAlert(reason: 'Upaya Pembobolan PIN ($_failedAttemptsCount kali salah)');
      } else {
        _processEvidenceAndEmergency('Percobaan PIN Salah Berulang ($_failedAttemptsCount)');
      }
    }

    return false;
  }

  void forceDisarm() {
    if (_currentState == SecurityState.countdown) {
      _countdownTimer?.cancel();
      _disarmSystem();
    }
  }

  void _disarmSystem() {
    _currentState = SecurityState.disarmed;
    
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;

    _batterySubscription?.cancel();
    _batterySubscription = null;

    FlutterRingtonePlayer().stop();
    Vibration.cancel();
    _vibrationLoopTimer?.cancel();
    _vibrationLoopTimer = null;

    _stopVolumeLock();

    WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    notifyListeners();
  }

  Future<bool> sendEmergencyAlertNow() async {
    if (_storageService == null) return false;
    final contactNumber = _storageService!.getEmergencyContactNumber();
    if (contactNumber.isEmpty) return false;

    return await EmergencyLocationService.sendEmergencyAlert(
      contactNumber: contactNumber,
      triggerReason: _lastTriggerReason.isNotEmpty 
          ? _lastTriggerReason 
          : 'Alarm Keamanan Terpicu',
      latitude: _lastLatitude,
      longitude: _lastLongitude,
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _disarmSystem();
    super.dispose();
  }
}
