import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/track.dart';
import '../../../../domain/repositories/history_repository.dart';
import '../../../../services/audio/audio_service_provider.dart';

final historyProvider = FutureProvider<List<Track>>((ref) async {
  final historyRepo = ref.read(historyRepositoryProvider);
  final result = await historyRepo.getPlaybackHistory(limit: 100);
  return result.fold(
    (l) => [],
    (r) => r,
  );
});

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(historyProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Listening History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Clear History',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear History'),
                  content: const Text('Are you sure you want to clear your listening history?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('CANCEL'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('CLEAR'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                final historyRepo = ref.read(historyRepositoryProvider);
                await historyRepo.clearHistory();
                ref.invalidate(historyProvider);
              }
            },
          ),
        ],
      ),
      body: historyState.when(
        data: (tracks) {
          if (tracks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 80, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text(
                    'No history yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(historyProvider);
            },
            child: ListView.builder(
              itemCount: tracks.length,
              itemBuilder: (context, index) {
                final track = tracks[index];
                return ListTile(
                  leading: track.artworkUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(imageUrl: track.artworkUrl!, width: 50, height: 50, memCacheWidth: 150, memCacheHeight: 150, fit: BoxFit.cover),
                        )
                      : Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.music_note),
                        ),
                  title: Text(track.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text(track.artist, maxLines: 1, overflow: TextOverflow.ellipsis),
                  onTap: () {
                    final audioHandler = ref.read(audioHandlerProvider);
                    audioHandler.playFromMediaId(track.id);
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
