import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import '../../../../services/audio/audio_service_provider.dart';
import '../../../../services/audio/audio_player_handler.dart';
import '../viewmodels/home_viewmodel.dart';
import '../../../../domain/entities/track.dart';
import '../../../../domain/entities/online_item.dart';
import '../../search/views/genre_playlists_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

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
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Text(
                getGreeting(),
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
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
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primaryContainer,
                            theme.colorScheme.secondaryContainer,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          if (track.artworkUrl != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: CachedNetworkImage(
                                imageUrl: track.artworkUrl!,
                                width: 64,
                                height: 64,
                                memCacheWidth: 150,
                                memCacheHeight: 150,
                                fit: BoxFit.cover,
                              ),
                            )
                          else
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.music_note),
                            ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Continue Listening', 
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  track.title, 
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18), 
                                  maxLines: 1, 
                                  overflow: TextOverflow.ellipsis
                                ),
                                Text(
                                  track.artist, 
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant
                                  ), 
                                  maxLines: 1, 
                                  overflow: TextOverflow.ellipsis
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Icon(Icons.play_arrow, size: 28, color: theme.colorScheme.onPrimary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, delay: 100.ms);
              },
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
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
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ),
        state.when(
          data: (items) {
            if (items.isEmpty) return const SizedBox.shrink();
            
            // Render as horizontal chips or small cards
            return SizedBox(
              height: 140,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              letterSpacing: 0.5,
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
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
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
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      width: 150,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.shadow.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
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
                          const SizedBox(height: 12),
                          Text(
                            track.title,
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            track.artist,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: (50 * (index % 10)).ms).slideX(begin: 0.1);
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
