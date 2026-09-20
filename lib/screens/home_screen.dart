import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/security_provider.dart';
import '../utils/constants.dart';
import 'alarm_lock_screen.dart';
import 'evidence_screen.dart';
import 'password_dialog.dart';
import 'settings_screen.dart';
import 'tutorial_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLockScreenShowing = false;
  bool _isPasswordDialogShowing = false;

  void _showAlarmLockScreen(BuildContext context) {
    if (_isLockScreenShowing) return;
    _isLockScreenShowing = true;
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const AlarmLockScreen(),
      ),
    ).then((_) {
      _isLockScreenShowing = false;
    });
  }

  void _showPasswordDialog(BuildContext context) {
    if (_isPasswordDialogShowing) return;
    _isPasswordDialogShowing = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const PasswordDialog(),
    ).then((_) {
      _isPasswordDialogShowing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: Consumer<SecurityProvider>(
        builder: (context, provider, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (provider.currentState == SecurityState.alert && !_isLockScreenShowing) {
              _showAlarmLockScreen(context);
            }
          });

          return SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 14.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildHeader(provider),

                            const SizedBox(height: 12),
                            const Spacer(),

                            _buildStatusCircle(provider),

                            const Spacer(),
                            const SizedBox(height: 12),

                            _buildFeatureBadges(provider),

                            const SizedBox(height: 14),

                            _buildDashboard(provider),

                            const SizedBox(height: 20),

                            _buildMainButton(provider),

                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(SecurityProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppConstants.cardColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppConstants.textColor.withAlpha(20),
              ),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: AppConstants.accentColor,
              size: 20,
            ),
          ),
          tooltip: 'Pengaturan Keamanan & PIN',
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
        ),

        Column(
          children: [
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.security_rounded,
                  color: AppConstants.accentColor,
                  size: 22,
                ),
                SizedBox(width: 8),
                Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.5,
                    color: AppConstants.textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              AppConstants.appSubTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppConstants.textMutedColor,
              ),
            ),
          ],
        ),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConstants.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppConstants.textColor.withAlpha(20),
                  ),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: AppConstants.textColor,
                  size: 20,
                ),
              ),
              tooltip: 'Riwayat Bukti Kejadian',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EvidenceScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.help_outline_rounded,
                color: AppConstants.textMutedColor,
                size: 24,
              ),
              tooltip: 'Panduan Penggunaan',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TutorialScreen()),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureBadges(SecurityProvider provider) {
    final storage = provider.storageService;
    final isLocationOn = storage?.isEmergencyLocationEnabled() ?? true;
    final hasEmergencyContact = storage?.getEmergencyContactNumber().isNotEmpty ?? false;
    final isPhotoOn = storage?.isIntruderPhotoEnabled() ?? false;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppConstants.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: hasEmergencyContact
                    ? AppConstants.successColor.withAlpha(60)
                    : AppConstants.textColor.withAlpha(20),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 13,
                  color: (isLocationOn && hasEmergencyContact)
                      ? AppConstants.successColor
                      : AppConstants.textMutedColor,
                ),
                const SizedBox(width: 4),
                Text(
                  hasEmergencyContact ? 'Lokasi Siap' : 'Kontak Belum Diisi',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: hasEmergencyContact
                        ? AppConstants.textColor
                        : AppConstants.textMutedColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),

        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppConstants.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isPhotoOn
                    ? AppConstants.accentColor.withAlpha(60)
                    : AppConstants.textColor.withAlpha(20),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.camera_alt_rounded,
                  size: 13,
                  color: isPhotoOn
                      ? AppConstants.accentColor
                      : AppConstants.textMutedColor,
                ),
                const SizedBox(width: 4),
                Text(
                  isPhotoOn ? 'Foto Aktif' : 'Foto Nonaktif',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: isPhotoOn
                        ? AppConstants.accentColor
                        : AppConstants.textMutedColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCircle(SecurityProvider provider) {
    Color statusColor;
    IconData statusIcon;
    String statusTitle;
    String statusDesc;

    switch (provider.currentState) {
      case SecurityState.disarmed:
        statusColor = AppConstants.textMutedColor;
        statusIcon = Icons.lock_open_rounded;
        statusTitle = 'SIAGA';
        statusDesc = 'Sistem tidak aktif. Tekan tombol di bawah untuk mengaktifkan proteksi.';
        break;
      case SecurityState.countdown:
        statusColor = AppConstants.warningColor;
        statusIcon = Icons.hourglass_empty_rounded;
        statusTitle = 'COUNTDOWN';
        statusDesc = 'Mempersiapkan sensor keamanan. Mohon segera letakkan HP Anda.';
        break;
      case SecurityState.armed:
        statusColor = AppConstants.successColor;
        statusIcon = Icons.gpp_good_rounded;
        statusTitle = 'TERKUNCI & AKTIF';
        statusDesc = 'Sensor gerak & deteksi charger aktif. Jangan gerakkan perangkat.';
        break;
      case SecurityState.alert:
        statusColor = AppConstants.primaryColor;
        statusIcon = Icons.gpp_bad_rounded;
        statusTitle = 'ALARM TERPICU!';
        statusDesc = 'Alarm berbunyi maksimal! Sistem mengunci seluruh navigasi.';
        break;
    }

    return Column(
      children: [
        Container(
          width: 175,
          height: 175,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppConstants.cardColor,
            border: Border.all(color: statusColor.withAlpha(80), width: 2.5),
          ),
          child: Center(
            child: provider.currentState == SecurityState.countdown
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 125,
                        height: 125,
                        child: CircularProgressIndicator(
                          value:
                              provider.countdownValue /
                              AppConstants.countdownSeconds,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppConstants.warningColor,
                          ),
                          backgroundColor: AppConstants.textColor.withAlpha(10),
                          strokeWidth: 4,
                        ),
                      ),
                      Text(
                        '${provider.countdownValue}',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w800,
                          color: AppConstants.warningColor,
                        ),
                      ),
                    ],
                  )
                : Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusColor.withAlpha(10),
                    ),
                    child: Icon(statusIcon, size: 64, color: statusColor),
                  ),
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withAlpha(15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withAlpha(40), width: 1.0),
          ),
          child: Text(
            statusTitle,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: statusColor,
              letterSpacing: 2.0,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            statusDesc,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppConstants.textMutedColor,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDashboard(SecurityProvider provider) {
    final isArmed = provider.currentState == SecurityState.armed;
    final isAlert = provider.currentState == SecurityState.alert;
    final isActive = isArmed || isAlert;

    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            icon: Icons.sensors_rounded,
            title: 'Deteksi Gerak',
            subtitle: isActive ? 'MEMANTAU' : 'STANDBY',
            statusColor: isActive
                ? (isAlert
                      ? AppConstants.primaryColor
                      : AppConstants.successColor)
                : AppConstants.textMutedColor,
            isActive: isActive,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _buildInfoCard(
            icon: Icons.power_rounded,
            title: 'Deteksi Charger',
            subtitle: isActive ? 'TERKUNCI' : 'STANDBY',
            statusColor: isActive
                ? (isAlert
                      ? AppConstants.primaryColor
                      : AppConstants.successColor)
                : AppConstants.textMutedColor,
            isActive: isActive,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color statusColor,
    required bool isActive,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppConstants.textColor.withAlpha(15),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: statusColor, size: 18),
              ),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppConstants.textMutedColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: isActive
                  ? AppConstants.textColor
                  : AppConstants.textMutedColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainButton(SecurityProvider provider) {
    bool isDisarmed = provider.currentState == SecurityState.disarmed;
    bool isCountdown = provider.currentState == SecurityState.countdown;

    Color btnColor;
    String btnText;
    IconData btnIcon;

    if (isDisarmed) {
      btnColor = AppConstants.successColor;
      btnText = 'AKTIFKAN KEAMANAN';
      btnIcon = Icons.gpp_good_rounded;
    } else if (isCountdown) {
      btnColor = AppConstants.warningColor;
      btnText = 'BATALKAN SEKARANG';
      btnIcon = Icons.cancel_rounded;
    } else {
      btnColor = AppConstants.primaryColor;
      btnText = 'NONAKTIFKAN SISTEM';
      btnIcon = Icons.shield_rounded;
    }

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: btnColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      onPressed: () {
        if (isDisarmed) {
          provider.startSecurity();
        } else if (isCountdown) {
          provider.forceDisarm();
        } else if (provider.currentState == SecurityState.alert) {
          _showAlarmLockScreen(context);
        } else {
          _showPasswordDialog(context);
        }
      },
      icon: Icon(btnIcon, size: 22),
      label: Text(
        btnText,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
