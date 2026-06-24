import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  Future<bool> requestMediaPermissions() async {
    if (Platform.isIOS) {
      final status = await Permission.mediaLibrary.request();
      return status.isGranted;
    }

    if (!Platform.isAndroid) return true;

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    if (sdkInt >= 33) {
      // Android 13+ uses specific media permissions
      final status = await Permission.audio.request();
      return status.isGranted;
    } else {
      // Android 12 and below use standard storage permissions
      final status = await Permission.storage.request();
      return status.isGranted;
    }
  }

  Future<bool> hasPermissions() async {
    if (Platform.isIOS) {
      return await Permission.mediaLibrary.isGranted;
    }

    if (!Platform.isAndroid) return true;

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    if (sdkInt >= 33) {
      return await Permission.audio.isGranted;
    } else {
      return await Permission.storage.isGranted;
    }
  }
}
