// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'artist_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ArtistProfile {

 String get id; String get name; String? get artworkUrl; String? get subscribers; String? get shuffleId; String? get radioId; List<Track> get topSongs; List<OnlineItem> get albums; List<OnlineItem> get singles; List<OnlineItem> get relatedArtists;
/// Create a copy of ArtistProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ArtistProfileCopyWith<ArtistProfile> get copyWith => _$ArtistProfileCopyWithImpl<ArtistProfile>(this as ArtistProfile, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ArtistProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.artworkUrl, artworkUrl) || other.artworkUrl == artworkUrl)&&(identical(other.subscribers, subscribers) || other.subscribers == subscribers)&&(identical(other.shuffleId, shuffleId) || other.shuffleId == shuffleId)&&(identical(other.radioId, radioId) || other.radioId == radioId)&&const DeepCollectionEquality().equals(other.topSongs, topSongs)&&const DeepCollectionEquality().equals(other.albums, albums)&&const DeepCollectionEquality().equals(other.singles, singles)&&const DeepCollectionEquality().equals(other.relatedArtists, relatedArtists));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,artworkUrl,subscribers,shuffleId,radioId,const DeepCollectionEquality().hash(topSongs),const DeepCollectionEquality().hash(albums),const DeepCollectionEquality().hash(singles),const DeepCollectionEquality().hash(relatedArtists));

@override
String toString() {
  return 'ArtistProfile(id: $id, name: $name, artworkUrl: $artworkUrl, subscribers: $subscribers, shuffleId: $shuffleId, radioId: $radioId, topSongs: $topSongs, albums: $albums, singles: $singles, relatedArtists: $relatedArtists)';
}


}

/// @nodoc
abstract mixin class $ArtistProfileCopyWith<$Res>  {
  factory $ArtistProfileCopyWith(ArtistProfile value, $Res Function(ArtistProfile) _then) = _$ArtistProfileCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? artworkUrl, String? subscribers, String? shuffleId, String? radioId, List<Track> topSongs, List<OnlineItem> albums, List<OnlineItem> singles, List<OnlineItem> relatedArtists
});




}
/// @nodoc
class _$ArtistProfileCopyWithImpl<$Res>
    implements $ArtistProfileCopyWith<$Res> {
  _$ArtistProfileCopyWithImpl(this._self, this._then);

  final ArtistProfile _self;
  final $Res Function(ArtistProfile) _then;

/// Create a copy of ArtistProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? artworkUrl = freezed,Object? subscribers = freezed,Object? shuffleId = freezed,Object? radioId = freezed,Object? topSongs = null,Object? albums = null,Object? singles = null,Object? relatedArtists = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,artworkUrl: freezed == artworkUrl ? _self.artworkUrl : artworkUrl // ignore: cast_nullable_to_non_nullable
as String?,subscribers: freezed == subscribers ? _self.subscribers : subscribers // ignore: cast_nullable_to_non_nullable
as String?,shuffleId: freezed == shuffleId ? _self.shuffleId : shuffleId // ignore: cast_nullable_to_non_nullable
as String?,radioId: freezed == radioId ? _self.radioId : radioId // ignore: cast_nullable_to_non_nullable
as String?,topSongs: null == topSongs ? _self.topSongs : topSongs // ignore: cast_nullable_to_non_nullable
as List<Track>,albums: null == albums ? _self.albums : albums // ignore: cast_nullable_to_non_nullable
as List<OnlineItem>,singles: null == singles ? _self.singles : singles // ignore: cast_nullable_to_non_nullable
as List<OnlineItem>,relatedArtists: null == relatedArtists ? _self.relatedArtists : relatedArtists // ignore: cast_nullable_to_non_nullable
as List<OnlineItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [ArtistProfile].
extension ArtistProfilePatterns on ArtistProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ArtistProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ArtistProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ArtistProfile value)  $default,){
final _that = this;
switch (_that) {
case _ArtistProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ArtistProfile value)?  $default,){
final _that = this;
switch (_that) {
case _ArtistProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? artworkUrl,  String? subscribers,  String? shuffleId,  String? radioId,  List<Track> topSongs,  List<OnlineItem> albums,  List<OnlineItem> singles,  List<OnlineItem> relatedArtists)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ArtistProfile() when $default != null:
return $default(_that.id,_that.name,_that.artworkUrl,_that.subscribers,_that.shuffleId,_that.radioId,_that.topSongs,_that.albums,_that.singles,_that.relatedArtists);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? artworkUrl,  String? subscribers,  String? shuffleId,  String? radioId,  List<Track> topSongs,  List<OnlineItem> albums,  List<OnlineItem> singles,  List<OnlineItem> relatedArtists)  $default,) {final _that = this;
switch (_that) {
case _ArtistProfile():
return $default(_that.id,_that.name,_that.artworkUrl,_that.subscribers,_that.shuffleId,_that.radioId,_that.topSongs,_that.albums,_that.singles,_that.relatedArtists);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? artworkUrl,  String? subscribers,  String? shuffleId,  String? radioId,  List<Track> topSongs,  List<OnlineItem> albums,  List<OnlineItem> singles,  List<OnlineItem> relatedArtists)?  $default,) {final _that = this;
switch (_that) {
case _ArtistProfile() when $default != null:
return $default(_that.id,_that.name,_that.artworkUrl,_that.subscribers,_that.shuffleId,_that.radioId,_that.topSongs,_that.albums,_that.singles,_that.relatedArtists);case _:
  return null;

}
}

}

