import 'package:on_audio_query/on_audio_query.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter/foundation.dart';
import '../../core/errors/failure.dart';
import '../../core/helpers/result_type.dart';
import '../../domain/entities/track.dart';

List<Track> _parseLocalSongs(Map<String, dynamic> args) {
  final songMaps = args['songs'] as List<Map<String, dynamic>>;
  final selectedFolders = args['selectedFolders'] as List<String>?;

  var tracks = songMaps.map((s) => Track(
    id: (s['uri'] ?? s['data']).toString(),
    title: s['title']?.toString() ?? 'Unknown',
    artist: s['artist']?.toString() ?? '<Unknown>',
    album: s['album']?.toString() ?? 'Unknown Album',
    durationMs: s['duration'] as int? ?? 0,
    source: TrackSource.local,
    dataUrl: (s['uri'] ?? s['data']).toString(),
    artworkUrl: null,
    genre: s['genre']?.toString(),
    year: null,
  )).toList();

  if (selectedFolders != null && selectedFolders.isNotEmpty) {
    tracks = tracks.where((track) {
      final path = track.dataUrl;
      return selectedFolders.any((folder) => path.startsWith(folder));
    }).toList();
  }

  return tracks;
}

class LocalAudioService {
  final OnAudioQuery _audioQuery = OnAudioQuery();

  Future<Result<List<String>>> getAudioFolders() async {
    try {
      final hasPermission = await _audioQuery.checkAndRequest(retryRequest: true);
      if (!hasPermission) {
        return Left(const Failure('Storage permission denied'));
      }

      final songs = await _audioQuery.querySongs();
      final Set<String> folders = {};
      
      for (var s in songs) {
        final data = s.data;
        // Data usually contains the full path like /storage/emulated/0/Music/song.mp3
        final lastSlash = data.lastIndexOf('/');
        if (lastSlash != -1) {
          folders.add(data.substring(0, lastSlash));
        }
      }
      
      final sortedFolders = folders.toList()..sort();
      return Right(sortedFolders);
    } catch (e) {
      return Left(Failure('Failed to fetch audio folders', exception: e));
    }
  }

  Future<Result<List<Track>>> getLocalSongs({List<String>? selectedFolders}) async {
    try {
      final hasPermission = await _audioQuery.checkAndRequest(retryRequest: true);
      if (!hasPermission) {
        return Left(const Failure('Storage permission denied'));
      }

      final songs = await _audioQuery.querySongs(
        sortType: null,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      final songMaps = songs.map((s) => {
        'uri': s.uri,
        'data': s.data,
        'title': s.title,
        'artist': s.artist,
        'album': s.album,
        'duration': s.duration,
        'genre': s.genre,
      }).toList();

      final tracks = await compute(_parseLocalSongs, {
        'songs': songMaps,
        'selectedFolders': selectedFolders,
      });

      return Right(tracks);
    } catch (e) {
      return Left(Failure('Failed to fetch local songs', exception: e));
    }
  }
}
