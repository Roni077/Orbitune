import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import '../../../../services/audio/audio_service_provider.dart';
import 'now_playing_screen.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioHandler = ref.read(audioHandlerProvider);
    final theme = Theme.of(context);

    return StreamBuilder<MediaItem?>(
      stream: audioHandler.mediaItem,
      builder: (context, mediaSnapshot) {
        final mediaItem = mediaSnapshot.data;
        if (mediaItem == null) return const SizedBox.shrink();

        return StreamBuilder<PlaybackState>(
          stream: audioHandler.playbackState,
          builder: (context, playbackSnapshot) {
            final state = playbackSnapshot.data;
            final isPlaying = state?.playing ?? false;

            return Dismissible(
              key: ValueKey('mini_player_${mediaItem.id}'),
              direction: DismissDirection.horizontal,
              onDismissed: (_) {
                audioHandler.stop();
              },
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const NowPlayingScreen(),
                      fullscreenDialog: true,
                    ),
                  );
                },
                child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                        image: mediaItem.artUri != null
                            ? DecorationImage(
                                image: CachedNetworkImageProvider(mediaItem.artUri!.toString()),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: mediaItem.artUri == null
                          ? Icon(Icons.music_note, color: theme.colorScheme.onPrimaryContainer)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            mediaItem.title,
                            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            mediaItem.artist ?? '',
                            style: theme.textTheme.bodySmall,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_previous),
                      onPressed: () => audioHandler.skipToPrevious(),
                    ),
                    IconButton(
                      icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill, size: 36),
                      color: theme.colorScheme.primary,
                      onPressed: () {
                        if (isPlaying) {
                          audioHandler.pause();
                        } else {
                          audioHandler.play();
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next),
                      onPressed: () => audioHandler.skipToNext(),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
