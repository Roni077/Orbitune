import 'package:fpdart/fpdart.dart';
import 'package:ytmusicapi_dart/ytmusicapi_dart.dart';
import 'package:ytmusicapi_dart/enums.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/helpers/result_type.dart';
import '../../../../domain/entities/track.dart';
import '../../../../domain/entities/online_item.dart';
import '../../../../domain/entities/artist_profile.dart';
import '../../../../core/helpers/sanitizer.dart';
import '../audio/stream_resolver.dart';

abstract class OnlineAudioService {
  Future<Result<List<Track>>> searchSongs(String query, {int page = 1});
  Future<Result<List<OnlineItem>>> searchAlbums(String query, {int page = 1});
  Future<Result<List<OnlineItem>>> searchArtists(String query, {int page = 1});
  Future<Result<List<OnlineItem>>> searchPlaylists(String query, {int page = 1});
  
  Future<Result<List<String>>> getSearchSuggestions(String query);
  Future<Result<List<Track>>> getTrendingSongs();
  Future<Result<List<Track>>> getNewReleases();
  Future<Result<List<Track>>> getCharts();
  
  Future<Result<List<Track>>> getAlbumTracks(String albumId);
  Future<Result<List<Track>>> getArtistTracks(String artistId);
  Future<Result<List<Track>>> getPlaylistTracks(String playlistId);
  
  Future<Result<List<OnlineItem>>> getGenresAndMoods();
  Future<Result<List<OnlineItem>>> getMoodPlaylists(String params);
  Future<Result<String>> getLyrics(String trackId);
  Future<Result<String>> resolveStreamUrl(String trackId);
  Future<Result<List<Track>>> getRelatedTracks(String trackId);
  Future<Result<ArtistProfile>> getArtistProfile(String artistId);
}

class YoutubeAudioService implements OnlineAudioService {
  final _streamResolver = StreamResolver();
  YTMusic? _ytMusic;
  bool _ytMusicInitialized = false;

  Future<void> _initYTMusic() async {
    if (!_ytMusicInitialized) {
      try {
        _ytMusic = await YTMusic.create();
        _ytMusicInitialized = true;
      } catch (e) {
        // Silently fail, we will fallback to youtube_explode
      }
    }
  }

  @override
  Future<Result<List<Track>>> searchSongs(String query, {int page = 1}) async {
    await _initYTMusic();

    try {
      if (_ytMusic != null) {
        // Try ytmusicapi first
        final results = await _ytMusic!.search(query, filter: SearchFilterType.songs, limit: page * 20);
        final tracks = results.skip((page - 1) * 20).map((json) {
          final artists = json['artists'] as List<dynamic>? ?? [];
          final artistName = artists.isNotEmpty ? artists.first['name'] as String : 'Unknown Artist';
          
          final thumbnails = json['thumbnails'] as List<dynamic>? ?? [];
          String? artworkUrl;
          if (thumbnails.isNotEmpty) {
            artworkUrl = thumbnails.last['url'] as String;
            if (artworkUrl.contains('w120-h120')) {
              artworkUrl = artworkUrl.replaceAll('w120-h120', 'w500-h500');
            }
          }
          
          final durationStr = json['duration'] as String?;
          int durationMs = 0;
          if (durationStr != null) {
            final parts = durationStr.split(':');
            if (parts.length == 2) {
              durationMs = (int.parse(parts[0]) * 60 + int.parse(parts[1])) * 1000;
            }
          }

          return Track(
            id: json['videoId'] as String? ?? '',
            title: Sanitizer.sanitizeMetadata(json['title'] as String? ?? 'Unknown Title'),
            artist: Sanitizer.sanitizeMetadata(artistName),
            album: Sanitizer.sanitizeMetadata(json['album'] != null ? json['album']['name'] as String? ?? 'Single' : 'Single'),
            durationMs: durationMs,
            source: TrackSource.online,
            dataUrl: 'yt:${json['videoId']}',
            artworkUrl: artworkUrl,
            year: DateTime.now().year,
          );
        }).where((t) => t.id.isNotEmpty).toList();
        
        return Right(tracks);
      }
    } catch (e) {
      return Left(Failure('Failed to search songs', exception: e));
    }
    return Left(Failure('Failed to search songs, YTMusic not initialized'));
  }

