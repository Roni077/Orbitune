import 'package:freezed_annotation/freezed_annotation.dart';

part 'track.freezed.dart';

enum TrackSource { local, online, cached }

@freezed
abstract class Track with _$Track {
  const factory Track({
    required String id,
    required String title,
    required String artist,
    required String album,
    required int durationMs,
    required TrackSource source,
    required String dataUrl, // file path or network url
    String? artworkUrl,
    String? genre,
    int? year,
    @Default(0) int playCount,
    @Default(0) int skipCount,
    DateTime? dateAdded,
    DateTime? lastPlayed,
  }) = _Track;
}
