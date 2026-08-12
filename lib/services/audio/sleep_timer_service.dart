import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'audio_service_provider.dart';

final sleepTimerServiceProvider = Provider<SleepTimerService>((ref) {
  final audioHandler = ref.read(audioHandlerProvider);
  return SleepTimerService(audioHandler);
});

class SleepTimerService {
  final dynamic _audioHandler;
  Timer? _timer;

  SleepTimerService(this._audioHandler);

  void startTimer(Duration duration) {
    _timer?.cancel();
    _audioHandler.customAction('cancelSleepTimer'); // Reset end of song flag
    _timer = Timer(duration, () {
      _audioHandler.pause();
    });
  }

  void startTimerForEndOfSong() {
    _timer?.cancel();
    _timer = null;
    _audioHandler.customAction('stopAfterCurrentSong');
  }

  void cancelTimer() {
    _timer?.cancel();
    _timer = null;
    _audioHandler.customAction('cancelSleepTimer');
  }
}
