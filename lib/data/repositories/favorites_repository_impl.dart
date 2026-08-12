import 'package:fpdart/fpdart.dart';
import 'package:drift/drift.dart' as drift;
import '../../core/helpers/result_type.dart';
import '../../core/errors/failure.dart';
import '../../domain/entities/album.dart';
import '../../domain/entities/artist.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/local/app_database.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final AppDatabase _db;

  FavoritesRepositoryImpl(this._db);

  @override
  Future<Result<List<Album>>> getFavoriteAlbums() async {
    try {
      final query = _db.select(_db.favoriteAlbums)
        ..orderBy([(a) => drift.OrderingTerm(expression: a.favoritedAt, mode: drift.OrderingMode.desc)]);
      final records = await query.get();
      final albums = records.map((a) => Album(
        id: a.id,
        name: a.name,
        artist: a.artist,
        artworkUrl: a.artworkUrl,
      )).toList();
      return Right(albums);
    } catch (e) {
      return Left(Failure('Failed to fetch favorite albums', exception: e));
    }
  }

  @override
  Future<Result<Unit>> addFavoriteAlbum(Album album) async {
    try {
      await _db.into(_db.favoriteAlbums).insertOnConflictUpdate(
        FavoriteAlbumEntity(
          id: album.id,
          name: album.name,
          artist: album.artist,
          artworkUrl: album.artworkUrl,
          favoritedAt: DateTime.now(),
        ),
      );
      return const Right(unit);
    } catch (e) {
      return Left(Failure('Failed to add favorite album', exception: e));
    }
  }

  @override
  Future<Result<Unit>> removeFavoriteAlbum(String albumId) async {
    try {
      await (_db.delete(_db.favoriteAlbums)..where((a) => a.id.equals(albumId))).go();
      return const Right(unit);
    } catch (e) {
      return Left(Failure('Failed to remove favorite album', exception: e));
    }
  }

  @override
  Future<Result<bool>> isAlbumFavorite(String albumId) async {
    try {
      final count = await (_db.select(_db.favoriteAlbums)..where((a) => a.id.equals(albumId))).get();
      return Right(count.isNotEmpty);
    } catch (e) {
      return Left(Failure('Failed to check if album is favorite', exception: e));
    }
  }

  @override
  Future<Result<List<Artist>>> getFavoriteArtists() async {
    try {
      final query = _db.select(_db.favoriteArtists)
        ..orderBy([(a) => drift.OrderingTerm(expression: a.favoritedAt, mode: drift.OrderingMode.desc)]);
      final records = await query.get();
      final artists = records.map((a) => Artist(
        id: a.id,
        name: a.name,
        imageUrl: a.imageUrl,
      )).toList();
      return Right(artists);
    } catch (e) {
      return Left(Failure('Failed to fetch favorite artists', exception: e));
    }
  }

  @override
  Future<Result<Unit>> addFavoriteArtist(Artist artist) async {
    try {
      await _db.into(_db.favoriteArtists).insertOnConflictUpdate(
        FavoriteArtistEntity(
          id: artist.id,
          name: artist.name,
          imageUrl: artist.imageUrl,
          favoritedAt: DateTime.now(),
        ),
      );
      return const Right(unit);
    } catch (e) {
      return Left(Failure('Failed to add favorite artist', exception: e));
    }
  }

  @override
  Future<Result<Unit>> removeFavoriteArtist(String artistId) async {
    try {
      await (_db.delete(_db.favoriteArtists)..where((a) => a.id.equals(artistId))).go();
      return const Right(unit);
    } catch (e) {
      return Left(Failure('Failed to remove favorite artist', exception: e));
    }
  }

  @override
  Future<Result<bool>> isArtistFavorite(String artistId) async {
    try {
      final count = await (_db.select(_db.favoriteArtists)..where((a) => a.id.equals(artistId))).get();
      return Right(count.isNotEmpty);
    } catch (e) {
      return Left(Failure('Failed to check if artist is favorite', exception: e));
    }
  }
}