/// @nodoc


class _ArtistProfile implements ArtistProfile {
  const _ArtistProfile({required this.id, required this.name, this.artworkUrl, this.subscribers, this.shuffleId, this.radioId, final  List<Track> topSongs = const [], final  List<OnlineItem> albums = const [], final  List<OnlineItem> singles = const [], final  List<OnlineItem> relatedArtists = const []}): _topSongs = topSongs,_albums = albums,_singles = singles,_relatedArtists = relatedArtists;
  

@override final  String id;
@override final  String name;
@override final  String? artworkUrl;
@override final  String? subscribers;
@override final  String? shuffleId;
@override final  String? radioId;
 final  List<Track> _topSongs;
@override@JsonKey() List<Track> get topSongs {
  if (_topSongs is EqualUnmodifiableListView) return _topSongs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_topSongs);
}

 final  List<OnlineItem> _albums;
@override@JsonKey() List<OnlineItem> get albums {
  if (_albums is EqualUnmodifiableListView) return _albums;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_albums);
}

 final  List<OnlineItem> _singles;
@override@JsonKey() List<OnlineItem> get singles {
  if (_singles is EqualUnmodifiableListView) return _singles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_singles);
}

 final  List<OnlineItem> _relatedArtists;
@override@JsonKey() List<OnlineItem> get relatedArtists {
  if (_relatedArtists is EqualUnmodifiableListView) return _relatedArtists;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_relatedArtists);
}


/// Create a copy of ArtistProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ArtistProfileCopyWith<_ArtistProfile> get copyWith => __$ArtistProfileCopyWithImpl<_ArtistProfile>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ArtistProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.artworkUrl, artworkUrl) || other.artworkUrl == artworkUrl)&&(identical(other.subscribers, subscribers) || other.subscribers == subscribers)&&(identical(other.shuffleId, shuffleId) || other.shuffleId == shuffleId)&&(identical(other.radioId, radioId) || other.radioId == radioId)&&const DeepCollectionEquality().equals(other._topSongs, _topSongs)&&const DeepCollectionEquality().equals(other._albums, _albums)&&const DeepCollectionEquality().equals(other._singles, _singles)&&const DeepCollectionEquality().equals(other._relatedArtists, _relatedArtists));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,artworkUrl,subscribers,shuffleId,radioId,const DeepCollectionEquality().hash(_topSongs),const DeepCollectionEquality().hash(_albums),const DeepCollectionEquality().hash(_singles),const DeepCollectionEquality().hash(_relatedArtists));

@override
String toString() {
  return 'ArtistProfile(id: $id, name: $name, artworkUrl: $artworkUrl, subscribers: $subscribers, shuffleId: $shuffleId, radioId: $radioId, topSongs: $topSongs, albums: $albums, singles: $singles, relatedArtists: $relatedArtists)';
}


}

/// @nodoc
abstract mixin class _$ArtistProfileCopyWith<$Res> implements $ArtistProfileCopyWith<$Res> {
  factory _$ArtistProfileCopyWith(_ArtistProfile value, $Res Function(_ArtistProfile) _then) = __$ArtistProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? artworkUrl, String? subscribers, String? shuffleId, String? radioId, List<Track> topSongs, List<OnlineItem> albums, List<OnlineItem> singles, List<OnlineItem> relatedArtists
});




}
/// @nodoc
class __$ArtistProfileCopyWithImpl<$Res>
    implements _$ArtistProfileCopyWith<$Res> {
  __$ArtistProfileCopyWithImpl(this._self, this._then);

  final _ArtistProfile _self;
  final $Res Function(_ArtistProfile) _then;

/// Create a copy of ArtistProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? artworkUrl = freezed,Object? subscribers = freezed,Object? shuffleId = freezed,Object? radioId = freezed,Object? topSongs = null,Object? albums = null,Object? singles = null,Object? relatedArtists = null,}) {
  return _then(_ArtistProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,artworkUrl: freezed == artworkUrl ? _self.artworkUrl : artworkUrl // ignore: cast_nullable_to_non_nullable
as String?,subscribers: freezed == subscribers ? _self.subscribers : subscribers // ignore: cast_nullable_to_non_nullable
as String?,shuffleId: freezed == shuffleId ? _self.shuffleId : shuffleId // ignore: cast_nullable_to_non_nullable
as String?,radioId: freezed == radioId ? _self.radioId : radioId // ignore: cast_nullable_to_non_nullable
as String?,topSongs: null == topSongs ? _self._topSongs : topSongs // ignore: cast_nullable_to_non_nullable
as List<Track>,albums: null == albums ? _self._albums : albums // ignore: cast_nullable_to_non_nullable
as List<OnlineItem>,singles: null == singles ? _self._singles : singles // ignore: cast_nullable_to_non_nullable
as List<OnlineItem>,relatedArtists: null == relatedArtists ? _self._relatedArtists : relatedArtists // ignore: cast_nullable_to_non_nullable
as List<OnlineItem>,
  ));
}


}

// dart format on
