import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'SIGAP';
  static const String appSubTitle = 'Sistem Gerak Aman dari Pencurian';
  static const String appVersion = '1.0.0';

  static const String defaultSecurityPin = '1234';
  static const double motionThreshold = 2.0;
  static const int countdownSeconds = 5;
  static const int maxFailedAttemptsBeforeAlert = 3;

  static const String keyVibrationEnabled = 'vibration_enabled';
  static const String keyChargerAlarmEnabled = 'charger_alarm_enabled';

  static const Color primaryColor = Color(0xFFFF334B);
  static const Color secondaryColor = Color(0xFF0D9488);
  static const Color accentColor = Color(0xFF38BDF8);
  static const Color backgroundColor = Color(0xFF0B0F19);
  static const Color cardColor = Color(0xFF1E293B);
  
  static const Color textColor = Color(0xFFF8FAFC);
  static const Color textMutedColor = Color(0xFF94A3B8);
  
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);

  static const List<Color> bgGradient = [
    Color(0xFF0B132B),
    Color(0xFF020617),
  ];

  static const List<Color> accentGradient = [
    Color(0xFF38BDF8),
    Color(0xFF0EA5E9),
  ];
}
