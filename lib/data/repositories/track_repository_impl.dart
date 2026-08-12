import 'package:fpdart/fpdart.dart';
import '../../core/errors/failure.dart';
import '../../core/helpers/result_type.dart';
import '../../../domain/entities/track.dart';
import '../../../domain/repositories/track_repository.dart';
import '../datasources/local/app_database.dart';
import 'package:drift/drift.dart' as drift;

class TrackRepositoryImpl implements TrackRepository {
  final AppDatabase _db;

  TrackRepositoryImpl(this._db);

  @override
  Future<Result<List<Track>>> getLocalTracks() async {
    try {
      final records = await _db.select(_db.tracks).get();
      final tracks = records.map((t) => Track(
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
      )).toList();
      return Right(tracks);
    } catch (e) {
      return Left(Failure('Failed to fetch tracks', exception: e));
    }
  }

  @override
  Future<Result<Track>> saveTrackToLocal(Track track) async {
    try {
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
        lastPlayed: track.lastPlayed,
      ));
      return Right(track);
    } catch (e) {
      return Left(Failure('Failed to save track', exception: e));
    }
  }

  @override
  Future<Result<Unit>> deleteTrack(String id) async {
    try {
      await (_db.delete(_db.tracks)..where((t) => t.id.equals(id))).go();
      return const Right(unit);
    } catch (e) {
      return Left(Failure('Failed to delete track', exception: e));
    }
  }

  @override
  Future<Result<List<Track>>> getRecentlyPlayed({int limit = 20}) async {
    try {
      final query = _db.select(_db.tracks)
        ..where((t) => t.lastPlayed.isNotNull())
        ..orderBy([(t) => drift.OrderingTerm(expression: t.lastPlayed, mode: drift.OrderingMode.desc)])
        ..limit(limit);
      final records = await query.get();
      
      final tracks = records.map((t) => Track(
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
      )).toList();
      return Right(tracks);
    } catch (e) {
      return Left(Failure('Failed to fetch recently played', exception: e));
    }
  }

  @override
  Future<Result<Unit>> markTrackAsPlayed(String id) async {
    try {
      await _db.into(_db.playbackHistory).insert(
        PlaybackHistoryCompanion.insert(
          trackId: id,
          playedAt: DateTime.now(),
        ),
      );

      final currentTrack = await (_db.select(_db.tracks)..where((t) => t.id.equals(id))).getSingleOrNull();
      if (currentTrack != null) {
        final query = _db.update(_db.tracks)..where((t) => t.id.equals(id));
        await query.write(
          TracksCompanion(
            playCount: drift.Value(currentTrack.playCount + 1),
            lastPlayed: drift.Value(DateTime.now()),
          ),
        );
      }
      return const Right(unit);
    } catch (e) {
      return Left(Failure('Failed to mark track as played', exception: e));
    }
  }

  @override
  Future<Result<List<Track>>> getMostPlayed({int limit = 20}) async {
    try {
      final query = _db.select(_db.tracks)
        ..orderBy([
          (t) => drift.OrderingTerm(expression: t.playCount, mode: drift.OrderingMode.desc)
        ])
        ..limit(limit);
      
      final records = await query.get();
      final tracks = records.map(_mapRecordToTrack).toList();
      return Right(tracks);
    } catch (e) {
      return Left(Failure('Failed to fetch most played tracks', exception: e));
    }
  }

  @override
  Future<Result<List<Track>>> getRecentlyAdded({int limit = 20}) async {
    try {
      final query = _db.select(_db.tracks)
        ..orderBy([
          (t) => drift.OrderingTerm(expression: t.dateAdded, mode: drift.OrderingMode.desc)
        ])
        ..limit(limit);
      
      final records = await query.get();
      final tracks = records.map(_mapRecordToTrack).toList();
      return Right(tracks);
    } catch (e) {
      return Left(Failure('Failed to fetch recently added tracks', exception: e));
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
    );
  }
}
