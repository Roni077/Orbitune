# Orbitune: Senior Developer Implementation Plan

**Project Type:** 100% Free & Open Source Offline Music Player  
**Target Platforms:** Android, iOS, Windows  
**Architecture:** Feature-based Modular Clean Architecture (MVVM-like with Riverpod)

This document serves as the master blueprint for developing Orbitune. As a senior developer, I have structured this into highly detailed, actionable phases to ensure maximum code quality, scalability, and performance (120 FPS target).

---

## 🏗️ Phase 1: Project Scaffolding & Dependencies (Foundation)
*Goal: Establish the technical foundation, CI/CD readiness, and folder structure.*

1. **Dependency Injection & State Management**
   - Add `flutter_riverpod`, `riverpod_annotation`, `get_it`, `freezed`, `json_serializable`.
   - Setup `build_runner` for code generation.
2. **Routing & Navigation**
   - Add `go_router`.
   - Create `lib/routes/app_router.dart` defining the root shell route (Bottom Nav) and sub-routes.
3. **Storage & Database**
   - Add `isar` and `isar_flutter_libs` (for local media metadata & playlists).
   - Add `hive` and `hive_flutter` (for fast key-value settings).
4. **Media & Permissions**
   - Add `just_audio`, `audio_service`, `audio_session`.
   - Add `on_audio_query` and `permission_handler`.
5. **UI & Theming**
   - Add `dynamic_color`, `google_fonts`, `palette_generator`, `flutter_animate`.
6. **Folder Structure Creation**
   - Generate the precise structure: `core/`, `data/`, `domain/`, `features/`, `shared/`, `services/`, `widgets/`, `routes/`, `themes/`, `models/`, `repositories/`.

---

## 🎨 Phase 2: Design System & Core UI (Theming)
*Goal: Create the visual identity, dynamic AMOLED themes, and responsive shell.*

1. **Theme Engine (`lib/themes/`)**
   - Implement `AppTheme` class utilizing Material 3 `ColorScheme`.
   - Implement dynamic color extraction for Android 12+.
   - Create pure AMOLED Dark Theme (Pitch black backgrounds `#000000`) and Light Theme.
2. **Typography & Glassmorphism (`lib/shared/`)**
   - Define `AppTextStyles` using Google Fonts (e.g., Inter or Outfit).
   - Create `GlassContainer` reusable widget using `BackdropFilter` and `ClipRRect`.
3. **Application Shell (`lib/features/shell/`)**
   - Implement `ScaffoldWithNavBar` handling GoRouter's `StatefulNavigationShell`.
   - Create the bottom navigation bar with fluid micro-animations on selection.

---

## 🗄️ Phase 3: Data Layer & Local Storage (Database)
*Goal: Initialize local databases and define data models.*

1. **Isar Database Schema (`lib/models/`)**
   - Define `@collection` for `SongEntity`, `AlbumEntity`, `ArtistEntity`, and `PlaylistEntity`.
   - Create Isar relationships (e.g., Playlist contains many Songs).
2. **Hive Settings Initialization (`lib/services/`)**
   - Setup Hive box for user preferences (Theme mode, scan exclusions, audio quality).
3. **Data Repositories (`lib/repositories/`)**
   - Implement `LocalMediaRepository` with CRUD operations for Isar.
   - Implement `SettingsRepository` wrapping Hive.

---

## 🔍 Phase 4: Permissions & Media Scanner
*Goal: Request OS permissions and scan device for audio files.*

1. **Permission Service (`lib/services/`)**
   - Implement logic to request `READ_EXTERNAL_STORAGE` or Android 13+ granular audio permissions.
2. **Media Scanner Service (`lib/services/`)**
   - Wrap `on_audio_query` to scan for MP3, FLAC, WAV, AAC, etc.
   - Map `SongModel` from `on_audio_query` into Orbitune's `SongEntity`.
   - Implement background isolate processing for fast indexing of large libraries.
   - Save scanned media to Isar Database.

---

## 🎵 Phase 5: Audio Engine & Background Playback
*Goal: Build the robust playback engine with lock-screen controls.*

1. **Audio Service Implementation (`lib/services/`)**
   - Create `OrbituneAudioHandler` extending `BaseAudioHandler`.
   - Implement `play()`, `pause()`, `seek()`, `skipToNext()`, `skipToPrevious()`.
   - Setup `AudioSession` to handle audio focus (e.g., pausing during phone calls).
2. **Playback Logic (`lib/domain/`)**
   - Implement Queue Management (shuffle, repeat modes, drag-and-drop ordering).
   - Implement gapless playback and crossfade settings via `just_audio` concatenating audio sources.
3. **State Exposure (`lib/features/player/`)**
   - Create Riverpod providers: `playbackStateProvider`, `currentSongProvider`, `queueProvider`, `positionDataProvider`.

---

## 📱 Phase 6: Core Features (Home & Library)
*Goal: Build the primary user-facing screens for browsing music.*

1. **Home Screen (`lib/features/home/`)**
   - "Recently Added" horizontal scroll list.
   - "Most Played" grid.
   - Pull-to-refresh to trigger a manual media scan.
2. **Library Screen (`lib/features/library/`)**
   - Tabbed view: Songs, Albums, Artists, Folders.
   - Lazy-loaded `ListView.builder` for performance with 10k+ songs.
   - Fast alphabetic scrollbar.
   - Search Bar (instant filtering using Riverpod).

---

## ▶️ Phase 7: Advanced Player UI
*Goal: Build the premium, immersive playback experience.*

1. **Mini Player (`lib/widgets/`)**
   - Persistent mini player above the bottom nav bar.
   - Swipe gestures (swipe left/right to change tracks, swipe up to open full player).
2. **Full Player Screen (`lib/features/player/`)**
   - Hero animation transition from Mini Player to Full Player.
   - Dynamic background: Blown-up, blurred version of the current album art using `palette_generator`.
   - High-fidelity seek bar (waveform or smooth slider).
   - Controls: Pitch control, Playback Speed, Sleep Timer dialog.
3. **Lyrics Integration**
   - Extract embedded LRC/Lyrics data and display in a synchronized scrolling view.

---

## 🎛️ Phase 8: Playlists & Audio Enhancement
*Goal: User curation and audio tuning.*

1. **Playlist Management (`lib/features/playlists/`)**
   - UI to Create, Edit, and Delete custom playlists.
   - "Favorite Songs" dedicated Smart Playlist.
2. **Equalizer (`lib/features/equalizer/`)**
   - Implement `AndroidEqualizer` / iOS equivalent logic via `just_audio` pipelines.
   - Build UI for frequency bands, Bass Boost, and Virtualizer sliders.

---

## 🚀 Phase 9: Optimization & Desktop Support
*Goal: Final polish, Windows specific adaptations, and release prep.*

1. **Desktop / Windows Adjustments**
   - Implement keyboard shortcuts (Space to play/pause, Arrows to seek).
   - Adaptive multi-column layout for wide screens.
2. **Performance & Security**
   - Ensure absolute zero internet calls (100% offline).
   - Run Dart DevTools memory profile.
3. **App Icons & Splash Screen**
   - Configure `flutter_native_splash` and `flutter_launcher_icons`.
4. **Testing**
   - Write unit tests for the `OrbituneAudioHandler`.
   - Write widget tests for the `MiniPlayer` and `GlassContainer`.
