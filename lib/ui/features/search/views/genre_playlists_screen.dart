import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/online_item.dart';
import '../../../../core/helpers/providers.dart';
import '../../../core/widgets/loading_skeleton.dart';
import 'online_details_screen.dart';

final moodPlaylistsProvider = FutureProvider.family<List<OnlineItem>, String>((ref, params) async {
  final service = ref.read(onlineAudioServiceProvider);
  final res = await service.getMoodPlaylists(params);
  return res.getOrElse((_) => []);
});

class GenrePlaylistsScreen extends ConsumerWidget {
  final OnlineItem item;

  const GenrePlaylistsScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final playlistsState = ref.watch(moodPlaylistsProvider(item.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
      ),
      body: playlistsState.when(
        data: (playlists) {
          if (playlists.isEmpty) {
            return const Center(child: Text('No playlists found.'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OnlineDetailsScreen(item: playlist),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                          image: playlist.artworkUrl != null
                              ? DecorationImage(
                                  image: CachedNetworkImageProvider(playlist.artworkUrl!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: playlist.artworkUrl == null
                            ? Icon(Icons.playlist_play, size: 48, color: theme.colorScheme.onSecondaryContainer)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      playlist.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (playlist.subtitle != null)
                      Text(
                        playlist.subtitle!,
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            return const LoadingSkeleton(width: double.infinity, height: double.infinity, borderRadius: 12);
          },
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
