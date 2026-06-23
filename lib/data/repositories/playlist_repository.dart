import 'package:isar/isar.dart';
import '../models/playlist_model.dart';

class PlaylistRepository {
  final Isar _isar;

  PlaylistRepository(this._isar);

  Future<void> createPlaylist(String name, [List<String> initialSongUris = const []]) async {
    final playlist = PlaylistModel()
      ..name = name
      ..creationDate = DateTime.now()
      ..songUris = initialSongUris;
    
    await _isar.writeTxn(() async {
      await _isar.playlistModels.put(playlist);
    });
  }

  Future<void> deletePlaylist(int id) async {
    await _isar.writeTxn(() async {
      await _isar.playlistModels.delete(id);
    });
  }

  Future<void> addSongsToPlaylist(int id, List<String> newUris) async {
    final playlist = await _isar.playlistModels.get(id);
    if (playlist != null) {
      playlist.songUris = [...playlist.songUris, ...newUris];
      await _isar.writeTxn(() async {
        await _isar.playlistModels.put(playlist);
      });
    }
  }

  Future<void> removeSongFromPlaylist(int id, String uri) async {
    final playlist = await _isar.playlistModels.get(id);
    if (playlist != null) {
      playlist.songUris = playlist.songUris.where((u) => u != uri).toList();
      await _isar.writeTxn(() async {
        await _isar.playlistModels.put(playlist);
      });
    }
  }

  Stream<List<PlaylistModel>> watchAllPlaylists() {
    return _isar.playlistModels.where().sortByCreationDateDesc().watch(fireImmediately: true);
  }

  Future<List<PlaylistModel>> getAllPlaylists() async {
    return await _isar.playlistModels.where().sortByCreationDateDesc().findAll();
  }
}
