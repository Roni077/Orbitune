import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import '../../core/helpers/result_type.dart';
import '../entities/track.dart';

final trackRepositoryProvider = Provider<TrackRepository>((ref) {
  throw UnimplementedError('Initialize in main/provider setup');
});

abstract class TrackRepository {
  Future<Result<List<Track>>> getLocalTracks();
  Future<Result<List<Track>>> getRecentlyPlayed({int limit = 20});
  Future<Result<List<Track>>> getMostPlayed({int limit = 20});
  Future<Result<List<Track>>> getRecentlyAdded({int limit = 20});
  Future<Result<Track>> saveTrackToLocal(Track track);
  Future<Result<Unit>> markTrackAsPlayed(String id);
  Future<Result<Unit>> deleteTrack(String id);
}
