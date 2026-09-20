import 'dart:convert';

class SecurityEvent {
  final String id;
  final DateTime timestamp;
  final String triggerType;
  final double? latitude;
  final double? longitude;
  final String? mapsUrl;
  final String? photoPath;
  final int failedAttempts;

  const SecurityEvent({
    required this.id,
    required this.timestamp,
    required this.triggerType,
    this.latitude,
    this.longitude,
    this.mapsUrl,
    this.photoPath,
    this.failedAttempts = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'triggerType': triggerType,
      'latitude': latitude,
      'longitude': longitude,
      'mapsUrl': mapsUrl,
      'photoPath': photoPath,
      'failedAttempts': failedAttempts,
    };
  }

  factory SecurityEvent.fromMap(Map<String, dynamic> map) {
    return SecurityEvent(
      id: map['id'] ?? '',
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      triggerType: map['triggerType'] ?? 'Peringatan Keamanan',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      mapsUrl: map['mapsUrl'],
      photoPath: map['photoPath'],
      failedAttempts: (map['failedAttempts'] as num?)?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory SecurityEvent.fromJson(String source) =>
      SecurityEvent.fromMap(json.decode(source));
}
