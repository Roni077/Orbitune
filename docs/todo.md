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
- [x] Create `lib/routes/app_router.dart` utilizing `GoRouter`.
- [x] Implement `StatefulShellRoute` for Bottom Navigation Bar.
- [x] Create `ScaffoldWithNavBar` with fluid micro-animations (120 FPS optimized).
- [x] Scaffold empty screens for Home, Library, and Settings.

## Phase 4: Local Storage & Security (Database)
- [x] Define Isar `@collection` models with Metadata support (ID3 Tags, Track Number, Year, Genre).
- [x] Create `lib/data/repositories/audio_repository.dart`.
- [x] Create Device Storage permission flow (Android Scoped Storage handle).
- [x] Create robust MediaScanner service to index all audio files.
- [x] Run `build_runner` for Isar code generation.
- [x] Setup Hive boxes for `UserPreferences` (Theme, scan settings, audio quality).
- [x] Implement `LocalMediaRepository` (Isar CRUD operations).

## Phase 5: Media Scanning & Permissions
- [x] Implement `PermissionService` (Scoped Storage Support, Android 13+).
- [x] Implement `LocalMediaScannerService` wrapping `on_audio_query`.
- [x] Support scanning internal storage, SD cards, and recursive folder scanning.
- [x] Implement feature to exclude specific folders.
- [x] Implement background isolates for fast indexing of large libraries without blocking UI.
- [x] Auto-extract Album Art and Artist Information during scanning.

## Phase 6: Player Engine & Background Playback
- [x] Create `OrbituneAudioHandler` extending `BaseAudioHandler` using `just_audio`.
- [x] Support audio formats: MP3, FLAC, WAV, AAC, OGG, M4A, OPUS.
- [x] Implement core playback: gapless playback, crossfade playback, play, pause, stop, next, previous, seek.
- [x] Configure `AudioSession` for OS audio focus handling.
- [x] Setup Foreground Service, Media Style Notification, and Lock Screen Controls (Android/iOS Control Center).
- [x] Implement Sleep Timer and Resume Playback functionality.
- [x] Create Riverpod providers: `playbackStateProvider`, `currentSongProvider`, `queueProvider`.

## Phase 7: UI Implementation - Home & Library
- [x] Build Home Screen: "Recently Added", "Most Played", and "Usage Dashboard" (Analytics).
- [x] Implement Pull-to-refresh for manual media scanning.
- [x] Build Library Screen: Tabbed views (Songs, Albums, Artists, Genres).
- [x] Implement Folder View (Browse by folder, Folder Tree Navigation, Folder Pinning).
- [x] Implement efficient caching, lazy loading, and smooth scrolling for large lists.
- [x] Implement alphabetic fast-scroll bar.
- [x] Add Instant Search (Search songs, albums, artists, playlists) with Search History.

## Phase 8: Advanced Player Experience & Gestures
- [x] Build `MiniPlayer` widget positioned above the bottom navigation bar.
- [x] Build Full `PlayerScreen` with Hero animation transition.
- [x] Add dynamic blurred background based on current album art & HD Artwork Viewer.
- [x] Build high-fidelity waveform/seek bar.
- [x] Integrate Pitch Control and Playback Speed sliders.
- [x] Implement embedded Lyrics viewer (LRC Support, Synchronized Lyrics, Full Screen Mode).
- [x] Implement Gesture System: Swipe to change track, double tap actions, long press menus, custom gesture mapping.

## Phase 9: Playlists & Queue Management
- [x] Build Playlists UI: Create, Edit, Delete, Smart Playlists, Import/Export Playlists.
- [x] Implement robust Drag-and-Drop queue management.
- [x] Implement advanced Queue features: "Play Next", "Add to Queue", "Clear Queue", and "Save Queue as Playlist".
- [x] Build multi-select functionality across all lists.

## Phase 10: Audio Enhancement (Equalizer)
- [x] Implement `AndroidEqualizer` logic using `just_audio` pipelines.
- [x] Build 5-band or 10-band Equalizer UI.
- [x] Add pre-configured EQ presets (Pop, Rock, Classical, Bass Boost, etc.).
- [x] Implement global audio effects (Reverb, Virtualizer/3D Audio, Bass Boost, Loudness Enhancer).

## Phase 11: Settings & Backup System
- [x] Build Settings Screen (Theme Selection, Dynamic Color Toggle, Audio Quality).
- [x] Implement About & Licenses section.
- [x] Build Isar database Backup & Restore functionality (JSON or raw DB copy).
- [x] Build app-wide sleep timer UI integration (if not done in Phase 7).
- [x] Build Analytics Dashboard (Local playback stats, listening history).

## Phase 12: Final Polish & Desktop Support
- [ ] Windows Support: Implement keyboard shortcuts, adaptive desktop layout, drag & drop music files, system media controls.
- [ ] Configure `flutter_launcher_icons`.
- [ ] Run Dart DevTools for memory profiling and FPS optimization.
- [ ] Write unit, widget, and integration tests.
