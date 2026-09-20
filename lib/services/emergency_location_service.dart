import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyLocationService {
  static Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return await Geolocator.getLastKnownPosition();
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          return null;
        }
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 6),
        ),
      );
    } catch (_) {
      try {
        return await Geolocator.getLastKnownPosition();
      } catch (_) {
        return null;
      }
    }
  }

  static String buildMapsUrl(double lat, double lng) {
    return 'https://maps.google.com/?q=$lat,$lng';
  }

  static String cleanPhoneNumber(String rawNumber) {
    String cleaned = rawNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.startsWith('0')) {
      cleaned = '62${cleaned.substring(1)}';
    } else if (cleaned.startsWith('+')) {
      cleaned = cleaned.substring(1);
    }
    return cleaned;
  }

  static Future<bool> sendEmergencyAlert({
    required String contactNumber,
    required String triggerReason,
    double? latitude,
    double? longitude,
    bool preferWhatsApp = true,
  }) async {
    if (contactNumber.trim().isEmpty) return false;

    final cleanNumber = cleanPhoneNumber(contactNumber);
    final timeStr = DateTime.now().toString().split('.')[0];
    
    String message = '🚨 [SIGAP DARURAT] Alarm keamanan HP telah terpicu!\n'
        'Waktu: $timeStr\n'
        'Penyebab: $triggerReason\n';

    if (latitude != null && longitude != null) {
      final mapsUrl = buildMapsUrl(latitude, longitude);
      message += 'Lokasi Terkini: $mapsUrl\n';
    } else {
      message += 'Lokasi GPS tidak dapat diakses saat kejadian.\n';
    }

    message += 'Pesan otomatis dikirim oleh Sistem Keamanan SIGAP.';

    if (preferWhatsApp) {
      final waUri = Uri.parse(
        'https://wa.me/$cleanNumber?text=${Uri.encodeComponent(message)}',
      );
      if (await canLaunchUrl(waUri)) {
        return await launchUrl(waUri, mode: LaunchMode.externalApplication);
      }
    }

    final smsUri = Uri(
      scheme: 'sms',
      path: cleanNumber,
      queryParameters: {'body': message},
    );

    if (await canLaunchUrl(smsUri)) {
      return await launchUrl(smsUri, mode: LaunchMode.externalApplication);
    }

    return false;
  }
}
