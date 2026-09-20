import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../providers/security_provider.dart';
import '../utils/constants.dart';
import 'evidence_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _currentPinController = TextEditingController();
  final TextEditingController _newPinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();

  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _contactNameController = TextEditingController();

  bool _isEmergencyLocationEnabled = true;
  bool _isIntruderPhotoEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _currentPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    _contactNumberController.dispose();
    _contactNameController.dispose();
    super.dispose();
  }

  void _loadSettings() {
    final provider = Provider.of<SecurityProvider>(context, listen: false);
    final storage = provider.storageService;
    if (storage != null) {
      setState(() {
        _isEmergencyLocationEnabled = storage.isEmergencyLocationEnabled();
        _isIntruderPhotoEnabled = storage.isIntruderPhotoEnabled();
        _contactNumberController.text = storage.getEmergencyContactNumber();
        _contactNameController.text = storage.getEmergencyContactName();
      });
    }
  }

  Future<void> _handleIntruderPhotoToggle(bool value) async {
    final provider = Provider.of<SecurityProvider>(context, listen: false);
    final storage = provider.storageService;
    if (storage == null) return;

    if (value) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppConstants.cardColor,
          title: const Row(
            children: [
              Icon(Icons.camera_alt_rounded, color: AppConstants.accentColor),
              SizedBox(width: 10),
              Text(
                'Izin Kamera Penyusup',
                style: TextStyle(color: AppConstants.textColor, fontSize: 18),
              ),
            ],
          ),
          content: const Text(
            'Untuk merekam foto wajah penyusup saat alarm berbunyi atau PIN salah 3x, aplikasi memerlukan izin kamera depan.\n\nFoto hanya disimpan secara lokal di memori HP Anda untuk bukti keamanan.',
            style: TextStyle(color: AppConstants.textMutedColor, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('BATAL', style: TextStyle(color: AppConstants.textMutedColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.accentColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('IZINKAN'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      final status = await Permission.camera.request();
      if (status.isGranted) {
        await storage.setIntruderPhotoEnabled(true);
        setState(() => _isIntruderPhotoEnabled = true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto bukti penyusup berhasil diaktifkan!'),
              backgroundColor: AppConstants.successColor,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Izin kamera ditolak. Fitur tidak dapat diaktifkan.'),
              backgroundColor: AppConstants.primaryColor,
            ),
          );
        }
      }
    } else {
      await storage.setIntruderPhotoEnabled(false);
      setState(() => _isIntruderPhotoEnabled = false);
    }
  }

  Future<void> _handleEmergencyLocationToggle(bool val) async {
    if (val) {
      final status = await Permission.location.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Izin lokasi ditolak. Aktifkan izin lokasi di pengaturan HP.'),
              backgroundColor: AppConstants.primaryColor,
            ),
          );
        }
        return;
      }
    }
    setState(() => _isEmergencyLocationEnabled = val);
  }

  Future<void> _saveEmergencySettings() async {
    final provider = Provider.of<SecurityProvider>(context, listen: false);
    final storage = provider.storageService;
    if (storage == null) return;

    setState(() => _isLoading = true);
    await storage.setEmergencyLocationEnabled(_isEmergencyLocationEnabled);
    await storage.setEmergencyContactNumber(_contactNumberController.text);
    await storage.setEmergencyContactName(_contactNameController.text);
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengaturan kontak darurat berhasil disimpan!'),
          backgroundColor: AppConstants.successColor,
        ),
      );
    }
  }

  Future<void> _changePin() async {
    final currentPin = _currentPinController.text.trim();
    final newPin = _newPinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    if (currentPin.isEmpty || newPin.isEmpty || confirmPin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua kolom PIN wajib diisi!'),
          backgroundColor: AppConstants.primaryColor,
        ),
      );
      return;
    }

    if (newPin != confirmPin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN baru dan konfirmasi tidak cocok!'),
          backgroundColor: AppConstants.primaryColor,
        ),
      );
      return;
    }

    if (newPin.length < 4 || newPin.length > 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PIN harus berupa 4 sampai 8 digit angka!'),
          backgroundColor: AppConstants.primaryColor,
        ),
      );
      return;
    }

    final provider = Provider.of<SecurityProvider>(context, listen: false);
    final success = await provider.changePin(
      currentPin: currentPin,
      newPin: newPin,
    );

    if (success) {
      _currentPinController.clear();
      _newPinController.clear();
      _confirmPinController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN keamanan berhasil diperbarui!'),
            backgroundColor: AppConstants.successColor,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PIN saat ini salah!'),
            backgroundColor: AppConstants.primaryColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Pengaturan Keamanan'),
        backgroundColor: AppConstants.backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: AppConstants.accentColor),
            tooltip: 'Riwayat Bukti Penyusup',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EvidenceScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                icon: Icons.pin_rounded,
                title: 'PIN Keamanan Aplikasi',
                subtitle: 'Ganti PIN untuk mematikan alarm (bukan hardcoded)',
              ),
              const SizedBox(height: 12),
              _buildChangePinCard(),

              const SizedBox(height: 28),

              _buildSectionHeader(
                icon: Icons.emergency_share_rounded,
                title: 'Berbagi Lokasi Darurat',
                subtitle: 'Kirim koordinat GPS otomatis saat alarm terpicu',
              ),
              const SizedBox(height: 12),
              _buildEmergencyLocationCard(),

              const SizedBox(height: 28),

              _buildSectionHeader(
                icon: Icons.remove_red_eye_rounded,
                title: 'Bukti Penyusup (Intruder Evidence)',
                subtitle: 'Simpan log insiden & foto kamera depan saat pembobolan',
              ),
              const SizedBox(height: 12),
              _buildIntruderEvidenceCard(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppConstants.accentColor.withAlpha(20),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppConstants.accentColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppConstants.textMutedColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChangePinCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppConstants.textColor.withAlpha(15),
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          TextField(
            controller: _currentPinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(8),
            ],
            style: const TextStyle(color: AppConstants.textColor),
            decoration: const InputDecoration(
              labelText: 'PIN Saat Ini',
              hintText: 'Default awal: 1234',
              prefixIcon: Icon(Icons.lock_outline_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _newPinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(8),
            ],
            style: const TextStyle(color: AppConstants.textColor),
            decoration: const InputDecoration(
              labelText: 'PIN Baru',
              hintText: 'Masukkan 4 sampai 8 digit angka',
              prefixIcon: Icon(Icons.password_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _confirmPinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(8),
            ],
            style: const TextStyle(color: AppConstants.textColor),
            decoration: const InputDecoration(
              labelText: 'Konfirmasi PIN Baru',
              prefixIcon: Icon(Icons.check_circle_outline_rounded),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _changePin,
              icon: const Icon(Icons.save_rounded, size: 18),
              label: const Text(
                'SIMPAN PIN BARU',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyLocationCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppConstants.textColor.withAlpha(15),
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Aktifkan Lokasi Darurat',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppConstants.textColor,
                fontSize: 14,
              ),
            ),
            subtitle: const Text(
              'Ambil koordinat GPS saat alarm berbunyi',
              style: TextStyle(color: AppConstants.textMutedColor, fontSize: 12),
            ),
            value: _isEmergencyLocationEnabled,
            activeThumbColor: AppConstants.accentColor,
            activeTrackColor: AppConstants.accentColor.withAlpha(128),
            onChanged: _handleEmergencyLocationToggle,
          ),
          const Divider(color: Colors.white10),
          const SizedBox(height: 8),
          TextField(
            controller: _contactNameController,
            style: const TextStyle(color: AppConstants.textColor),
            decoration: const InputDecoration(
              labelText: 'Nama Kontak Darurat',
              hintText: 'Misal: Ayah / Sahabat',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _contactNumberController,
            keyboardType: TextInputType.phone,
            style: const TextStyle(color: AppConstants.textColor),
            decoration: const InputDecoration(
              labelText: 'Nomor WhatsApp / SMS',
              hintText: 'Misal: 081234567890',
              prefixIcon: Icon(Icons.phone_rounded),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.secondaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _isLoading ? null : _saveEmergencySettings,
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text(
                'SIMPAN KONTAK DARURAT',
                style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntruderEvidenceCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppConstants.textColor.withAlpha(15),
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Ambil Foto Wajah Penyusup',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppConstants.textColor,
                fontSize: 14,
              ),
            ),
            subtitle: const Text(
              'Jepret kamera depan saat alarm terpicu atau salah PIN 3x',
              style: TextStyle(color: AppConstants.textMutedColor, fontSize: 12),
            ),
            value: _isIntruderPhotoEnabled,
            activeThumbColor: AppConstants.accentColor,
            activeTrackColor: AppConstants.accentColor.withAlpha(128),
            onChanged: _handleIntruderPhotoToggle,
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppConstants.textColor.withAlpha(5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppConstants.textColor.withAlpha(10)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.privacy_tip_outlined,
                  size: 18,
                  color: AppConstants.accentColor,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Privasi terjaga: Foto hanya disimpan lokal di perangkat Anda dan dapat dilihat sewaktu-waktu di menu Riwayat Bukti.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppConstants.textMutedColor,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: AppConstants.accentColor.withAlpha(100)),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EvidenceScreen()),
              );
            },
            icon: const Icon(Icons.photo_library_rounded, size: 18, color: AppConstants.accentColor),
            label: const Text(
              'BUKA RIWAYAT BUKTI PENYUSUP',
              style: TextStyle(
                color: AppConstants.accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