  @override
  Future<Result<List<String>>> getSearchSuggestions(String query) async {
    await _initYTMusic();
    try {
      if (_ytMusic != null) {
        final suggestions = await _ytMusic!.getSearchSuggestions(query);
        final results = suggestions.map((s) => s.toString()).toList();
        return Right(results);
      }
      return Left(Failure('YTMusic not initialized'));
    } catch (e) {
      return Left(Failure('Failed to fetch search suggestions', exception: e));
    }
  }

  @override
  Future<Result<List<Track>>> getTrendingSongs() async {
    try {
      return await searchSongs('Global Top Songs');
    } catch (e) {
      return Left(Failure('Failed to fetch trending songs', exception: e));
    }
  }

  @override
  Future<Result<List<Track>>> getNewReleases() async {
    try {
      return await searchSongs('New Music Releases');
    } catch (e) {
      return Left(Failure('Failed to fetch new releases', exception: e));
    }
  }

  @override
  Future<Result<List<Track>>> getCharts() async {
    try {
      return await searchSongs('Top 50 Charts');
    } catch (e) {
      return Left(Failure('Failed to fetch charts', exception: e));
    }
  }

  @override
  Future<Result<String>> resolveStreamUrl(String trackId) async {
    // Strip 'yt:' prefix if present
    final videoId = trackId.startsWith('yt:') ? trackId.substring(3) : trackId;
    return _streamResolver.resolve(videoId);
  }

  @override
  Future<Result<String>> getLyrics(String trackId) async {
    await _initYTMusic();
    try {
      if (_ytMusic != null) {
        final res = await _ytMusic!.getWatchPlaylist(videoId: trackId);
        if (res.containsKey('lyrics') && res['lyrics'] != null) {
          final browseId = res['lyrics'] as String;
          final lyricsRes = await _ytMusic!.getLyrics(browseId);
          if (lyricsRes != null && lyricsRes.containsKey('lyrics')) {
            return Right(lyricsRes['lyrics'] as String);
          }
        }
      }
      return Left(Failure('Lyrics not available online yet.\nTry downloading the track for offline use!'));
    } catch (e) {
      return Left(Failure('Failed to fetch lyrics', exception: e));
    }
  }

  String? _getHighRes(List<dynamic> thumbnails) {
    if (thumbnails.isEmpty) return null;
    var url = thumbnails.last['url'] as String;
    if (url.contains('w120-h120')) {
      url = url.replaceAll('w120-h120', 'w500-h500');
    }
    return url;
  }

  int _parseDuration(String? durationStr) {
    if (durationStr == null) return 0;
    final parts = durationStr.split(':');
    if (parts.length == 2) {
      return (int.parse(parts[0]) * 60 + int.parse(parts[1])) * 1000;
    } else if (parts.length == 3) {
      return (int.parse(parts[0]) * 3600 + int.parse(parts[1]) * 60 + int.parse(parts[2])) * 1000;
    }
    return 0;
  }

  @override
  Future<Result<List<Track>>> getRelatedTracks(String trackId) async {
    await _initYTMusic();
    try {
      if (_ytMusic != null) {
        final res = await _ytMusic!.getWatchPlaylist(videoId: trackId);
        if (res.containsKey('tracks')) {
          final tracksList = res['tracks'] as List<dynamic>;
          // Skip the first track since it's the current track
          final tracks = tracksList.skip(1).map((json) {
            final artists = json['artists'] as List<dynamic>? ?? [];
            final artistName = artists.isNotEmpty ? artists.first['name'] as String : 'Unknown Artist';
            
            final thumbnails = json['thumbnails'] as List<dynamic>? ?? [];
            String? artworkUrl = _getHighRes(thumbnails);
            
            final durationStr = json['length'] as String?; // usually 'length' in watch playlist
            int durationMs = _parseDuration(durationStr);

            return Track(
              id: json['videoId'] as String? ?? '',
              title: json['title'] as String? ?? 'Unknown Title',
              artist: artistName,
              album: json['album'] != null ? json['album']['name'] as String? ?? 'Single' : 'Single',
              durationMs: durationMs,
              source: TrackSource.online,
              dataUrl: 'yt:${json['videoId']}',
              artworkUrl: artworkUrl,
              year: DateTime.now().year,
            );
          }).where((t) => t.id.isNotEmpty).toList();
          return Right(tracks);
        }
      }
      return Left(Failure('No related tracks found'));
    } catch (e) {
      return Left(Failure('Failed to fetch related tracks', exception: e));
    }
  }

