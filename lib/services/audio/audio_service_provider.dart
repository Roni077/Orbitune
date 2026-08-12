import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'audio_player_handler.dart';
import '../../domain/repositories/track_repository.dart';

import '../metadata/online_audio_service.dart';

import '../../domain/repositories/history_repository.dart';

// Provides the AudioPlayerHandler instance
final audioHandlerProvider = Provider<AudioPlayerHandler>((ref) {
  throw UnimplementedError('Initialize this in main.dart');
});

Future<AudioPlayerHandler> initAudioService(
  TrackRepository trackRepo, 
  SharedPreferences prefs, 
  OnlineAudioService onlineAudioService,
  HistoryRepository historyRepo,
) async {
  return await AudioService.init(
    builder: () => AudioPlayerHandler(trackRepo, prefs, onlineAudioService, historyRepo),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.orbitune.channel.audio',
      androidNotificationChannelName: 'Orbitune Audio Playback',
      androidNotificationOngoing: false,
      androidStopForegroundOnPause: false,
    ),
  );
}
