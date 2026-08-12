import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/track.dart';
import '../../../../core/helpers/providers.dart';

final albumProfileViewModelProvider = FutureProvider.family<List<Track>, String>((ref, albumId) async {
  final service = ref.read(onlineAudioServiceProvider);
  final result = await service.getAlbumTracks(albumId);
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (tracks) => tracks,
  );
});
