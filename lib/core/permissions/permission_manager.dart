import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionManager {
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      // Android 13+ uses audio/video/images instead of storage
      // However, permission_handler handles this cleanly with .audio
      // or we can request storage.
      if (await Permission.audio.isGranted || await Permission.storage.isGranted) {
        return true;
      }
      
      final storageStatus = await Permission.storage.request();
      if (storageStatus.isGranted) return true;
      
      final audioStatus = await Permission.audio.request();
      return audioStatus.isGranted;
    } else {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
  }

  static Future<void> requestNotificationPermission() async {
    if (Platform.isAndroid) {
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }
    }
  }
}
