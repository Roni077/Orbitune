import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrbituneAudioHandler extends BaseAudioHandler with SeekHandler {
  final AndroidEqualizer equalizer = AndroidEqualizer();
  final AndroidLoudnessEnhancer loudnessEnhancer = AndroidLoudnessEnhancer();
  
  late final AudioPlayer _player;
  // ignore: deprecated_member_use
  final ConcatenatingAudioSource _playlist = ConcatenatingAudioSource(children: []);
  Timer? _sleepTimer;
  final SharedPreferences prefs;

  OrbituneAudioHandler(this.prefs) {
    _player = AudioPlayer(
      audioPipeline: AudioPipeline(
        androidAudioEffects: [
          equalizer,
          loudnessEnhancer,
        ],
      ),
    );
    _init();
  }

  Future<void> _init() async {
    // Apply saved EQ settings
    equalizer.setEnabled(prefs.getBool('eq_enabled') ?? false);
    loudnessEnhancer.setEnabled(prefs.getBool('loudness_enabled') ?? false);
    
    final loudnessGain = prefs.getDouble('loudness_gain');
    if (loudnessGain != null) {
      loudnessEnhancer.setTargetGain(loudnessGain);
    }

    // Wait for the pipeline to start processing so parameters become available
    // FutureBuilder in EqualizerScreen will handle loading. 
    // We can't synchronously wait for parameters here because it stalls init if no audio is playing.
    try {
      final params = await equalizer.parameters;
      for (int i = 0; i < params.bands.length; i++) {
        final gain = prefs.getDouble('eq_band_$i');
        if (gain != null) {
          params.bands[i].setGain(gain);
        }
      }
    } catch (e) {
      // Ignored if unsupported
    }

    // Configure audio session for background playback and audio focus ducking
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // Listen to audio session interruptions (e.g., phone call, other apps)
    session.interruptionEventStream.listen((event) {
      if (event.begin) {
        switch (event.type) {
          case AudioInterruptionType.duck:
            _player.setVolume(0.5);
            break;
          case AudioInterruptionType.pause:
          case AudioInterruptionType.unknown:
            pause();
            break;
        }
      } else {
        switch (event.type) {
          case AudioInterruptionType.duck:
            _player.setVolume(1.0);
            break;
          case AudioInterruptionType.pause:
            play();
            break;
          case AudioInterruptionType.unknown:
            break;
        }
      }
    });

    try {
      await _player.setAudioSource(_playlist);
    } catch (e) {
      debugPrint("Error loading audio source: $e");
    }

    // Broadcast playback state changes to the OS
    _player.playbackEventStream.listen(_broadcastState);
    
    // Broadcast current media item changes to the OS
    _player.currentIndexStream.listen((index) {
      if (index != null && queue.value.isNotEmpty && index < queue.value.length) {
        mediaItem.add(queue.value[index]);
      }
    });
  }

  void _broadcastState(PlaybackEvent event) {
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
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
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    ));
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }

  @override
  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  Future<void> setPitch(double pitch) async {
    await _player.setPitch(pitch);
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    final audioSources = mediaItems.map(_createAudioSource).toList();
    await _playlist.addAll(audioSources);
    
    final newQueue = queue.value..addAll(mediaItems);
    queue.add(newQueue);
  }

  @override
  Future<void> updateQueue(List<MediaItem> queue) async {
    await _playlist.clear();
    final audioSources = queue.map(_createAudioSource).toList();
    await _playlist.addAll(audioSources);
    
    super.queue.add(queue);
  }

  Future<void> moveQueueItem(int oldIndex, int newIndex) async {
    if (oldIndex < 0 || oldIndex >= queue.value.length) return;
    if (newIndex < 0 || newIndex >= queue.value.length) return;

    await _playlist.move(oldIndex, newIndex);
    
    final newQueue = List<MediaItem>.from(queue.value);
    final item = newQueue.removeAt(oldIndex);
    newQueue.insert(newIndex, item);
    queue.add(newQueue);
  }

  @override
  Future<void> insertQueueItem(int index, MediaItem mediaItem) async {
    if (index < 0) index = 0;
    if (index > queue.value.length) index = queue.value.length;

    await _playlist.insert(index, _createAudioSource(mediaItem));
    
    final newQueue = List<MediaItem>.from(queue.value);
    newQueue.insert(index, mediaItem);
    queue.add(newQueue);
  }

  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    final index = queue.value.indexWhere((item) => item.id == mediaItem.id);
    if (index != -1) {
      await _player.seek(Duration.zero, index: index);
      play();
    }
  }

  AudioSource _createAudioSource(MediaItem mediaItem) {
    return AudioSource.uri(
      Uri.parse(mediaItem.id),
      tag: mediaItem,
    );
  }

  // Set a sleep timer that stops playback after the duration
  void startSleepTimer(Duration duration) {
    _sleepTimer?.cancel();
    _sleepTimer = Timer(duration, () {
      pause();
    });
  }
  
  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
  }
}
