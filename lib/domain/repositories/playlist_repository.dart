import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import '../../core/helpers/result_type.dart';
import '../entities/playlist.dart';
import '../entities/track.dart';

final playlistRepositoryProvider = Provider<PlaylistRepository>((ref) {
  throw UnimplementedError('Initialize in main/provider setup');
});

abstract class PlaylistRepository {
  Future<Result<List<Playlist>>> getAllPlaylists();
  Future<Result<Playlist>> createPlaylist(String name, {bool isFavoritePlaylist = false});
  Future<Result<Unit>> addTrackToPlaylist(String playlistId, Track track);
  Future<Result<Unit>> removeTrackFromPlaylist(String playlistId, String trackId);
  Future<Result<Unit>> deletePlaylist(String playlistId);
  Future<Result<Unit>> renamePlaylist(String playlistId, String newName);
  Future<Result<Unit>> reorderTracks(String playlistId, List<String> newTrackIds);
  Future<Result<Playlist>> duplicatePlaylist(String playlistId);
}
