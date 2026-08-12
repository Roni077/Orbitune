import 'package:fpdart/fpdart.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../../core/errors/failure.dart';
import '../../core/helpers/result_type.dart';

/// Resolves a YouTube videoId to a playable audio stream URL.
/// Uses the androidVR client which bypasses YouTube's PO token requirement.
/// Falls back to the safari client if androidVR fails.
class StreamResolver {
  static final StreamResolver _instance = StreamResolver._internal();
  factory StreamResolver() => _instance;
  StreamResolver._internal();

  final YoutubeExplode _yt = YoutubeExplode();

  Future<Result<String>> resolve(String videoId) async {
    try {
      final manifest = await _yt.videos.streamsClient.getManifest(
        videoId,
        ytClients: [
          YoutubeApiClient.androidVr,  // Primary: bypasses PO token requirement
          YoutubeApiClient.safari,     // Secondary: different client type
        ],
      );
      final audioStreams = manifest.audioOnly;
      if (audioStreams.isNotEmpty) {
        final url = audioStreams.withHighestBitrate().url.toString();
        return Right(url);
      }
      return Left(Failure('No audio stream found for video: $videoId'));
    } catch (e) {
      return Left(Failure('Failed to resolve stream URL', exception: e));
    }
  }

  void dispose() => _yt.close();
}
