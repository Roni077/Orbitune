import 'package:drift/drift.dart';
import 'package:fpdart/fpdart.dart';
import '../../core/errors/failure.dart';
import '../../core/helpers/result_type.dart';
import '../../../domain/entities/playlist.dart';
import '../../../domain/entities/track.dart';
import '../../../domain/repositories/playlist_repository.dart';
import '../datasources/local/app_database.dart';

class PlaylistRepositoryImpl implements PlaylistRepository {
  final AppDatabase _db;

  PlaylistRepositoryImpl(this._db);

  @override
  Future<Result<List<Playlist>>> getAllPlaylists() async {
    try {
      final playlists = await _db.select(_db.playlists).get();
      final playlistEntries = await _db.select(_db.playlistEntries).get();

      final mappedPlaylists = playlists.map((p) {
        final trackIds = playlistEntries
            .where((e) => e.playlistId == p.id)
            .toList()
            ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
            
        return Playlist(
          id: p.id,
          name: p.name,
          trackIds: trackIds.map((e) => e.trackId).toList(),
          coverUrl: p.coverUrl,
          isFavoritePlaylist: p.isFavoritePlaylist,
          createdAt: p.createdAt,
        );
      }).toList();

      return Right(mappedPlaylists);
    } catch (e) {
      return Left(Failure('Failed to fetch playlists', exception: e));
    }
  }

  @override
  Future<Result<Playlist>> createPlaylist(String name, {bool isFavoritePlaylist = false}) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final now = DateTime.now();
      
      await _db.into(_db.playlists).insert(PlaylistEntity(
        id: id,
        name: name,
        isFavoritePlaylist: isFavoritePlaylist,
        createdAt: now,
      ));

      return Right(Playlist(
        id: id,
        name: name,
        isFavoritePlaylist: isFavoritePlaylist,
        createdAt: now,
      ));
    } catch (e) {
      return Left(Failure('Failed to create playlist', exception: e));
    }
  }

  @override
  Future<Result<Unit>> addTrackToPlaylist(String playlistId, Track track) async {
    try {
      return await _db.transaction(() async {
        // First ensure the track exists in the tracks table
        await _db.into(_db.tracks).insertOnConflictUpdate(TrackEntity(
          id: track.id,
          title: track.title,
          artist: track.artist,
          album: track.album,
          durationMs: track.durationMs,
          source: track.source.name,
          dataUrl: track.dataUrl,
          artworkUrl: track.artworkUrl,
          genre: track.genre,
          year: track.year,
          playCount: track.playCount,
          skipCount: track.skipCount,
          dateAdded: track.dateAdded,
        ));

        // Get current max sort order
        final countQuery = _db.select(_db.playlistEntries)..where((tbl) => tbl.playlistId.equals(playlistId));
        final currentEntries = await countQuery.get();
        final maxSortOrder = currentEntries.isEmpty 
            ? 0 
            : currentEntries.map((e) => e.sortOrder).reduce((a, b) => a > b ? a : b);

        // Insert entry
        await _db.into(_db.playlistEntries).insert(PlaylistEntryEntity(
          playlistId: playlistId,
          trackId: track.id,
          sortOrder: maxSortOrder + 1,
        ));

        // Update coverUrl if the playlist doesn't have one and this track does
        if (track.artworkUrl != null) {
          final playlist = await (_db.select(_db.playlists)..where((tbl) => tbl.id.equals(playlistId))).getSingleOrNull();
          if (playlist != null && playlist.coverUrl == null) {
            await (_db.update(_db.playlists)..where((tbl) => tbl.id.equals(playlistId)))
                .write(PlaylistsCompanion(coverUrl: Value(track.artworkUrl)));
          }
        }

        return const Right(unit);
      });
    } catch (e) {
      return Left(Failure('Failed to add track to playlist', exception: e));
    }
  }

  @override
  Future<Result<Unit>> removeTrackFromPlaylist(String playlistId, String trackId) async {
    try {
      await (_db.delete(_db.playlistEntries)
            ..where((tbl) => tbl.playlistId.equals(playlistId) & tbl.trackId.equals(trackId)))
          .go();
      return const Right(unit);
    } catch (e) {
      return Left(Failure('Failed to remove track from playlist', exception: e));
    }
  }

  @override
  Future<Result<Unit>> deletePlaylist(String playlistId) async {
    try {
      return await _db.transaction(() async {
        // Delete all entries first (foreign key cascades aren't on by default without pragma)
        await (_db.delete(_db.playlistEntries)..where((tbl) => tbl.playlistId.equals(playlistId))).go();
        
        // Delete the playlist
        await (_db.delete(_db.playlists)..where((tbl) => tbl.id.equals(playlistId))).go();
        
        return const Right(unit);
      });
    } catch (e) {
      return Left(Failure('Failed to delete playlist', exception: e));
    }
  }

  @override
  Future<Result<Unit>> renamePlaylist(String playlistId, String newName) async {
    try {
      await (_db.update(_db.playlists)..where((tbl) => tbl.id.equals(playlistId)))
          .write(PlaylistsCompanion(name: Value(newName)));
      return const Right(unit);
    } catch (e) {
      return Left(Failure('Failed to rename playlist', exception: e));
    }
  }

  @override
  Future<Result<Unit>> reorderTracks(String playlistId, List<String> newTrackIds) async {
    try {
      return await _db.transaction(() async {
        for (int i = 0; i < newTrackIds.length; i++) {
          await (_db.update(_db.playlistEntries)
                ..where((tbl) => tbl.playlistId.equals(playlistId) & tbl.trackId.equals(newTrackIds[i])))
              .write(PlaylistEntriesCompanion(sortOrder: Value(i)));
        }
        return const Right(unit);
      });
    } catch (e) {
      return Left(Failure('Failed to reorder playlist', exception: e));
    }
  }
  @override
  Future<Result<Playlist>> duplicatePlaylist(String playlistId) async {
    try {
      final originalQuery = await (_db.select(_db.playlists)..where((tbl) => tbl.id.equals(playlistId))).getSingleOrNull();
      if (originalQuery == null) return Left(Failure('Playlist not found'));

      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final now = DateTime.now();
      final newName = '${originalQuery.name} (Copy)';

      await _db.transaction(() async {
        await _db.into(_db.playlists).insert(PlaylistEntity(
          id: id,
          name: newName,
          isFavoritePlaylist: false,
          createdAt: now,
          coverUrl: originalQuery.coverUrl,
        ));

        final entries = await (_db.select(_db.playlistEntries)..where((tbl) => tbl.playlistId.equals(playlistId))).get();
        for (final entry in entries) {
          await _db.into(_db.playlistEntries).insert(PlaylistEntryEntity(
            playlistId: id,
            trackId: entry.trackId,
            sortOrder: entry.sortOrder,
          ));
        }
      });

      final newEntries = await (_db.select(_db.playlistEntries)..where((tbl) => tbl.playlistId.equals(id))).get();
      final trackIds = newEntries.map((e) => e.trackId).toList();

      return Right(Playlist(
        id: id,
        name: newName,
        isFavoritePlaylist: false,
        createdAt: now,
        coverUrl: originalQuery.coverUrl,
        trackIds: trackIds,
      ));
    } catch (e) {
      return Left(Failure('Failed to duplicate playlist', exception: e));
    }
  }
}
