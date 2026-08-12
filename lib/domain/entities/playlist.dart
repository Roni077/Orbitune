import 'package:freezed_annotation/freezed_annotation.dart';

part 'playlist.freezed.dart';

@freezed
abstract class Playlist with _$Playlist {
  const factory Playlist({
    required String id,
    required String name,
    @Default([]) List<String> trackIds,
    String? coverUrl,
    @Default(false) bool isFavoritePlaylist,
    DateTime? createdAt,
  }) = _Playlist;
}
