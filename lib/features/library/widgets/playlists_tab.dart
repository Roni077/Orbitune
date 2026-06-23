import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';

final playlistsStreamProvider = StreamProvider((ref) {
  final repo = ref.watch(playlistRepositoryProvider);
  return repo.watchAllPlaylists();
});

class PlaylistsTab extends ConsumerWidget {
  const PlaylistsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playlistsAsync = ref.watch(playlistsStreamProvider);

    return playlistsAsync.when(
      data: (playlists) {
        if (playlists.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.queue_music, size: 64, color: Colors.white24),
                const SizedBox(height: 16),
                const Text('No playlists yet', style: TextStyle(color: Colors.white54)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showCreatePlaylistDialog(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Playlist'),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            ListView.builder(
              itemCount: playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlists[index];
                return ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.queue_music),
                  ),
                  title: Text(playlist.name),
                  subtitle: Text('${playlist.songUris.length} songs'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      ref.read(playlistRepositoryProvider).deletePlaylist(playlist.id);
                    },
                  ),
                  onTap: () {
                    // TODO: Navigate to playlist details screen
                  },
                );
              },
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                onPressed: () => _showCreatePlaylistDialog(context, ref),
                child: const Icon(Icons.add),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Playlist'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Playlist Name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                ref.read(playlistRepositoryProvider).createPlaylist(name);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
