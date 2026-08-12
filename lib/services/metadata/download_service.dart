import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import '../../../../domain/entities/track.dart';

final downloadServiceProvider = Provider((ref) => DownloadService());

class DownloadService {
  final Dio _dio = Dio();

  Future<bool> downloadTrack(MediaItem item, void Function(double) onProgress) async {
    var dataUrl = item.extras?['url'] as String?;
    if (dataUrl == null || dataUrl.isEmpty) {
      dataUrl = item.id;
    }

    try {
      if (dataUrl.startsWith('yt:')) {
        dataUrl = dataUrl.substring(3);
      }
      
      // If it's a bare video ID, point to proxy
      if (!dataUrl.startsWith('http') && !dataUrl.startsWith('/')) {
        dataUrl = 'http://127.0.0.1:8080/?videoId=$dataUrl';
      }

      // Use getExternalStorageDirectory for Android to make it accessible to the user
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) return false;

      final orbituneDir = Directory('${directory.path}/Orbitune');
      if (!await orbituneDir.exists()) {
        await orbituneDir.create(recursive: true);
      }

      // Clean filename
      final safeTitle = item.title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      final safeArtist = item.artist?.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_') ?? 'Unknown';
      
      final filePath = '${orbituneDir.path}/$safeTitle - $safeArtist.m4a';

      await _dio.download(
        dataUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress(received / total);
          }
        },
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Track>> getDownloadedTracks() async {
    try {
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }
      
      if (directory == null) return [];
      
      final orbituneDir = Directory('${directory.path}/Orbitune');
      if (!await orbituneDir.exists()) return [];

      final files = orbituneDir.listSync().whereType<File>().where((f) => f.path.endsWith('.m4a') || f.path.endsWith('.mp3')).toList();
      
      return files.map((f) {
        final filename = f.path.split(Platform.pathSeparator).last;
        final nameWithoutExt = filename.substring(0, filename.lastIndexOf('.'));
        final parts = nameWithoutExt.split(' - ');
        final title = parts.isNotEmpty ? parts[0] : 'Unknown Title';
        final artist = parts.length > 1 ? parts.sublist(1).join(' - ') : 'Unknown Artist';
        
        return Track(
          id: f.path, // Using file path as ID for local files
          title: title,
          artist: artist,
          album: 'Orbitune Downloads',
          durationMs: 0, // Duration will be parsed when played
          source: TrackSource.local,
          dataUrl: f.path,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }
  
  Future<bool> deleteDownloadedTrack(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
