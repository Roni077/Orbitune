import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/track.dart';
import '../viewmodels/library_viewmodel.dart';
import '../../../../domain/repositories/playlist_repository.dart';

class AddToPlaylistSheet extends ConsumerWidget {
  final List<Track> tracks;

  const AddToPlaylistSheet({super.key, required this.tracks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryState = ref.watch(libraryViewModelProvider);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              tracks.length == 1 ? 'Add to Playlist' : 'Add ${tracks.length} Songs to Playlist', 
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
            ),
          ),
          const SizedBox(height: 16),
          libraryState.when(
            data: (playlists) {
              final regularPlaylists = playlists.where((p) => !p.isFavoritePlaylist).toList();
              if (regularPlaylists.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No playlists found. Create one first!'),
                );
              }
              return Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: regularPlaylists.length,
                  itemBuilder: (context, index) {
                    final playlist = regularPlaylists[index];
                    return ListTile(
                      leading: const Icon(Icons.queue_music),
                      title: Text(playlist.name),
                      onTap: () async {
                        final repo = ref.read(playlistRepositoryProvider);
                        for (final track in tracks) {
                          await repo.addTrackToPlaylist(playlist.id, track);
                        }
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Added to ${playlist.name}')),
                          );
                        }
                      },
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ],
      ),
    );
  }
}

void showAddToPlaylistSheet(BuildContext context, List<Track> tracks) {
  showModalBottomSheet(
    context: context,
    builder: (context) => AddToPlaylistSheet(tracks: tracks),
  );
}
