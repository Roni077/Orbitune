// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import '../../domain/repositories/track_repository.dart';
import '../../domain/repositories/history_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../metadata/online_audio_service.dart';

class AudioPlayerHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final AndroidEqualizer equalizer = AndroidEqualizer();
  final AndroidLoudnessEnhancer loudnessEnhancer = AndroidLoudnessEnhancer();
  late final AudioPlayer _player;
  final TrackRepository _trackRepository;
  final SharedPreferences _prefs;
  final OnlineAudioService _onlineAudioService;
  StreamSubscription<Duration>? _positionSubscription;
  bool _stopAfterCurrentSong = false;
  final HistoryRepository _historyRepository;
  
  bool _isFetchingAutoplay = false;

  double get pitch => _player.pitch;

  AudioPlayerHandler(this._trackRepository, this._prefs, this._onlineAudioService, this._historyRepository) {
    _player = AudioPlayer(
      audioPipeline: AudioPipeline(
        androidAudioEffects: [
          equalizer,
          loudnessEnhancer,
        ],
      ),
    );
    _notifyAudioHandlerAboutPlaybackEvents();
    _listenForDurationChanges();
    _listenForSequenceStateChanges();
    _listenForCurrentSongChanges();
    _listenForCrossfade();
  }

  void _listenForCrossfade() {
    _positionSubscription = _player.positionStream.listen((position) {
      final crossfadeDurationSeconds = _prefs.getInt('crossfade_duration') ?? 0;
      if (crossfadeDurationSeconds == 0) {
        if (_player.volume != 1.0) {
          _player.setVolume(1.0);
        }
        return;
      }

      final duration = _player.duration;
      if (duration == null) return;

      final crossfadeDurationMs = crossfadeDurationSeconds * 1000;
      final remainingMs = duration.inMilliseconds - position.inMilliseconds;
      
      // Fade Out Logic
      if (remainingMs <= crossfadeDurationMs && remainingMs > 0) {
        final volume = remainingMs / crossfadeDurationMs;
        _player.setVolume(volume.clamp(0.0, 1.0));
      } 
      // Fade In Logic (start of song)
      else if (position.inMilliseconds <= crossfadeDurationMs && position.inMilliseconds > 0) {
        final volume = position.inMilliseconds / crossfadeDurationMs;
        _player.setVolume(volume.clamp(0.0, 1.0));
      } 
      // Normal Playback
      else {
        if (_player.volume != 1.0) {
          _player.setVolume(1.0);
        }
      }
    });
  }

  void _listenForCurrentSongChanges() {
    _player.currentIndexStream.listen((index) async {
      if (index != null && index < queue.value.length) {
        if (_stopAfterCurrentSong) {
          _stopAfterCurrentSong = false;
          await _player.pause();
          // Reset to start of the track so if user resumes, it starts from beginning
          await _player.seek(Duration.zero);
          return; // Skip history marking and autoplay for now, wait for explicit play
        }

        final item = queue.value[index];
        final pauseHistory = _prefs.getBool('pause_history') ?? false;
        if (!pauseHistory) {
          _trackRepository.markTrackAsPlayed(item.id);
        }
        
        // Autoplay logic
        final autoplay = _prefs.getBool('autoplay') ?? true;
        if (autoplay && index == queue.value.length - 1 && !_isFetchingAutoplay) {
          if (item.id.startsWith('yt:')) {
            _isFetchingAutoplay = true;
            final result = await _onlineAudioService.getRelatedTracks(item.id.replaceAll('yt:', ''));
            result.fold(
              (failure) => null,
              (tracks) {
                final mediaItems = tracks.take(10).map((t) => MediaItem(
                  id: t.dataUrl,
                  title: t.title,
                  artist: t.artist,
                  album: t.album,
                  duration: Duration(milliseconds: t.durationMs),
                  artUri: t.artworkUrl != null ? Uri.parse(t.artworkUrl!) : null,
                  extras: {
                    'source': t.source.toString(),
                  },
                )).toList();
                
                if (mediaItems.isNotEmpty) {
                  addQueueItems(mediaItems);
                }
              },
            );
            _isFetchingAutoplay = false;
          }
        }
      }
    });
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
      ));
    }, onError: (Object e, StackTrace stackTrace) {
      if (e is PlayerException) {
        customEvent.add({
          'type': 'error',
          'message': 'Playback error: ${e.message}',
          'code': e.code.toString(),
        });
      } else {
        customEvent.add({
          'type': 'error',
          'message': 'An unknown playback error occurred.',
        });
      }
    });
  }

  void _listenForDurationChanges() {
    _player.durationStream.listen((duration) {
      final index = _player.currentIndex;
      final newQueue = queue.value;
      if (index == null || newQueue.isEmpty) return;
      if (_player.shuffleModeEnabled) {
        // Handle shuffle indexing if needed
      }
      final oldMediaItem = newQueue[index];
      final newMediaItem = oldMediaItem.copyWith(duration: duration);
      newQueue[index] = newMediaItem;
      queue.add(newQueue);
      mediaItem.add(newMediaItem);
    });
  }

  void _listenForSequenceStateChanges() {
    _player.sequenceStateStream.listen((SequenceState? sequenceState) {
      final sequence = sequenceState?.effectiveSequence;
      if (sequence == null || sequence.isEmpty) return;
      final items = sequence.map((b) => b.tag as MediaItem).toList();
      queue.add(items);
    });
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    final position = _player.position;
    final duration = _player.duration;
    if (position.inSeconds < 15 || (duration != null && position.inMilliseconds < duration.inMilliseconds * 0.1)) {
      final currentItem = mediaItem.value;
      if (currentItem != null) {
        await _historyRepository.incrementSkipCount(currentItem.id);
      }
    }
    return _player.seekToNext();
  }

  @override
  Future<void> skipToPrevious() async {
    final position = _player.position;
    final duration = _player.duration;
    if (position.inSeconds < 15 || (duration != null && position.inMilliseconds < duration.inMilliseconds * 0.1)) {
      final currentItem = mediaItem.value;
      if (currentItem != null) {
        await _historyRepository.incrementSkipCount(currentItem.id);
      }
    }
    return _player.seekToPrevious();
  }

  @override
  Future<void> stop() async {
    await _positionSubscription?.cancel();
    await _player.stop();
    return super.stop();
  }

  // Set the playlist and start playing
  Future<void> loadPlaylist(List<MediaItem> mediaItems, {int initialIndex = 0}) async {
    if (mediaItems.isEmpty) return;
    
    final playlist = ConcatenatingAudioSource(children: []);
    await _player.setAudioSource(playlist);
    
    // 1. Resolve and play the clicked item IMMEDIATELY
    final clickedItem = mediaItems[initialIndex];
    final initialSource = await _resolveAudioSource(clickedItem);
    await playlist.add(initialSource);
    
    // We only added 1 item, so index is 0 in the actual player queue
    await _player.seek(Duration.zero, index: 0);

    // 2. Resolve the rest of the items in the background
    _resolveAndEnqueue(mediaItems, initialIndex, playlist);
  }

  Future<AudioSource> _resolveAudioSource(MediaItem item) async {
    var url = item.extras?['url'] as String?;
    
    // Fallback to the ID if dataUrl is empty or null (which is the case for online tracks)
    if (url == null || url.isEmpty) {
      url = item.id;
    }
    
    if (url.startsWith('yt:')) {
      url = url.substring(3);
    }
    
    // If it's a raw video ID (doesn't start with http or a local file slash), route it to our proxy
    if (!url.startsWith('http') && !url.startsWith('/')) {
      final proxyUrl = 'http://127.0.0.1:8080/?videoId=$url';
      // ignore: experimental_member_use
      return LockCachingAudioSource(
        Uri.parse(proxyUrl), 
        tag: item,
      );
    }
    
    if (url.startsWith('http')) {
      // ignore: experimental_member_use
      return LockCachingAudioSource(
        Uri.parse(url), 
        tag: item,
      );
    } else {
      // It's a local downloaded file path
      if (!url.startsWith('file://')) {
        url = 'file://$url';
      }
      return AudioSource.uri(
        Uri.parse(url), 
        tag: item,
      );
    }
  }

  Future<void> _resolveAndEnqueue(List<MediaItem> mediaItems, int initialIndex, ConcatenatingAudioSource playlist) async {
    // Add items after the initial index
    for (int i = initialIndex + 1; i < mediaItems.length; i++) {
      final source = await _resolveAudioSource(mediaItems[i]);
      await playlist.add(source);
    }
    // Add items before the initial index (if the user wants to go back)
    for (int i = 0; i < initialIndex; i++) {
      final source = await _resolveAudioSource(mediaItems[i]);
      await playlist.insert(i, source);
    }
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= queue.value.length) return;
    await _player.seek(Duration.zero, index: index);
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    final playlist = _player.audioSource as ConcatenatingAudioSource?;
    if (playlist != null) {
      for (final item in mediaItems) {
        final source = await _resolveAudioSource(item);
        await playlist.add(source);
      }
    }
    // No need to manually update queue, sequenceStateStream will handle it
  }

  @override
  Future<void> removeQueueItem(MediaItem mediaItem) async {
    final index = queue.value.indexOf(mediaItem);
    if (index != -1) {
      final playlist = _player.audioSource as ConcatenatingAudioSource?;
      if (playlist != null) {
        await playlist.removeAt(index);
      }
    }
  }

  @override
  Future<void> customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name == 'stopAfterCurrentSong') {
      _stopAfterCurrentSong = true;
    } else if (name == 'cancelSleepTimer') {
      _stopAfterCurrentSong = false;
    } else if (name == 'moveQueueItem' && extras != null) {
      final currentIndex = extras['currentIndex'] as int?;
      final newIndex = extras['newIndex'] as int?;
      if (currentIndex != null && newIndex != null) {
        final playlist = _player.audioSource as ConcatenatingAudioSource?;
        if (playlist != null) {
          await playlist.move(currentIndex, newIndex);
        }
      }
    } else if (name == 'setVolume' && extras != null) {
      final volume = (extras['volume'] as num?)?.toDouble();
      if (volume != null) {
        await _player.setVolume(volume);
      }
    }
    return super.customAction(name, extras);
  }

  @override
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
    return super.setSpeed(speed);
  }

  Future<void> setPitch(double pitch) async {
    await _player.setPitch(pitch);
  }
}