  @override
  Future<Result<List<OnlineItem>>> searchAlbums(String query, {int page = 1}) async {
    await _initYTMusic();
    try {
      if (_ytMusic != null) {
        final results = await _ytMusic!.search(query, filter: SearchFilterType.albums, limit: page * 20);
        final items = results.skip((page - 1) * 20).map((json) {
          final title = json['title'] as String? ?? 'Unknown Album';
          final artists = json['artists'] as List<dynamic>? ?? [];
          final subtitle = artists.isNotEmpty ? artists.first['name'] as String : null;
          final id = json['browseId'] as String? ?? '';
          return OnlineItem(
            id: id,
            title: title,
            subtitle: subtitle,
            artworkUrl: _getHighRes(json['thumbnails'] as List<dynamic>? ?? []),
            type: OnlineItemType.album,
          );
        }).where((i) => i.id.isNotEmpty).toList();
        return Right(items);
      }
      return Left(Failure('YTMusic not initialized'));
    } catch (e) {
      return Left(Failure('Failed to search albums', exception: e));
    }
  }

  @override
  Future<Result<List<OnlineItem>>> searchArtists(String query, {int page = 1}) async {
    await _initYTMusic();
    try {
      if (_ytMusic != null) {
        final results = await _ytMusic!.search(query, filter: SearchFilterType.artists, limit: page * 20);
        final items = results.skip((page - 1) * 20).map((json) {
          final title = json['artist'] as String? ?? 'Unknown Artist';
          final id = json['browseId'] as String? ?? '';
          return OnlineItem(
            id: id,
            title: title,
            subtitle: 'Artist',
            artworkUrl: _getHighRes(json['thumbnails'] as List<dynamic>? ?? []),
            type: OnlineItemType.artist,
          );
        }).where((i) => i.id.isNotEmpty).toList();
        return Right(items);
      }
      return Left(Failure('YTMusic not initialized'));
    } catch (e) {
      return Left(Failure('Failed to search artists', exception: e));
    }
  }

  @override
  Future<Result<List<OnlineItem>>> searchPlaylists(String query, {int page = 1}) async {
    await _initYTMusic();
    try {
      if (_ytMusic != null) {
        final results = await _ytMusic!.search(query, filter: SearchFilterType.playlists, limit: page * 20);
        final items = results.skip((page - 1) * 20).map((json) {
          final title = json['title'] as String? ?? 'Unknown Playlist';
          final author = json['author'] as String?;
          final id = json['browseId'] as String? ?? '';
          return OnlineItem(
            id: id,
            title: title,
            subtitle: author,
            artworkUrl: _getHighRes(json['thumbnails'] as List<dynamic>? ?? []),
            type: OnlineItemType.playlist,
          );
        }).where((i) => i.id.isNotEmpty).toList();
        return Right(items);
      }
      return Left(Failure('YTMusic not initialized'));
    } catch (e) {
      return Left(Failure('Failed to search playlists', exception: e));
    }
  }

  @override
  Future<Result<List<Track>>> getAlbumTracks(String albumId) async {
    await _initYTMusic();
    try {
      if (_ytMusic != null) {
        final album = await _ytMusic!.getAlbum(albumId);
        final albumTitle = album['title'] as String? ?? 'Album';
        final albumArtists = album['artists'] as List<dynamic>? ?? [];
        final defaultArtist = albumArtists.isNotEmpty ? albumArtists.first['name'] as String : 'Unknown Artist';
        final thumbnails = album['thumbnails'] as List<dynamic>? ?? [];
        final artworkUrl = _getHighRes(thumbnails);
        final year = album['year'] is String ? int.tryParse(album['year']) : null;
        
        final tracks = (album['tracks'] as List<dynamic>? ?? []).map((json) {
          final title = json['title'] as String? ?? 'Unknown Track';
          final videoId = json['videoId'] as String? ?? '';
          return Track(
            id: videoId,
            title: title,
            artist: defaultArtist,
            album: albumTitle,
            durationMs: _parseDuration(json['duration'] as String?),
            source: TrackSource.online,
            dataUrl: 'yt:$videoId',
            artworkUrl: artworkUrl,
            year: year ?? DateTime.now().year,
          );
        }).where((t) => t.id.isNotEmpty).toList();
        return Right(tracks);
      }
      return Left(Failure('YTMusic not initialized'));
    } catch (e) {
      return Left(Failure('Failed to get album tracks', exception: e));
    }
  }

