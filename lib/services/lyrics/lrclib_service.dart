import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fpdart/fpdart.dart';
import '../../core/helpers/result_type.dart';
import '../../core/errors/failure.dart';

class LrcLibService {
  static const _baseUrl = 'https://lrclib.net/api';

  Future<Result<Map<String, String?>>> getLyrics(String trackName, String artistName, int durationMs) async {
    try {
      // 1. Try precise match using /get
      final uri = Uri.parse('$_baseUrl/get').replace(queryParameters: {
        'track_name': trackName,
        'artist_name': artistName,
        'duration': (durationMs / 1000).round().toString(),
      });

      var response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && (data['syncedLyrics'] != null || data['plainLyrics'] != null)) {
          return Right({
            'syncedLyrics': data['syncedLyrics'] as String?,
            'plainLyrics': data['plainLyrics'] as String?,
          });
        }
      }

      // 2. Fallback to /search if precise match fails
      final searchUri = Uri.parse('$_baseUrl/search').replace(queryParameters: {
        'q': '$trackName $artistName',
      });
      response = await http.get(searchUri);

      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        for (var result in results) {
          // Find the first result that has synced lyrics
          if (result['syncedLyrics'] != null) {
            return Right({
              'syncedLyrics': result['syncedLyrics'] as String?,
              'plainLyrics': result['plainLyrics'] as String?,
            });
          }
        }
        // If no synced lyrics, return plain lyrics if available
        if (results.isNotEmpty && results[0]['plainLyrics'] != null) {
          return Right({
            'syncedLyrics': null,
            'plainLyrics': results[0]['plainLyrics'] as String?,
          });
        }
      }

      return Left(Failure('Lyrics not found on LRCLIB'));
    } catch (e) {
      return Left(Failure('Network error fetching lyrics from LRCLIB', exception: e));
    }
  }
}
