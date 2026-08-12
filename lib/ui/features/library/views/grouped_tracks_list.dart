import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/track.dart';
import 'package:audio_service/audio_service.dart';
import '../../../../services/audio/audio_service_provider.dart';
import '../../../../domain/repositories/favorites_repository.dart';
import '../../../../domain/entities/album.dart';
import '../../../../domain/entities/artist.dart';
import 'add_to_playlist_sheet.dart';
import 'album_profile_screen.dart';

class GroupedTracksList extends ConsumerWidget {
  final List<Track> tracks;
  final String Function(Track) groupBy;
  final String title;
  final IconData icon;

  const GroupedTracksList({
    super.key,
    required this.tracks,
    required this.groupBy,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final audioHandler = ref.read(audioHandlerProvider);

    final grouped = <String, List<Track>>{};
    for (final track in tracks) {
      final key = groupBy(track);
      if (key.isNotEmpty) {
        grouped.putIfAbsent(key, () => []).add(track);
      }
    }

    final sortedKeys = grouped.keys.toList()..sort();

    if (sortedKeys.isEmpty) {
      return Center(child: Text('No $title found.'));
    }

    return ListView.builder(
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final key = sortedKeys[index];
        final groupTracks = grouped[key]!;
        final firstTrack = groupTracks.first;

        return ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(8),
              image: firstTrack.artworkUrl != null
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(firstTrack.artworkUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: firstTrack.artworkUrl == null
                ? Icon(icon, color: theme.colorScheme.onSecondaryContainer)
                : null,
          ),
          title: Text(key, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${groupTracks.length} tracks'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.play_circle_filled),
                color: theme.colorScheme.primary,
                onPressed: () async {
                  final mediaItems = groupTracks.map((t) => MediaItem(
                    id: t.id,
                    album: t.album,
                    title: t.title,
                    artist: t.artist,
                    duration: Duration(milliseconds: t.durationMs),
                    extras: {'url': t.dataUrl},
                    artUri: t.artworkUrl != null ? Uri.parse(t.artworkUrl!) : null,
                  )).toList();
                  await audioHandler.loadPlaylist(mediaItems, initialIndex: 0);
                  await audioHandler.play();
                },
              ),
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'add_to_playlist') {
                    showAddToPlaylistSheet(context, groupTracks);
                  } else if (value == 'favorite') {
                    final repo = ref.read(favoritesRepositoryProvider);
                    if (title == 'albums') {
                      await repo.addFavoriteAlbum(Album(
                        id: key,
                        name: key,
                        artist: firstTrack.artist,
                        artworkUrl: firstTrack.artworkUrl,
                      ));
                    } else if (title == 'artists') {
                      await repo.addFavoriteArtist(Artist(
                        id: key,
                        name: key,
                        imageUrl: firstTrack.artworkUrl,
                      ));
                    }
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to Liked Items')),
                      );
                    }
                  }
                },
                itemBuilder: (context) => [
                  if (title == 'albums' || title == 'artists')
                    const PopupMenuItem(
                      value: 'favorite',
                      child: Text('Like'),
                    ),
                  const PopupMenuItem(
                    value: 'add_to_playlist',
                    child: Text('Add to Playlist'),
                  ),
                ],
              ),
            ],
          ),
          onTap: () {
            if (title == 'albums') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AlbumProfileScreen(
                    albumTitle: key,
                    localTracks: groupTracks,
                  ),
                ),
              );
            } else {
              _showGroupDetailsSheet(context, theme, key, groupTracks, audioHandler);
            }
          },
        );
      },
    );
  }

  void _showGroupDetailsSheet(BuildContext context, ThemeData theme, String groupName, List<Track> groupTracks, dynamic audioHandler) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(groupName, style: theme.textTheme.titleLarge),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: groupTracks.length,
                    itemBuilder: (context, index) {
                      final track = groupTracks[index];
                      return ListTile(
                        leading: const Icon(Icons.music_note),
                        title: Text(track.title, maxLines: 1),
                        subtitle: Text(track.artist, maxLines: 1),
                        onTap: () async {
                          Navigator.pop(context);
                          final mediaItems = groupTracks.map((t) => MediaItem(
                            id: t.id,
                            album: t.album,
                            title: t.title,
                            artist: t.artist,
                            duration: Duration(milliseconds: t.durationMs),
                            extras: {'url': t.dataUrl},
                            artUri: t.artworkUrl != null ? Uri.parse(t.artworkUrl!) : null,
                          )).toList();
                          await audioHandler.loadPlaylist(mediaItems, initialIndex: index);
                          await audioHandler.play();
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
