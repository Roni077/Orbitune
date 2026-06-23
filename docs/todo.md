# Orbitune Phase-by-Phase Execution Todo

## Phase 1: Foundation & Dependencies 
- [ ] Initialize `docs/` folder and documentation.
- [ ] Clean up default `lib/main.dart` and `pubspec.yaml`.
- [ ] Add all core dependencies to `pubspec.yaml` (Riverpod, GoRouter, Isar, Hive, Just Audio, Audio Service, Freezed, etc.).
- [ ] Setup `build_runner` and generate initial code.
- [ ] Scaffold the clean architecture folder structure inside `lib/`.
- [ ] Initialize `GetIt` locator and Riverpod `ProviderScope`.
- [ ] Configure Android `AndroidManifest.xml` and iOS `Info.plist` for audio background execution.
- [ ] Configure native splash screen (`flutter_native_splash`).

## Phase 2: Design System & Theming
- [ ] Create `lib/themes/app_theme.dart`.
- [ ] Implement Material 3 `ColorScheme`.
- [ ] Add dynamic color extraction using `dynamic_color` package.
- [ ] Create AMOLED Dark Theme (Pitch black `#000000`) and Light Theme.
- [ ] Define `AppTextStyles` using Google Fonts (Inter/Outfit).
- [ ] Build reusable `GlassContainer` widget for glassmorphism effects.

## Phase 3: Core App Shell & Routing
- [ ] Create `lib/routes/app_router.dart` utilizing `GoRouter`.
- [ ] Implement `StatefulShellRoute` for Bottom Navigation Bar.
- [ ] Create `ScaffoldWithNavBar` with fluid micro-animations for tab selection.
- [ ] Scaffold empty screens for Home, Library, and Settings to map routes.

## Phase 4: Local Storage & Databases
- [ ] Define Isar `@collection` models: `SongEntity`, `AlbumEntity`, `ArtistEntity`, `PlaylistEntity`.
- [ ] Create relationships between Isar entities (e.g., Playlist -> Songs).
- [ ] Initialize Isar database instance.
- [ ] Setup Hive boxes for `UserPreferences` (Theme, scan settings).
- [ ] Implement `LocalMediaRepository` (Isar CRUD operations).
- [ ] Implement `SettingsRepository` (Hive CRUD operations).

## Phase 5: Media Scanning & Permissions
- [ ] Implement `PermissionService` to handle `READ_EXTERNAL_STORAGE` and Android 13+ audio permissions.
- [ ] Implement `LocalMediaScannerService` wrapping `on_audio_query`.
- [ ] Map `SongModel` from OS to Orbitune's `SongEntity`.
- [ ] Implement background isolates to batch insert scanned media into Isar database.
- [ ] Expose scanning state via Riverpod providers.

## Phase 6: Audio Engine
- [ ] Create `OrbituneAudioHandler` extending `BaseAudioHandler` using `just_audio`.
- [ ] Implement core playback controls (`play`, `pause`, `seek`, `skipToNext`, `skipToPrevious`).
- [ ] Configure `AudioSession` for OS audio focus handling.
- [ ] Implement queue management logic (shuffle, repeat, gapless playback).
- [ ] Create Riverpod providers: `playbackStateProvider`, `currentSongProvider`, `queueProvider`.

## Phase 7: UI Implementation - Home & Library
- [ ] Build Home Screen: "Recently Added" horizontal list.
- [ ] Build Home Screen: "Most Played" grid.
- [ ] Implement Pull-to-refresh for manual media scanning.
- [ ] Build Library Screen: Tabbed views (Songs, Albums, Artists, Folders).
- [ ] Implement lazy-loaded `ListView.builder` for 10k+ song performance.
- [ ] Implement alphabetic fast-scroll bar.
- [ ] Add instant search bar filtering via Riverpod.

## Phase 8: Advanced Player Experience
- [ ] Build `MiniPlayer` widget positioned above the bottom navigation bar.
- [ ] Implement swipe gestures on `MiniPlayer` (change track, open full player).
- [ ] Build Full `PlayerScreen`.
- [ ] Implement Hero animation transition from `MiniPlayer` to `PlayerScreen`.
- [ ] Add dynamic blurred background based on current album art (`palette_generator`).
- [ ] Build high-fidelity waveform/seek bar.
- [ ] Integrate Pitch Control and Playback Speed sliders.
- [ ] Implement embedded Lyrics viewer.

## Phase 9: Playlists & Equalizer
- [ ] Build Playlists UI: Create, Edit, Delete custom playlists.
- [ ] Implement "Favorite Songs" dedicated UI.
- [ ] Implement `AndroidEqualizer` logic using `just_audio` pipelines.
- [ ] Build Equalizer UI (Frequency bands, Bass Boost, Virtualizer).

## Phase 10: Final Polish & Desktop Support
- [ ] Implement keyboard shortcuts for Windows desktop (Space to play/pause).
- [ ] Create adaptive multi-column layout for wide screens.
- [ ] Configure `flutter_launcher_icons`.
- [ ] Run Dart DevTools for memory profiling and FPS optimization.
- [ ] Write widget and unit tests for critical paths (`AudioHandler`, `MiniPlayer`).
