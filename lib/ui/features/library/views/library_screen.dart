import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import '../../history/views/history_screen.dart';
import 'downloads_screen.dart';
import 'statistics_screen.dart';
import 'favorites_screen.dart';
import '../viewmodels/library_viewmodel.dart';
import '../viewmodels/local_songs_viewmodel.dart';
import 'grouped_tracks_list.dart';
import '../../../core/widgets/orbitune_button.dart';
import '../../../../services/audio/audio_service_provider.dart';
import 'playlist_details_screen.dart';
import 'add_to_playlist_sheet.dart';
import 'track_options_sheet.dart';
import 'most_played_screen.dart';
import 'recently_added_screen.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryState = ref.watch(libraryViewModelProvider);
    final localSongsState = ref.watch(localSongsViewModelProvider);
    final theme = Theme.of(context);
    final audioHandler = ref.read(audioHandlerProvider);

    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Your Library', style: TextStyle(fontWeight: FontWeight.w700)),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                _showCreatePlaylistDialog(context, ref);
              },
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            tabAlignment: TabAlignment.start,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 16),
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
        body: TabBarView(
          children: [
            // PLAYLISTS TAB
            libraryState.when(
              data: (playlists) {
                final favorites = playlists.where((p) => p.isFavoritePlaylist).toList();
                final regularPlaylists = playlists.where((p) => !p.isFavoritePlaylist).toList();

                if (playlists.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('No playlists yet.'),
                        const SizedBox(height: 16),
                        OrbituneButton(
                          label: 'Create Playlist',
                          onPressed: () => _showCreatePlaylistDialog(context, ref),
                        ),
                      ],
                    ),
                  );
                }

                final searchQuery = ref.watch(playlistSearchQueryProvider).toLowerCase();
                final sortOption = ref.watch(playlistSortOptionProvider);

                var filteredPlaylists = regularPlaylists.where((p) => p.name.toLowerCase().contains(searchQuery)).toList();
                
                switch (sortOption) {
                  case PlaylistSortOption.name:
                    filteredPlaylists.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
                    break;
                  case PlaylistSortOption.dateCreated:
                    filteredPlaylists.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));
                    break;
                  case PlaylistSortOption.trackCount:
                    filteredPlaylists.sort((a, b) => b.trackIds.length.compareTo(a.trackIds.length));
                    break;
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Search playlists...',
                                prefixIcon: const Icon(Icons.search),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onChanged: (value) {
                                ref.read(playlistSearchQueryProvider.notifier).update(value);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          PopupMenuButton<PlaylistSortOption>(
                            icon: const Icon(Icons.sort),
                            onSelected: (option) {
                              ref.read(playlistSortOptionProvider.notifier).update(option);
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: PlaylistSortOption.dateCreated,
                                child: Text('Sort by Date'),
                              ),
                              PopupMenuItem(
                                value: PlaylistSortOption.name,
                                child: Text('Sort by Name'),
                              ),
                              PopupMenuItem(
                                value: PlaylistSortOption.trackCount,
                                child: Text('Sort by Track Count'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        children: [
                          if (favorites.isNotEmpty && searchQuery.isEmpty)
                            ListTile(
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.favorite, color: theme.colorScheme.onPrimaryContainer),
                              ),
                              title: const Text('Liked Songs', style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${favorites.first.trackIds.length} tracks'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PlaylistDetailsScreen(playlist: favorites.first),
                                  ),
                                );
                              },
                            ),
                          if (searchQuery.isEmpty)
                            ListTile(
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.album, color: theme.colorScheme.onPrimaryContainer),
                              ),
                              title: const Text('Liked Albums', style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: const Text('Saved albums'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const FavoriteAlbumsScreen(),
                                  ),
                                );
                              },
                            ),
                          if (searchQuery.isEmpty)
                            ListTile(
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.person, color: theme.colorScheme.onPrimaryContainer),
                              ),
                              title: const Text('Liked Artists', style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: const Text('Saved artists'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const FavoriteArtistsScreen(),
                                  ),
                                );
                              },
                            ),
                          if (searchQuery.isEmpty)
                            ListTile(
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.tertiaryContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.analytics, color: theme.colorScheme.onTertiaryContainer),
                              ),
                              title: const Text('Your Stats', style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: const Text('Listening statistics and top artists'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const StatisticsScreen(),
                                  ),
                                );
                              },
                            ),
                          if (searchQuery.isEmpty)
                            ListTile(
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.history, color: theme.colorScheme.onSecondaryContainer),
                              ),
                              title: const Text('Listening History', style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: const Text('Recently played tracks'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const HistoryScreen(),
                                  ),
                                );
                              },
                            ),
                          if (searchQuery.isEmpty)
                            ListTile(
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.leaderboard, color: theme.colorScheme.onSecondaryContainer),
                              ),
                              title: const Text('Most Played', style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: const Text('Your top tracks'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const MostPlayedScreen(),
                                  ),
                                );
                              },
                            ),
                          if (searchQuery.isEmpty)
                            ListTile(
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.new_releases, color: theme.colorScheme.onSecondaryContainer),
                              ),
                              title: const Text('Recently Added', style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: const Text('Newest tracks in library'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const RecentlyAddedScreen(),
                                  ),
                                );
                              },
                            ),
                          if (searchQuery.isEmpty)
                            ListTile(
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.tertiaryContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(Icons.download_done, color: theme.colorScheme.onTertiaryContainer),
                              ),
                              title: const Text('Downloads', style: TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: const Text('Offline saved music'),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const DownloadsScreen(),
                                  ),
                                );
                              },
                            ),
                          if (searchQuery.isEmpty)
                            const Divider(),
                          if (filteredPlaylists.isEmpty && searchQuery.isNotEmpty)
                            const Center(child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Text('No matching playlists found.'),
                            )),
                          ...filteredPlaylists.map((playlist) {
                            return ListTile(
                              leading: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondaryContainer,
                                  borderRadius: BorderRadius.circular(10),
                                  image: playlist.coverUrl != null
                                      ? DecorationImage(
                                          image: CachedNetworkImageProvider(playlist.coverUrl!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: playlist.coverUrl == null
                                    ? Icon(Icons.queue_music, color: theme.colorScheme.onSecondaryContainer)
                                    : null,
                              ),
                              title: Text(playlist.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${playlist.trackIds.length} tracks'),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'duplicate') {
                                    ref.read(libraryViewModelProvider.notifier).duplicatePlaylist(playlist);
                                  } else if (value == 'delete') {
                                    ref.read(libraryViewModelProvider.notifier).deletePlaylist(playlist.id);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'duplicate',
                                    child: Row(
                                      children: [
                                        Icon(Icons.copy),
                                        SizedBox(width: 8),
                                        Text('Duplicate'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete),
                                        SizedBox(width: 8),
                                        Text('Delete'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PlaylistDetailsScreen(playlist: playlist),
                                  ),
                                );
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Error: $err')),
            ),

            // LOCAL DEVICE TAB
            localSongsState.tracks.when(
              data: (tracks) {
                if (tracks.isEmpty && localSongsState.searchQuery.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.music_off, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text('No local music found.'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ref.read(localSongsViewModelProvider.notifier).loadLocalSongs();
                          },
                          child: const Text('Rescan'),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Filter local songs...',
                                prefixIcon: const Icon(Icons.search),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onChanged: (value) {
                                ref.read(localSongsViewModelProvider.notifier).setSearchQuery(value);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          PopupMenuButton<TrackSortOption>(
                            icon: const Icon(Icons.sort),
                            onSelected: (option) {
                              ref.read(localSongsViewModelProvider.notifier).setSortOption(option);
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: TrackSortOption.title,
                                child: Text('Sort by Title'),
                              ),
                              const PopupMenuItem(
                                value: TrackSortOption.artist,
                                child: Text('Sort by Artist'),
                              ),
                              const PopupMenuItem(
                                value: TrackSortOption.duration,
                                child: Text('Sort by Duration'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: tracks.isEmpty
                        ? const Center(child: Text('No matches found.'))
                        : ListView.builder(
                            itemCount: tracks.length,
                            itemBuilder: (context, index) {
                              final track = tracks[index];
                              final isSelected = localSongsState.selectedTrackIds.contains(track.id);

                              return ListTile(
                                leading: localSongsState.isSelectionMode
                                  ? Checkbox(
                                      value: isSelected,
                                      onChanged: (_) => ref.read(localSongsViewModelProvider.notifier).toggleTrackSelection(track.id),
                                    )
                                  : Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.secondaryContainer,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.music_note),
                                    ),
                                title: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                                subtitle: Text(track.artist, maxLines: 1, overflow: TextOverflow.ellipsis),
                                trailing: localSongsState.isSelectionMode 
                                  ? null 
                                  : IconButton(
                                      icon: const Icon(Icons.more_vert),
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          builder: (context) => TrackOptionsSheet(track: track),
                                        );
                                      },
                                    ),
                                onLongPress: () {
                                  if (!localSongsState.isSelectionMode) {
                                    ref.read(localSongsViewModelProvider.notifier).toggleSelectionMode();
                                    ref.read(localSongsViewModelProvider.notifier).toggleTrackSelection(track.id);
                                  }
                                },
                                onTap: () async {
                                  if (localSongsState.isSelectionMode) {
                                    ref.read(localSongsViewModelProvider.notifier).toggleTrackSelection(track.id);
                                  } else {
                                    final mediaItem = MediaItem(
                                      id: track.id,
                                      album: track.album,
                                      title: track.title,
                                      artist: track.artist,
                                      duration: Duration(milliseconds: track.durationMs),
                                      extras: {'url': track.dataUrl},
                                    );
                                    await audioHandler.loadPlaylist([mediaItem]);
                                    await audioHandler.play();
                                  }
                                },
                              );
                            },
                          ),
                    ),
                    if (localSongsState.isSelectionMode)
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${localSongsState.selectedTrackIds.length} Selected'),
                            Row(
                              children: [
                                TextButton(
                                  onPressed: () => ref.read(localSongsViewModelProvider.notifier).selectAll(),
                                  child: const Text('Select All'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.playlist_add),
                                  onPressed: localSongsState.selectedTrackIds.isEmpty ? null : () {
                                    final selectedTracks = tracks.where((t) => localSongsState.selectedTrackIds.contains(t.id)).toList();
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (context) => AddToPlaylistSheet(tracks: selectedTracks),
                                    );
                                    ref.read(localSongsViewModelProvider.notifier).clearSelection();
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: localSongsState.selectedTrackIds.isEmpty ? null : () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete Tracks?'),
                                        content: Text('Are you sure you want to permanently delete ${localSongsState.selectedTrackIds.length} tracks from your device? This action cannot be undone.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('Cancel'),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                            onPressed: () => Navigator.pop(context, true),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await ref.read(localSongsViewModelProvider.notifier).deleteSelectedTracks();
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Tracks deleted')),
                                        );
                                      }
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () => ref.read(localSongsViewModelProvider.notifier).clearSelection(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      err.toString().contains('permission denied') ? Icons.folder_off : Icons.error_outline,
                      size: 64,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      err.toString().contains('permission denied')
                          ? 'Storage Permission Denied\nOrbitune needs access to your local storage to find your offline music.'
                          : 'Error loading songs\n$err',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                    ),
                    const SizedBox(height: 24),
                    OrbituneButton(
                      label: err.toString().contains('permission denied') ? 'Grant Permission' : 'Retry',
                      onPressed: () => ref.read(localSongsViewModelProvider.notifier).loadLocalSongs(),
                    ),
                  ],
                ),
              ),
            ),
            // ALBUMS TAB
            localSongsState.tracks.when(
              data: (tracks) => Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.favorite, color: theme.colorScheme.onSecondaryContainer),
                    ),
                    title: const Text('Liked Albums', style: TextStyle(fontWeight: FontWeight.bold)),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoriteAlbumsScreen()));
                    },
                  ),
                  const Divider(),
                  Expanded(
                    child: GroupedTracksList(
                      tracks: tracks,
                      groupBy: (t) => t.album,
                      title: 'albums',
                      icon: Icons.album,
                    ),
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
            
            // ARTISTS TAB
            localSongsState.tracks.when(
              data: (tracks) => Column(
                children: [
                  ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.favorite, color: theme.colorScheme.onSecondaryContainer),
                    ),
                    title: const Text('Liked Artists', style: TextStyle(fontWeight: FontWeight.bold)),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoriteArtistsScreen()));
                    },
                  ),
                  const Divider(),
                  Expanded(
                    child: GroupedTracksList(
                      tracks: tracks,
                      groupBy: (t) => t.artist,
                      title: 'artists',
                      icon: Icons.person,
                    ),
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
            
            // GENRES TAB
            localSongsState.tracks.when(
              data: (tracks) => GroupedTracksList(
                tracks: tracks,
                groupBy: (t) => t.genre ?? 'Unknown Genre',
                title: 'genres',
                icon: Icons.category,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),

            
            // FOLDERS TAB
            localSongsState.tracks.when(
              data: (tracks) => GroupedTracksList(
                tracks: tracks,
                groupBy: (t) {
                  if (t.source.name != 'local' || t.dataUrl.isEmpty) return '';
                  final parts = t.dataUrl.split(RegExp(r'[\\/]'));
                  if (parts.length > 1) {
                    return parts.sublist(0, parts.length - 1).join('/');
                  }
                  return '';
                },
                title: 'folders',
                icon: Icons.folder,
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ],
        ),
      ),
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
          autofocus: true,
          maxLength: 50,
          decoration: const InputDecoration(
            hintText: 'Playlist Name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty && name.length <= 50) {
                ref.read(libraryViewModelProvider.notifier).createPlaylist(name);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Playlist name must be between 1 and 50 characters.')),
                );
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
