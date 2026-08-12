// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'track.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Track {

 String get id; String get title; String get artist; String get album; int get durationMs; TrackSource get source; String get dataUrl;// file path or network url
 String? get artworkUrl; String? get genre; int? get year; int get playCount; int get skipCount; DateTime? get dateAdded; DateTime? get lastPlayed;
/// Create a copy of Track
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrackCopyWith<Track> get copyWith => _$TrackCopyWithImpl<Track>(this as Track, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Track&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.album, album) || other.album == album)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.source, source) || other.source == source)&&(identical(other.dataUrl, dataUrl) || other.dataUrl == dataUrl)&&(identical(other.artworkUrl, artworkUrl) || other.artworkUrl == artworkUrl)&&(identical(other.genre, genre) || other.genre == genre)&&(identical(other.year, year) || other.year == year)&&(identical(other.playCount, playCount) || other.playCount == playCount)&&(identical(other.skipCount, skipCount) || other.skipCount == skipCount)&&(identical(other.dateAdded, dateAdded) || other.dateAdded == dateAdded)&&(identical(other.lastPlayed, lastPlayed) || other.lastPlayed == lastPlayed));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,artist,album,durationMs,source,dataUrl,artworkUrl,genre,year,playCount,skipCount,dateAdded,lastPlayed);

@override
String toString() {
  return 'Track(id: $id, title: $title, artist: $artist, album: $album, durationMs: $durationMs, source: $source, dataUrl: $dataUrl, artworkUrl: $artworkUrl, genre: $genre, year: $year, playCount: $playCount, skipCount: $skipCount, dateAdded: $dateAdded, lastPlayed: $lastPlayed)';
}


}

/// @nodoc
abstract mixin class $TrackCopyWith<$Res>  {
  factory $TrackCopyWith(Track value, $Res Function(Track) _then) = _$TrackCopyWithImpl;
@useResult
$Res call({
 String id, String title, String artist, String album, int durationMs, TrackSource source, String dataUrl, String? artworkUrl, String? genre, int? year, int playCount, int skipCount, DateTime? dateAdded, DateTime? lastPlayed
});




}
/// @nodoc
class _$TrackCopyWithImpl<$Res>
    implements $TrackCopyWith<$Res> {
  _$TrackCopyWithImpl(this._self, this._then);

  final Track _self;
  final $Res Function(Track) _then;

/// Create a copy of Track
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? artist = null,Object? album = null,Object? durationMs = null,Object? source = null,Object? dataUrl = null,Object? artworkUrl = freezed,Object? genre = freezed,Object? year = freezed,Object? playCount = null,Object? skipCount = null,Object? dateAdded = freezed,Object? lastPlayed = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String,album: null == album ? _self.album : album // ignore: cast_nullable_to_non_nullable
as String,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as TrackSource,dataUrl: null == dataUrl ? _self.dataUrl : dataUrl // ignore: cast_nullable_to_non_nullable
as String,artworkUrl: freezed == artworkUrl ? _self.artworkUrl : artworkUrl // ignore: cast_nullable_to_non_nullable
as String?,genre: freezed == genre ? _self.genre : genre // ignore: cast_nullable_to_non_nullable
as String?,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,playCount: null == playCount ? _self.playCount : playCount // ignore: cast_nullable_to_non_nullable
as int,skipCount: null == skipCount ? _self.skipCount : skipCount // ignore: cast_nullable_to_non_nullable
as int,dateAdded: freezed == dateAdded ? _self.dateAdded : dateAdded // ignore: cast_nullable_to_non_nullable
as DateTime?,lastPlayed: freezed == lastPlayed ? _self.lastPlayed : lastPlayed // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Track].
extension TrackPatterns on Track {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Track value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Track() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Track value)  $default,){
final _that = this;
switch (_that) {
case _Track():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Track value)?  $default,){
final _that = this;
switch (_that) {
case _Track() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String artist,  String album,  int durationMs,  TrackSource source,  String dataUrl,  String? artworkUrl,  String? genre,  int? year,  int playCount,  int skipCount,  DateTime? dateAdded,  DateTime? lastPlayed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Track() when $default != null:
return $default(_that.id,_that.title,_that.artist,_that.album,_that.durationMs,_that.source,_that.dataUrl,_that.artworkUrl,_that.genre,_that.year,_that.playCount,_that.skipCount,_that.dateAdded,_that.lastPlayed);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String artist,  String album,  int durationMs,  TrackSource source,  String dataUrl,  String? artworkUrl,  String? genre,  int? year,  int playCount,  int skipCount,  DateTime? dateAdded,  DateTime? lastPlayed)  $default,) {final _that = this;
switch (_that) {
case _Track():
return $default(_that.id,_that.title,_that.artist,_that.album,_that.durationMs,_that.source,_that.dataUrl,_that.artworkUrl,_that.genre,_that.year,_that.playCount,_that.skipCount,_that.dateAdded,_that.lastPlayed);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String artist,  String album,  int durationMs,  TrackSource source,  String dataUrl,  String? artworkUrl,  String? genre,  int? year,  int playCount,  int skipCount,  DateTime? dateAdded,  DateTime? lastPlayed)?  $default,) {final _that = this;
switch (_that) {
case _Track() when $default != null:
return $default(_that.id,_that.title,_that.artist,_that.album,_that.durationMs,_that.source,_that.dataUrl,_that.artworkUrl,_that.genre,_that.year,_that.playCount,_that.skipCount,_that.dateAdded,_that.lastPlayed);case _:
  return null;

}
}

}

