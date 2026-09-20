import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sensormobile/main.dart';
import 'package:sensormobile/models/security_event_model.dart';
import 'package:sensormobile/utils/constants.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SecurityEvent Model Tests', () {
    test('Should correctly serialize and deserialize SecurityEvent', () {
      final now = DateTime.now();
      final event = SecurityEvent(
        id: 'SEC_TEST_123',
        timestamp: now,
        triggerType: 'Gerakan Mencurigakan Terdeteksi',
        latitude: -6.2000,
        longitude: 106.8166,
        mapsUrl: 'https://maps.google.com/?q=-6.2,106.8166',
        photoPath: '/storage/intruder_test.jpg',
        failedAttempts: 2,
      );

      final jsonString = event.toJson();
      final fromJson = SecurityEvent.fromJson(jsonString);

      expect(fromJson.id, 'SEC_TEST_123');
      expect(fromJson.triggerType, 'Gerakan Mencurigakan Terdeteksi');
      expect(fromJson.latitude, -6.2000);
      expect(fromJson.longitude, 106.8166);
      expect(fromJson.photoPath, '/storage/intruder_test.jpg');
      expect(fromJson.failedAttempts, 2);
    });
  });

  group('AppConstants Tests', () {
    test('Default PIN should be configured and not empty', () {
      expect(AppConstants.defaultSecurityPin, isNotEmpty);
      expect(AppConstants.defaultSecurityPin, '1234');
    });
  });

  testWidgets('SIGAP HomeScreen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.text('AKTIFKAN KEAMANAN'), findsOneWidget);
  });
}
