# SIGAP - Motion-Activated Anti-Theft & Mobile Hardware Security

SIGAP is an advanced mobile device security application built with Flutter, engineered to safeguard smartphones against unauthorized physical relocation, pickpocketing, and charger unplugging through real-time hardware sensor integration.

## Application Interface Previews

| Armed Monitoring Dashboard | Immersive Emergency Lockscreen | Forensic Evidence Logs |
|:---:|:---:|:---:|
| ![Armed Monitoring Dashboard](docs/screenshots/sigap_dashboard.png) | ![Immersive Emergency Lockscreen](docs/screenshots/sigap_lockscreen.png) | ![Forensic Evidence Logs](docs/screenshots/sigap_intruder_logs.png) |

## Core Capabilities

- Tri-Axis Accelerometer Motion Detection: Continuously streams hardware accelerometer vectors (XYZ). Any unauthorized shifting, lifting, or tampering triggers immediate alarm protocols.
- Charger Power Interruption Trigger: Detects sudden disconnects from charging sources, securing devices left on public charging stations.
- Arming Countdown Timer: Provides a 5-second arming delay, allowing the owner to position the handset steadily on flat surfaces before sensors become active.
- Anti-Bypass 100% Volume Watchdog: Loops high-decibel emergency siren audio while programmatically forcing the system volume to 100% to prevent silencing.
- Immersive PIN Emergency Lock: Overlays an immersive full-screen barrier that blocks system gesture navigation, back buttons, and recent apps until a valid numeric PIN is authenticated.
- Automated Intruder Camera Capture: Discretely snaps front-camera photographs of whoever triggers the alarm or repeatedly enters invalid unlock PINs.
- Real-Time GPS Geolocation Logging: Captures precise latitude and longitude coordinates during an incident and links them with map navigation.
- Local Forensic Incident Log: Retains a tamper-resistant local archive documenting timestamped breach events, trigger classifications, geographic coordinates, and intruder portraits.
- Emergency Contact Dispatch: Quick action links to broadcast distress alerts with location data via WhatsApp or SMS to preconfigured emergency contacts.

## System Requirements

- Flutter SDK: Version 3.11.5 or higher
- Dart SDK: Version 3.11.5 or higher
- Target Platform: Android 5.0 (API Level 21) or higher
- Hardware Permissions: Front Camera, Fine Location (GPS), Vibration, and Hardware Motion Sensors

## Installation and Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/ANTARTICA1/sigap-flutter.git
   cd sigap-flutter
   ```

2. Install Flutter package dependencies:
   ```bash
   flutter pub get
   ```

3. Verify connected Android devices or emulators:
   ```bash
   flutter devices
   ```

4. Launch the application in debug mode:
   ```bash
   flutter run
   ```

5. Build the optimized production release APK:
   ```bash
   flutter build apk --release
   ```

## Directory Structure

```
sigap-flutter/
├── lib/
│   ├── main.dart             # Application entry point and root providers initialization
│   ├── models/               # Domain models (SecurityEvent, IncidentRecord)
│   ├── providers/            # State management for accelerometer streams and battery status
│   ├── screens/              # UI screens (Dashboard, EmergencyLock, Logs, Settings)
│   ├── services/             # Platform services (Camera API, Geolocator, Audio, Storage)
│   └── utils/                # Theme definitions, constants, and audio assets
├── docs/
│   └── screenshots/          # High-resolution interface preview assets
├── pubspec.yaml              # Package dependencies and asset manifests
└── README.md                 # Technical documentation
```

## Author

Anak Agung Ngurah Krisna Artha Wibawa ([ANTARTICA1](https://github.com/ANTARTICA1))

## License

This project is open-source and licensed under the MIT License.