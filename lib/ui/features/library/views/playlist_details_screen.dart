import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import '../../../../domain/entities/playlist.dart';
import '../viewmodels/playlist_details_viewmodel.dart';
import '../../../../services/audio/audio_service_provider.dart';
import '../../../../domain/repositories/playlist_repository.dart';

class PlaylistDetailsScreen extends ConsumerWidget {
  final Playlist playlist;

  const PlaylistDetailsScreen({super.key, required this.playlist});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(playlistDetailsViewModelProvider(playlist));
    final theme = Theme.of(context);
    final audioHandler = ref.read(audioHandlerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(playlist.isFavoritePlaylist ? 'Liked Songs' : playlist.name),
        actions: [
          if (!playlist.isFavoritePlaylist)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Rename Playlist',
              onPressed: () {
                _showRenameDialog(context, ref);
              },
            ),
        ],
      ),
      floatingActionButton: state.maybeWhen(
        data: (tracks) => tracks.isNotEmpty
            ? FloatingActionButton.extended(
                icon: const Icon(Icons.shuffle),
                label: const Text('Shuffle'),
                onPressed: () async {
                  final mediaItems = tracks.map((t) => MediaItem(
                    id: t.id,
                    album: t.album,
                    title: t.title,
                    artist: t.artist,
                    duration: Duration(milliseconds: t.durationMs),
                    extras: {'url': t.dataUrl},
                    artUri: t.artworkUrl != null ? Uri.parse(t.artworkUrl!) : null,
                  )).toList();
                  await audioHandler.loadPlaylist(mediaItems, initialIndex: 0);
                  await audioHandler.setShuffleMode(AudioServiceShuffleMode.all);
                  await audioHandler.play();
                },
              )
            : null,
        orElse: () => null,
      ),
      body: state.when(
        data: (tracks) {
          if (tracks.isEmpty) {
            return const Center(child: Text('This playlist is empty.'));
          }
          return ReorderableListView.builder(
            // ignore: deprecated_member_use
            onReorder: (oldIndex, newIndex) {
              ref.read(playlistDetailsViewModelProvider(playlist).notifier).reorderTracks(oldIndex, newIndex);
            },
            itemCount: tracks.length,
            itemBuilder: (context, index) {
              final track = tracks[index];
              return ListTile(
                key: ValueKey(track.id),
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
                trailing: !playlist.isFavoritePlaylist
                    ? IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () {
                          ref.read(playlistDetailsViewModelProvider(playlist).notifier).removeTrack(track.id);
                        },
                      )
                    : null,
                onTap: () async {
                  final mediaItems = tracks.map((t) => MediaItem(
                    id: t.id,
                    album: t.album,
                    title: t.title,
                    artist: t.artist,
                    duration: Duration(milliseconds: t.durationMs),
                    extras: {'url': t.dataUrl},
                    artUri: t.artworkUrl != null ? Uri.parse(t.artworkUrl!) : null,
                  )).toList();
                  await audioHandler.loadPlaylist(mediaItems, initialIndex: index);
                  await audioHandler.setShuffleMode(AudioServiceShuffleMode.none);
                  await audioHandler.play();
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _showRenameDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: playlist.name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Playlist'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Playlist Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                final repo = ref.read(playlistRepositoryProvider);
                await repo.renamePlaylist(playlist.id, newName);
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.pop(context); // Go back as title doesn't reactively update without a deeper provider refactor
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Playlist renamed')));
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
