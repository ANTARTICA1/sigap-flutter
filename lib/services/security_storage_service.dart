import 'package:shared_preferences/shared_preferences.dart';
import '../models/security_event_model.dart';
import '../utils/constants.dart';

class SecurityStorageService {
  static const String _keyPin = 'sigap_security_pin';
  static const String _keyEmergencyLocationEnabled = 'sigap_emergency_location_enabled';
  static const String _keyEmergencyContactNumber = 'sigap_emergency_contact_number';
  static const String _keyEmergencyContactName = 'sigap_emergency_contact_name';
  static const String _keyIntruderPhotoEnabled = 'sigap_intruder_photo_enabled';
  static const String _keySecurityEvents = 'sigap_security_events_list';

  final SharedPreferences _prefs;

  SecurityStorageService(this._prefs);

  static Future<SecurityStorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return SecurityStorageService(prefs);
  }

  String getPin() {
    return _prefs.getString(_keyPin) ?? AppConstants.defaultSecurityPin;
  }

  Future<bool> setPin(String newPin) async {
    return await _prefs.setString(_keyPin, newPin.trim());
  }

  bool isEmergencyLocationEnabled() {
    return _prefs.getBool(_keyEmergencyLocationEnabled) ?? true;
  }

  Future<bool> setEmergencyLocationEnabled(bool enabled) async {
    return await _prefs.setBool(_keyEmergencyLocationEnabled, enabled);
  }

  String getEmergencyContactNumber() {
    return _prefs.getString(_keyEmergencyContactNumber) ?? '';
  }

  Future<bool> setEmergencyContactNumber(String number) async {
    return await _prefs.setString(_keyEmergencyContactNumber, number.trim());
  }

  String getEmergencyContactName() {
    return _prefs.getString(_keyEmergencyContactName) ?? '';
  }

  Future<bool> setEmergencyContactName(String name) async {
    return await _prefs.setString(_keyEmergencyContactName, name.trim());
  }

  bool isIntruderPhotoEnabled() {
    return _prefs.getBool(_keyIntruderPhotoEnabled) ?? false;
  }

  Future<bool> setIntruderPhotoEnabled(bool enabled) async {
    return await _prefs.setBool(_keyIntruderPhotoEnabled, enabled);
  }

  List<SecurityEvent> getSecurityEvents() {
    final rawList = _prefs.getStringList(_keySecurityEvents) ?? [];
    List<SecurityEvent> events = [];
    for (final item in rawList) {
      try {
        events.add(SecurityEvent.fromJson(item));
      } catch (_) {}
    }
    events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return events;
  }

  Future<void> addSecurityEvent(SecurityEvent event) async {
    final events = getSecurityEvents();
    events.insert(0, event);

    final trimmed = events.take(50).toList();
    final stringList = trimmed.map((e) => e.toJson()).toList();
    await _prefs.setStringList(_keySecurityEvents, stringList);
  }

  Future<void> deleteSecurityEvent(String id) async {
    final events = getSecurityEvents();
    events.removeWhere((e) => e.id == id);
    final stringList = events.map((e) => e.toJson()).toList();
    await _prefs.setStringList(_keySecurityEvents, stringList);
  }

  Future<void> clearSecurityEvents() async {
    await _prefs.remove(_keySecurityEvents);
  }
}
