import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

final downloadsProvider = FutureProvider.autoDispose<List<File>>((ref) async {
  Directory? directory;
  if (Platform.isAndroid) {
    directory = await getExternalStorageDirectory();
  } else {
    directory = await getApplicationDocumentsDirectory();
  }

  if (directory == null) return [];

  final orbituneDir = Directory('${directory.path}/Orbitune');
  if (!await orbituneDir.exists()) {
    return [];
  }

  final files = orbituneDir.listSync();
  final audioFiles = files
      .whereType<File>()
      .where((file) => file.path.endsWith('.m4a') || file.path.endsWith('.mp3'))
      .toList();

  // Sort by modification time (newest first)
  audioFiles.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

  return audioFiles;
});

final downloadOperationsProvider = Provider((ref) => DownloadOperations(ref));

class DownloadOperations {
  final Ref ref;
  DownloadOperations(this.ref);

  Future<void> deleteFile(File file) async {
    if (await file.exists()) {
      await file.delete();
      ref.invalidate(downloadsProvider);
    }
  }
}
