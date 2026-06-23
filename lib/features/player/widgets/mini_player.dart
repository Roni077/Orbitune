import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import 'package:go_router/go_router.dart';
import '../player_providers.dart';
import '../../../widgets/glass_container.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaItemAsync = ref.watch(currentMediaItemProvider);
    final playbackStateAsync = ref.watch(playbackStateProvider);

    final mediaItem = mediaItemAsync.valueOrNull;
    final playbackState = playbackStateAsync.valueOrNull;

    if (mediaItem == null) {
      return const SizedBox.shrink(); // Hide if nothing is playing/queued
    }

    final isPlaying = playbackState?.playing ?? false;
    final audioHandler = ref.read(audioHandlerProvider);
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        context.push('/player');
      },
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          audioHandler.skipToPrevious();
        } else if (details.primaryVelocity! < 0) {
          audioHandler.skipToNext();
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: GlassContainer(
          borderRadius: BorderRadius.circular(12),
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Hero(
                    tag: 'album_art_${mediaItem.id}',
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: mediaItem.artUri != null
                            ? DecorationImage(
                                image: FileImage(File(mediaItem.artUri!.toFilePath())),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: theme.colorScheme.surfaceContainerHighest,
                      ),
                      child: mediaItem.artUri == null
                          ? const Icon(Icons.music_note, color: Colors.white54)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          mediaItem.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          mediaItem.artist ?? 'Unknown Artist',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
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
                ],
              ),
              const SizedBox(height: 6),
              // Linear Progress Bar using AudioService.position stream
              StreamBuilder<Duration>(
                stream: AudioService.position,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final duration = mediaItem.duration ?? const Duration(seconds: 1);
                  final progress = (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
                  
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: progress.isNaN ? 0.0 : progress,
                      minHeight: 3,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
