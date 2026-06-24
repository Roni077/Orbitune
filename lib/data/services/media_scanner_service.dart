import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';
import '../models/audio_model.dart';
import '../repositories/audio_repository.dart';
import '../../features/permissions/permissions_service.dart';

class MediaScannerService {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioRepository _audioRepository;
  final PermissionsService _permissionsService;

  MediaScannerService(this._audioRepository, this._permissionsService);

  Future<void> scanAndSaveAudios({List<String> excludedFolders = const []}) async {
    final hasPermission = await _permissionsService.hasPermissions();
    if (!hasPermission) {
      final granted = await _permissionsService.requestMediaPermissions();
      if (!granted) return; 
    }

    // Query all songs from device
    final songs = await _audioQuery.querySongs(
      sortType: null,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );

    // Run mapping directly instead of via compute() to avoid heavy serialization overhead
    final audioModels = _mapSongs({
      'songs': songs,
      'excludedFolders': excludedFolders,
    });

    // Delete orphaned records
    final existingAudios = await _audioRepository.getAllAudios();
    final newUris = audioModels.map((a) => a.uri).toSet();
    final orphanedIds = existingAudios
        .where((a) => !newUris.contains(a.uri))
        .map((a) => a.id)
        .toList();

    if (orphanedIds.isNotEmpty) {
      await _audioRepository.deleteAudios(orphanedIds);
    }

    // Save to Isar database
    await _audioRepository.saveAudios(audioModels);
    
    // Kick off background artwork extraction and await it so the UI RefreshIndicator knows when it's done
    await _extractAlbumArtInBackground();
  }

  // Mapper entry point
  static List<AudioModel> _mapSongs(Map<String, dynamic> args) {
    final List<SongModel> songs = args['songs'];
    final List<String> excludedFolders = args['excludedFolders'];
    
    return songs.where((song) {
      final path = song.data;
      // Skip excluded folders
      return !excludedFolders.any((folder) => path.contains(folder));
    }).map((song) {
      return AudioModel()
        ..uri = song.data 
        ..title = song.title
        ..artist = song.artist ?? '<Unknown>'
        ..album = song.album ?? '<Unknown>'
        ..displayName = song.displayName
        ..mediaStoreId = song.id
        ..durationMs = song.duration ?? 0
        ..trackNumber = song.track ?? 0
        ..sizeBytes = song.size
        ..genre = song.genre
        ..dateAdded = song.dateAdded != null 
            ? DateTime.fromMillisecondsSinceEpoch(song.dateAdded! * 1000)
            : DateTime.now();
    }).toList();
  }

  Future<void> _extractAlbumArtInBackground() async {
    final allAudios = await _audioRepository.getAllAudios();
    final appDir = await getApplicationDocumentsDirectory();
    final artDir = Directory('${appDir.path}/album_art');
    
    if (!await artDir.exists()) {
      await artDir.create(recursive: true);
    }

    // Extract by album to avoid redundant queries
    final Set<String> processedAlbums = {};
    final List<AudioModel> updatedAudios = [];

    int processedCount = 0;

    for (var audio in allAudios) {
      if (processedAlbums.contains(audio.album)) continue;
      
      // Yield to the event loop every 5 iterations to prevent UI stutter
      if (processedCount++ % 5 == 0) {
        await Future.delayed(Duration.zero);
      }

      try {
        final Uint8List? artBytes = await _audioQuery.queryArtwork(
          audio.mediaStoreId ?? audio.id,
          ArtworkType.AUDIO,
          format: ArtworkFormat.JPEG,
          size: 500,
        );

        if (artBytes != null && artBytes.isNotEmpty) {
          // Save to local storage
          final safeAlbumName = audio.album.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
          final File artFile = File('${artDir.path}/$safeAlbumName.jpg');
          await artFile.writeAsBytes(artBytes);

          // Find all songs with this album and update them
          final albumSongs = allAudios.where((a) => a.album == audio.album);
          for (var song in albumSongs) {
            song.albumArtPath = artFile.path;
            updatedAudios.add(song);
          }
        }
        processedAlbums.add(audio.album);
      } catch (e) {
        debugPrint('Failed to extract art for ${audio.title}: $e');
      }
    }

    if (updatedAudios.isNotEmpty) {
      await _audioRepository.saveAudios(updatedAudios);
    }
  }
}
