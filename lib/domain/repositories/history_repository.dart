import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import '../../core/helpers/result_type.dart';
import '../entities/track.dart';

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  throw UnimplementedError('Initialize in main/provider setup');
});

abstract class HistoryRepository {
  Future<Result<List<Track>>> getPlaybackHistory({int limit = 50, int offset = 0});
  Future<Result<Unit>> recordPlayEvent(String trackId);
  Future<Result<Unit>> clearHistory();
  Future<Result<Unit>> deletePlayEvent(int historyId);

  // Analytics & Smart Features
  Future<Result<int>> getTotalListeningTimeMs();
  Future<Result<int>> getTotalSkips();
  Future<Result<List<String>>> getTopArtists(int limit);
  Future<Result<List<String>>> getTopAlbums(int limit);
  Future<Result<Unit>> incrementSkipCount(String trackId);
}
