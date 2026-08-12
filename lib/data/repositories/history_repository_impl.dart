import 'package:fpdart/fpdart.dart';
import 'package:drift/drift.dart' as drift;
import '../../core/helpers/result_type.dart';
import '../../core/errors/failure.dart';
import '../../domain/entities/track.dart';
import '../../domain/repositories/history_repository.dart';
import '../datasources/local/app_database.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final AppDatabase _db;

  HistoryRepositoryImpl(this._db);

  @override
  Future<Result<List<Track>>> getPlaybackHistory({int limit = 50, int offset = 0}) async {
    try {
      final query = _db.select(_db.playbackHistory).join([
        drift.innerJoin(_db.tracks, _db.tracks.id.equalsExp(_db.playbackHistory.trackId))
      ])
        ..orderBy([drift.OrderingTerm(expression: _db.playbackHistory.playedAt, mode: drift.OrderingMode.desc)])
        ..limit(limit, offset: offset);
      
      final records = await query.get();
      final tracks = records.map((row) {
        final t = row.readTable(_db.tracks);
        return _mapRecordToTrack(t);
      }).toList();
      return Right(tracks);
    } catch (e) {
      return Left(Failure('Failed to fetch history', exception: e));
    }
  }

  @override
  Future<Result<Unit>> recordPlayEvent(String trackId) async {
    try {
      await _db.into(_db.playbackHistory).insert(
        PlaybackHistoryCompanion.insert(
          trackId: trackId,
          playedAt: DateTime.now(),
        ),
      );
      
      // Update play count and last played in Tracks table
      final currentTrack = await (_db.select(_db.tracks)..where((t) => t.id.equals(trackId))).getSingleOrNull();
      if (currentTrack != null) {
        final newPlayCount = currentTrack.playCount + 1;
        await (_db.update(_db.tracks)..where((t) => t.id.equals(trackId))).write(
          TracksCompanion(
            playCount: drift.Value(newPlayCount),
            lastPlayed: drift.Value(DateTime.now()),
          ),
        );
      }
      
      return const Right(unit);
    } catch (e) {
      return Left(Failure('Failed to record play event', exception: e));
    }
  }

  @override
  Future<Result<Unit>> clearHistory() async {
    try {
      await _db.delete(_db.playbackHistory).go();
      return const Right(unit);
    } catch (e) {
      return Left(Failure('Failed to clear history', exception: e));
    }
  }

  @override
  Future<Result<Unit>> deletePlayEvent(int historyId) async {
    try {
      await (_db.delete(_db.playbackHistory)..where((h) => h.id.equals(historyId))).go();
      return const Right(unit);
    } catch (e) {
      return Left(Failure('Failed to delete history event', exception: e));
    }
  }

  Track _mapRecordToTrack(TrackEntity t) {
    return Track(
      id: t.id,
      title: t.title,
      artist: t.artist,
      album: t.album,
      durationMs: t.durationMs,
      source: TrackSource.values.firstWhere(
        (e) => e.name == t.source,
        orElse: () => TrackSource.local,
      ),
      dataUrl: t.dataUrl,
      artworkUrl: t.artworkUrl,
      genre: t.genre,
      year: t.year,
      playCount: t.playCount,
      dateAdded: t.dateAdded,
      lastPlayed: t.lastPlayed,
      skipCount: t.skipCount,
    );
  }

  @override
  Future<Result<int>> getTotalListeningTimeMs() async {
    try {
      final totalMsExpr = _db.tracks.durationMs * _db.tracks.playCount;
      final query = _db.selectOnly(_db.tracks)
        ..addColumns([totalMsExpr.sum()]);
      
      final row = await query.getSingle();
      final total = row.read(totalMsExpr.sum()) ?? 0;
      
      return Right(total);
    } catch (e) {
      return Left(Failure('Failed to calculate total listening time', exception: e));
    }
  }

  @override
  Future<Result<int>> getTotalSkips() async {
    try {
      final query = _db.selectOnly(_db.tracks)
        ..addColumns([_db.tracks.skipCount.sum()]);
      
      final row = await query.getSingle();
      final total = row.read(_db.tracks.skipCount.sum()) ?? 0;
      
      return Right(total);
    } catch (e) {
      return Left(Failure('Failed to calculate total skips', exception: e));
    }
  }

  @override
  Future<Result<List<String>>> getTopArtists(int limit) async {
    try {
      final sumPlayCount = _db.tracks.playCount.sum();
      final query = _db.selectOnly(_db.tracks)
        ..addColumns([_db.tracks.artist, sumPlayCount])
        ..where(_db.tracks.playCount.isBiggerThanValue(0))
        ..groupBy([_db.tracks.artist])
        ..orderBy([drift.OrderingTerm(expression: sumPlayCount, mode: drift.OrderingMode.desc)])
        ..limit(limit);
      
      final result = await query.get();
      final artists = result.map((row) => row.read(_db.tracks.artist)!).toList();
      return Right(artists);
    } catch (e) {
      return Left(Failure('Failed to get top artists', exception: e));
    }
  }

  @override
  Future<Result<List<String>>> getTopAlbums(int limit) async {
    try {
      final sumPlayCount = _db.tracks.playCount.sum();
      final query = _db.selectOnly(_db.tracks)
        ..addColumns([_db.tracks.album, sumPlayCount])
        ..where(_db.tracks.playCount.isBiggerThanValue(0))
        ..groupBy([_db.tracks.album])
        ..orderBy([drift.OrderingTerm(expression: sumPlayCount, mode: drift.OrderingMode.desc)])
        ..limit(limit);
      
      final result = await query.get();
      final albums = result.map((row) => row.read(_db.tracks.album)!).toList();
      return Right(albums);
    } catch (e) {
      return Left(Failure('Failed to get top albums', exception: e));
    }
  }

  @override
  Future<Result<Unit>> incrementSkipCount(String trackId) async {
    try {
      final currentTrack = await (_db.select(_db.tracks)..where((t) => t.id.equals(trackId))).getSingleOrNull();
      if (currentTrack != null) {
        final newSkipCount = currentTrack.skipCount + 1;
        await (_db.update(_db.tracks)..where((t) => t.id.equals(trackId))).write(
          TracksCompanion(skipCount: drift.Value(newSkipCount)),
        );
      }
      return const Right(unit);
    } catch (e) {
      return Left(Failure('Failed to increment skip count', exception: e));
    }
  }
}
