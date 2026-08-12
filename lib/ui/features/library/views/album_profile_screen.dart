import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';

import '../../../../domain/entities/album.dart';
import '../../../../domain/entities/online_item.dart';
import '../../../../domain/entities/track.dart';
import '../../../../domain/repositories/favorites_repository.dart';
import '../../../../services/audio/audio_service_provider.dart';
import '../../../../services/downloads/download_manager.dart';
import '../../../core/widgets/loading_skeleton.dart';
import '../viewmodels/album_profile_viewmodel.dart';
import 'add_to_playlist_sheet.dart';

final isFavoriteAlbumProvider = FutureProvider.family<bool, String>((ref, id) async {
  final repo = ref.read(favoritesRepositoryProvider);
  final res = await repo.isAlbumFavorite(id);
  return res.getOrElse((_) => false);
});

class AlbumProfileScreen extends ConsumerWidget {
  final OnlineItem? onlineItem;
  final List<Track>? localTracks;
  final String albumTitle;

  const AlbumProfileScreen({
    super.key,
    this.onlineItem,
    this.localTracks,
    required this.albumTitle,
  }) : assert(onlineItem != null || localTracks != null);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final audioHandler = ref.read(audioHandlerProvider);
    final downloadService = ref.read(downloadManagerProvider.notifier);
    
    // For local tracks, we already have them. For online, we watch the provider.
    final tracksState = onlineItem != null 
        ? ref.watch(albumProfileViewModelProvider(onlineItem!.id))
        : AsyncData<List<Track>>(localTracks!);

    // Extract common metadata from the first track if available, else from onlineItem
    String? artworkUrl = onlineItem?.artworkUrl;
    String artistName = onlineItem?.subtitle ?? 'Unknown Artist';
    String? year;
    int trackCount = 0;
    
    if (tracksState.hasValue && tracksState.value!.isNotEmpty) {
      final first = tracksState.value!.first;
      artworkUrl ??= first.artworkUrl;
      if (artistName == 'Unknown Artist') artistName = first.artist;
      year = first.year?.toString();
      trackCount = tracksState.value!.length;
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300.0,
            floating: false,
            pinned: true,
            actions: [
              _FavoriteButton(
                albumId: onlineItem?.id ?? albumTitle,
                albumName: albumTitle,
                artistName: artistName,
                artworkUrl: artworkUrl,
              ),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'add_to_playlist') {
                    if (tracksState.hasValue && tracksState.value!.isNotEmpty) {
                      showAddToPlaylistSheet(context, tracksState.value!);
                    }
                  } else if (value == 'download') {
                    if (tracksState.hasValue && tracksState.value!.isNotEmpty) {
                      for (final track in tracksState.value!) {
                        final mediaItem = MediaItem(
                          id: track.id,
                          album: track.album,
                          title: track.title,
                          artist: track.artist,
                          duration: Duration(milliseconds: track.durationMs),
                          extras: {'url': track.dataUrl},
                          artUri: track.artworkUrl != null ? Uri.parse(track.artworkUrl!) : null,
                        );
                        downloadService.enqueue(mediaItem);
                      }
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Downloading album...')),
                        );
                      }
                    }
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'add_to_playlist',
                    child: Text('Add to Playlist'),
                  ),
                  const PopupMenuItem(
                    value: 'download',
                    child: Text('Download Album'),
                  ),
                ],
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (artworkUrl != null)
                    CachedNetworkImage(
                      imageUrl: artworkUrl,
                      fit: BoxFit.cover,
                      color: Colors.black.withValues(alpha: 0.5),
                      colorBlendMode: BlendMode.darken,
                    )
                  else
                    Container(
                      color: theme.colorScheme.secondaryContainer,
                      child: Icon(Icons.album, size: 100, color: theme.colorScheme.onSecondaryContainer),
                    ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          albumTitle,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            shadows: [const Shadow(color: Colors.black54, blurRadius: 4)],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              artistName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white70,
                                shadows: [const Shadow(color: Colors.black54, blurRadius: 4)],
                              ),
                            ),
                            if (year != null) ...[
                              const SizedBox(width: 8),
                              const Text('•', style: TextStyle(color: Colors.white70)),
                              const SizedBox(width: 8),
                              Text(
                                year,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white70,
                                  shadows: [const Shadow(color: Colors.black54, blurRadius: 4)],
                                ),
                              ),
                            ],
                            if (trackCount > 0) ...[
                              const SizedBox(width: 8),
                              const Text('•', style: TextStyle(color: Colors.white70)),
                              const SizedBox(width: 8),
                              Text(
                                '$trackCount tracks',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white70,
                                  shadows: [const Shadow(color: Colors.black54, blurRadius: 4)],
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: tracksState.hasValue && tracksState.value!.isNotEmpty ? () async {
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
                              } : null,
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Play'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: tracksState.hasValue && tracksState.value!.isNotEmpty ? () async {
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
                                // Shuffle the media items
                                final shuffled = List<MediaItem>.from(mediaItems)..shuffle();
                                await audioHandler.loadPlaylist(shuffled);
                                await audioHandler.play();
                              } : null,
                              icon: const Icon(Icons.shuffle),
                              label: const Text('Shuffle'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.secondaryContainer,
                                foregroundColor: theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: tracksState.hasValue && tracksState.value!.isNotEmpty ? () async {
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
                                for (var item in mediaItems) {
                                  await audioHandler.addQueueItem(item);
                                }
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Album added to queue')),
                                  );
                                }
                              } : null,
                              icon: const Icon(Icons.queue_music),
                              tooltip: 'Add to queue',
                              style: IconButton.styleFrom(
                                backgroundColor: theme.colorScheme.secondaryContainer,
                                foregroundColor: theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
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
                      leading: Text(
                        '${index + 1}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      title: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(track.artist, maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {
                          // Show track options sheet if implemented, or popup menu
                          // Let's just use the standard AddToPlaylist for now
                          showAddToPlaylistSheet(context, [track]);
                        },
                      ),
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
    );
  }
}

class _FavoriteButton extends ConsumerWidget {
  final String albumId;
  final String albumName;
  final String artistName;
  final String? artworkUrl;

  const _FavoriteButton({
    required this.albumId,
    required this.albumName,
    required this.artistName,
    this.artworkUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isFavorite = ref.watch(isFavoriteAlbumProvider(albumId));

    return isFavorite.when(
      data: (isFav) => IconButton(
        icon: Icon(
          isFav ? Icons.favorite : Icons.favorite_border,
          color: isFav ? theme.colorScheme.primary : Colors.white,
        ),
        onPressed: () async {
          final repo = ref.read(favoritesRepositoryProvider);
          if (isFav) {
            await repo.removeFavoriteAlbum(albumId);
          } else {
            await repo.addFavoriteAlbum(Album(
              id: albumId,
              name: albumName,
              artist: artistName,
              artworkUrl: artworkUrl,
            ));
          }
        },
      ),
      loading: () => const IconButton(icon: Icon(Icons.favorite_border, color: Colors.white), onPressed: null),
      error: (err, stack) => const IconButton(icon: Icon(Icons.favorite_border, color: Colors.white), onPressed: null),
    );
  }
}
