import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import '../../../../domain/entities/online_item.dart';
import '../../../../domain/entities/track.dart';
import '../../../../services/audio/audio_service_provider.dart';
import '../../../../core/helpers/providers.dart';
import '../../../core/widgets/loading_skeleton.dart';

import '../../../../domain/entities/album.dart';
import '../../../../domain/entities/artist.dart';
import '../../../../domain/repositories/favorites_repository.dart';

final onlineItemDetailsProvider = FutureProvider.family<List<Track>, OnlineItem>((ref, item) async {
  final service = ref.read(onlineAudioServiceProvider);
  switch (item.type) {
    case OnlineItemType.album:
      final res = await service.getAlbumTracks(item.id);
      return res.getOrElse((_) => []);
    case OnlineItemType.artist:
      final res = await service.getArtistTracks(item.id);
      return res.getOrElse((_) => []);
    case OnlineItemType.playlist:
      final res = await service.getPlaylistTracks(item.id);
      return res.getOrElse((_) => []);
    case OnlineItemType.genre:
      return [];
  }
});

class OnlineDetailsScreen extends ConsumerWidget {
  final OnlineItem item;

  const OnlineDetailsScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final audioHandler = ref.read(audioHandlerProvider);
    final tracksState = ref.watch(onlineItemDetailsProvider(item));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            actions: [
              if (item.type == OnlineItemType.album || item.type == OnlineItemType.artist)
                _FavoriteButton(item: item),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(item.title, style: const TextStyle(shadows: [Shadow(color: Colors.black, blurRadius: 4)])),
              background: item.artworkUrl != null
                  ? CachedNetworkImage(
                      imageUrl: item.artworkUrl!,
                      fit: BoxFit.cover,
                      color: Colors.black.withValues(alpha: 0.4),
                      colorBlendMode: BlendMode.darken,
                    )
                  : Container(
                      color: theme.colorScheme.secondaryContainer,
                      child: Icon(Icons.music_note, size: 80, color: theme.colorScheme.onSecondaryContainer),
                    ),
            ),
          ),
          tracksState.when(
            data: (tracks) {
              if (tracks.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('No tracks found.')),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final track = tracks[index];
                    return ListTile(
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(10),
                          image: track.artworkUrl != null
                              ? DecorationImage(
                                  image: CachedNetworkImageProvider(track.artworkUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: track.artworkUrl == null
                            ? Icon(Icons.music_note, color: theme.colorScheme.onSecondaryContainer)
                            : null,
                      ),
                      title: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(track.artist, maxLines: 1, overflow: TextOverflow.ellipsis),
                      onTap: () async {
                        final mediaItems = tracks.map((t) => MediaItem(
                          id: t.id,
                          album: t.album,
                          title: t.title,
                          artist: t.artist,
                          duration: Duration(milliseconds: t.durationMs),
                          artUri: t.artworkUrl != null ? Uri.parse(t.artworkUrl!) : null,
                          extras: {'url': t.dataUrl},
                        )).toList();
                        
                        await audioHandler.loadPlaylist(mediaItems, initialIndex: index);
                        await audioHandler.play();
                      },
                    );
                  },
                  childCount: tracks.length,
                ),
              );
            },
            loading: () => SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: LoadingSkeleton(width: double.infinity, height: 60, borderRadius: 10),
                ),
                childCount: 10,
              ),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: tracksState.value?.isNotEmpty == true
          ? FloatingActionButton(
              onPressed: () async {
                final tracks = tracksState.value!;
                final mediaItems = tracks.map((t) => MediaItem(
                  id: t.id,
                  album: t.album,
                  title: t.title,
                  artist: t.artist,
                  duration: Duration(milliseconds: t.durationMs),
                  artUri: t.artworkUrl != null ? Uri.parse(t.artworkUrl!) : null,
                  extras: {'url': t.dataUrl},
                )).toList();
                
                await audioHandler.loadPlaylist(mediaItems);
                await audioHandler.play();
              },
              child: const Icon(Icons.play_arrow),
            )
          : null,
    );
  }
}

class _FavoriteButton extends ConsumerStatefulWidget {
  final OnlineItem item;
  const _FavoriteButton({required this.item});

  @override
  ConsumerState<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends ConsumerState<_FavoriteButton> {
  bool _isFavorite = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final repo = ref.read(favoritesRepositoryProvider);
    bool isFav = false;
    if (widget.item.type == OnlineItemType.album) {
      final res = await repo.isAlbumFavorite(widget.item.id);
      isFav = res.getOrElse((_) => false);
    } else if (widget.item.type == OnlineItemType.artist) {
      final res = await repo.isArtistFavorite(widget.item.id);
      isFav = res.getOrElse((_) => false);
    }
    
    if (mounted) {
      setState(() {
        _isFavorite = isFav;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    final repo = ref.read(favoritesRepositoryProvider);
    setState(() => _isLoading = true);

    if (widget.item.type == OnlineItemType.album) {
      if (_isFavorite) {
        await repo.removeFavoriteAlbum(widget.item.id);
      } else {
        await repo.addFavoriteAlbum(Album(
          id: widget.item.id,
          name: widget.item.title,
          artist: widget.item.subtitle ?? 'Unknown',
          artworkUrl: widget.item.artworkUrl,
        ));
      }
    } else if (widget.item.type == OnlineItemType.artist) {
      if (_isFavorite) {
        await repo.removeFavoriteArtist(widget.item.id);
      } else {
        await repo.addFavoriteArtist(Artist(
          id: widget.item.id,
          name: widget.item.title,
          imageUrl: widget.item.artworkUrl,
        ));
      }
    }

    if (mounted) {
      setState(() {
        _isFavorite = !_isFavorite;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          ),
        ),
      );
    }

    return IconButton(
      icon: Icon(_isFavorite ? Icons.favorite : Icons.favorite_border),
      color: _isFavorite ? Colors.red : Colors.white,
      onPressed: _toggleFavorite,
    );
  }
}
