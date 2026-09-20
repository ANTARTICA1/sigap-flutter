import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/security_provider.dart';
import '../utils/constants.dart';

class AlarmLockScreen extends StatefulWidget {
  const AlarmLockScreen({super.key});

  @override
  State<AlarmLockScreen> createState() => _AlarmLockScreenState();
}

class _AlarmLockScreenState extends State<AlarmLockScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _pinController = TextEditingController();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _onKeypadTap(String value, SecurityProvider provider) {
    if (_pinController.text.length < 8) {
      setState(() {
        _pinController.text += value;
        _errorMessage = '';
      });
    }
  }

  void _onBackspace() {
    if (_pinController.text.isNotEmpty) {
      setState(() {
        _pinController.text = _pinController.text.substring(
          0,
          _pinController.text.length - 1,
        );
      });
    }
  }

  void _submitPin(SecurityProvider provider) {
    final pin = _pinController.text;
    if (pin.isEmpty) {
      setState(() {
        _errorMessage = 'Masukkan PIN keamanan Anda!';
      });
      return;
    }

    final success = provider.verifyAndDisarm(pin);
    if (!success) {
      setState(() {
        _errorMessage = 'PIN Salah! (${provider.failedAttemptsCount}x percobaan gagal)';
        _pinController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SecurityProvider>(
      builder: (context, provider, child) {
        if (provider.currentState != SecurityState.alert) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && ModalRoute.of(context)?.isCurrent == true) {
              Navigator.of(context).pop();
            }
          });
        }

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {},
          child: Scaffold(
            backgroundColor: const Color(0xFF0D0204),
            body: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 16.0,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppConstants.primaryColor.withAlpha(35),
                            border: Border.all(
                              color: AppConstants.primaryColor,
                              width: 3.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppConstants.primaryColor.withAlpha(90),
                                blurRadius: 35,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.gpp_bad_rounded,
                            size: 64,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'PERANGKAT TERKUNCI!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.0,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        provider.lastTriggerReason.isNotEmpty
                            ? provider.lastTriggerReason
                            : 'Gerakan terdeteksi atau pengisi daya dicabut paksa!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppConstants.textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildEmergencyBadges(provider),
                      const SizedBox(height: 20),
                      _buildPinDisplay(),
                      if (_errorMessage.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppConstants.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      _buildNumericKeypad(provider),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppConstants.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 8,
                            shadowColor: AppConstants.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () => _submitPin(provider),
                          icon: const Icon(Icons.lock_open_rounded, size: 22),
                          label: const Text(
                            'BUKA KUNCI ALARM',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmergencyBadges(SecurityProvider provider) {
    final hasLocation = provider.lastLatitude != null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppConstants.primaryColor.withAlpha(60),
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                hasLocation ? Icons.location_on_rounded : Icons.location_searching_rounded,
                color: hasLocation ? AppConstants.accentColor : AppConstants.warningColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hasLocation
                      ? 'Lokasi Darurat: ${provider.lastLatitude!.toStringAsFixed(4)}, ${provider.lastLongitude!.toStringAsFixed(4)}'
                      : 'Mencari koordinat lokasi GPS darurat...',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppConstants.textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.volume_up_rounded,
                color: AppConstants.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Volume terkunci 100% (Anti-Silenced)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.textMutedColor,
                  ),
                ),
              ),
              if (provider.storageService?.getEmergencyContactNumber().isNotEmpty == true)
                InkWell(
                  onTap: () {
                    provider.sendEmergencyAlertNow();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Membuka pengiriman lokasi darurat...'),
                        backgroundColor: AppConstants.cardColor,
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppConstants.accentColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppConstants.accentColor, width: 1),
                    ),
                    child: const Text(
                      'Kirim WA/SMS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.accentColor,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPinDisplay() {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppConstants.textColor.withAlpha(30),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          _pinController.text.isEmpty
              ? 'Ketik PIN Anda'
              : '● ' * _pinController.text.length,
          style: TextStyle(
            fontSize: _pinController.text.isEmpty ? 15 : 22,
            fontWeight: FontWeight.bold,
            letterSpacing: _pinController.text.isEmpty ? 0 : 4,
            color: _pinController.text.isEmpty
                ? AppConstants.textMutedColor
                : AppConstants.textColor,
          ),
        ),
      ),
    );
  }

  Widget _buildNumericKeypad(SecurityProvider provider) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['1', '2', '3']
              .map((d) => _buildKeypadButton(d, provider))
              .toList(),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['4', '5', '6']
              .map((d) => _buildKeypadButton(d, provider))
              .toList(),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: ['7', '8', '9']
              .map((d) => _buildKeypadButton(d, provider))
              .toList(),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSpecialKeypadButton(
              icon: Icons.clear_rounded,
              onTap: () {
                setState(() {
                  _pinController.clear();
                  _errorMessage = '';
                });
              },
            ),
            _buildKeypadButton('0', provider),
            _buildSpecialKeypadButton(
              icon: Icons.backspace_outlined,
              onTap: _onBackspace,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKeypadButton(String digit, SecurityProvider provider) {
    return SizedBox(
      width: 78,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.cardColor,
          foregroundColor: AppConstants.textColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: AppConstants.textColor.withAlpha(20),
              width: 1,
            ),
          ),
          padding: EdgeInsets.zero,
        ),
        onPressed: () => _onKeypadTap(digit, provider),
        child: Text(
          digit,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialKeypadButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 78,
      height: 60,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppConstants.textColor.withAlpha(10),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Icon(icon, color: AppConstants.textColor, size: 24),
          ),
        ),
      ),
    );
  }
}
