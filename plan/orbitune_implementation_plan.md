# Orbitune Implementation Plan

## Goal Description
Build a complete, production-ready Android music player application in Flutter + Dart named "Orbitune". The app will focus equally on offline/local music playback and online music discovery/streaming (using `jiosaavn`, `saavn_play`, and `ytmusicapi_dart`). It will feature a premium, Material 3 dark-first design, comprehensive audio playback controls (background, lock screen, equalizer), state management using Riverpod, and a robust offline-first caching mechanism and local database.

## User Review Required
> [!IMPORTANT]
> - **Architecture & State Management**: Using Clean Architecture, Riverpod for state, and Isar or Drift for the local database. I am leaning towards `Isar` for its speed and simplicity with Flutter objects, but I can use `Drift` if you strongly prefer relational SQL queries. Please confirm your preference.
> - **Audio Engine**: Using `audio_service` combined with `just_audio` as the robust background playback engine, which meets all the lock-screen and playback control requirements.
> - **UI/UX Direction**: Confirming the use of a dark-first Material 3 design with vibrant dynamic colors derived from album art.

## Open Questions
> [!WARNING]
> - Since we are integrating YouTube Music (`ytmusicapi_dart`), JioSaavn (`jiosaavn`, `saavn_play`), some streams might require API keys or proxy setups depending on the region. Do you have any specific requirements or keys for the APIs, or should we use the public unauthenticated endpoints?
> - For downloads, do you want to use the standard Android `Downloads` directory, or an app-specific directory for the cached/downloaded online files?

## Proposed Changes

### Phase 1: Project setup + architecture + theme
- Update `pubspec.yaml` with all required dependencies (`riverpod`, `audio_service`, `just_audio`, `isar`, `jiosaavn`, `ytmusicapi_dart`, `go_router`, `google_fonts`, `palette_generator`, etc.).
- Set up core architecture folders (`core`, `data`, `domain`, `services`, `features`).
- Implement the Material 3 Dark theme and `google_fonts`.

### Phase 2: Database + models + repositories
- Define the normalized `Track` model (with `TrackSource` enum).
- Setup Isar/Drift local database to store Songs, Playlists, Favorites, and Recently Played.
- Create base repository interfaces and data sources.

### Phase 3: Android permissions + local music scanner
- Configure `AndroidManifest.xml` with `READ_MEDIA_AUDIO`, `FOREGROUND_SERVICE`, etc.
- Implement the `on_audio_query` (or custom MethodChannel) scanner to find local MP3, FLAC files and read ID3 metadata.

### Phase 4: Audio engine + background playback
- Setup `audio_service` `AudioHandler` singleton to handle background playback, lock-screen controls, and media notifications.
- Integrate `just_audio` as the backend player for both local files and online streams.
- Create the global `PlaybackState` notifier (Riverpod).

### Phase 5: Home + Library + player UI
- Build the `Home` dashboard (Trending, New Releases, Quick Picks, Recently Played).
- Build the `Library` with tabs (Songs, Albums, Artists, Folders, Genres).
- Implement the `MiniPlayer` widget and full-screen `NowPlaying` screen with artwork and playback controls.

### Phase 6: Playlists + Favorites + History
- Build UI and logic for adding/removing items from Playlists and Favorites.
- Track playback history and save to the database.

### Phase 7: Online providers
- Implement `OnlineMusicRepository` using the Strategy pattern with JioSaavn and YouTube Music providers.
- Implement the fallback logic if one provider fails.

### Phase 8: Online search + discovery
- Build the Search UI with debouncing.
- Aggregate search results from local and online sources.

### Phase 9: Lyrics
- Create `LyricsRepository` and UI.
- Use synced lyrics when available from providers.

### Phase 10: Equalizer
- Integrate Android Equalizer API using a Flutter plugin (e.g., `equalizer` or native channels).

### Phase 11: Caching/download manager
- Implement `flutter_cache_manager` or a custom download service for caching streams and album art.

### Phase 12: Settings + customization
- Build the Settings UI (Appearance, Library, Audio, Privacy).

### Phase 13 & 14: Performance optimization, Testing + bug fixing
- Write Unit and Widget tests.
- Resolve any analyzer issues and optimize widget rebuilds.

### Phase 15: Release build verification
- Final release compile (`flutter build apk --release`).

## Verification Plan

### Automated Tests
- `flutter test` for unit tests and widget tests.
- `flutter analyze` to ensure code quality.

### Manual Verification
- Launch the app, accept media permissions, verify local tracks appear, play a track (verify background/lockscreen controls), search for an online track, and verify the equalizer and lyrics features.