  @override
  Future<Result<List<Track>>> getArtistTracks(String artistId) async {
    await _initYTMusic();
    try {
      if (_ytMusic != null) {
        final artist = await _ytMusic!.getArtist(artistId);
        final songsInfo = artist['songs'] as Map<dynamic, dynamic>?;
        final results = songsInfo != null ? (songsInfo['results'] as List<dynamic>? ?? []) : [];
        final defaultArtist = artist['name'] as String? ?? 'Unknown Artist';
        final defaultArtwork = _getHighRes(artist['thumbnails'] as List<dynamic>? ?? []);
        
        final tracks = results.map((json) {
          final title = json['title'] as String? ?? 'Unknown Track';
          final videoId = json['videoId'] as String? ?? '';
          final albumName = json['album'] != null ? (json['album']['name'] as String? ?? 'Single') : 'Single';
          return Track(
            id: videoId,
            title: title,
            artist: defaultArtist,
            album: albumName,
            durationMs: 0,
            source: TrackSource.online,
            dataUrl: 'yt:$videoId',
            artworkUrl: _getHighRes(json['thumbnails'] as List<dynamic>? ?? []) ?? defaultArtwork,
            year: DateTime.now().year,
          );
        }).where((t) => t.id.isNotEmpty).toList();
        return Right(tracks);
      }
      return Left(Failure('YTMusic not initialized'));
    } catch (e) {
      return Left(Failure('Failed to get artist tracks', exception: e));
    }
  }

  @override
  Future<Result<ArtistProfile>> getArtistProfile(String artistId) async {
    await _initYTMusic();
    try {
      if (_ytMusic != null) {
        final artist = await _ytMusic!.getArtist(artistId);
        
        final defaultArtist = artist['name'] as String? ?? 'Unknown Artist';
        final defaultArtwork = _getHighRes(artist['thumbnails'] as List<dynamic>? ?? []);
        
        // Songs
        final songsInfo = artist['songs'] as Map<dynamic, dynamic>?;
        final songResults = songsInfo != null ? (songsInfo['results'] as List<dynamic>? ?? []) : [];
        final topSongs = songResults.map((json) {
          final title = json['title'] as String? ?? 'Unknown Track';
          final videoId = json['videoId'] as String? ?? '';
          final albumName = json['album'] != null ? (json['album']['name'] as String? ?? 'Single') : 'Single';
          return Track(
            id: videoId,
            title: title,
            artist: defaultArtist,
            album: albumName,
            durationMs: 0,
            source: TrackSource.online,
            dataUrl: 'yt:$videoId',
            artworkUrl: _getHighRes(json['thumbnails'] as List<dynamic>? ?? []) ?? defaultArtwork,
            year: DateTime.now().year,
          );
        }).where((t) => t.id.isNotEmpty).toList();

        // Albums
        final albumsInfo = artist['albums'] as Map<dynamic, dynamic>?;
        final albumResults = albumsInfo != null ? (albumsInfo['results'] as List<dynamic>? ?? []) : [];
        final albums = albumResults.map((json) {
          return OnlineItem(
            id: json['browseId'] as String? ?? '',
            title: json['title'] as String? ?? 'Unknown Album',
            subtitle: json['year'] as String?,
            artworkUrl: _getHighRes(json['thumbnails'] as List<dynamic>? ?? []),
            type: OnlineItemType.album,
          );
        }).where((i) => i.id.isNotEmpty).toList();

        // Singles
        final singlesInfo = artist['singles'] as Map<dynamic, dynamic>?;
        final singleResults = singlesInfo != null ? (singlesInfo['results'] as List<dynamic>? ?? []) : [];
        final singles = singleResults.map((json) {
          return OnlineItem(
            id: json['browseId'] as String? ?? '',
            title: json['title'] as String? ?? 'Unknown Single',
            subtitle: json['year'] as String?,
            artworkUrl: _getHighRes(json['thumbnails'] as List<dynamic>? ?? []),
            type: OnlineItemType.album,
          );
        }).where((i) => i.id.isNotEmpty).toList();

        // Related
        final relatedInfo = artist['related'] as Map<dynamic, dynamic>?;
        final relatedResults = relatedInfo != null ? (relatedInfo['results'] as List<dynamic>? ?? []) : [];
        final relatedArtists = relatedResults.map((json) {
          return OnlineItem(
            id: json['browseId'] as String? ?? '',
            title: json['title'] as String? ?? 'Unknown Artist',
            subtitle: 'Artist',
            artworkUrl: _getHighRes(json['thumbnails'] as List<dynamic>? ?? []),
            type: OnlineItemType.artist,
          );
        }).where((i) => i.id.isNotEmpty).toList();

        final profile = ArtistProfile(
          id: artistId,
          name: defaultArtist,
          artworkUrl: defaultArtwork,
          subscribers: artist['subscribers'] as String?,
          shuffleId: artist['shuffleId'] as String?,
          radioId: artist['radioId'] as String?,
          topSongs: topSongs,
          albums: albums,
          singles: singles,
          relatedArtists: relatedArtists,
        );
        return Right(profile);
      }
      return Left(Failure('YTMusic not initialized'));
    } catch (e) {
      return Left(Failure('Failed to fetch artist profile', exception: e));
    }
  }


