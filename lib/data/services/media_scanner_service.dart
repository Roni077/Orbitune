import 'package:on_audio_query/on_audio_query.dart';
import '../models/audio_model.dart';
import '../repositories/audio_repository.dart';
import '../../features/permissions/permissions_service.dart';

class MediaScannerService {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioRepository _audioRepository;
  final PermissionsService _permissionsService;

  MediaScannerService(this._audioRepository, this._permissionsService);

  Future<void> scanAndSaveAudios() async {
    final hasPermission = await _permissionsService.hasPermissions();
    if (!hasPermission) {
      final granted = await _permissionsService.requestMediaPermissions();
      if (!granted) return; // Cannot proceed without permissions
    }

    // Query all songs from device
    final songs = await _audioQuery.querySongs(
      sortType: null,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );

    // Map SongModel to our Isar AudioModel
    final audioModels = songs.map((song) {
      return AudioModel()
        ..uri = song.data // Direct file path
        ..title = song.title
        ..artist = song.artist ?? '<Unknown>'
        ..album = song.album ?? '<Unknown>'
        ..displayName = song.displayName
        ..durationMs = song.duration ?? 0
        ..trackNumber = song.track ?? 0
        ..sizeBytes = song.size ?? 0
        ..genre = song.genre
        ..dateAdded = song.dateAdded != null 
            ? DateTime.fromMillisecondsSinceEpoch(song.dateAdded! * 1000)
            : DateTime.now();
    }).toList();

    // Save to Isar database
    await _audioRepository.saveAudios(audioModels);
  }
}
