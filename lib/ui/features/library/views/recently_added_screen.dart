import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import '../../../../domain/repositories/track_repository.dart';
import '../../../../services/audio/audio_service_provider.dart';

final recentlyAddedLibraryProvider = FutureProvider((ref) async {
  final repo = ref.watch(trackRepositoryProvider);
  final result = await repo.getRecentlyAdded(limit: 50);
  return result.getOrElse((_) => []);
});

class RecentlyAddedScreen extends ConsumerWidget {
  const RecentlyAddedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recentlyAddedLibraryProvider);
    final theme = Theme.of(context);
    final audioHandler = ref.read(audioHandlerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recently Added'),
      ),
      body: state.when(
        data: (tracks) {
          if (tracks.isEmpty) {
            return const Center(child: Text('No recently added tracks.'));
          }
          return ListView.builder(
            itemCount: tracks.length,
            itemBuilder: (context, index) {
              final track = tracks[index];
              return ListTile(
                leading: track.artworkUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(imageUrl: track.artworkUrl!, width: 50, height: 50, fit: BoxFit.cover),
                      )
                    : Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.music_note, color: theme.colorScheme.onSecondaryContainer),
                      ),
                title: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(track.artist, maxLines: 1, overflow: TextOverflow.ellipsis),
                onTap: () async {
                  final mediaItem = MediaItem(
                    id: track.id,
                    album: track.album,
                    title: track.title,
                    artist: track.artist,
                    duration: Duration(milliseconds: track.durationMs),
                    extras: {'url': track.dataUrl},
                    artUri: track.artworkUrl != null ? Uri.parse(track.artworkUrl!) : null,
                  );
                  await audioHandler.loadPlaylist([mediaItem]);
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
}
