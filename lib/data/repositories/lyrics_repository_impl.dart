import 'package:fpdart/fpdart.dart';
import '../../core/errors/failure.dart';
import '../../core/helpers/result_type.dart';
import '../../domain/repositories/lyrics_repository.dart';
import '../datasources/local/app_database.dart';

class LyricsRepositoryImpl implements LyricsRepository {
  final AppDatabase _db;

  LyricsRepositoryImpl(this._db);

  @override
  Future<Result<Map<String, String?>>> getCachedLyrics(String trackId) async {
    try {
      final query = _db.select(_db.cachedLyrics)
        ..where((t) => t.trackId.equals(trackId));
      
      final result = await query.getSingleOrNull();
      
      if (result != null) {
        return Right({
          'syncedLyrics': result.syncedLyrics,
          'plainLyrics': result.plainLyrics,
        });
      } else {
        return Left(Failure('No cached lyrics found'));
      }
    } catch (e) {
      return Left(Failure('Failed to get cached lyrics', exception: e));
    }
  }

  @override
  Future<Result<void>> saveLyrics(String trackId, Map<String, String?> lyrics) async {
    try {
      await _db.into(_db.cachedLyrics).insertOnConflictUpdate(
        CachedLyricEntity(
          trackId: trackId,
          syncedLyrics: lyrics['syncedLyrics'],
          plainLyrics: lyrics['plainLyrics'],
        ),
      );
      return const Right(null);
    } catch (e) {
      return Left(Failure('Failed to save lyrics', exception: e));
    }
  }
}
