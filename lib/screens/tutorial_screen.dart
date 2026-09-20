import 'package:flutter/material.dart';
import '../utils/constants.dart';

class TutorialScreen extends StatelessWidget {
  const TutorialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> steps = [
      {
        'step': '01',
        'title': 'Hubungkan Kabel Charger',
        'desc':
            'Sambungkan HP Anda ke charger (opsional). Jika proteksi diaktifkan maka alarm akan langsung berbunyi apabila charger dicabut paksa oleh orang lain ataupun hp tersebut diambil saat diletakan.',
      },
      {
        'step': '02',
        'title': 'Aktifkan Keamanan',
        'desc':
            'Tekan tombol "AKTIFKAN KEAMANAN" di halaman beranda. Countdown selama 5 detik akan berjalan memberi Anda waktu untuk meletakkan HP.',
      },
      {
        'step': '03',
        'title': 'Letakkan HP di Tempat Datar',
        'desc':
            'Setelah countdown selesai maka sistem akan memasuki kondisi AKTIF. Jangan pindahkan HP Anda agar sensor gerak tetap dalam posisi siaga terkalibrasi.',
      },
      {
        'step': '04',
        'title': 'Layar Terkunci & Kunci Volume 100%',
        'desc':
            'Saat alarm berbunyi, layar otomatis terkunci dan volume dikunci maksimal 100% (anti-mute). Masukkan PIN Anda (default 1234, dapat diubah di Pengaturan). Sistem juga otomatis merekam koordinat GPS darurat dan foto bukti penyusup jika diaktifkan.',
      },
    ];

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Panduan Penggunaan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cara Menggunakan SIGAP',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppConstants.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ikuti langkah sederhana berikut untuk mengamankan perangkat Anda dari tindakan pencurian.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppConstants.textMutedColor,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),

                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: steps.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 36),
                  itemBuilder: (context, index) {
                    final item = steps[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppConstants.accentColor.withAlpha(20),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppConstants.accentColor.withAlpha(50),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                item['step']!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppConstants.accentColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                item['title']!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppConstants.textColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            item['desc']!,
                            style: const TextStyle(
                              fontSize: 13.5,
                              color: AppConstants.textMutedColor,
                              height: 1.4,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              'img/${index + 1}.png',
                              width: MediaQuery.of(context).size.width * 0.6,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: AppConstants.cardColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.broken_image_outlined,
                                        size: 32,
                                        color: AppConstants.textMutedColor
                                            .withAlpha(100),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Gagal memuat gambar ${item['step']}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppConstants.textMutedColor
                                              .withAlpha(150),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'SAYA MENGERTI',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
