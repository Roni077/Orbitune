import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import 'orbitune_audio_handler.dart';

// Provider for the global AudioHandler instance
final audioHandlerProvider = Provider<OrbituneAudioHandler>((ref) {
  throw UnimplementedError('audioHandlerProvider not initialized');
});

// Stream provider for the current playback state (playing, paused, buffering, etc)
final playbackStateProvider = StreamProvider<PlaybackState>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.playbackState;
});

// Stream provider for the currently playing media item
final currentMediaItemProvider = StreamProvider<MediaItem?>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.mediaItem;
});

// Stream provider for the current queue
final queueProvider = StreamProvider<List<MediaItem>>((ref) {
  final handler = ref.watch(audioHandlerProvider);
  return handler.queue;
});