/// @nodoc


class _Track implements Track {
  const _Track({required this.id, required this.title, required this.artist, required this.album, required this.durationMs, required this.source, required this.dataUrl, this.artworkUrl, this.genre, this.year, this.playCount = 0, this.skipCount = 0, this.dateAdded, this.lastPlayed});
  

@override final  String id;
@override final  String title;
@override final  String artist;
@override final  String album;
@override final  int durationMs;
@override final  TrackSource source;
@override final  String dataUrl;
// file path or network url
@override final  String? artworkUrl;
@override final  String? genre;
@override final  int? year;
@override@JsonKey() final  int playCount;
@override@JsonKey() final  int skipCount;
@override final  DateTime? dateAdded;
@override final  DateTime? lastPlayed;

/// Create a copy of Track
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrackCopyWith<_Track> get copyWith => __$TrackCopyWithImpl<_Track>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Track&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.artist, artist) || other.artist == artist)&&(identical(other.album, album) || other.album == album)&&(identical(other.durationMs, durationMs) || other.durationMs == durationMs)&&(identical(other.source, source) || other.source == source)&&(identical(other.dataUrl, dataUrl) || other.dataUrl == dataUrl)&&(identical(other.artworkUrl, artworkUrl) || other.artworkUrl == artworkUrl)&&(identical(other.genre, genre) || other.genre == genre)&&(identical(other.year, year) || other.year == year)&&(identical(other.playCount, playCount) || other.playCount == playCount)&&(identical(other.skipCount, skipCount) || other.skipCount == skipCount)&&(identical(other.dateAdded, dateAdded) || other.dateAdded == dateAdded)&&(identical(other.lastPlayed, lastPlayed) || other.lastPlayed == lastPlayed));
}


@override
int get hashCode => Object.hash(runtimeType,id,title,artist,album,durationMs,source,dataUrl,artworkUrl,genre,year,playCount,skipCount,dateAdded,lastPlayed);

@override
String toString() {
  return 'Track(id: $id, title: $title, artist: $artist, album: $album, durationMs: $durationMs, source: $source, dataUrl: $dataUrl, artworkUrl: $artworkUrl, genre: $genre, year: $year, playCount: $playCount, skipCount: $skipCount, dateAdded: $dateAdded, lastPlayed: $lastPlayed)';
}


}

/// @nodoc
abstract mixin class _$TrackCopyWith<$Res> implements $TrackCopyWith<$Res> {
  factory _$TrackCopyWith(_Track value, $Res Function(_Track) _then) = __$TrackCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String artist, String album, int durationMs, TrackSource source, String dataUrl, String? artworkUrl, String? genre, int? year, int playCount, int skipCount, DateTime? dateAdded, DateTime? lastPlayed
});




}
/// @nodoc
class __$TrackCopyWithImpl<$Res>
    implements _$TrackCopyWith<$Res> {
  __$TrackCopyWithImpl(this._self, this._then);

  final _Track _self;
  final $Res Function(_Track) _then;

/// Create a copy of Track
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? artist = null,Object? album = null,Object? durationMs = null,Object? source = null,Object? dataUrl = null,Object? artworkUrl = freezed,Object? genre = freezed,Object? year = freezed,Object? playCount = null,Object? skipCount = null,Object? dateAdded = freezed,Object? lastPlayed = freezed,}) {
  return _then(_Track(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,artist: null == artist ? _self.artist : artist // ignore: cast_nullable_to_non_nullable
as String,album: null == album ? _self.album : album // ignore: cast_nullable_to_non_nullable
as String,durationMs: null == durationMs ? _self.durationMs : durationMs // ignore: cast_nullable_to_non_nullable
as int,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as TrackSource,dataUrl: null == dataUrl ? _self.dataUrl : dataUrl // ignore: cast_nullable_to_non_nullable
as String,artworkUrl: freezed == artworkUrl ? _self.artworkUrl : artworkUrl // ignore: cast_nullable_to_non_nullable
as String?,genre: freezed == genre ? _self.genre : genre // ignore: cast_nullable_to_non_nullable
as String?,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,playCount: null == playCount ? _self.playCount : playCount // ignore: cast_nullable_to_non_nullable
as int,skipCount: null == skipCount ? _self.skipCount : skipCount // ignore: cast_nullable_to_non_nullable
as int,dateAdded: freezed == dateAdded ? _self.dateAdded : dateAdded // ignore: cast_nullable_to_non_nullable
as DateTime?,lastPlayed: freezed == lastPlayed ? _self.lastPlayed : lastPlayed // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
