import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/security_event_model.dart';
import '../providers/security_provider.dart';
import '../utils/constants.dart';

class EvidenceScreen extends StatefulWidget {
  const EvidenceScreen({super.key});

  @override
  State<EvidenceScreen> createState() => _EvidenceScreenState();
}

class _EvidenceScreenState extends State<EvidenceScreen> {
  List<SecurityEvent> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() {
    final provider = Provider.of<SecurityProvider>(context, listen: false);
    final storage = provider.storageService;
    if (storage != null) {
      setState(() {
        _events = storage.getSecurityEvents();
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearAllEvents() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppConstants.cardColor,
        title: const Text(
          'Hapus Semua Bukti?',
          style: TextStyle(color: AppConstants.textColor),
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus seluruh riwayat log keamanan dan bukti foto penyusup?',
          style: TextStyle(color: AppConstants.textMutedColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('BATAL', style: TextStyle(color: AppConstants.textMutedColor)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('HAPUS SEMUA'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final provider = Provider.of<SecurityProvider>(context, listen: false);
      await provider.storageService?.clearSecurityEvents();
      if (mounted) {
        _loadEvents();
      }
    }
  }

  void _showImageDialog(String imagePath) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(imagePath),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  padding: const EdgeInsets.all(24),
                  color: AppConstants.cardColor,
                  child: const Text(
                    'Gambar tidak dapat dimuat atau telah dihapus.',
                    style: TextStyle(color: AppConstants.textMutedColor),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
  }

  void _openMaps(double lat, double lng) async {
    final uri = Uri.parse('https://maps.google.com/?q=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Bukti Penyusup & Log'),
        backgroundColor: AppConstants.backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_events.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: AppConstants.primaryColor),
              tooltip: 'Hapus Semua Riwayat',
              onPressed: _clearAllEvents,
            ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppConstants.accentColor))
            : _events.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(18),
                    itemCount: _events.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      return _buildEventCard(_events[index]);
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppConstants.successColor.withAlpha(20),
              ),
              child: const Icon(
                Icons.verified_user_rounded,
                size: 64,
                color: AppConstants.successColor,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Belum Ada Insiden',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppConstants.textColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Perangkat Anda aman. Tidak ada riwayat alarm mencurigakan atau pembobolan PIN.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: AppConstants.textMutedColor,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard(SecurityEvent event) {
    final hasPhoto = event.photoPath != null && File(event.photoPath!).existsSync();
    final hasLocation = event.latitude != null && event.longitude != null;
    final timeStr = '${event.timestamp.day.toString().padLeft(2, '0')}/${event.timestamp.month.toString().padLeft(2, '0')}/${event.timestamp.year} '
        '${event.timestamp.hour.toString().padLeft(2, '0')}:${event.timestamp.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppConstants.primaryColor.withAlpha(50),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConstants.primaryColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: AppConstants.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.triggerType,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeStr,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppConstants.textMutedColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (hasPhoto || hasLocation) ...[
            const SizedBox(height: 14),
            const Divider(color: Colors.white10),
            const SizedBox(height: 8),
          ],

          Row(
            children: [
              if (hasPhoto)
                GestureDetector(
                  onTap: () => _showImageDialog(event.photoPath!),
                  child: Container(
                    width: 60,
                    height: 60,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppConstants.accentColor, width: 1.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(event.photoPath!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasPhoto)
                      const Text(
                        '📸 Foto Penyusup Tersimpan (Ketuk foto untuk perbesar)',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.accentColor,
                        ),
                      ),
                    if (hasLocation) ...[
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () => _openMaps(event.latitude!, event.longitude!),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 16,
                              color: AppConstants.accentColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Lihat Lokasi (${event.latitude!.toStringAsFixed(3)}, ${event.longitude!.toStringAsFixed(3)})',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppConstants.accentColor,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
