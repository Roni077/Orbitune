import 'package:freezed_annotation/freezed_annotation.dart';
import 'track.dart';
import 'online_item.dart';

part 'artist_profile.freezed.dart';

@freezed
abstract class ArtistProfile with _$ArtistProfile {
  const factory ArtistProfile({
    required String id,
    required String name,
    String? artworkUrl,
    String? subscribers,
    String? shuffleId,
    String? radioId,
    @Default([]) List<Track> topSongs,
    @Default([]) List<OnlineItem> albums,
    @Default([]) List<OnlineItem> singles,
    @Default([]) List<OnlineItem> relatedArtists,
  }) = _ArtistProfile;
}
