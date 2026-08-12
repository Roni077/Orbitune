import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/playlist.dart';
import '../../../../domain/repositories/playlist_repository.dart';

enum PlaylistSortOption {
  name,
  dateCreated,
  trackCount,
}

final playlistSearchQueryProvider = NotifierProvider<PlaylistSearchQueryNotifier, String>(PlaylistSearchQueryNotifier.new);
class PlaylistSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void update(String value) => state = value;
}

final playlistSortOptionProvider = NotifierProvider<PlaylistSortOptionNotifier, PlaylistSortOption>(PlaylistSortOptionNotifier.new);
class PlaylistSortOptionNotifier extends Notifier<PlaylistSortOption> {
  @override
  PlaylistSortOption build() => PlaylistSortOption.dateCreated;
  void update(PlaylistSortOption value) => state = value;
}

final libraryViewModelProvider = AsyncNotifierProvider<LibraryViewModel, List<Playlist>>(() {
  return LibraryViewModel();
});

class LibraryViewModel extends AsyncNotifier<List<Playlist>> {
  @override
  FutureOr<List<Playlist>> build() async {
    return _fetchPlaylists();
  }

  Future<List<Playlist>> _fetchPlaylists() async {
    final repository = ref.read(playlistRepositoryProvider);
    final result = await repository.getAllPlaylists();

    return result.match(
      (failure) => throw Exception(failure.message),
      (playlists) => playlists,
    );
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPlaylists());
  }



  Future<void> createPlaylist(String name) async {
    final repository = ref.read(playlistRepositoryProvider);
    final result = await repository.createPlaylist(name);

    result.match(
      (failure) {
        // You could emit a side effect here if needed
      },
      (playlist) {
        if (state.hasValue) {
          state = AsyncValue.data([...state.value!, playlist]);
        }
      },
    );
  }

  Future<void> deletePlaylist(String id) async {
    final repository = ref.read(playlistRepositoryProvider);
    final result = await repository.deletePlaylist(id);

    if (result.isRight() && state.hasValue) {
      state = AsyncValue.data(
        state.value!.where((p) => p.id != id).toList(),
      );
    }
  }

  Future<void> duplicatePlaylist(Playlist playlist) async {
    final repository = ref.read(playlistRepositoryProvider);
    final result = await repository.duplicatePlaylist(playlist.id);
    
    result.match(
      (failure) {},
      (newPlaylist) {
        if (state.hasValue) {
          state = AsyncValue.data([...state.value!, newPlaylist]);
        }
      },
    );
  }
}
