import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/album.dart';
import '../../../../domain/entities/artist.dart';
import '../../../../domain/repositories/favorites_repository.dart';

final favoriteAlbumsProvider = FutureProvider<List<Album>>((ref) async {
  final repo = ref.watch(favoritesRepositoryProvider);
  final result = await repo.getFavoriteAlbums();
  return result.fold((l) => [], (r) => r);
});

final favoriteArtistsProvider = FutureProvider<List<Artist>>((ref) async {
  final repo = ref.watch(favoritesRepositoryProvider);
  final result = await repo.getFavoriteArtists();
  return result.fold((l) => [], (r) => r);
});

class FavoriteAlbumsScreen extends ConsumerWidget {
  const FavoriteAlbumsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(favoriteAlbumsProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Liked Albums')),
      body: state.when(
        data: (albums) {
          if (albums.isEmpty) return const Center(child: Text('No liked albums yet'));
          return ListView.builder(
            itemCount: albums.length,
            itemBuilder: (context, index) {
              final album = albums[index];
              return ListTile(
                leading: album.artworkUrl != null 
                  ? CachedNetworkImage(imageUrl: album.artworkUrl!, width: 50, height: 50, fit: BoxFit.cover)
                  : const Icon(Icons.album, size: 50),
                title: Text(album.name),
                subtitle: Text(album.artist),
                trailing: IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: () async {
                    await ref.read(favoritesRepositoryProvider).removeFavoriteAlbum(album.id);
                    ref.invalidate(favoriteAlbumsProvider);
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class FavoriteArtistsScreen extends ConsumerWidget {
  const FavoriteArtistsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(favoriteArtistsProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Liked Artists')),
      body: state.when(
        data: (artists) {
          if (artists.isEmpty) return const Center(child: Text('No liked artists yet'));
          return ListView.builder(
            itemCount: artists.length,
            itemBuilder: (context, index) {
              final artist = artists[index];
              return ListTile(
                leading: artist.imageUrl != null 
                  ? CircleAvatar(backgroundImage: CachedNetworkImageProvider(artist.imageUrl!))
                  : const CircleAvatar(child: Icon(Icons.person)),
                title: Text(artist.name),
                trailing: IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: () async {
                    await ref.read(favoritesRepositoryProvider).removeFavoriteArtist(artist.id);
                    ref.invalidate(favoriteArtistsProvider);
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
