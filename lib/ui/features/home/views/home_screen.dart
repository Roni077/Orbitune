import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import '../../../../services/audio/audio_service_provider.dart';
import '../../../../services/audio/audio_player_handler.dart';
import '../viewmodels/home_viewmodel.dart';
import '../../../../domain/entities/track.dart';
import '../../../../domain/entities/online_item.dart';
import '../../../../core/helpers/network_state_provider.dart';
import '../../search/views/genre_playlists_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentlyPlayed = ref.watch(recentlyPlayedProvider);
    final madeForYou = ref.watch(madeForYouProvider);
    final trending = ref.watch(trendingProvider);
    final newReleases = ref.watch(newReleasesProvider);
    final charts = ref.watch(chartsProvider);
    final genresAndMoods = ref.watch(genresAndMoodsProvider);
    final localTracks = ref.watch(homeLocalTracksProvider);
    final recentlyAdded = ref.watch(recentlyAddedProvider);
    final audioHandler = ref.read(audioHandlerProvider);
    final theme = Theme.of(context);
    final isOnline = ref.watch(networkStateProvider).value ?? true;

    String getGreeting() {
      final hour = DateTime.now().hour;
      if (hour < 12) return 'Good Morning';
      if (hour < 17) return 'Good Afternoon';
      return 'Good Evening';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orbitune', style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Optionally navigate to a dedicated search route if not using bottom tabs
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(recentlyPlayedProvider);
          ref.invalidate(quickPicksProvider);
          ref.invalidate(madeForYouProvider);
          ref.invalidate(trendingProvider);
          ref.invalidate(newReleasesProvider);
          ref.invalidate(chartsProvider);
          ref.invalidate(homeLocalTracksProvider);
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                getGreeting(),
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            recentlyPlayed.when(
              data: (tracks) {
                if (tracks.isEmpty) return const SizedBox.shrink();
                final track = tracks.first;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: InkWell(
                    onTap: () {
                      final mediaItem = MediaItem(
                        id: track.id,
                        title: track.title,
                        artist: track.artist,
                        extras: {'url': track.dataUrl},
                        artUri: track.artworkUrl != null ? Uri.parse(track.artworkUrl!) : null,
                      );
                      audioHandler.loadPlaylist([mediaItem]);
                      audioHandler.play();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          if (track.artworkUrl != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: track.artworkUrl!,
                                width: 56,
                                height: 56,
                                memCacheWidth: 150,
                                memCacheHeight: 150,
                                fit: BoxFit.cover,
                              ),
                            )
                          else
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.music_note),
                            ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Continue Listening', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.primary)),
                                Text(track.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                                Text(track.artist, style: theme.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          const Icon(Icons.play_circle_fill, size: 36),
                        ],
                      ),
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
            if (isOnline) ...[
              _buildSection(
                context, 
                'Made For You', 
                madeForYou, // Now uses real mix logic
                audioHandler, 
                theme,
              ),
              _buildGenresSection(
                context,
                'Genres & Moods',
                genresAndMoods,
                theme,
              ),
              _buildSection(
                context, 
                'Trending Online', 
                trending, 
                audioHandler, 
                theme,
              ),
              _buildSection(
                context, 
                'New Releases', 
                newReleases, 
                audioHandler, 
                theme,
              ),
              _buildSection(
                context, 
                'Top Charts', 
                charts, 
                audioHandler, 
                theme,
              ),
              _buildSection(
                context, 
                'Recently Played', 
                recentlyPlayed, 
                audioHandler, 
                theme,
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.offline_bolt, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'You are offline. Only local and downloaded music is available.',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            _buildSection(
              context, 
              'Recently Added (Local)', 
              recentlyAdded, 
              audioHandler, 
              theme,
            ),
            _buildSection(
              context, 
              'Local Music', 
              localTracks, 
              audioHandler, 
              theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenresSection(
    BuildContext context,
    String title,
    AsyncValue<List<OnlineItem>> state,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        state.when(
          data: (items) {
            if (items.isEmpty) return const SizedBox.shrink();
            
            // Render as horizontal chips or small cards
            return SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  // Use random bright colors for genres
                  final colorList = [
                    Colors.redAccent, Colors.blueAccent, Colors.green, 
                    Colors.orange, Colors.purple, Colors.teal, Colors.pink
                  ];
                  final cardColor = colorList[index % colorList.length].withValues(alpha: 0.8);
                  
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => GenrePlaylistsScreen(item: item)),
                      );
                    },
                    child: Container(
                      width: 140,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: CircularProgressIndicator(),
          ),
          error: (_, _) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, 
    String title, 
    AsyncValue<List<Track>> state, 
    AudioPlayerHandler audioHandler, 
    ThemeData theme
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        state.when(
          data: (tracks) {
            if (tracks.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('No tracks available.'),
              );
            }
            return SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: tracks.length,
                itemBuilder: (context, index) {
                  final track = tracks[index];
                  return GestureDetector(
                    onTap: () {
                      final mediaItems = tracks.map((t) => MediaItem(
                        id: t.id,
                        album: t.album,
                        title: t.title,
                        artist: t.artist,
                        duration: Duration(milliseconds: t.durationMs),
                        extras: {'url': t.dataUrl},
                        artUri: t.artworkUrl != null ? Uri.parse(t.artworkUrl!) : null,
                      )).toList();
                      audioHandler.loadPlaylist(mediaItems, initialIndex: index);
                    },
                    child: Container(
                      width: 140,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(12),
                              image: track.artworkUrl != null
                                  ? DecorationImage(
                                    image: CachedNetworkImageProvider(track.artworkUrl!, maxWidth: 300, maxHeight: 300),
                                    fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: track.artworkUrl == null
                                ? Icon(Icons.music_note, size: 40, color: theme.colorScheme.onSecondaryContainer)
                                : null,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            track.title,
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Error loading tracks: $err'),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
