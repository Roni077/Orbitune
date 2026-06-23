import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import 'package:go_router/go_router.dart';
import 'player_providers.dart';
import 'widgets/waveform_seek_bar.dart';
import 'widgets/advanced_controls.dart';
import 'widgets/lyrics_view.dart';
import '../queue/queue_sheet.dart';

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaItemAsync = ref.watch(currentMediaItemProvider);
    final playbackStateAsync = ref.watch(playbackStateProvider);

    final mediaItem = mediaItemAsync.valueOrNull;
    final playbackState = playbackStateAsync.valueOrNull;

    if (mediaItem == null) {
      return const Scaffold(
        body: Center(child: Text('No media playing')),
      );
    }

    final isPlaying = playbackState?.playing ?? false;
    final audioHandler = ref.read(audioHandlerProvider);
    final theme = Theme.of(context);
    final artPath = mediaItem.artUri?.toFilePath();

    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          // Swipe down to dismiss
          context.pop();
        }
      },
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          audioHandler.skipToPrevious();
        } else if (details.primaryVelocity! < 0) {
          audioHandler.skipToNext();
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.keyboard_arrow_down, size: 32),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.queue_music),
              onPressed: () {
                showQueueSheet(context);
              },
            ),
            IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                showAdvancedControls(context);
              },
            ),
          ],
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Blurred Dynamic Background
            if (artPath != null)
              Image.file(
                File(artPath),
                fit: BoxFit.cover,
              )
            else
              Container(color: theme.colorScheme.surface),
            
            // Blur overlay
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),
            
            // Content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    // Album Art with Hero & Lyrics via PageView
                    SizedBox(
                      height: MediaQuery.of(context).size.width * 0.9,
                      child: PageView(
                        children: [
                          Center(
                            child: Hero(
                              tag: 'album_art_${mediaItem.id}',
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.8,
                                height: MediaQuery.of(context).size.width * 0.8,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black45,
                                      blurRadius: 20,
                                      offset: Offset(0, 10),
                                    ),
                                  ],
                                  image: artPath != null
                                      ? DecorationImage(
                                          image: FileImage(File(artPath)),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                  color: theme.colorScheme.surfaceContainerHighest,
                                ),
                                child: artPath == null
                                    ? const Icon(Icons.music_note, size: 100, color: Colors.white54)
                                    : null,
                              ),
                            ),
                          ),
                          // Lyrics Page
                          if (mediaItem.extras?['uri'] != null)
                            LyricsView(audioFilePath: mediaItem.extras!['uri'])
                          else
                            const Center(child: Text('Lyrics not available')),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Title and Artist
                    Text(
                      mediaItem.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      mediaItem.artist ?? 'Unknown Artist',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Waveform Seek Bar
                    StreamBuilder<Duration>(
                      stream: AudioService.position,
                      builder: (context, snapshot) {
                        final position = snapshot.data ?? Duration.zero;
                        final duration = mediaItem.duration ?? const Duration(seconds: 1);
                        
                        return Column(
                          children: [
                            WaveformSeekBar(
                              position: position,
                              duration: duration,
                              seedString: mediaItem.id, // Deterministic seed
                              onChanged: (newPosition) {
                                audioHandler.seek(newPosition);
                              },
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(position),
                                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                                ),
                                Text(
                                  _formatDuration(duration),
                                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          iconSize: 32,
                          icon: const Icon(Icons.shuffle),
                          color: Colors.white70,
                          onPressed: () {
                            // TODO: Toggle shuffle
                          },
                        ),
                        IconButton(
                          iconSize: 48,
                          icon: const Icon(Icons.skip_previous),
                          onPressed: () => audioHandler.skipToPrevious(),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.primary,
                          ),
                          child: IconButton(
                            iconSize: 64,
                            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                            color: theme.colorScheme.onPrimary,
                            onPressed: () {
                              if (isPlaying) {
                                audioHandler.pause();
                              } else {
                                audioHandler.play();
                              }
                            },
                          ),
                        ),
                        IconButton(
                          iconSize: 48,
                          icon: const Icon(Icons.skip_next),
                          onPressed: () => audioHandler.skipToNext(),
                        ),
                        IconButton(
                          iconSize: 32,
                          icon: const Icon(Icons.repeat),
                          color: Colors.white70,
                          onPressed: () {
                            // TODO: Toggle repeat
                          },
                        ),
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0
        ? '${duration.inHours}:$minutes:$seconds'
        : '$minutes:$seconds';
  }
}
