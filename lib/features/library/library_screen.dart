import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:audio_service/audio_service.dart';
import '../../core/providers.dart';
import '../player/player_providers.dart';
import 'library_providers.dart';
import 'widgets/songs_tab.dart';
import 'widgets/albums_tab.dart';
import 'widgets/artists_tab.dart';
import 'widgets/genres_tab.dart';
import 'widgets/folders_tab.dart';
import 'widgets/playlists_tab.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSongs = ref.watch(selectedSongsProvider);
    final isMultiSelectMode = selectedSongs.isNotEmpty;
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: isMultiSelectMode
            ? AppBar(
                backgroundColor: theme.colorScheme.primaryContainer,
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    ref.read(selectedSongsProvider.notifier).clear();
                  },
                ),
                title: Text('${selectedSongs.length} Selected'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.playlist_add),
                    tooltip: 'Add to Playlist',
                    onPressed: () {
                      _showAddToPlaylistDialog(context, ref, selectedSongs);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.queue_music),
                    tooltip: 'Add to Queue',
                    onPressed: () async {
                      final audioHandler = ref.read(audioHandlerProvider);
                      final allSongs = ref.read(songsStreamProvider).valueOrNull ?? [];
                      final selectedSongsList = allSongs.where((s) => selectedSongs.contains(s.uri)).toList();
                      
                      final mediaItems = selectedSongsList.map((song) => MediaItem(
                        id: song.id.toString(),
                        title: song.title,
                        artist: song.artist,
                        album: song.album,
                        duration: Duration(milliseconds: song.durationMs),
                        artUri: song.albumArtPath != null ? Uri.file(song.albumArtPath!) : null,
                        extras: {'uri': song.uri},
                      )).toList();
                      
                      await audioHandler.addQueueItems(mediaItems);
                      
                      ref.read(selectedSongsProvider.notifier).clear();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Added ${selectedSongsList.length} songs to queue')),
                        );
                      }
                    },
                  ),
                ],
                bottom: const TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: [
                    Tab(text: 'Playlists'),
                    Tab(text: 'Songs'),
                    Tab(text: 'Albums'),
                    Tab(text: 'Artists'),
                    Tab(text: 'Genres'),
                    Tab(text: 'Folders'),
                  ],
                ),
              )
            : AppBar(
                title: const Text('Library', style: TextStyle(fontWeight: FontWeight.bold)),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () {
                      context.push('/search');
                    },
                  ),
                ],
                bottom: const TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: [
                    Tab(text: 'Playlists'),
                    Tab(text: 'Songs'),
                    Tab(text: 'Albums'),
                    Tab(text: 'Artists'),
                    Tab(text: 'Genres'),
                    Tab(text: 'Folders'),
                  ],
                ),
              ),
        body: const TabBarView(
          children: [
            PlaylistsTab(),
            SongsTab(),
            AlbumsTab(),
            ArtistsTab(),
            GenresTab(),
            FoldersTab(),
          ],
        ),
      ),
    );
  }

  void _showAddToPlaylistDialog(BuildContext context, WidgetRef ref, Set<String> selectedUris) async {
    final playlists = await ref.read(playlistRepositoryProvider).getAllPlaylists();
    
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add to Playlist'),
          content: playlists.isEmpty 
            ? const Text('No playlists available. Create one first!')
            : SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = playlists[index];
                    return ListTile(
                      title: Text(playlist.name),
                      onTap: () {
                        ref.read(playlistRepositoryProvider).addSongsToPlaylist(
                          playlist.id, 
                          selectedUris.toList()
                        );
                        ref.read(selectedSongsProvider.notifier).clear();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Added ${selectedUris.length} songs to ${playlist.name}')),
                        );
                      },
                    );
                  },
                ),
              ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
