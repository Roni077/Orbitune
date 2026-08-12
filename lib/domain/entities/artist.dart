import 'package:freezed_annotation/freezed_annotation.dart';

part 'artist.freezed.dart';

@freezed
abstract class Artist with _$Artist {
  const factory Artist({
    required String id,
    required String name,
    String? imageUrl,
    @Default(0) int albumCount,
    @Default(0) int trackCount,
  }) = _Artist;
}
