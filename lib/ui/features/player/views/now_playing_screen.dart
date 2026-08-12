import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import '../../../../services/audio/audio_service_provider.dart';
import '../../../core/widgets/seek_bar.dart';
import 'equalizer_screen.dart';
import '../../../../services/downloads/download_manager.dart';
import '../../library/viewmodels/favorites_viewmodel.dart';
import '../../../../domain/entities/track.dart';
import 'queue_screen.dart';
import 'lyrics_screen.dart';
import '../../../../services/audio/sleep_timer_service.dart';

class NowPlayingScreen extends ConsumerStatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  ConsumerState<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends ConsumerState<NowPlayingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showSleepTimerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final sleepTimer = ref.read(sleepTimerServiceProvider);
        
        void setTimer(int minutes) {
          sleepTimer.startTimer(Duration(minutes: minutes));
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sleep timer set for $minutes minutes')),
          );
        }

        return AlertDialog(
          title: const Text('Sleep Timer'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final minutes in [5, 10, 15, 30, 45, 60])
                  ListTile(
                    title: Text('$minutes Minutes'),
                    onTap: () => setTimer(minutes),
                  ),
                ListTile(
                  title: const Text('End of current song'),
                  onTap: () {
                    sleepTimer.startTimerForEndOfSong();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Playback will stop after this song')),
                    );
                  },
                ),
                ListTile(
                  title: const Text('Custom...'),
                  onTap: () {
                    Navigator.pop(context);
                    _showCustomTimerDialog(context);
                  },
                ),
                const Divider(),
                ListTile(
                  title: const Text('Cancel Timer', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    sleepTimer.cancelTimer();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sleep timer cancelled')),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCustomTimerDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Custom Timer'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Minutes',
              hintText: 'Enter duration in minutes',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final mins = int.tryParse(controller.text);
                if (mins != null && mins > 0) {
                  ref.read(sleepTimerServiceProvider).startTimer(Duration(minutes: mins));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Sleep timer set for $mins minutes')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid number')),
                  );
                }
              },
              child: const Text('Start'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioHandler = ref.read(audioHandlerProvider);
    final theme = Theme.of(context);
    // Removed direct downloadService access
    return StreamBuilder<MediaItem?>(
      stream: audioHandler.mediaItem,
      builder: (context, mediaSnapshot) {
        final mediaItem = mediaSnapshot.data;
        if (mediaItem == null) {
          return const Scaffold(body: Center(child: Text('No track playing')));
        }

        return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing', style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'Share',
            onPressed: () {
              SharePlus.instance.share(ShareParams(text: 'Listening to ${mediaItem.title} by ${mediaItem.artist} on Orbitune! 🎵'));
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Download',
            onPressed: () {
              ref.read(downloadManagerProvider.notifier).enqueue(mediaItem);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Added "${mediaItem.title}" to download queue')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Equalizer',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const EqualizerScreen()),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'queue') {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const QueueScreen()),
                );
              } else if (value == 'sleep_timer') {
                _showSleepTimerDialog(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'queue',
                child: Row(
                  children: [
                    Icon(Icons.queue_music),
                    SizedBox(width: 8),
                    Text('Up Next'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'sleep_timer',
                child: Row(
                  children: [
                    Icon(Icons.timer),
                    SizedBox(width: 8),
                    Text('Sleep Timer'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Artwork
                StreamBuilder<PlaybackState>(
                  stream: audioHandler.playbackState,
                  builder: (context, playbackSnapshot) {
                    final isPlaying = playbackSnapshot.data?.playing ?? false;
                    if (isPlaying) {
                      _animationController.repeat();
                    } else {
                      _animationController.stop();
                    }

                    return RotationTransition(
                      turns: _animationController,
                      child: Container(
                        width: MediaQuery.of(context).size.width - 48,
                        height: MediaQuery.of(context).size.width - 48,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          shape: BoxShape.circle,
                          image: mediaItem.artUri != null
                              ? DecorationImage(
                                  image: CachedNetworkImageProvider(mediaItem.artUri!.toString()),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.shadow.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: mediaItem.artUri == null
                            ? Icon(Icons.music_note, size: 100, color: theme.colorScheme.onSecondaryContainer)
                            : null,
                      ),
                    );
                  }
                ),
                const SizedBox(height: 16),
                
                // Audio Quality Indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: mediaItem.id.startsWith('yt:')
                        ? Colors.blue.withValues(alpha: 0.2)
                        : Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    mediaItem.id.startsWith('yt:') ? 'HQ Stream' : 'Local Audio',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: mediaItem.id.startsWith('yt:') ? Colors.blue : Colors.green,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Title & Artist with Favorite Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 48), // Balance for favorite icon
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            mediaItem.title,
                            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            mediaItem.artist ?? 'Unknown Artist',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Consumer(
                      builder: (context, ref, child) {
                        final favState = ref.watch(favoritesViewModelProvider);
                        final isFav = favState.contains(mediaItem.id);
                        return IconButton(
                          icon: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.red : theme.colorScheme.onSurface,
                          ),
                          onPressed: () {
                            // Recreate a Track object to add to favorites
                            final track = Track(
                              id: mediaItem.id,
                              title: mediaItem.title,
                              artist: mediaItem.artist ?? 'Unknown Artist',
                              album: mediaItem.album ?? 'Single',
                              durationMs: mediaItem.duration?.inMilliseconds ?? 0,
                              source: TrackSource.online, // Defaults to online, repository resolves actual source
                              dataUrl: mediaItem.extras?['url'] as String? ?? mediaItem.id,
                              artworkUrl: mediaItem.artUri?.toString(),
                            );
                            ref.read(favoritesViewModelProvider.notifier).toggleFavorite(track);
                          },
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Seek Bar
                StreamBuilder<PlaybackState>(
                  stream: audioHandler.playbackState,
                  builder: (context, stateSnapshot) {
                    final state = stateSnapshot.data;
                    final position = state?.updatePosition ?? Duration.zero;
                    final buffered = state?.bufferedPosition ?? Duration.zero;
                    final duration = mediaItem.duration ?? Duration.zero;

                    return SeekBar(
                      duration: duration,
                      position: position,
                      bufferedPosition: buffered,
                      onChangeEnd: (newPosition) {
                        audioHandler.seek(newPosition);
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Controls
                StreamBuilder<PlaybackState>(
                  stream: audioHandler.playbackState,
                  builder: (context, stateSnapshot) {
                    final state = stateSnapshot.data;
                    final isPlaying = state?.playing ?? false;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(
                            state?.shuffleMode == AudioServiceShuffleMode.all 
                                ? Icons.shuffle_on 
                                : Icons.shuffle,
                          ),
                          color: state?.shuffleMode == AudioServiceShuffleMode.all
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          onPressed: () {
                            final mode = state?.shuffleMode == AudioServiceShuffleMode.all 
                                ? AudioServiceShuffleMode.none 
                                : AudioServiceShuffleMode.all;
                            audioHandler.setShuffleMode(mode);
                          },
                        ),
                        IconButton(
                          iconSize: 48,
                          icon: const Icon(Icons.skip_previous),
                          onPressed: () => audioHandler.skipToPrevious(),
                        ),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            iconSize: 48,
                            color: theme.colorScheme.onPrimary,
                            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
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
                          icon: Icon(
                            state?.repeatMode == AudioServiceRepeatMode.all
                                ? Icons.repeat_on
                                : (state?.repeatMode == AudioServiceRepeatMode.one 
                                    ? Icons.repeat_one_on 
                                    : Icons.repeat),
                          ),
                          color: state?.repeatMode != AudioServiceRepeatMode.none
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          onPressed: () {
                            AudioServiceRepeatMode mode;
                            if (state?.repeatMode == AudioServiceRepeatMode.none) {
                              mode = AudioServiceRepeatMode.all;
                            } else if (state?.repeatMode == AudioServiceRepeatMode.all) {
                              mode = AudioServiceRepeatMode.one;
                            } else {
                              mode = AudioServiceRepeatMode.none;
                            }
                            audioHandler.setRepeatMode(mode);
                          },
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                
                // Volume & Speed Controls
                VolumeControlWidget(audioHandler: audioHandler),
                const SizedBox(height: 16),
                StreamBuilder<PlaybackState>(
                  stream: audioHandler.playbackState,
                  builder: (context, snapshot) {
                    final speed = snapshot.data?.speed ?? 1.0;
                    return SpeedControlWidget(audioHandler: audioHandler, currentSpeed: speed);
                  },
                ),
                const SizedBox(height: 32),
                // Lyrics Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => LyricsScreen(mediaItem: mediaItem),
                        ),
                      );
                    },
                    icon: const Icon(Icons.lyrics),
                    label: const Text('Show Lyrics'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}

class VolumeControlWidget extends ConsumerStatefulWidget {
  final AudioHandler audioHandler;
  const VolumeControlWidget({super.key, required this.audioHandler});

  @override
  ConsumerState<VolumeControlWidget> createState() => _VolumeControlWidgetState();
}

class _VolumeControlWidgetState extends ConsumerState<VolumeControlWidget> {
  double _volume = 1.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.volume_down, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
        Expanded(
          child: Slider(
            value: _volume,
            min: 0.0,
            max: 1.0,
            onChanged: (val) {
              setState(() => _volume = val);
              widget.audioHandler.customAction('setVolume', {'volume': val});
            },
          ),
        ),
        Icon(Icons.volume_up, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
      ],
    );
  }
}

class SpeedControlWidget extends ConsumerWidget {
  final AudioHandler audioHandler;
  final double currentSpeed;
  const SpeedControlWidget({super.key, required this.audioHandler, required this.currentSpeed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Playback Speed', style: theme.textTheme.titleMedium),
        DropdownButton<double>(
          value: currentSpeed,
          underline: const SizedBox(),
          items: const [
            DropdownMenuItem(value: 0.5, child: Text('0.5x')),
            DropdownMenuItem(value: 0.8, child: Text('0.8x')),
            DropdownMenuItem(value: 1.0, child: Text('Normal')),
            DropdownMenuItem(value: 1.2, child: Text('1.2x')),
            DropdownMenuItem(value: 1.5, child: Text('1.5x')),
            DropdownMenuItem(value: 2.0, child: Text('2.0x')),
          ],
          onChanged: (val) {
            if (val != null) {
              audioHandler.setSpeed(val);
            }
          },
        ),
      ],
    );
  }
}
