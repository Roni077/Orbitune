import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import '../../core/helpers/result_type.dart';
import '../entities/album.dart';
import '../entities/artist.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  throw UnimplementedError('Initialize in main/provider setup');
});

abstract class FavoritesRepository {
  Future<Result<List<Album>>> getFavoriteAlbums();
  Future<Result<Unit>> addFavoriteAlbum(Album album);
  Future<Result<Unit>> removeFavoriteAlbum(String albumId);
  Future<Result<bool>> isAlbumFavorite(String albumId);

  Future<Result<List<Artist>>> getFavoriteArtists();
  Future<Result<Unit>> addFavoriteArtist(Artist artist);
  Future<Result<Unit>> removeFavoriteArtist(String artistId);
  Future<Result<bool>> isArtistFavorite(String artistId);
}
