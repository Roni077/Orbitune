# Orbitune Phase-by-Phase Execution Todo

## Phase 1: Foundation & Dependencies 
- [x] Initialize `docs/` folder and documentation.
- [x] Clean up default `lib/main.dart` and `pubspec.yaml`.
- [x] Add all core dependencies to `pubspec.yaml` (Riverpod, GoRouter, Isar, Hive, Just Audio, Audio Service, Freezed, etc.).
- [x] Setup `build_runner` and generate initial code.
- [x] Scaffold the clean architecture folder structure inside `lib/`.
- [x] Initialize `GetIt` locator and Riverpod `ProviderScope`.
- [x] Configure Android `AndroidManifest.xml` (Android 8+, Android 15 ready, no internet permission).
- [x] Configure iOS `Info.plist` (Background audio).
- [x] Configure native splash screen (`flutter_native_splash`).

## Phase 2: Design System, Theming & Accessibility
- [x] Create `lib/themes/app_theme.dart`.
- [x] Implement Material 3 `ColorScheme` & Accent Color Selection.
- [x] Add dynamic color extraction using `dynamic_color` package.
- [x] Create AMOLED Dark Theme, Light Theme, and High Contrast Mode.
- [x] Define `AppTextStyles` using Google Fonts (Inter/Outfit) with Large Font Support.
- [x] Build reusable `GlassContainer` widget for glassmorphism effects.
- [x] Ensure full Accessibility (Screen Reader Support & Keyboard Navigation).

## Phase 3: Core App Shell & Routing
- [ ] Create `lib/routes/app_router.dart` utilizing `GoRouter`.
- [ ] Implement `StatefulShellRoute` for Bottom Navigation Bar.
- [ ] Create `ScaffoldWithNavBar` with fluid micro-animations (120 FPS optimized).
- [ ] Scaffold empty screens for Home, Library, and Settings.

## Phase 4: Local Storage & Security (Database)
- [ ] Define Isar `@collection` models with Metadata support (ID3 Tags, Track Number, Year, Genre).
- [ ] Create Isar models: `SongEntity`, `AlbumEntity`, `ArtistEntity`, `PlaylistEntity`, `HistoryEntity`.
- [ ] Initialize Isar database with Local Data Encryption (Safe Storage Practices).
- [ ] Setup Hive boxes for `UserPreferences` (Theme, scan settings, audio quality).
- [ ] Implement `LocalMediaRepository` (Isar CRUD operations).

## Phase 5: Media Scanning & Permissions
- [ ] Implement `PermissionService` (Scoped Storage Support, Android 13+).
- [ ] Implement `LocalMediaScannerService` wrapping `on_audio_query`.
- [ ] Support scanning internal storage, SD cards, and recursive folder scanning.
- [ ] Implement feature to exclude specific folders.
- [ ] Implement background isolates for fast indexing of large libraries without blocking UI.
- [ ] Auto-extract Album Art and Artist Information during scanning.

## Phase 6: Player Engine & Background Playback
- [ ] Create `OrbituneAudioHandler` extending `BaseAudioHandler` using `just_audio`.
- [ ] Support audio formats: MP3, FLAC, WAV, AAC, OGG, M4A, OPUS.
- [ ] Implement core playback: gapless playback, crossfade playback, play, pause, stop, next, previous, seek.
- [ ] Configure `AudioSession` for OS audio focus handling.
- [ ] Setup Foreground Service, Media Style Notification, and Lock Screen Controls (Android/iOS Control Center).
- [ ] Implement Sleep Timer and Resume Playback functionality.
- [ ] Create Riverpod providers: `playbackStateProvider`, `currentSongProvider`, `queueProvider`.

## Phase 7: UI Implementation - Home & Library
- [ ] Build Home Screen: "Recently Added", "Most Played", and "Usage Dashboard" (Analytics).
- [ ] Implement Pull-to-refresh for manual media scanning.
- [ ] Build Library Screen: Tabbed views (Songs, Albums, Artists, Genres).
- [ ] Implement Folder View (Browse by folder, Folder Tree Navigation, Folder Pinning).
- [ ] Implement efficient caching, lazy loading, and smooth scrolling for large lists.
- [ ] Implement alphabetic fast-scroll bar.
- [ ] Add Instant Search (Search songs, albums, artists, playlists) with Search History.

## Phase 8: Advanced Player Experience & Gestures
- [ ] Build `MiniPlayer` widget positioned above the bottom navigation bar.
- [ ] Build Full `PlayerScreen` with Hero animation transition.
- [ ] Add dynamic blurred background based on current album art & HD Artwork Viewer.
- [ ] Build high-fidelity waveform/seek bar.
- [ ] Integrate Pitch Control and Playback Speed sliders.
- [ ] Implement embedded Lyrics viewer (LRC Support, Synchronized Lyrics, Full Screen Mode).
- [ ] Implement Gesture System: Swipe to change track, double tap actions, long press menus, custom gesture mapping.

## Phase 9: Playlists & Queue Management
- [ ] Build Playlists UI: Create, Edit, Delete, Smart Playlists, Import/Export Playlists.
- [ ] Implement "Favorite Songs" dedicated UI.
- [ ] Implement Queue Management: Drag and drop queue, queue save/restore, queue history, temporary queue.

## Phase 10: Audio Enhancement (Equalizer)
- [ ] Implement `AndroidEqualizer` logic using `just_audio` pipelines.
- [ ] Build Equalizer UI (Frequency bands, Bass Boost, Virtualizer).
- [ ] Implement Preset Manager (Save/load custom presets).

## Phase 11: Settings & Backup System
- [ ] Build Settings Screen (Theme Selection, Dynamic Color Toggle, Audio Quality).
- [ ] Implement Backup & Restore functionality (Export/Import settings, Export playlists, Restore data).
- [ ] Build Analytics Dashboard (Local playback stats, listening history).

## Phase 12: Final Polish & Desktop Support
- [ ] Windows Support: Implement keyboard shortcuts, adaptive desktop layout, drag & drop music files, system media controls.
- [ ] Configure `flutter_launcher_icons`.
- [ ] Run Dart DevTools for memory profiling and FPS optimization.
- [ ] Write unit, widget, and integration tests.