  @override
  Future<Result<List<Track>>> getPlaylistTracks(String playlistId) async {
    await _initYTMusic();
    try {
      if (_ytMusic != null) {
        final playlist = await _ytMusic!.getPlaylist(playlistId);
        final defaultArtwork = _getHighRes(playlist['thumbnails'] as List<dynamic>? ?? []);
        final tracks = (playlist['tracks'] as List<dynamic>? ?? []).map((json) {
          final title = json['title'] as String? ?? 'Unknown Track';
          final videoId = json['videoId'] as String? ?? '';
          final artists = json['artists'] as List<dynamic>? ?? [];
          final artistName = artists.isNotEmpty ? artists.first['name'] as String : 'Unknown Artist';
          final albumName = json['album'] != null ? (json['album']['name'] as String? ?? 'Single') : 'Single';
          return Track(
            id: videoId,
            title: title,
            artist: artistName,
            album: albumName,
            durationMs: _parseDuration(json['duration'] as String?),
            source: TrackSource.online,
            dataUrl: 'yt:$videoId',
            artworkUrl: _getHighRes(json['thumbnails'] as List<dynamic>? ?? []) ?? defaultArtwork,
            year: DateTime.now().year,
          );
        }).where((t) => t.id.isNotEmpty).toList();
        return Right(tracks);
      }
      return Left(Failure('YTMusic not initialized'));
    } catch (e) {
      return Left(Failure('Failed to get playlist tracks', exception: e));
    }
  }

  @override
  Future<Result<List<OnlineItem>>> getGenresAndMoods() async {
    await _initYTMusic();
    try {
      if (_ytMusic != null) {
        final res = await _ytMusic!.getMoodCategories();
        final List<OnlineItem> items = [];
        res.forEach((key, categoryList) {
          for (var item in (categoryList as List<dynamic>)) {
            items.add(OnlineItem(
              id: item['params'] as String,
              title: item['title'] as String,
              subtitle: key,
              type: OnlineItemType.genre,
            ));
          }
        });
        return Right(items);
      }
      return Left(Failure('YTMusic not initialized'));
    } catch (e) {
      return Left(Failure('Failed to fetch genres/moods', exception: e));
    }
  }

  @override
  Future<Result<List<OnlineItem>>> getMoodPlaylists(String params) async {
    await _initYTMusic();
    try {
      if (_ytMusic != null) {
        final res = await _ytMusic!.getMoodPlaylists(params);
        final items = (res).map((json) {
          return OnlineItem(
            id: json['playlistId'] as String? ?? '',
            title: json['title'] as String? ?? 'Playlist',
            subtitle: json['description'] as String?,
            artworkUrl: _getHighRes(json['thumbnails'] as List<dynamic>? ?? []),
            type: OnlineItemType.playlist,
          );
        }).where((i) => i.id.isNotEmpty).toList();
        return Right(items);
      }
      return Left(Failure('YTMusic not initialized'));
    } catch (e) {
      return Left(Failure('Failed to fetch mood playlists', exception: e));
    }
  }

}
