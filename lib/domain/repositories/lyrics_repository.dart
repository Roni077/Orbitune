import '../../core/helpers/result_type.dart';

abstract class LyricsRepository {
  Future<Result<Map<String, String?>>> getCachedLyrics(String trackId);
  Future<Result<void>> saveLyrics(String trackId, Map<String, String?> lyrics);
}
