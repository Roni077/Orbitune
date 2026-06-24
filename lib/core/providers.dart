import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/audio_repository.dart';
import '../data/repositories/playlist_repository.dart';
import '../data/services/media_scanner_service.dart';
import '../features/permissions/permissions_service.dart';

// Global Isar instance provider
final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError('isarProvider must be overridden in main.dart');
});

// SharedPreferences provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main.dart');
});

// Services
final permissionsServiceProvider = Provider<PermissionsService>((ref) {
  return PermissionsService();
});

final audioRepositoryProvider = Provider<AudioRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return AudioRepository(isar);
});

final playlistRepositoryProvider = Provider<PlaylistRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return PlaylistRepository(isar);
});

final mediaScannerServiceProvider = Provider<MediaScannerService>((ref) {
  final repo = ref.watch(audioRepositoryProvider);
  final perms = ref.watch(permissionsServiceProvider);
  return MediaScannerService(repo, perms);
});
