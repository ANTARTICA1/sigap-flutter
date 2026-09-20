import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraEvidenceService {
  static Future<String?> captureIntruderPhoto() async {
    try {
      final status = await Permission.camera.status;
      if (!status.isGranted) {
        return null;
      }

      final cameras = await availableCameras();
      if (cameras.isEmpty) return null;

      CameraDescription? frontCamera;
      for (final cam in cameras) {
        if (cam.lensDirection == CameraLensDirection.front) {
          frontCamera = cam;
          break;
        }
      }
      frontCamera ??= cameras.first;

      final controller = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      XFile rawFile;
      try {
        await controller.initialize();
        rawFile = await controller.takePicture();
      } finally {
        await controller.dispose();
      }

      final appDir = await getApplicationDocumentsDirectory();
      final evidenceDir = Directory('${appDir.path}/intruder_evidence');
      if (!await evidenceDir.exists()) {
        await evidenceDir.create(recursive: true);
      }

      final fileName = 'intruder_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = '${evidenceDir.path}/$fileName';
      await rawFile.saveTo(savedPath);

      return savedPath;
    } catch (e) {
      return null;
    }
  }
}
