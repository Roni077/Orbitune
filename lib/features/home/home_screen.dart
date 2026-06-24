import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:audio_service/audio_service.dart';
import '../../core/providers.dart';
import '../player/player_providers.dart';
import '../library/library_providers.dart';
import '../../widgets/glass_container.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final recentlyAddedAsync = ref.watch(recentlyAddedProvider);
    final totalSongsAsync = ref.watch(songsStreamProvider);
    final isScanning = ref.watch(isScanningProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Orbitune', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              context.push('/search');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.read(isScanningProvider.notifier).state = true;
          try {
            await ref.read(mediaScannerServiceProvider).scanAndSaveAudios();
          } finally {
            ref.read(isScanningProvider.notifier).state = false;
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isScanning)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16.0),
                  child: LinearProgressIndicator(),
                ),

              // 1. Usage Dashboard
              Text('Your Library', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              totalSongsAsync.when(
                data: (songs) {
                  final uniqueArtists = songs.map((s) => s.artist).toSet().length;
                  final uniqueAlbums = songs.map((s) => s.album).toSet().length;

                  return Row(
                    children: [
                      Expanded(child: _buildStatCard(context, 'Songs', songs.length.toString(), Icons.music_note)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard(context, 'Artists', uniqueArtists.toString(), Icons.person)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard(context, 'Albums', uniqueAlbums.toString(), Icons.album)),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, st) => Text('Error: $e'),
              ),

              const SizedBox(height: 32),

              // 2. Recently Added Carousel
              Text('Recently Added', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              recentlyAddedAsync.when(
                data: (recentSongs) {
                  if (recentSongs.isEmpty) {
                    return const Text('No recent songs found.');
                  }
                  return SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: recentSongs.length,
                      itemBuilder: (context, index) {
                        final song = recentSongs[index];
                        return GestureDetector(
                          onTap: () async {
                            final audioHandler = ref.read(audioHandlerProvider);
                            final queue = recentSongs.map((s) => MediaItem(
                              id: s.id.toString(),
                              title: s.title,
                              artist: s.artist,
                              album: s.album,
                              duration: Duration(milliseconds: s.durationMs),
                              artUri: s.albumArtPath != null ? Uri.file(s.albumArtPath!) : null,
                              extras: {'uri': s.uri},
                            )).toList();
                            
                            await audioHandler.updateQueue(queue);
                            await audioHandler.playMediaItem(queue[index]);
                          },
                          child: Container(
                            width: 140,
                            margin: const EdgeInsets.only(right: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GlassContainer(
                                  width: 140,
                                  height: 140,
                                  borderRadius: BorderRadius.circular(16),
                                  child: song.albumArtPath != null && song.albumArtPath!.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(16),
                                          child: Image.file(
                                            File(song.albumArtPath!),
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : const Icon(Icons.music_note, size: 50, color: Colors.white54),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  song.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
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
                error: (e, st) => Text('Error: $e'),
              ),

              const SizedBox(height: 32),

              // 3. Quick Actions
              Text('Quick Actions', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.shuffle),
                title: const Text('Shuffle All'),
                tileColor: theme.colorScheme.surfaceContainerHighest,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onTap: () {
                  // TODO: Play all songs shuffled
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon) {
    final theme = Theme.of(context);
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 28),
          const SizedBox(height: 8),
          Text(value, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          Text(title, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
